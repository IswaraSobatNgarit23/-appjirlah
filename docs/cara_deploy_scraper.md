# 🤖 Panduan Deploy Scraper Python di Coolify

Karena Anda menggunakan Coolify, men-deploy *script* Python (Scraper) yang berjalan terus-menerus di latar belakang (*Worker*) sangatlah mudah berkat fitur **Nixpacks** yang sudah ada di dalam Coolify.

Ikuti langkah-langkah berikut untuk men-deploy `magma_scraper.py`.

---

## Step 1: Push Repository Saat Ini

Sangat bisa! Anda **tidak perlu** membuat repositori terpisah. Kita akan menggunakan repositori Flutter (EWS) Anda saat ini.
1. Saya baru saja membuatkan file `requirements.txt` di dalam folder `scripts/` bersama dengan `magma_scraper.py`.
2. Anda cukup **commit & push** semua perubahan kode di folder proyek Anda saat ini ke GitHub Anda.

## Step 2: Tambahkan Aplikasi di Coolify

1. Buka dashboard Coolify Anda (`sagamuda.id`).
2. Masuk ke Project **sgmd** → Environment **production**.
3. Klik tombol **+ New**.
4. Pilih **Public Repository** (jika repo GitHub Anda public) atau **Private Repository** (jika private dan sudah dihubungkan dengan Coolify App).
5. Masukkan URL repositori GitHub Anda dan Branch-nya (misalnya `main`).
6. Klik **Save**.

## Step 3: Konfigurasi Deployment (PENTING)

Setelah aplikasi ditambahkan, Anda akan masuk ke halaman konfigurasi. Ubah pengaturan berikut:

### A. Base Directory (SANGAT PENTING)
Di tab **General**, cari bagian **Base Directory**. 
Ubah menjadi: `/scripts`
*Mengapa? Karena proyek Anda adalah proyek Flutter. Jika tidak diubah, Coolify akan mencoba membangun aplikasi Flutter. Dengan mengarahkan ke `/scripts`, Coolify hanya akan melihat file `requirements.txt` dan menganggap ini adalah aplikasi Python.*

### B. Build Pack
Pastikan **Build Pack** yang terpilih adalah **Nixpacks**.

### C. Start Command
Di tab **General**, gulir ke bawah ke bagian *Start Command* dan isi dengan:
```bash
python magma_scraper.py
```

### C. Environment Variables
Script ini membutuhkan informasi rahasia agar bisa masuk ke PocketBase Anda. Buka tab **Environment Variables** dan tambahkan 3 variabel ini:

```
POCKETBASE_URL = https://db-ews.sagamuda.id
PB_ADMIN_EMAIL = email_admin_anda@sagamuda.id
PB_ADMIN_PASSWORD = password_super_rahasia_anda
```

## Step 4: Matikan Fitur Domain (Ini adalah Worker)
Karena *script* ini hanya berjalan di balik layar dan **tidak menampilkan website**, Anda **tidak perlu memasang domain**.
1. Hapus isi kolom **FQDN (Domains)** jika ada.
2. Pastikan tidak ada konfigurasi Traefik router yang diaktifkan untuk aplikasi ini.

## Step 5: Deploy!
1. Klik tombol **Deploy** di kanan atas.
2. Tunggu proses *build* selesai. Coolify akan otomatis menginstal Python, men-download `requests`, dan menjalankan perintah `python magma_scraper.py`.
3. Setelah status menjadi **Hijau (Running)**, buka tab **Logs**.
4. Di bagian *Logs*, Anda seharusnya melihat tulisan:
   ```
   === Memulai Script EWS Semeru Scraper ===
   Mencoba login ke PocketBase Admin...
   Login sukses!
   Mengambil data dari https://magma.esdm.go.id/v1/gunung-api/laporan ...
   ✅ Sensor data berhasil disimpan!
   ✅ Status gunung berhasil disimpan!
   Menunggu 15 menit untuk update selanjutnya...
   ```

🎉 **Selesai!** 
Sekarang scraper Anda sudah berjalan di awan (VPS) selama 24 jam penuh! Kapanpun ia mengirimkan data ke PocketBase setiap 15 menit, aplikasi Flutter di HP pengguna akan langsung terupdate (berkat fitur *realtime socket*).
