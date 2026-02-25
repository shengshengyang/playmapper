-- V1: 建立使用者表

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_role CHECK (role IN ('user', 'admin'))
);

-- 建立索引
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);

-- 插入預設管理員帳號 (密碼: admin123，使用 BCrypt 加密)
INSERT INTO users (username, email, password_hash, role)
VALUES ('admin', 'admin@familymap.com', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iAt6V.S', 'admin');
