const pool = require('../config/db.config');

class TagRepository {
    async getAll() {
        const result = await pool.query('SELECT * FROM tag');
        return result.rows;
    }

    async getById(id) {
        const result = await pool.query('SELECT * FROM tag WHERE tag_id = $1', [id]);
        return result.rows[0];
    }

    async create(tagName) {
        const result = await pool.query(
            'INSERT INTO tag (tag_name) VALUES ($1) RETURNING *',
            [tagName]
        );
        return result.rows[0];
    }

    async delete(id) {
        const result = await pool.query(
            'DELETE FROM tag WHERE tag_id = $1 RETURNING *',
            [id]
        );
        return result.rows[0];
    }
}

module.exports = new TagRepository();
