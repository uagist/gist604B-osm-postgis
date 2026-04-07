-- Query 2: Road Network Analysis
-- Purpose: Calculate total road length per island

-- Requirements:
-- - Join roads with places_a where fclass = 'island'
-- - Use ST_Intersects to match roads to islands
-- - Use ST_Length(geom::geography) for accurate road lengths on WGS84
-- - Convert meters to kilometers (divide by 1,000)
-- - Use ST_Area(geom::geography) to calculate island area
-- - Convert square meters to square kilometers (divide by 1,000,000)
-- - Group by island
-- - Order results by total road length (largest first)

-- Expected Output:
-- - island_name
-- - total_road_length_km
-- - island_area_sq_km

SELECT
    p.name AS island_name,
    SUM(ST_Length(r.geom::geography)) / 1000 AS total_road_length_km,
    ST_Area(p.geom::geography) / 1000000 AS island_area_sq_km
FROM
    places_a AS p
JOIN
    roads AS r ON ST_Intersects(p.geom, r.geom)
WHERE
    p.fclass = 'island'
GROUP BY
    p.name, p.geom
ORDER BY
    total_road_length_km DESC;