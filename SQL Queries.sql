-- 1. Which nationalities have the most wins?
SELECT 
    d.nationality, 
    COUNT(*) AS total_wins
FROM results r
JOIN drivers d ON r.driverId = d.driverId
WHERE r.position = 1
GROUP BY d.nationality
ORDER BY total_wins DESC;

-- 2. Which nationalities have the most F1 drivers?
SELECT 
    d.nationality, 
    COUNT(*) AS drivers_count
FROM drivers d
GROUP BY d.nationality
ORDER BY drivers_count DESC;

-- 3. What age do F1 drivers have the most wins?
SELECT 
    YEAR(ra.date) - YEAR(d.dob) AS age, 
    COUNT(r.raceId) AS wins
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.position = 1
GROUP BY age
ORDER BY wins DESC;

-- 4. What season in their career do F1 drivers have the most wins?
WITH first_season AS (
    SELECT 
        re.driverId, 
        dr.forename, 
        ra.year AS season1
    FROM (
        SELECT 
            re.driverId, 
            re.raceId, 
            re.position, 
            ra.year, 
            ROW_NUMBER() OVER (PARTITION BY re.driverId ORDER BY ra.year) AS row_num
        FROM results re
        JOIN races ra ON re.raceId = ra.raceId
    ) AS re
    JOIN races ra ON re.raceId = ra.raceId
    JOIN drivers dr ON re.driverId = dr.driverId
    WHERE re.row_num = 1
),
winners AS (
    SELECT 
        re.driverId, 
        ra.year AS won_year
    FROM results re
    JOIN races ra ON re.raceId = ra.raceId
    WHERE re.position = 1
)
SELECT 
    wi.won_year - fs.season1 AS season_in_f1, 
    COUNT(*) AS total_wins
FROM first_season fs
JOIN winners wi ON fs.driverId = wi.driverId
GROUP BY season_in_f1
ORDER BY total_wins DESC;

-- 5. Which country has hosted the most races?
SELECT 
    c.country, 
    COUNT(*) AS races
FROM circuits c
JOIN races r ON c.circuitId = r.circuitId
GROUP BY c.country
ORDER BY races DESC;
