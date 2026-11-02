# KOSFIND Backend — Tugas Backend Development

Proyek latihan database PostgreSQL dan REST API Express.js untuk studi kasus Sistem Informasi Pencarian Kos (KOSFIND).

## Isi proyek

- `database/schema.sql`: 8 tabel, relasi, indeks, dan data contoh.
- `database/dbdiagram.dbml`: kode diagram untuk dbdiagram.io.
- `src/server.js`: aplikasi Express.
- `src/db.js`: konfigurasi koneksi PostgreSQL.
- `src/routes/kosRoutes.js`: lima endpoint CRUD untuk tabel `kos`.
- `postman/KOSFIND.postman_collection.json`: koleksi pengujian Postman.
- `.env.example`: contoh konfigurasi, bukan file rahasia aktif.
- `.gitignore`: mengecualikan `node_modules` dan `.env`.

## A. Buat database

1. Buka pgAdmin 4 dan sambungkan ke server PostgreSQL.
2. Klik kanan `Databases` → `Create` → `Database...`.
3. Isi nama database: `kosfind_db`, lalu Save.
4. Pilih database `kosfind_db`, buka Query Tool.
5. Buka file `database/schema.sql`, salin seluruh isinya ke Query Tool, lalu tekan Execute (ikon petir).
6. Pastikan tabel `users`, `profiles`, `kos`, `kamar`, `fasilitas`, `kos_fasilitas`, `pemesanan`, dan `ulasan` muncul di Schemas → public → Tables.
7. Data contoh membuat satu kos awal bernama `Kos Melati` dengan ID biasanya `1` pada database baru. Periksa tabel `kos` jika sudah ada data sebelumnya.

## B. Siapkan Node.js dan Express

1. Pastikan Node.js versi LTS terpasang. Cek di terminal:
   ```bash
   node -v
   npm -v
   ```
2. Buka folder proyek ini di VS Code.
3. Di terminal VS Code jalankan:
   ```bash
   npm install
   ```
4. Salin `.env.example` menjadi file baru bernama `.env`.
5. Isi `DB_PASSWORD` dengan password PostgreSQL yang dibuat saat instalasi. Sesuaikan `DB_USER` jika bukan `postgres`.
6. Jangan mengunggah `.env` ke GitHub atau membagikan password.
7. Jalankan server:
   ```bash
   npm run dev
   ```
   Jika berhasil, terminal menampilkan `KOSFIND API berjalan di http://localhost:3000`.

## C. Cek koneksi

Buka browser ke `http://localhost:3000/health/db`. Jika berhasil, respons berisi `Koneksi PostgreSQL berhasil`.

## D. Tes dengan Postman

1. Buka Postman → Import.
2. Pilih file `postman/KOSFIND.postman_collection.json`.
3. Pastikan server Express masih berjalan.
4. Jalankan permintaan dalam urutan berikut:
   - **POST** Tambah kos
   - **GET** Semua kos
   - **GET** Kos berdasarkan ID
   - **PUT** Perbarui kos
   - **DELETE** Hapus kos
5. Setelah POST, lihat `id` pada respons. Jika ID bukan `1`, ubah variable `kos_id` di koleksi Postman ke ID yang benar.
6. PUT dan DELETE mengubah/menghapus data. Gunakan data contoh atau data yang memang dibuat untuk tes.
7. Screenshot setiap respons yang berhasil untuk bukti tugas. Screenshot harus berasal dari pengujianmu sendiri, jangan menggunakan gambar contoh sebagai bukti.

## E. Buat diagram publik

1. Buka https://dbdiagram.io dan login/daftar.
2. Buat diagram baru.
3. Buka `database/dbdiagram.dbml`, salin isinya ke editor diagram.
4. Periksa relasi yang tampil.
5. Gunakan fitur Share dan atur akses sesuai permintaan tugas (publik), lalu salin link untuk formulir pengumpulan.

## F. Pengumpulan

- Link dbdiagram.io yang publik.
- Link repository GitHub publik atau ZIP proyek.
- Lima screenshot hasil pengujian Postman sesuai instruksi mentor.
- Lengkapi identitas pada formulir pengumpulan.

## Relasi database

- One-to-one: `users` ↔ `profiles` (kolom `profiles.user_id` unik).
- One-to-many: `users` → `kos`; `kos` → `kamar`.
- Many-to-many: `kos` ↔ `fasilitas`, melalui tabel penghubung `kos_fasilitas`.

## Catatan

- Data akun pada SQL adalah data contoh untuk latihan; `password_hash` bukan autentikasi aktif.
- Proyek ini hanya backend API, bukan website frontend.
- Pastikan menguji proyek pada laptop sendiri dan mengambil screenshot aktual sebelum dikumpulkan.
