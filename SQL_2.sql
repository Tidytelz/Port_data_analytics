-- Video- and model-derived wave data ingestion (2025)
-- Extraction and temporal alignment of significant wave height estimates

SELECT 
    vd.dt AS Date_time,
    vd.Raw_Hs AS Hs_vid,
    sd.Hs AS Hs,
    'Hs_M1' AS category,
    w.vel AS WS
FROM New_video_2025 AS vd
JOIN New_synthetic_2025 AS sd ON TRIM(sd.dt) = TRIM(vd.dt)
JOIN new_wind_2025 AS w ON TRIM(w.dt) = TRIM(vd.dt)

UNION ALL

SELECT 
    vd.dt AS Date_time,
    vd.Raw_Hs AS Hs_vid,
    sd.S1_Hs AS Hs,
    'Hs_M2' AS category,
    w.vel AS WS
FROM New_video_2025 AS vd
JOIN New_synthetic_2025 AS sd ON TRIM(sd.dt) = TRIM(vd.dt)
JOIN new_wind_2025 AS w ON TRIM(w.dt) = TRIM(vd.dt)

UNION ALL

SELECT 
    vd.dt AS Date_time,
    vd.Raw_Hs AS Hs_vid,
    sd.S2_Hs AS Hs,
    'Hs_M3' AS category,
    w.vel AS WS
FROM New_video_2025 AS vd
JOIN New_synthetic_2025 AS sd ON TRIM(sd.dt) = TRIM(vd.dt)
JOIN new_wind_2025 AS w ON TRIM(w.dt) = TRIM(vd.dt)

UNION ALL

SELECT 
    vd.dt AS Date_time,
    vd.Raw_Hs AS Hs_vid,
    sd.Ws_Hs AS Hs,
    'Hs_M4' AS category,
    w.vel AS WS
FROM New_video_2025 AS vd
JOIN New_synthetic_2025 AS sd ON TRIM(sd.dt) = TRIM(vd.dt)
JOIN new_wind_2025 AS w ON TRIM(w.dt) = TRIM(vd.dt)

ORDER BY Date_time, category;



-- Historical wind speed data processing (2015–2024)
-- Filtering wind speed values below 7 m/s
-- Computation of occurrence percentage

WITH LowWind AS (
    SELECT 
        MONTH(date_time) AS mnth,
        COUNT(*) AS low_wind_count
    FROM wind_15_25
    WHERE WS < 7
    GROUP BY  MONTH(date_time)
),
TotalMonth AS (
    SELECT 
        MONTH(date_time) AS mnth,
     
        COUNT(*) AS total_count
    FROM wind_15_25
    GROUP BY MONTH(date_time)
)
SELECT 
   
    t.mnth,
    COALESCE(l.low_wind_count, 0) AS low_wind_count,
    t.total_count,
    ROUND(COALESCE(l.low_wind_count, 0) / t.total_count * 100, 2) AS percentage
FROM TotalMonth t
LEFT JOIN LowWind l ON  t.mnth = l.mnth
ORDER BY t.mnth;
