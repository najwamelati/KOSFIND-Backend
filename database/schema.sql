-- KOSFIND: Sistem Informasi Pencarian Kos
-- Jalankan file ini pada database kosfind_db menggunakan pgAdmin atau psql.

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('pemilik', 'penyewa', 'admin')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Relasi one-to-one: satu user mempunyai satu profile.
CREATE TABLE IF NOT EXISTS profiles (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    nomor_telepon VARCHAR(25),
    alamat TEXT,
    foto_profil TEXT
);

-- Relasi one-to-many: satu pemilik (users) dapat mempunyai banyak kos.
CREATE TABLE IF NOT EXISTS kos (
    id SERIAL PRIMARY KEY,
    pemilik_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    nama_kos VARCHAR(150) NOT NULL,
    alamat TEXT NOT NULL,
    kota VARCHAR(100) NOT NULL,
    deskripsi TEXT,
    jenis_kos VARCHAR(30) NOT NULL DEFAULT 'campur'
        CHECK (jenis_kos IN ('putra', 'putri', 'campur')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Relasi one-to-many: satu kos mempunyai banyak kamar.
CREATE TABLE IF NOT EXISTS kamar (
    id SERIAL PRIMARY KEY,
    kos_id INTEGER NOT NULL REFERENCES kos(id) ON DELETE CASCADE,
    nomor_kamar VARCHAR(30) NOT NULL,
    harga_per_bulan NUMERIC(12,2) NOT NULL CHECK (harga_per_bulan >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'tersedia'
        CHECK (status IN ('tersedia', 'terisi', 'perbaikan')),
    luas_kamar VARCHAR(30),
    UNIQUE (kos_id, nomor_kamar)
);

CREATE TABLE IF NOT EXISTS fasilitas (
    id SERIAL PRIMARY KEY,
    nama_fasilitas VARCHAR(100) NOT NULL UNIQUE
);

-- Relasi many-to-many antara kos dan fasilitas.
CREATE TABLE IF NOT EXISTS kos_fasilitas (
    kos_id INTEGER NOT NULL REFERENCES kos(id) ON DELETE CASCADE,
    fasilitas_id INTEGER NOT NULL REFERENCES fasilitas(id) ON DELETE CASCADE,
    PRIMARY KEY (kos_id, fasilitas_id)
);

CREATE TABLE IF NOT EXISTS pemesanan (
    id SERIAL PRIMARY KEY,
    kamar_id INTEGER NOT NULL REFERENCES kamar(id) ON DELETE CASCADE,
    penyewa_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'menunggu'
        CHECK (status IN ('menunggu', 'dikonfirmasi', 'dibatalkan', 'selesai')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CHECK (tanggal_selesai IS NULL OR tanggal_selesai >= tanggal_mulai)
);

CREATE TABLE IF NOT EXISTS ulasan (
    id SERIAL PRIMARY KEY,
    kos_id INTEGER NOT NULL REFERENCES kos(id) ON DELETE CASCADE,
    penyewa_id INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    komentar TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (kos_id, penyewa_id)
);

CREATE INDEX IF NOT EXISTS idx_kos_pemilik_id ON kos(pemilik_id);
CREATE INDEX IF NOT EXISTS idx_kamar_kos_id ON kamar(kos_id);
CREATE INDEX IF NOT EXISTS idx_pemesanan_penyewa_id ON pemesanan(penyewa_id);
CREATE INDEX IF NOT EXISTS idx_ulasan_kos_id ON ulasan(kos_id);

-- Data contoh minimal agar API bisa langsung diuji setelah schema dijalankan.
INSERT INTO users (nama, email, password_hash, role)
VALUES
 ('Pemilik Contoh', 'pemilik@example.com', 'dummy-hash-untuk-tugas', 'pemilik'),
 ('Penyewa Contoh', 'penyewa@example.com', 'dummy-hash-untuk-tugas', 'penyewa')
ON CONFLICT (email) DO NOTHING;

INSERT INTO profiles (user_id, nomor_telepon, alamat)
SELECT id, '081234567890', 'Surabaya'
FROM users WHERE email = 'pemilik@example.com'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO profiles (user_id, nomor_telepon, alamat)
SELECT id, '081234567891', 'Surabaya'
FROM users WHERE email = 'penyewa@example.com'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO kos (pemilik_id, nama_kos, alamat, kota, deskripsi, jenis_kos)
SELECT id, 'Kos Melati', 'Jl. Contoh No. 10', 'Surabaya',
       'Kos contoh untuk pengujian tugas REST API.', 'campur'
FROM users WHERE email = 'pemilik@example.com'
AND NOT EXISTS (SELECT 1 FROM kos WHERE nama_kos = 'Kos Melati');

INSERT INTO kamar (kos_id, nomor_kamar, harga_per_bulan, status, luas_kamar)
SELECT id, 'A01', 750000, 'tersedia', '3 x 3 meter'
FROM kos WHERE nama_kos = 'Kos Melati'
ON CONFLICT (kos_id, nomor_kamar) DO NOTHING;

INSERT INTO fasilitas (nama_fasilitas)
VALUES ('Wi-Fi'), ('Kamar mandi dalam'), ('Parkir motor')
ON CONFLICT (nama_fasilitas) DO NOTHING;

INSERT INTO kos_fasilitas (kos_id, fasilitas_id)
SELECT k.id, f.id
FROM kos k CROSS JOIN fasilitas f
WHERE k.nama_kos = 'Kos Melati'
  AND f.nama_fasilitas IN ('Wi-Fi', 'Parkir motor')
ON CONFLICT DO NOTHING;
