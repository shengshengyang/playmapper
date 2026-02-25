-- V4: 建立行程景點關聯表

CREATE TABLE trip_places (
    id BIGSERIAL PRIMARY KEY,
    trip_id BIGINT REFERENCES trips(id) ON DELETE CASCADE,
    place_id BIGINT REFERENCES places(id),
    day_number INT NOT NULL,
    visit_order INT NOT NULL,
    scheduled_arrival TIME,
    scheduled_departure TIME,
    actual_arrival TIME,
    actual_departure TIME,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT unique_trip_day_order UNIQUE(trip_id, day_number, visit_order),
    CONSTRAINT check_day_number CHECK (day_number > 0),
    CONSTRAINT check_visit_order CHECK (visit_order > 0)
);

-- 索引
CREATE INDEX idx_trip_places_trip_id ON trip_places(trip_id);
CREATE INDEX idx_trip_places_place_id ON trip_places(place_id);
CREATE INDEX idx_trip_places_day ON trip_places(trip_id, day_number);
