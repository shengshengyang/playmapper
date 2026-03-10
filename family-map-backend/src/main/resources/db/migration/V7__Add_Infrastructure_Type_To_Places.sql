-- V7: 將地點主體調整為親子基礎設施點
ALTER TABLE places
ADD COLUMN infrastructure_type VARCHAR(50) NOT NULL DEFAULT 'general';

UPDATE places
SET infrastructure_type = 'general'
WHERE infrastructure_type IS NULL;
