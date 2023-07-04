-- changing the wal level for the connector debezium
ALTER SYSTEM SET wal_level = logical;

show wal_level;

-- create the schema
create schema dev;

-- create the table users
CREATE TABLE dev.users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    creation_date DATE
);

-- or you can create the table users with the following schema to avoid entering dates
CREATE TABLE your_table_name (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- insert the first so the topic would auto created by the connector
INSERT INTO  dev.users (name, creation_date) VALUES ('jane doe','2022-01-23');

--
-- Inject more data into the table -----------

-- Generate sample names
WITH sample_names AS (
  SELECT 'John' AS name UNION ALL
  SELECT 'Jane' AS name UNION ALL
  SELECT 'Mike' AS name UNION ALL
  SELECT 'Emily' AS name UNION ALL
  SELECT 'David' AS name UNION ALL
  SELECT 'Sarah' AS name UNION ALL
  SELECT 'Michael' AS name UNION ALL
  SELECT 'Olivia' AS name UNION ALL
  SELECT 'Daniel' AS name UNION ALL
  SELECT 'Sophia' AS name
)

-- Insert data into the users table
INSERT INTO dev.users (name, creation_date)
SELECT
  name,
  current_date - (random() * 365)::integer AS creation_date
FROM sample_names
CROSS JOIN generate_series(1, 5);




--test an upsert statement to validate it won't be counted--


INSERT INTO dev.users (id, name, creation_date)
VALUES (1, 'judy', '2022-01-01')
ON CONFLICT (id)
DO UPDATE SET name = EXCLUDED.name, creation_date = EXCLUDED.creation_date;

