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
