const pool = require('../config/db.config');

class TagRealEstateRepository {
    async getAll() {
        const result = await pool.query('SELECT * FROM tag_real_estate');
        return result.rows;
    }

    async getByRealEstateId(realEstateId) {
        const result = await pool.query(
            'SELECT * FROM tag_real_estate WHERE real_estate_id = $1',
            [realEstateId]
        );
        return result.rows;
    }

    async getRealEstateByTagId(tagId) {
        const result = await pool.query(
            'SELECT * FROM tag_real_estate WHERE tag_id = $1',
            [tagId]
        );
        return result.rows;
    }

    async create(data) {
        const result = await pool.query(
            `INSERT INTO tag_real_estate (tag_id, real_estate_id) 
             VALUES ($1, $2) RETURNING *`,
            [data.tag_id, data.real_estate_id]
        );
        return result.rows[0];
    }

    async delete(id) {
        const result = await pool.query(
            'DELETE FROM tag_real_estate WHERE tag_real_id = $1 RETURNING *',
            [id]
        );
        return result.rows[0];
    }
}

module.exports = new TagRealEstateRepository();
