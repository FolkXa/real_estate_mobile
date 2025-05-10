module.exports = {
    createTable: `CREATE TABLE IF NOT EXISTS real_estates (
        id SERIAL PRIMARY KEY,
        user_id INT NOT NULL,  
        title VARCHAR(255) NOT NULL,
        description TEXT,
        price NUMERIC(12, 2) NOT NULL,
        location VARCHAR(255) NOT NULL,
        tambon VARCHAR(100),  
        amphur VARCHAR(100),  
        province VARCHAR(100),  
        size NUMERIC(10, 2),
        type VARCHAR(50),  -- ประเภทอสังหาริมทรัพย์ (เช่น บ้าน, คอนโด, ที่ดิน)
        type_sell VARCHAR(50), -- ประเภทการขาย (ขายขาด หรือ เช่า)
        owner VARCHAR(255),
        contact_info VARCHAR(255),
        view INT DEFAULT 0, 
        premium_promote BOOLEAN DEFAULT FALSE, 
        active BOOLEAN DEFAULT TRUE,
        promote_at TIMESTAMP,  
        promote_end TIMESTAMP, 
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
    );`
};
