const pool = require('../config/db.config');

class UserRepository {
    async getAllUsers() {
        const result = await pool.query('SELECT * FROM users WHERE active = TRUE');
        return result.rows;
    }

    async getUserById(user_id) {
        const result = await pool.query('SELECT * FROM users WHERE user_id = $1 AND active = TRUE', [user_id]);
        return result.rows[0];
    }

    async createUser(user) {
        const result = await pool.query(
            `INSERT INTO users (username, password, email, image_path, role, first_name, last_name, nick_name, phone_number, active) 
             VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, TRUE) RETURNING *`,
            [user.username, user.password, user.email, user.image_path, user.role, user.first_name, user.last_name, user.nick_name, user.phone_number]
        );
        return result.rows[0];
    }

    async updateUser(user_id, user) {
        const result = await pool.query(
            `UPDATE users 
             SET username = $1, email = $2, image_path = $3, role = $4, first_name = $5, last_name = $6, nick_name = $7, phone_number = $8, password = $9, updated_at = NOW()
             WHERE user_id = $10 RETURNING *`,
            [
                user.username, 
                user.email, 
                user.image_path, 
                user.role, 
                user.first_name, 
                user.last_name, 
                user.nick_name, 
                user.phone_number, 
                user.password, 
                user_id
            ]
        );
        return result.rows[0];
    }
async reactivateUser(user_id) {
    const result = await pool.query(
        'UPDATE users SET active = TRUE WHERE user_id = $1 RETURNING *',
        [user_id]
    );
    return result.rows[0];
}


    async softDeleteUser(user_id) {
        const result = await pool.query('UPDATE users SET active = FALSE WHERE user_id = $1 RETURNING *', [user_id]);
        return result.rows[0];
    }
}

module.exports = new UserRepository();
