import requests
import time
import os
import re
from bs4 import BeautifulSoup

# ==============================================================================
# KONFIGURASI SCRAPER & POCKETBASE
# ==============================================================================
POCKETBASE_URL = os.getenv("POCKETBASE_URL", "https://db-ews.sagamuda.id")
PB_ADMIN_EMAIL = os.getenv("PB_ADMIN_EMAIL", "admin@email.com")
PB_ADMIN_PASSWORD = os.getenv("PB_ADMIN_PASSWORD", "password_anda")

MAGMA_URL = "https://magma.esdm.go.id/v1/gunung-api/laporan"
SCRAPE_INTERVAL = 300  # 5 menit (dalam detik)

def get_pb_token():
    auth_url = f"{POCKETBASE_URL}/api/collections/_superusers/auth-with-password"
    payload = {"identity": PB_ADMIN_EMAIL, "password": PB_ADMIN_PASSWORD}
    print("Mencoba login ke PocketBase Admin...")
    response = requests.post(auth_url, json=payload)
    if response.status_code == 200:
        token = response.json()['token']
        print("✅ Login berhasil!")
        return token
    print(f"❌ Login gagal: {response.status_code} {response.text}")
    return None

def check_duplicate(token, new_data):
    """Cek apakah laporan_url sudah ada atau data sama persis dengan data terbaru di database."""
    headers = {"Authorization": f"Bearer {token}"}
    url = f"{POCKETBASE_URL}/api/collections/volcano_status/records"
    
    # 1. Cek berdasarkan laporan_url
    laporan_url = new_data.get("laporan_url", "")
    if laporan_url:
        params = {
            "filter": f'laporan_url="{laporan_url}"',
            "perPage": 1
        }
        try:
            res = requests.get(url, headers=headers, params=params)
            if res.status_code == 200 and res.json().get("totalItems", 0) > 0:
                return True, "Laporan dengan URL ini sudah ada di database."
        except Exception as e:
            print(f"Peringatan saat cek duplikat URL: {e}")

    # 2. Cek berdasarkan kemiripan data dengan record terbaru
    try:
        params_latest = {
            "sort": "-created",
            "perPage": 1
        }
        res_latest = requests.get(url, headers=headers, params=params_latest)
        if res_latest.status_code == 200:
            body = res_latest.json()
            if body.get("totalItems", 0) > 0:
                latest = body["items"][0]
                # Jika data sama persis dengan record terakhir, anggap duplikat
                if (latest.get("kegempaan") == new_data.get("kegempaan") and
                    latest.get("visual") == new_data.get("visual") and
                    latest.get("klimatologi") == new_data.get("klimatologi") and
                    latest.get("level") == new_data.get("level") and
                    latest.get("gempa_total") == new_data.get("gempa_total")):
                    return True, "Data sama persis dengan laporan terakhir (tidak ada perubahan)."
    except Exception as e:
        print(f"Peringatan saat cek data terbaru: {e}")
        
    return False, ""

