module.exports = {
    createTable: `CREATE TABLE IF NOT EXISTS tag (
        tag_id SERIAL PRIMARY KEY,
        tag_name VARCHAR(100) NOT NULL UNIQUE
    );`
};
