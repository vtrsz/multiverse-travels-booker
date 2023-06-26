-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE travels (
    id int NOT NULL GENERATED ALWAYS AS IDENTITY,
    travel_stops int[] NOT NULL
);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE IF EXISTS travels;