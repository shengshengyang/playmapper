CREATE TABLE infrastructure_types (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO infrastructure_types (name, sort_order)
VALUES
    ('親子廁所', 10),
    ('尿布台', 20),
    ('哺乳室', 30),
    ('無障礙廁所', 40),
    ('休息區', 50)
ON CONFLICT (name) DO NOTHING;

INSERT INTO infrastructure_types (name, sort_order)
SELECT DISTINCT p.infrastructure_type, 100
FROM places p
WHERE p.infrastructure_type IS NOT NULL
  AND p.infrastructure_type <> ''
ON CONFLICT (name) DO NOTHING;
