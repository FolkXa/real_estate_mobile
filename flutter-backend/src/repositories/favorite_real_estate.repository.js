const pool = require('../config/db.config');

class FavoriteRealEstateRepository {
    async create(userId, realEstateId) {
        const result = await pool.query(
            'INSERT INTO favorite_real_estate (user_id, real_estate_id) VALUES ($1, $2) RETURNING *',
            [userId, realEstateId]
        );
        return result.rows[0];
    }

    async getAll() {
        const result = await pool.query('SELECT * FROM favorite_real_estate');
        return result.rows;
    }

    async getById(id) {
        const result = await pool.query('SELECT * FROM favorite_real_estate WHERE user_id = $1', [id]);
        return result.rows[0];
    }

    async delete(id) {
        await pool.query('DELETE FROM favorite_real_estate WHERE favorite_id = $1', [id]);
    }
}
module.exports = new FavoriteRealEstateRepository();