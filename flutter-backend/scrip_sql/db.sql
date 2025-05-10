DROP TABLE IF EXISTS tag_real_estate;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS favorite_real_estate;
DROP TABLE IF EXISTS image_real_estate;
DROP TABLE IF EXISTS real_estate;
DROP TABLE IF EXISTS users;

-- Create users table
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
    active BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create real_estate table with promote_at and promote_end
CREATE TABLE real_estate (
    real_estate_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    type_realestate VARCHAR(50) NOT NULL,
    type_sell VARCHAR(20) CHECK (type_sell IN ('ขายขาด', 'เช่า')) NOT NULL,
    address TEXT NOT NULL,
    tambon VARCHAR(50),
    amphur VARCHAR(50),
    province VARCHAR(50),
    details TEXT,
    view INT DEFAULT 0,
    premium_promote BOOLEAN DEFAULT FALSE,
    active BOOLEAN DEFAULT TRUE,
    promote_at TIMESTAMP,
    promote_end TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create image_real_estate table
CREATE TABLE image_real_estate (
    image_id SERIAL PRIMARY KEY,
    image_path VARCHAR(255) NOT NULL,
    real_estate_id INT REFERENCES real_estate(real_estate_id) ON DELETE CASCADE
);

-- Create favorite_real_estate table
CREATE TABLE favorite_real_estate (
    favorite_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    real_estate_id INT REFERENCES real_estate(real_estate_id) ON DELETE CASCADE
);
CREATE TABLE tag (
    tag_id SERIAL PRIMARY KEY,
    tag_name VARCHAR(100) NOT NULL UNIQUE
);

-- Create tag_real_estate table (many-to-many relationship)
CREATE TABLE tag_real_estate (
    tag_real_id SERIAL PRIMARY KEY,
    tag_id INT REFERENCES tag(tag_id) ON DELETE CASCADE,
    real_estate_id INT REFERENCES real_estate(real_estate_id) ON DELETE CASCADE
);

-- Create trigger function to update updated_at field
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for updating updated_at column on updates
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_real_estate_updated_at
BEFORE UPDATE ON real_estate
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Insert sample data into users
INSERT INTO users (username, password, email, image_path, role, first_name, last_name, nick_name, phone_number, active) VALUES
('john_doe', 'hashed_password1', 'john@example.com', '/images/john.jpg', 'user', 'John', 'Doe', 'Johnny', '0812345678', TRUE),
('jane_smith', 'hashed_password2', 'jane@example.com', '/images/jane.jpg', 'admin', 'Jane', 'Smith', 'Janey', '0898765432', TRUE),
('mike_tyson', 'hashed_password3', 'mike@example.com', NULL, 'worker', 'Mike', 'Tyson', 'IronMike', '0861234567', TRUE),
('alice_wonder', 'hashed_password4', 'alice@example.com', '/images/alice.jpg', 'user', 'Alice', 'Wonderland', NULL, '0856789123', TRUE),
('bob_builder', 'hashed_password5', 'bob@example.com', '/images/bob.jpg', 'worker', 'Bob', 'Builder', NULL, '0823456789', TRUE);

-- Insert sample data into real_estate with promote_at and promote_end
INSERT INTO real_estate (user_id, type_realestate, type_sell, address, tambon, amphur, province, details, view, premium_promote, active, promote_at, promote_end) VALUES
(1, 'บ้านเดี่ยว', 'ขายขาด', '123/4 ถนนพระราม 9', 'ห้วยขวาง', 'กรุงเทพฯ', 'กรุงเทพมหานคร', 'บ้านสวยใกล้รถไฟฟ้า', 100, TRUE, TRUE, '2025-01-01 10:00:00', '2025-12-31 23:59:59'),
(2, 'คอนโด', 'เช่า', '999/12 ซอยสุขุมวิท 50', 'พระโขนง', 'กรุงเทพฯ', 'กรุงเทพมหานคร', 'คอนโดใจกลางเมือง', 50, FALSE, TRUE, '2025-02-01 09:00:00', '2025-11-30 23:59:59'),
(3, 'ที่ดิน', 'ขายขาด', 'แปลง A หมู่ 3', 'บางใหญ่', 'นนทบุรี', 'นนทบุรี', 'ที่ดินเหมาะสร้างบ้าน', 20, TRUE, TRUE, '2025-03-01 08:00:00', '2025-08-31 23:59:59'),
(4, 'บ้านทาวน์เฮ้าส์', 'ขายขาด', '67/1 หมู่บ้านสุขสันต์', 'ลำลูกกา', 'ปทุมธานี', 'ปทุมธานี', 'ทาวน์เฮ้าส์ 2 ชั้น', 80, FALSE, TRUE, NULL, NULL),
(5, 'อาคารพาณิชย์', 'เช่า', '45/9 ถนนเยาวราช', 'สัมพันธวงศ์', 'กรุงเทพฯ', 'กรุงเทพมหานคร', 'อาคารพาณิชย์ 3 ชั้น', 30, TRUE, TRUE, '2025-04-01 11:00:00', '2025-10-31 23:59:59');

-- Insert sample data into image_real_estate
INSERT INTO image_real_estate (image_path, real_estate_id) VALUES
('/images/house1.jpg', 1),
('/images/condo1.jpg', 2),
('/images/land1.jpg', 3),
('/images/townhouse1.jpg', 4),
('/images/commercial1.jpg', 5);

-- Insert sample data into favorite_real_estate
INSERT INTO favorite_real_estate (user_id, real_estate_id) VALUES
(1, 2),
(2, 1),
(3, 5),
(4, 3),
(5, 4);

-- Insert sample data into tag
INSERT INTO tag (tag_name) VALUES
('ใกล้รถไฟฟ้า'),
('ติดทะเล'),
('มีสระว่ายน้ำ'),
('ราคาถูก'),
('บ้านใหม่'),
('ตกแต่งครบ'),
('ทำเลดี'),
('มีที่จอดรถ');

-- Insert sample data into tag_real_estate
INSERT INTO tag_real_estate (tag_id, real_estate_id) VALUES
(1, 1), 
(2, 3),
(3, 2), 
(4, 4), 
(5, 1),
(6, 2), 
(7, 5), 
(8, 5); 