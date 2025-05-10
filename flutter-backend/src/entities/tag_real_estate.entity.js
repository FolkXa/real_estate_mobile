module.exports = {
    createTable: `CREATE TABLE IF NOT EXISTS tag_real_estate (
    tag_real_id SERIAL PRIMARY KEY,
    tag_id INT REFERENCES tag(tag_id) ON DELETE CASCADE,
    real_estate_id INT REFERENCES real_estate(real_estate_id) ON DELETE CASCADE
);`
};
