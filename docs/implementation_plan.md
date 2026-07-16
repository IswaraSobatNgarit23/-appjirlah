# Redesign: Bento Grid & Cyberpunk Palette

Anda merasa desain saat ini masih kurang "nendang"? Mari kita rombak menjadi desain yang benar-benar **WOW** dan memukau, menggunakan tren UI modern: **Bento Box Grid** dengan sentuhan warna neon *(Cyberpunk/Glassmorphism)*.

## 🎯 Visi Desain (Aesthetics & Layout)

1.  **Warna & Suasana (Premium Dark Mode):**
    *   Mengganti warna latar belakang yang saat ini sedikit kebiruan (`#080C14`) menjadi **Obsidian Black** murni (`#09090B`) agar kontras layar OLED lebih maksimal.
    *   Warna aksen (`accent`) akan diubah dari *teal* standar menjadi gradasi **Neon Cyan (`#06B6D4`)** dan **Indigo (`#6366F1`)** yang menyala.
    *   Efek *Glassmorphism* akan diperkuat dengan *border* tipis bersinar dan bayangan (*glow shadow*) yang lebih dramatis.

2.  **Layout Bento Box (Staggered Grid):**
    *   Saat ini daftar sensor ditampilkan berbaris ke bawah secara membosankan.
    *   Kita akan merombaknya menjadi **Bento Grid**: 
        *   Kartu "Amplitudo" akan berukuran besar secara vertikal di sisi kiri.
        *   Kartu "Suhu" dan "Gempa" akan ditumpuk secara horizontal di sisi kanan.
    *   Ini akan menciptakan struktur visual (*Structural Variety* dari Hallmark) yang jauh lebih dinamis seperti *dashboard* mobil masa depan.

## 🛑 User Review Required

> [!IMPORTANT]
> Mengubah layout menjadi Bento Grid berarti kita akan membuat variasi bentuk kotak sensor (ada yang tinggi memanjang, ada yang pendek melebar). Apakah Anda menyukai konsep **Bento Dashboard** (seperti widget di iOS/Apple) ini?

## 🛠️ Proposed Changes

---

### Theme & Colors

#### [MODIFY] [app_theme.dart](file:///d:/coding/flutter/flutter/ews/-appjirlah/lib/theme/app_theme.dart)
- Mengubah palet `_darkColors`: `bgDark` menjadi `#09090B`, `bgCard` menjadi `#18181B`.
- Mengubah `accent` menjadi Cyan/Indigo.
- Memodifikasi fungsi `glassDecoration` dan `glowShadow` agar lebih tegas.

### UI Screens & Widgets

#### [MODIFY] [home_screen.dart](file:///d:/coding/flutter/flutter/ews/-appjirlah/lib/screens/home_screen.dart)
- Mengubah susunan `_buildSensorTiles` menggunakan kombinasi `IntrinsicHeight`, `Row`, dan `Column` untuk membentuk struktur grid Bento Box (1 kotak tinggi di kiri, 2 kotak pendek di kanan).

#### [MODIFY] [sensor_tile.dart](file:///d:/coding/flutter/flutter/ews/-appjirlah/lib/widgets/sensor_tile.dart)
- Menambahkan opsi `isCompact` atau `isTall` pada `SensorTile` agar komponen bisa menyesuaikan bentuknya saat diletakkan di dalam grid Bento.

---

## ✅ Verification Plan

### Manual Verification
- Menjalankan perintah `flutter run`.
- Memastikan palet warna baru (hitam pekat dan neon) merender dengan baik.
- Memastikan layout kotak Bento tidak berantakan (overflow) pada ukuran layar *mobile* biasa.
