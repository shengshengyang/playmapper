-- V5: 建立審核記錄表

CREATE TABLE place_reviews (
    id BIGSERIAL PRIMARY KEY,
    place_id BIGINT REFERENCES places(id) ON DELETE CASCADE,
    reviewer_id BIGINT REFERENCES users(id),
    action VARCHAR(20) NOT NULL,
    comment TEXT,
    reviewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT check_review_action CHECK (action IN ('approved', 'rejected', 'pending'))
);

-- 索引
CREATE INDEX idx_place_reviews_place_id ON place_reviews(place_id);
CREATE INDEX idx_place_reviews_reviewer_id ON place_reviews(reviewer_id);
CREATE INDEX idx_place_reviews_action ON place_reviews(action);
CREATE INDEX idx_place_reviews_date ON place_reviews(reviewed_at DESC);
