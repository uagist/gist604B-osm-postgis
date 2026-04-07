-- Query 3: Waterway Analysis
-- Purpose: Analyze waterways by island (total length, count, and average length)

-- Requirements:
-- - Join waterways with places_a where fclass = 'island'
-- - Use ST_Intersects to match waterways to islands
-- - Use ST_Length(geom::geography) for accurate length on WGS84
-- - Convert meters to kilometers (divide by 1,000)
-- - Calculate total length, count, and average length of waterways
-- - Group by island
-- - Order results by total waterway length (largest first)

-- Expected Output:
-- - island_name
-- - total_waterway_length_km
-- - number_of_waterways
-- - avg_waterway_length_km

SELECT
    p.name AS island_name,
    SUM(ST_Length(w.geom::geography)) / 1000 AS total_waterway_length_km,
    COUNT(*) AS number_of_waterways,
    AVG(ST_Length(w.geom::geography)) / 1000 AS avg_waterway_length_km
FROM
    places_a AS p
JOIN
    waterways AS w ON ST_Intersects(p.geom, w.geom)
WHERE
    p.fclass = 'island'
GROUP BY
    p.name
ORDER BY
    total_waterway_length_km DESC;