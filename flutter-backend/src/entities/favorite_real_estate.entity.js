module.exports = {
    createTable: `CREATE TABLE IF NOT EXISTS favorite_real_estate (
        favorite_id SERIAL PRIMARY KEY,
        user_id INT REFERENCES users(id) ON DELETE CASCADE,
        real_estate_id INT REFERENCES real_estate(id) ON DELETE CASCADE
    );`
};