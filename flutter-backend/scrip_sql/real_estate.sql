DROP TABLE IF EXISTS favorite_real_estate;
DROP TABLE IF EXISTS image_real_estate;
DROP TABLE IF EXISTS real_estate;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    image_path VARCHAR(255),
    role VARCHAR(20) CHECK (role IN ('user', 'admin', 'worker')) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nick_name VARCHAR(50),
    phone_number VARCHAR(15),
    active BOOLEAN DEFAULT TRUE
);

CREATE TABLE real_estate (
    real_estate_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, 
    address TEXT NOT NULL,
    tambon VARCHAR(50),
    amphur VARCHAR(50),
    province VARCHAR(50),
    details TEXT,
    view INT DEFAULT 0,
    premium_promote BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE
);


CREATE TABLE image_real_estate (
    image_id SERIAL PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL,
    real_estate_id INT REFERENCES real_estate(real_estate_id) ON DELETE CASCADE
);


CREATE TABLE favorite_real_estate (
    favorite_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    real_estate_id INT REFERENCES real_estate(real_estate_id) ON DELETE CASCADE
);


INSERT INTO users (username, password, email, image_path, role, first_name, last_name, nick_name, phone_number, active) VALUES
('john_doe', 'hashed_password1', 'john@example.com', '/images/john.jpg', 'user', 'John', 'Doe', 'Johnny', '0812345678', TRUE),
('jane_smith', 'hashed_password2', 'jane@example.com', '/images/jane.jpg', 'admin', 'Jane', 'Smith', 'Janey', '0898765432', TRUE),
('mike_tyson', 'hashed_password3', 'mike@example.com', NULL, 'worker', 'Mike', 'Tyson', 'IronMike', '0861234567', TRUE),
('alice_wonder', 'hashed_password4', 'alice@example.com', '/images/alice.jpg', 'user', 'Alice', 'Wonderland', NULL, '0856789123', TRUE),
('bob_builder', 'hashed_password5', 'bob@example.com', '/images/bob.jpg', 'worker', 'Bob', 'Builder', NULL, '0823456789', TRUE);


INSERT INTO real_estate (user_id, type, address, tambon, amphur, province, details, view, premium_promote, active) VALUES
(1, 'บ้านเดี่ยว', '123/4 ถนนพระราม 9', 'ห้วยขวาง', 'กรุงเทพฯ', 'กรุงเทพมหานคร', 'บ้านสวยใกล้รถไฟฟ้า', 100, TRUE, TRUE),
(2, 'คอนโด', '999/12 ซอยสุขุมวิท 50', 'พระโขนง', 'กรุงเทพฯ', 'กรุงเทพมหานคร', 'คอนโดใจกลางเมือง', 50, FALSE, TRUE),
(3, 'ที่ดิน', 'แปลง A หมู่ 3', 'บางใหญ่', 'นนทบุรี', 'นนทบุรี', 'ที่ดินเหมาะสร้างบ้าน', 20, TRUE, TRUE),
(4, 'บ้านทาวน์เฮ้าส์', '67/1 หมู่บ้านสุขสันต์', 'ลำลูกกา', 'ปทุมธานี', 'ปทุมธานี', 'ทาวน์เฮ้าส์ 2 ชั้น', 80, FALSE, TRUE),
(5, 'อาคารพาณิชย์', '45/9 ถนนเยาวราช', 'สัมพันธวงศ์', 'กรุงเทพฯ', 'กรุงเทพมหานคร', 'อาคารพาณิชย์ 3 ชั้น', 30, TRUE, TRUE);


INSERT INTO image_real_estate (image_path, real_estate_id) VALUES
('/images/house1.jpg', 1),
('/images/condo1.jpg', 2),
('/images/land1.jpg', 3),
('/images/townhouse1.jpg', 4),
('/images/commercial1.jpg', 5);


INSERT INTO favorite_real_estate (user_id, real_estate_id) VALUES
(1, 2),
(2, 1),
(3, 5),
(4, 3),
(5, 4);
