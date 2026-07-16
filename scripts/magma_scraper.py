import requests
import time
import random
import os

# ==============================================================================
# KONFIGURASI SCRAPER & POCKETBASE
# ==============================================================================
# URL PocketBase Anda
POCKETBASE_URL = os.getenv("POCKETBASE_URL", "https://db-ews.sagamuda.id")

# Auth Admin PocketBase (Agar bisa insert data ke tabel yang diproteksi)
PB_ADMIN_EMAIL = os.getenv("PB_ADMIN_EMAIL", "admin@email.com")
PB_ADMIN_PASSWORD = os.getenv("PB_ADMIN_PASSWORD", "password_anda")

# URL Target MAGMA (Ganti dengan endpoint/URL Semeru spesifik jika ada)
MAGMA_URL = "https://magma.esdm.go.id/v1/gunung-api/laporan"

def get_pb_token():
    """Mendapatkan token admin dari PocketBase (v0.23+)"""
    auth_url = f"{POCKETBASE_URL}/api/collections/_superusers/auth-with-password"
    payload = {
        "identity": PB_ADMIN_EMAIL,
        "password": PB_ADMIN_PASSWORD
    }
    
    print("Mencoba login ke PocketBase Admin...")
    response = requests.post(auth_url, json=payload)
    
    if response.status_code == 200:
        print("Login sukses!")
        return response.json()['token']
    else:
        print(f"Gagal login PB: {response.text}")
        return None

def fetch_magma_data():
    """
    Simulasi scraping atau fetching API MAGMA.
    Karena MAGMA tidak punya JSON API publik resmi, bagian ini biasanya
    menggunakan BeautifulSoup (bs4) untuk mengambil teks HTML dari MAGMA_URL.
    
    Untuk contoh ini, kita hasilkan data dummy yang dinamis (berubah-ubah).
    Nantinya Anda bisa ganti bagian ini dengan logika scraping bs4.
    """
    print(f"Mengambil data dari {MAGMA_URL} ...")
    
    # --- LOGIKA SCRAPING ASLI NANTINYA DI SINI ---
    # response = requests.get(MAGMA_URL)
    # soup = BeautifulSoup(response.text, 'html.parser')
    # text_amplitudo = soup.find('div', class_='amplitudo').text
    # dll...
    
    # --- DUMMY DATA SEMENTARA ---
    suhu = round(random.uniform(50.0, 90.0), 1)
    amplitudo = round(random.uniform(10.0, 25.0), 1)
    gempa_count = random.randint(10, 50)
    level = 2 if amplitudo < 15 else (3 if amplitudo < 22 else 4)
    
    messages = {
        2: "Waspada! Aktivitas meningkat, jauhi kawah radius 5 KM.",
        3: "Siaga! Terdapat potensi awan panas. Jauhi radius 13 KM.",
        4: "AWAS! Segera evakuasi dari zona merah!"
    }
    status_texts = {2: "Waspada", 3: "Siaga", 4: "Awas"}
    
    return {
        "sensor": {
            "amplitudo": amplitudo,
            "suhu": suhu,
            "gempa_count": gempa_count
        },
        "status": {
            "level": level,
            "status_text": status_texts.get(level, "Normal"),
            "message": messages.get(level, "Aman")
        }
    }

def push_to_pocketbase(token, data):
    """Menyimpan data terbaru ke PocketBase"""
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }
    
    # 1. Push Sensor Data
    sensor_url = f"{POCKETBASE_URL}/api/collections/sensor_data/records"
    print(f"Menyimpan Sensor Data: {data['sensor']}")
    res_sensor = requests.post(sensor_url, json=data['sensor'], headers=headers)
    
    if res_sensor.status_code == 200:
        print("✅ Sensor data berhasil disimpan!")
    else:
        print(f"❌ Gagal simpan sensor: {res_sensor.text}")
        
    # 2. Push Volcano Status
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
                # Ambil data dari Magma
                data = fetch_magma_data()
                
                # Push ke backend
                push_to_pocketbase(token, data)
                print("Data berhasil diperbarui!")
                
        except Exception as e:
            print(f"Error saat menjalankan scraper: {e}")
            
        print("Menunggu 15 menit untuk update selanjutnya...\n")
        time.sleep(900) # 900 detik = 15 menit

if __name__ == "__main__":
    main()
