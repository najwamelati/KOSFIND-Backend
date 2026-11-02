require('dotenv').config();

const express = require('express');
const cors = require('cors');
const pool = require('./db');
const kosRoutes = require('./routes/kosRoutes');

const app = express();
const PORT = Number(process.env.PORT || 3000);

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'KOSFIND Backend API berjalan', endpoints: ['/api/kos'] });
});

app.get('/health/db', async (req, res, next) => {
  try {
    const result = await pool.query('SELECT NOW() AS waktu_server');
    res.json({ message: 'Koneksi PostgreSQL berhasil', data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

app.use('/api/kos', kosRoutes);

// Middleware penanganan error
app.use((error, req, res, next) => {
  console.error(error.message);
  if (error.code === '23503') {
    return res.status(400).json({ message: 'ID pemilik tidak ditemukan atau data masih digunakan oleh relasi lain' });
  }
  if (error.code === '23505') {
    return res.status(409).json({ message: 'Data duplikat: periksa email atau data unik lainnya' });
  }
  res.status(500).json({ message: 'Terjadi kesalahan pada server', detail: error.message });
});

app.listen(PORT, () => {
  console.log(`KOSFIND API berjalan di http://localhost:${PORT}`);
});