def fetch_magma_data():
    print(f"Mencari laporan terbaru Semeru di {MAGMA_URL} ...")
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
    }
    
    try:
        response = requests.get(MAGMA_URL, headers=headers, timeout=15)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        detail_url = None
        level_text = None
        author_text = None
        
        # Cari laporan Semeru di timeline
        items = soup.find_all('div', class_='timeline-item')
        for item in items:
            title_p = item.find('p', class_='timeline-title')
            if title_p and "Semeru" in title_p.text:
                detail_link = item.find('a', class_='card-link')
                if detail_link:
                    detail_url = detail_link.get('href')
                    
                    # Ambil badge status
                    badge = title_p.find('span', class_='badge')
                    if badge:
                        level_text = badge.text.strip()
                    
                    # Ambil author
                    author_p = item.find('p', class_='timeline-author')
                    if author_p:
                        author_text = author_p.text.strip()
                        if " - " in author_text:
                            author_text = author_text.split(" - ")[0].replace("Dibuat oleh ", "").strip()
                            
                    break
                    
        if not detail_url:
            print("Tidak menemukan link detail Semeru di halaman utama.")
            return None
            
        print(f"Membuka detail laporan: {detail_url}")
        res_detail = requests.get(detail_url, headers=headers, timeout=15)
        dsoup = BeautifulSoup(res_detail.text, 'html.parser')
        
        # =====================================================================
        # 1. Parsing Visual
        # =====================================================================
        visual = ""
        visual_tag = dsoup.find(lambda tag: tag.name == "h6" and "Pengamatan Visual" in tag.text)
        if visual_tag and visual_tag.find_next_sibling('p'):
            visual = visual_tag.find_next_sibling('p').text.strip()
            
        # =====================================================================
        # 2. Parsing Klimatologi (teks lengkap saja, tanpa parsing suhu)
        # =====================================================================
        klimatologi = ""
        klimatologi_tag = dsoup.find(lambda tag: tag.name == "h6" and "Klimatologi" in tag.text)
        if klimatologi_tag and klimatologi_tag.find_next_sibling('p'):
            klimatologi = klimatologi_tag.find_next_sibling('p').text.strip()
                    
        # =====================================================================
        # 3. Parsing Kegempaan — hitung total gempa SEMUA jenis dengan akurat
        # =====================================================================
        kegempaan = ""
        gempa_total = 0
        
        kegempaan_tag = dsoup.find(lambda tag: tag.name == "h6" and "Pengamatan Kegempaan" in tag.text)
        if kegempaan_tag:
            parent = kegempaan_tag.parent
            p_tags = parent.find_all('p')
            kegempaan = "\n".join([p.text.strip() for p in p_tags])
            
            # Regex fleksibel: tangkap "X kali gempa" di mana pun posisinya
            for p in p_tags:
                text = p.text.strip()
                # Pola: angka + "kali" (di awal baris atau setelah spasi)
                count_matches = re.findall(r'(\d+)\s+kali', text, re.IGNORECASE)
                for match in count_matches:
                    gempa_total += int(match)
                    
        # =====================================================================
        # 4. Parsing Rekomendasi
        # =====================================================================
        rekomendasi = ""
        rek_tag = dsoup.find(lambda tag: tag.name == "h6" and "Rekomendasi" in tag.text)
        if rek_tag and rek_tag.find_next_sibling('p'):
            rekomendasi = rek_tag.find_next_sibling('p').get_text(separator="\n").strip()
            
        # =====================================================================
        # 5. Parse Level Status
        # =====================================================================
        level_num = 1
        status_text = "Normal"
        if level_text:
            if "Level I " in level_text or "Normal" in level_text:
                level_num = 1
                status_text = "Normal"
            elif "Level II " in level_text or "Waspada" in level_text:
                level_num = 2
                status_text = "Waspada"
            elif "Level III " in level_text or "Siaga" in level_text:
                level_num = 3
                status_text = "Siaga"
            elif "Level IV " in level_text or "Awas" in level_text:
                level_num = 4
                status_text = "Awas"
                
        message_map = {
            1: "Status aman.",
            2: "Aktivitas meningkat, berhati-hati.",
            3: "Siaga, jauhi area berbahaya.",
            4: "AWAS! Segera evakuasi!"
        }
        message = message_map.get(level_num, "Status aman.")
                
        return {
            "level": level_num,
            "status_text": status_text,
            "message": message,
            "visual": visual,
            "klimatologi": klimatologi,
            "kegempaan": kegempaan,
            "rekomendasi": rekomendasi,
            "author": author_text or "",
            "gempa_total": gempa_total,
            "laporan_url": detail_url
        }
    except Exception as e:
        print(f"Error scraping: {e}")
        return None

def push_to_pocketbase(token, data):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    status_url = f"{POCKETBASE_URL}/api/collections/volcano_status/records"
    print(f"Menyimpan data laporan (Gempa Total: {data['gempa_total']}, Level: {data['status_text']})")
    res = requests.post(status_url, json=data, headers=headers)
    if res.status_code == 200:
        print("✅ Data berhasil disimpan ke volcano_status!")
    else:
        print(f"❌ Gagal simpan: {res.status_code} {res.text}")

def main():
    print("=== Memulai Script EWS Semeru Scraper ===")
    print(f"Interval: {SCRAPE_INTERVAL} detik ({SCRAPE_INTERVAL // 60} menit)")
    print(f"PocketBase: {POCKETBASE_URL}")
    
    while True:
        try:
            token = get_pb_token()
            if not token:
                print("Gagal autentikasi PocketBase. Coba lagi nanti.")
            else:
                data = fetch_magma_data()
                if data:
                    # Cek duplikat data & URL
                    is_duplicate, reason = check_duplicate(token, data)
                    if is_duplicate:
                        print(f"⏭️ Skip penyimpanan: {reason}")
                    else:
                        push_to_pocketbase(token, data)
                        print("🎉 Data baru berhasil diperbarui!")
                else:
                    print("⚠️ Tidak mendapat data dari MAGMA.")
                
        except Exception as e:
            print(f"Error saat menjalankan scraper: {e}")
            
        print(f"Menunggu {SCRAPE_INTERVAL // 60} menit untuk pengecekan selanjutnya...\n")
        time.sleep(SCRAPE_INTERVAL)

if __name__ == "__main__":
    main()
