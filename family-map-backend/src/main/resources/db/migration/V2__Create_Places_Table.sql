-- V2: 建立景點表（含 PostGIS 擴展）

-- 啟用 PostGIS 擴展
CREATE EXTENSION IF NOT EXISTS postgis;

-- 建立景點表
CREATE TABLE places (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    address VARCHAR(500),
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    min_age INT DEFAULT 0,
    max_age INT DEFAULT 18,
    suggested_duration_minutes INT,
    opening_hours JSONB,
    facilities JSONB,
    ticket_price DECIMAL(10,2),
    phone VARCHAR(20),
    website VARCHAR(500),
    images TEXT[],
    rating DECIMAL(3,2) DEFAULT 0,
    review_count INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    submitter_id BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_age_range CHECK (min_age <= max_age),
    CONSTRAINT check_status CHECK (status IN ('pending', 'approved', 'rejected')),
    CONSTRAINT check_rating CHECK (rating >= 0 AND rating <= 5)
);

-- 地理空間索引
CREATE INDEX idx_places_location ON places USING GIST(location);

-- 其他索引
CREATE INDEX idx_places_status ON places(status);
CREATE INDEX idx_places_age_range ON places(min_age, max_age);
CREATE INDEX idx_places_rating ON places(rating DESC);

-- 建立景點圖片關聯表（用於存儲多張圖片）
CREATE TABLE place_images (
    id BIGSERIAL PRIMARY KEY,
    place_id BIGINT REFERENCES places(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_place_images_place_id ON place_images(place_id);
