module.exports = {
    createTable: `CREATE TABLE IF NOT EXISTS image_real_estate (
        id SERIAL PRIMARY KEY,
        real_estate_id INT NOT NULL REFERENCES real_estates(id) ON DELETE CASCADE,
        image_path TEXT NOT NULL
    );`
};