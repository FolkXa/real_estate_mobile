const pool = require('../config/db.config');

class ImageRealEstateRepository {
    async getAll() {
        const result = await pool.query('SELECT * FROM image_real_estate');
        return result.rows;
    }

    async getByRealEstateId(realEstateId) {
        const result = await pool.query('SELECT * FROM image_real_estate WHERE real_estate_id = $1', [realEstateId]);
        return result.rows;
    }

    async create(data) {
        const result = await pool.query(
            `INSERT INTO image_real_estate (real_estate_id, image_path) 
             VALUES ($1, $2) RETURNING *`,
            [data.real_estate_id, data.image_path]
        );
        return result.rows[0];
    }

    async delete(id) {
        const result = await pool.query('DELETE FROM image_real_estate WHERE image_id = $1 RETURNING *', [id]);
        return result.rows[0];
    }
}

module.exports = new ImageRealEstateRepository();