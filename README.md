# EcoPick ♻️

Aplikasi mobile berbasis Flutter untuk memudahkan pengelolaan dan penjemputan sampah terpilah langsung dari rumah, dilengkapi pemindaian jenis sampah berbasis AI dan sistem poin ramah lingkungan.

---

## Fitur Utama
* **AI Scanner:** Mendeteksi jenis sampah (misalnya plastik, kertas, kardus), kondisi kebersihan, estimasi berat, dan poin otomatis menggunakan kamera dan Google Gemini AI.
* **Autentikasi & Profil Pengguna:** Registrasi dan login aman menggunakan Supabase Auth.
* **Request Pickup & Tracking:** Pemesanan penjemputan sampah terpilah dan pelacakan status penjemputan secara *real-time*.
* **Eco-Wallet & Impact Tracker:** Akumulasi poin dari setiap penyetoran sampah serta pantauan dampak lingkungan pengguna.
* **Riwayat Penjemputan:** Catatan transaksi dan riwayat sampah yang telah disetorkan.

---

## Teknologi yang Digunakan
* **Frontend:** Flutter & Dart
* **Backend & Database:** Supabase (PostgreSQL, Authentication, Edge Functions)
* **AI Engine:** Google Gemini (`gemini-3-flash-preview`) via Supabase Edge Function
* **State & Konfigurasi:** `--dart-define-from-file` (`env.json`) untuk keamanan kredensial

---

## Cara Menjalankan Proyek

### 1. Prasyarat
* Flutter SDK terinstal (`flutter doctor` aman)
* Akun dan proyek Supabase yang sudah aktif

### 2. Instalasi & Konfigurasi
1. **Clone repositori ini:**
   `git clone https://github.com/USERNAME-KAMU/ecopick.git`
   `cd ecopick`

2. **Unduh dependensi Flutter:**
   `flutter pub get`

3. **Jalankan aplikasi:**
   `flutter run`
   *(Catatan: Konfigurasi koneksi ke Supabase sudah terpasang secara default sehingga aplikasi dapat langsung dijalankan.).*

---

## Akun Demo 
Aplikasi sudah terhubung langsung ke server Supabase. Silakan jalankan `flutter run` dan masuk menggunakan akun berikut (atau daftar akun baru langsung di aplikasi):
* **Email:** `User@gmail.com`
* **Password:** `Password123!`

## Struktur Proyek
* `lib/screens/` — Halaman UI (Login/Entry, Home, Scan, Pickup)
* `lib/scan_service.dart` — Komunikasi ke Supabase Edge Function (AI Scan)
* `lib/supa.dart` — Inisialisasi client Supabase
* `lib/state.dart` — Manajemen state aplikasi
* `lib/main.dart` — Entry point aplikasi
* `supabase/functions/scan/` — Kode Deno Edge Function untuk Gemini AI
* `supabase/schema.sql` — Skema tabel & izin database PostgreSQL
* `env.example.json` — Templat variabel lingkungan

---

## Status Pengembangan
- [x] Desain UI dan alur utama aplikasi
- [x] Autentikasi pengguna & database PostgreSQL (Supabase)
- [x] Pemindaian sampah dengan kamera & AI via Edge Function
- [x] Impact Tracker
- [ ] Fitur edit profil pengguna (data diri, alamat tersimpan, dan foto profil)
- [ ] Sistem notifikasi dan halaman bantuan
- [ ] Penukaran poin Eco-Wallet ke e-wallet
