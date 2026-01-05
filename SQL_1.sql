-- ============================================================================
-- DATABASE SETUP: WAVE HEIGHT VALIDATION SYSTEM
-- Port of Sines, Portugal - Video-Based Wave Measurement
-- ============================================================================
-- Purpose: Initialize database tables and load validation datasets
-- Data Sources:
--   1. Video-derived measurements (March 2025)
--   2. Numerical wave models (March 2025)
--   3. Historical wind data (2015-2024)
-- ============================================================================


-- ============================================================================
-- TABLE 1: VIDEO-DERIVED WAVE MEASUREMENTS
-- ============================================================================
-- Description: Wave heights extracted from video footage
-- Period: March 2024
-- Records: ~300 measurements
-- Source: New_video_2025.csv
-- ============================================================================

DROP TABLE IF EXISTS video_measurements;

CREATE TABLE video_measurements (
    measurement_id INT AUTO_INCREMENT PRIMARY KEY,
    date_time DATETIME NOT NULL,
    hs_video FLOAT NOT NULL COMMENT 'Video-derived significant wave height (m)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_datetime (date_time)
) COMMENT = 'Video-based wave height measurements from fixed camera installation';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New_video_2025.csv'
INTO TABLE video_measurements
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@dt, @hs_video)
SET
    date_time = STR_TO_DATE(@dt, '%Y-%m-%d %H:%i:%s'),
    hs_video = NULLIF(@hs_video, '');


-- ============================================================================
-- TABLE 2: NUMERICAL WAVE MODEL OUTPUTS
-- ============================================================================
-- Description: Wave height predictions from SIMAR-44 models
-- Period: March 2025
-- Records: ~300 hourly predictions
-- Source: New_synthetic_2025.csv
-- Models: Hs_M1, Hs_M2, Hs_M3 (different model configurations)
-- ============================================================================

DROP TABLE IF EXISTS wave_model_data;

CREATE TABLE wave_model_data (
    model_id INT AUTO_INCREMENT PRIMARY KEY,
    date_time DATETIME NOT NULL,
    hs_m1 FLOAT NOT NULL COMMENT 'Model 1 significant wave height (m)',
    hs_m2 FLOAT NOT NULL COMMENT 'Model 2 significant wave height (m)',
    hs_m3 FLOAT NOT NULL COMMENT 'Model 3 significant wave height (m)',
    wind_speed FLOAT COMMENT 'Concurrent wind speed (m/s)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_datetime (date_time)
) COMMENT = 'SIMAR-44 numerical wave model predictions';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New_synthetic_2025.csv'
INTO TABLE wave_model_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@dt, @hs_m1, @hs_m2, @hs_m3, @wind_speed)
SET
    date_time = STR_TO_DATE(@dt, '%Y-%m-%d %H:%i:%s'),
    hs_m1 = NULLIF(@hs_m1, ''),
    hs_m2 = NULLIF(@hs_m2, ''),
    hs_m3 = NULLIF(@hs_m3, ''),
    wind_speed = NULLIF(@wind_speed, '');


-- ============================================================================
-- TABLE 3: HISTORICAL WIND DATA
-- ============================================================================
-- Description: Hourly wind speed measurements for operational analysis
-- Period: 2015-2024 (10 years)
-- Records: 359,712 hourly measurements
-- Source: Wind_15_25.csv
-- Purpose: Determine long-term operational availability (WS < 7 m/s threshold)
-- ============================================================================

DROP TABLE IF EXISTS wind_historical;

CREATE TABLE wind_historical (
    wind_id INT AUTO_INCREMENT PRIMARY KEY,
    date_time DATETIME NOT NULL,
    wind_speed FLOAT NOT NULL COMMENT 'Wind speed (m/s)',
    year INT GENERATED ALWAYS AS (YEAR(date_time)) STORED,
    month INT GENERATED ALWAYS AS (MONTH(date_time)) STORED,
    is_favorable BOOLEAN GENERATED ALWAYS AS (wind_speed < 7) STORED COMMENT 'Favorable for measurement (WS < 7 m/s)',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_datetime (date_time),
    INDEX idx_year (year),
    INDEX idx_favorable (is_favorable)
) COMMENT = 'Historical wind data (2015-2024) for operational feasibility analysis';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Wind_15_25.csv'
INTO TABLE wind_historical
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@date_time, @wind_speed)
SET
    date_time = STR_TO_DATE(@date_time, '%Y %m %d %H %i'),
    wind_speed = NULLIF(@wind_speed, '');


-- ============================================================================
-- DATA QUALITY CHECKS
-- ============================================================================

-- Check record counts
SELECT 'video_measurements' AS table_name, COUNT(*) AS record_count FROM video_measurements
UNION ALL
SELECT 'wave_model_data' AS table_name, COUNT(*) AS record_count FROM wave_model_data
UNION ALL
SELECT 'wind_historical' AS table_name, COUNT(*) AS record_count FROM wind_historical;

-- Check for NULL values
SELECT 
    'video_measurements' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN hs_video IS NULL THEN 1 ELSE 0 END) AS null_hs_video
FROM video_measurements

UNION ALL

SELECT 
    'wave_model_data' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN hs_m1 IS NULL OR hs_m2 IS NULL OR hs_m3 IS NULL THEN 1 ELSE 0 END) AS null_wave_heights
FROM wave_model_data

UNION ALL

SELECT 
    'wind_historical' AS table_name,
    COUNT(*) AS total_records,
    SUM(CASE WHEN wind_speed IS NULL THEN 1 ELSE 0 END) AS null_wind_speed
FROM wind_historical;

-- Check date ranges
SELECT 
    'video_measurements' AS table_name,
    MIN(date_time) AS earliest_record,
    MAX(date_time) AS latest_record,
    DATEDIFF(MAX(date_time), MIN(date_time)) AS days_covered
FROM video_measurements

UNION ALL

SELECT 
    'wave_model_data' AS table_name,
    MIN(date_time) AS earliest_record,
    MAX(date_time) AS latest_record,
    DATEDIFF(MAX(date_time), MIN(date_time)) AS days_covered
FROM wave_model_data

UNION ALL

SELECT 
    'wind_historical' AS table_name,
    MIN(date_time) AS earliest_record,
    MAX(date_time) AS latest_record,
    DATEDIFF(MAX(date_time), MIN(date_time)) AS days_covered
FROM wind_historical;


-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Sample records from each table
SELECT 'Video Measurements Sample:' AS info;
SELECT * FROM video_measurements ORDER BY date_time LIMIT 5;

SELECT 'Wave Model Data Sample:' AS info;
SELECT * FROM wave_model_data ORDER BY date_time LIMIT 5;

SELECT 'Wind Historical Data Sample:' AS info;
SELECT * FROM wind_historical ORDER BY date_time LIMIT 5;


-- ============================================================================
-- END OF DATABASE SETUP
-- ============================================================================
-- Next step: Run SQL_2.sql for data integration and analysis tables
-- ============================================================================
