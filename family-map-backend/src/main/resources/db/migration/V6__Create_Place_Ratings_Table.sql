-- V6: 建立使用者評論表

CREATE TABLE place_ratings (
    id BIGSERIAL PRIMARY KEY,
    place_id BIGINT REFERENCES places(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id),
    rating INT NOT NULL,
    comment TEXT,
    visit_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unique_user_place_rating UNIQUE(place_id, user_id),
    CONSTRAINT check_rating_value CHECK (rating >= 1 AND rating <= 5)
);

-- 索引
CREATE INDEX idx_place_ratings_place_id ON place_ratings(place_id);
CREATE INDEX idx_place_ratings_user_id ON place_ratings(user_id);
CREATE INDEX idx_place_ratings_rating ON place_ratings(rating);
CREATE INDEX idx_place_ratings_date ON place_ratings(created_at DESC);

-- 建立更新評分的函數
CREATE OR REPLACE FUNCTION update_place_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE places
    SET rating = (
        SELECT COALESCE(AVG(rating), 0)
        FROM place_ratings
        WHERE place_id = COALESCE(NEW.place_id, OLD.place_id)
    ),
    review_count = (
        SELECT COUNT(*)
        FROM place_ratings
        WHERE place_id = COALESCE(NEW.place_id, OLD.place_id)
    )
    WHERE id = COALESCE(NEW.place_id, OLD.place_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 建立觸發器：當評論新增、更新或刪除時自動更新景點評分
CREATE TRIGGER trg_update_place_rating
AFTER INSERT OR UPDATE OR DELETE ON place_ratings
FOR EACH ROW
EXECUTE FUNCTION update_place_rating();
