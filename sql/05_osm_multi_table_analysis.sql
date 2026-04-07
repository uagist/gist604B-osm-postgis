-- Query 5: Multi-Table Analysis
-- Purpose: Summarize island infrastructure and water features in a single query

-- Requirements:
-- - Query places_a where fclass = 'island'
-- - Use CTEs (WITH clauses) to organize the analysis
-- - Join roads, waterways, and water_a to islands using ST_Intersects
-- - Use ST_Length(geom::geography) for accurate length calculations on WGS84
-- - Use ST_Area(geom::geography) for accurate area calculations on WGS84
-- - Convert meters to kilometers (divide by 1,000)
-- - Convert square meters to square kilometers (divide by 1,000,000)
-- - Calculate road density as total road length divided by island area
-- - Order results by road density (highest first)

-- Expected Output:
-- - island_name
-- - island_area_sq_km
-- - total_road_length_km
-- - total_waterway_length_km
-- - total_water_body_area_sq_km
-- - road_density_km_per_sq_km

WITH island_areas AS (
    SELECT
        name AS island_name,
        ST_Area(geom::geography) / 1000000 AS island_area_sq_km,
        geom
    FROM
        places_a
    WHERE
        fclass = 'island'
),
island_roads AS (
    SELECT
        p.island_name,
        SUM(ST_Length(r.geom::geography)) / 1000 AS total_road_length_km
    FROM
        island_areas AS p
    JOIN
        roads AS r ON ST_Intersects(p.geom, r.geom)
    GROUP BY
        p.island_name
),
island_waterways AS (
    SELECT
        p.island_name,
        SUM(ST_Length(w.geom::geography)) / 1000 AS total_waterway_length_km
    FROM
        island_areas AS p
    JOIN
        waterways AS w ON ST_Intersects(p.geom, w.geom)
    GROUP BY
        p.island_name
),
island_water_bodies AS (
    SELECT
        p.island_name,
        SUM(ST_Area(wb.geom::geography)) / 1000000 AS total_water_body_area_sq_km
    FROM
        island_areas AS p
    JOIN
        water_a AS wb ON ST_Intersects(p.geom, wb.geom)
    GROUP BY
        p.island_name
)
SELECT
    a.island_name,
    a.island_area_sq_km,
    COALESCE(r.total_road_length_km, 0) AS total_road_length_km,
    COALESCE(w.total_waterway_length_km, 0) AS total_waterway_length_km,
    COALESCE(wb.total_water_body_area_sq_km, 0) AS total_water_body_area_sq_km,
    CASE
        WHEN a.island_area_sq_km > 0 THEN
            COALESCE(r.total_road_length_km, 0) / a.island_area_sq_km
        ELSE 0
    END AS road_density_km_per_sq_km
FROM
    island_areas a
LEFT JOIN
    island_roads r ON a.island_name = r.island_name
LEFT JOIN
    island_waterways w ON a.island_name = w.island_name
LEFT JOIN
    island_water_bodies wb ON a.island_name = wb.island_name
ORDER BY
    road_density_km_per_sq_km DESC;