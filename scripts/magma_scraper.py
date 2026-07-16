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

def get_pb_token():
    auth_url = f"{POCKETBASE_URL}/api/collections/_superusers/auth-with-password"
    payload = {"identity": PB_ADMIN_EMAIL, "password": PB_ADMIN_PASSWORD}
    print("Mencoba login ke PocketBase Admin...")
    response = requests.post(auth_url, json=payload)
    if response.status_code == 200:
        return response.json()['token']
    return None

def fetch_magma_data():
    print(f"Mencari laporan terbaru Semeru di {MAGMA_URL} ...")
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
    }
    
    try:
        response = requests.get(MAGMA_URL, headers=headers, timeout=15)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        detail_url = None
        level_text = None
        author_text = None
        
        # Cari laporan Semeru
        items = soup.find_all('div', class_='timeline-item')
        for item in items:
            title_p = item.find('p', class_='timeline-title')
            if title_p and "Semeru" in title_p.text:
                detail_link = item.find('a', class_='card-link')
                if detail_link:
                    detail_url = detail_link.get('href')
                    
                    # Coba ambil badge status
                    badge = title_p.find('span', class_='badge')
                    if badge:
                        level_text = badge.text.strip()
                    
                    # Coba ambil author
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
        
        # 1. Parsing Visual
        visual = ""
        visual_tag = dsoup.find(lambda tag: tag.name == "h6" and "Pengamatan Visual" in tag.text)
        if visual_tag and visual_tag.find_next_sibling('p'):
            visual = visual_tag.find_next_sibling('p').text.strip()
            
        # 2. Parsing Klimatologi & Suhu
        klimatologi = ""
        suhu_min, suhu_max = 0.0, 0.0
        klimatologi_tag = dsoup.find(lambda tag: tag.name == "h6" and "Klimatologi" in tag.text)
        if klimatologi_tag and klimatologi_tag.find_next_sibling('p'):
            klimatologi = klimatologi_tag.find_next_sibling('p').text.strip()
            # Coba regex cari angka suhu (contoh: 20-26)
            suhu_match = re.search(r'Suhu udara sekitar (\d+)(?:\s*-\s*(\d+))?', klimatologi)
            if suhu_match:
                suhu_min = float(suhu_match.group(1))
                if suhu_match.group(2):
                    suhu_max = float(suhu_match.group(2))
                else:
                    suhu_max = suhu_min
                    
        # 3. Parsing Kegempaan & Hitung Gempa
        kegempaan = ""
        gempa_count = 0
        amplitudo_max = 0.0
        
        kegempaan_tag = dsoup.find(lambda tag: tag.name == "h6" and "Pengamatan Kegempaan" in tag.text)
        if kegempaan_tag:
            # Kegempaan biasanya ada beberapa paragraf
            parent = kegempaan_tag.parent
            p_tags = parent.find_all('p')
            kegempaan = "\n".join([p.text.strip() for p in p_tags])
            
            # Cari angka kali gempa
            for p in p_tags:
                count_match = re.search(r'^(\d+)\s+kali', p.text.strip())
                if count_match:
                    gempa_count += int(count_match.group(1))
                    
                # Cari max amplitudo
                amp_match = re.search(r'amplitudo(?:\s+\d+\s*-)?\s*(\d+)\s*mm', p.text.strip(), re.IGNORECASE)
                if amp_match:
                    amp = float(amp_match.group(1))
                    if amp > amplitudo_max:
                        amplitudo_max = amp
                        
        # 4. Parsing Rekomendasi
        rekomendasi = ""
        rek_tag = dsoup.find(lambda tag: tag.name == "h6" and "Rekomendasi" in tag.text)
        if rek_tag and rek_tag.find_next_sibling('p'):
            rekomendasi = rek_tag.find_next_sibling('p').get_text(separator="\n").strip()
            
        # Parse Level
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
                
        message = "Status aman." if level_num == 1 else ("Aktivitas meningkat, berhati-hati." if level_num == 2 else ("Siaga, jauhi area berbahaya." if level_num == 3 else "AWAS! Segera evakuasi!"))
                
        return {
            "sensor": {
                "amplitudo": amplitudo_max,
                "suhu_min": suhu_min,
                "suhu_max": suhu_max,
                "gempa_count": gempa_count
            },
            "status": {
                "level": level_num,
                "status_text": status_text,
                "message": message,
                "visual": visual,
                "klimatologi": klimatologi,
                "kegempaan": kegempaan,
                "rekomendasi": rekomendasi,
                "author": author_text or ""
            }
        }
    except Exception as e:
        print(f"Error scraping: {e}")
        return None

def push_to_pocketbase(token, data):
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    sensor_url = f"{POCKETBASE_URL}/api/collections/sensor_data/records"
    print(f"Menyimpan Sensor Data: {data['sensor']}")
    res_sensor = requests.post(sensor_url, json=data['sensor'], headers=headers)
    if res_sensor.status_code == 200:
        print("✅ Sensor data berhasil disimpan!")
    else:
        print(f"❌ Gagal simpan sensor: {res_sensor.text}")
        
    status_url = f"{POCKETBASE_URL}/api/collections/volcano_status/records"
    print(f"Menyimpan Status Gunung: {data['status']}")
    res_status = requests.post(status_url, json=data['status'], headers=headers)
    if res_status.status_code == 200:
        print("✅ Status gunung berhasil disimpan!")
    else:
        print(f"❌ Gagal simpan status: {res_status.text}")

def main():
    print("=== Memulai Script EWS Semeru Scraper ===")
    
    # Jalankan terus menerus setiap 15 menit (900 detik)
    while True:
        try:
            token = get_pb_token()
            if not token:
                print("Gagal autentikasi PocketBase. Coba lagi 15 menit ke depan.")
            else:
                data = fetch_magma_data()
                if data:
                    push_to_pocketbase(token, data)
                    print("Data berhasil diperbarui!")
                
        except Exception as e:
            print(f"Error saat menjalankan scraper: {e}")
            
        print("Menunggu 15 menit untuk update selanjutnya...\n")
        time.sleep(900)

if __name__ == "__main__":
    main()
