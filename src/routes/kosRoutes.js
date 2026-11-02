const express = require('express');
const pool = require('../db');

const router = express.Router();

// GET /api/kos - mendapatkan semua data kos
router.get('/', async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT k.id, k.pemilik_id, k.nama_kos, k.alamat, k.kota,
             k.deskripsi, k.jenis_kos, k.created_at, k.updated_at,
             u.nama AS nama_pemilik
      FROM kos k
      JOIN users u ON u.id = k.pemilik_id
      ORDER BY k.id ASC
    `);
    res.json({ message: 'Data kos berhasil diambil', data: result.rows });
  } catch (error) {
    next(error);
  }
});

// GET /api/kos/:id - mendapatkan satu data kos berdasarkan ID
router.get('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id < 1) {
      return res.status(400).json({ message: 'ID harus berupa bilangan bulat positif' });
    }

    const result = await pool.query(`
      SELECT k.id, k.pemilik_id, k.nama_kos, k.alamat, k.kota,
             k.deskripsi, k.jenis_kos, k.created_at, k.updated_at,
             u.nama AS nama_pemilik
      FROM kos k
      JOIN users u ON u.id = k.pemilik_id
      WHERE k.id = $1
    `, [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Data kos tidak ditemukan' });
    }
    res.json({ message: 'Data kos berhasil ditemukan', data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

// POST /api/kos - menambahkan data kos
router.post('/', async (req, res, next) => {
  try {
    const { pemilik_id, nama_kos, alamat, kota, deskripsi = null, jenis_kos = 'campur' } = req.body;

    if (!pemilik_id || !nama_kos || !alamat || !kota) {
      return res.status(400).json({
        message: 'Field wajib: pemilik_id, nama_kos, alamat, dan kota'
      });
    }
    if (!['putra', 'putri', 'campur'].includes(jenis_kos)) {
      return res.status(400).json({ message: "jenis_kos harus 'putra', 'putri', atau 'campur'" });
    }

    const result = await pool.query(`
      INSERT INTO kos (pemilik_id, nama_kos, alamat, kota, deskripsi, jenis_kos)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `, [pemilik_id, nama_kos, alamat, kota, deskripsi, jenis_kos]);

    res.status(201).json({ message: 'Data kos berhasil ditambahkan', data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

// PUT /api/kos/:id - memperbarui data kos
router.put('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id < 1) {
      return res.status(400).json({ message: 'ID harus berupa bilangan bulat positif' });
    }

    const { pemilik_id, nama_kos, alamat, kota, deskripsi = null, jenis_kos = 'campur' } = req.body;
    if (!pemilik_id || !nama_kos || !alamat || !kota) {
      return res.status(400).json({
        message: 'Field wajib: pemilik_id, nama_kos, alamat, dan kota'
      });
    }
    if (!['putra', 'putri', 'campur'].includes(jenis_kos)) {
      return res.status(400).json({ message: "jenis_kos harus 'putra', 'putri', atau 'campur'" });
    }

    const result = await pool.query(`
      UPDATE kos
      SET pemilik_id = $1, nama_kos = $2, alamat = $3, kota = $4,
          deskripsi = $5, jenis_kos = $6, updated_at = CURRENT_TIMESTAMP
      WHERE id = $7
      RETURNING *
    `, [pemilik_id, nama_kos, alamat, kota, deskripsi, jenis_kos, id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Data kos tidak ditemukan' });
    }
    res.json({ message: 'Data kos berhasil diperbarui', data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

// DELETE /api/kos/:id - menghapus data kos
router.delete('/:id', async (req, res, next) => {
  try {
    const id = Number(req.params.id);
    if (!Number.isInteger(id) || id < 1) {
      return res.status(400).json({ message: 'ID harus berupa bilangan bulat positif' });
    }

    const result = await pool.query('DELETE FROM kos WHERE id = $1 RETURNING *', [id]);
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Data kos tidak ditemukan' });
    }
    res.json({ message: 'Data kos berhasil dihapus', data: result.rows[0] });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
