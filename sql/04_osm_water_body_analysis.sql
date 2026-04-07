-- Query 4: Water Body Analysis
-- Purpose: Analyze water bodies by island, including total area, count, and largest water body

-- Requirements:
-- - Join water_a with places_a where fclass = 'island'
-- - Use ST_Intersects to match water bodies to islands
-- - Use ST_Area(geom::geography) for accurate area calculations on WGS84
-- - Convert square meters to square kilometers (divide by 1,000,000)
-- - Calculate total water body area per island
-- - Count the number of water bodies per island
-- - Identify the largest water body on each island
-- - Order results by total water body area (largest first)

-- Expected Output:
-- - island_name
-- - total_water_body_area_sq_km
-- - number_of_water_bodies
-- - largest_water_body_name
-- - largest_water_body_area_sq_km

WITH island_water_bodies AS (
    SELECT
        p.name AS island_name,
        w.name AS water_body_name,
        ST_Area(w.geom::geography) / 1000000 AS water_body_area_sq_km
    FROM
        places_a AS p
    JOIN
        water_a AS w ON ST_Intersects(p.geom, w.geom)
    WHERE
        p.fclass = 'island'
),
island_summary AS (
    SELECT
        island_name,
        SUM(water_body_area_sq_km) AS total_water_body_area_sq_km,
        COUNT(*) AS number_of_water_bodies,
        MAX(water_body_area_sq_km) AS largest_water_body_area_sq_km
    FROM
        island_water_bodies
    GROUP BY
        island_name
),
largest_water_bodies AS (
    SELECT DISTINCT ON (island_name)
        island_name,
        water_body_name AS largest_water_body_name,
        water_body_area_sq_km AS largest_water_body_area_sq_km
    FROM
        island_water_bodies
    ORDER BY
        island_name, water_body_area_sq_km DESC
)
SELECT
    s.island_name,
    s.total_water_body_area_sq_km,
    s.number_of_water_bodies,
    l.largest_water_body_name,
    l.largest_water_body_area_sq_km
FROM
    island_summary s
JOIN
    largest_water_bodies l ON s.island_name = l.island_name
ORDER BY
    total_water_body_area_sq_km DESC;