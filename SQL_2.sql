-- ============================================================================
-- DATA INTEGRATION AND ANALYSIS PREPARATION
-- Port of Sines, Portugal - Wave Height Validation System
-- ============================================================================
-- Purpose: Integrate video, model, and wind data for validation analysis
-- Creates analysis-ready tables and aggregated metrics
-- Dependencies: Requires SQL_1.sql to be run first
-- ============================================================================


-- ============================================================================
-- PART 1: INTEGRATED VALIDATION DATASET
-- ============================================================================
-- Description: Combines video-derived measurements with all model outputs
--              for comparative analysis
-- Output: Unified table with Hs_vid compared against each model variant
-- Structure: Long format (one row per model comparison per timestamp)
-- ============================================================================

DROP TABLE IF EXISTS validation_comparison;

CREATE TABLE validation_comparison AS
SELECT 
    v.date_time,
    v.hs_video AS hs_vid,
    m.hs_m1 AS hs_model,
    'Hs_M1' AS model_type,
    m.wind_speed AS wind_speed
FROM video_measurements v
INNER JOIN wave_model_data m 
    ON DATE_FORMAT(v.date_time, '%Y-%m-%d %H:%i') = DATE_FORMAT(m.date_time, '%Y-%m-%d %H:%i')

UNION ALL

SELECT 
    v.date_time,
    v.hs_video AS hs_vid,
    m.hs_m2 AS hs_model,
    'Hs_M2' AS model_type,
    m.wind_speed AS wind_speed
FROM video_measurements v
INNER JOIN wave_model_data m 
    ON DATE_FORMAT(v.date_time, '%Y-%m-%d %H:%i') = DATE_FORMAT(m.date_time, '%Y-%m-%d %H:%i')

UNION ALL

SELECT 
    v.date_time,
    v.hs_video AS hs_vid,
    m.hs_m3 AS hs_model,
    'Hs_M3' AS model_type,
    m.wind_speed AS wind_speed
FROM video_measurements v
INNER JOIN wave_model_data m 
    ON DATE_FORMAT(v.date_time, '%Y-%m-%d %H:%i') = DATE_FORMAT(m.date_time, '%Y-%m-%d %H:%i')

ORDER BY date_time, model_type;

-- Add index for faster filtering
ALTER TABLE validation_comparison 
ADD INDEX idx_model_type (model_type),
ADD INDEX idx_datetime (date_time);

-- Verification
SELECT 
    'validation_comparison' AS table_name,
    COUNT(*) AS total_records,
    COUNT(DISTINCT date_time) AS unique_timestamps,
    COUNT(DISTINCT model_type) AS model_variants
FROM validation_comparison;


-- ============================================================================
-- PART 2: OPERATIONAL AVAILABILITY ANALYSIS
-- ============================================================================
-- Description: Calculates percentage of favorable wind conditions (<7 m/s)
--              by year and month for operational feasibility assessment
-- Period: 2015-2024 (10 years)
-- Threshold: Wind speed < 7 m/s (above this, whitecaps affect measurements)
-- ============================================================================

DROP TABLE IF EXISTS operational_availability;

CREATE TABLE operational_availability AS
WITH favorable_conditions AS (
    SELECT 
        year,
        month,
        COUNT(*) AS favorable_hours
    FROM wind_historical
    WHERE is_favorable = TRUE  -- wind_speed < 7 m/s
    GROUP BY year, month
),
total_hours AS (
    SELECT 
        year,
        month,
        COUNT(*) AS total_hours
    FROM wind_historical
    GROUP BY year, month
)
SELECT 
    t.year,
    t.month,
    COALESCE(f.favorable_hours, 0) AS favorable_hours,
    t.total_hours,
    ROUND(COALESCE(f.favorable_hours, 0) / t.total_hours * 100, 2) AS availability_percentage,
    -- Convert to approximate days (assuming ~730 hours per month)
    ROUND(COALESCE(f.favorable_hours, 0) / 24, 1) AS favorable_days_approx
FROM total_hours t
LEFT JOIN favorable_conditions f 
    ON t.year = f.year AND t.month = f.month
ORDER BY t.year, t.month;

-- Add indexes
ALTER TABLE operational_availability
ADD INDEX idx_year (year),
ADD INDEX idx_month (month);

-- Verification
SELECT 
    'operational_availability' AS table_name,
    COUNT(*) AS total_records,
    MIN(year) AS earliest_year,
    MAX(year) AS latest_year
FROM operational_availability;


-- ============================================================================
-- PART 3: ANNUAL OPERATIONAL SUMMARY
-- ============================================================================
-- Description: Yearly aggregation of operational availability
-- Purpose: Long-term feasibility assessment for deployment planning
-- ============================================================================

DROP TABLE IF EXISTS annual_availability_summary;

CREATE TABLE annual_availability_summary AS
SELECT 
    year,
    SUM(favorable_hours) AS total_favorable_hours,
    SUM(total_hours) AS total_hours_in_year,
    ROUND(SUM(favorable_hours) / SUM(total_hours) * 100, 2) AS annual_availability_pct,
    ROUND(SUM(favorable_hours) / 24, 0) AS favorable_days_per_year,
    -- Total possible days (accounting for leap years)
    ROUND(SUM(total_hours) / 24, 0) AS total_days_in_year
FROM operational_availability
GROUP BY year
ORDER BY year;

-- Verification
SELECT * FROM annual_availability_summary ORDER BY year;


-- ============================================================================
-- PART 4: VALIDATION METRICS CALCULATION
-- ============================================================================
-- Description: Pre-calculate key statistical metrics for Power BI
-- Metrics: MAPE, MAE, RMSE, R² for each model comparison
-- ============================================================================

DROP TABLE IF EXISTS validation_metrics;

CREATE TABLE validation_metrics AS
SELECT 
    model_type,
    COUNT(*) AS n_measurements,
    
    -- Mean Absolute Percentage Error (MAPE)
    ROUND(AVG(ABS((hs_model - hs_vid) / hs_model)) * 100, 2) AS mape_percentage,
    
    -- Mean Absolute Error (MAE)
    ROUND(AVG(ABS(hs_model - hs_vid)), 3) AS mae_meters,
    
    -- Root Mean Square Error (RMSE)
    ROUND(SQRT(AVG(POWER(hs_model - hs_vid, 2))), 3) AS rmse_meters,
    
    -- Mean values
    ROUND(AVG(hs_vid), 3) AS mean_hs_vid,
    ROUND(AVG(hs_model), 3) AS mean_hs_model,
    
    -- Standard deviations
    ROUND(STDDEV(hs_vid), 3) AS stddev_hs_vid,
    ROUND(STDDEV(hs_model), 3) AS stddev_hs_model,
    
    -- Min/Max ranges
    ROUND(MIN(hs_vid), 3) AS min_hs_vid,
    ROUND(MAX(hs_vid), 3) AS max_hs_vid,
    ROUND(MIN(hs_model), 3) AS min_hs_model,
    ROUND(MAX(hs_model), 3) AS max_hs_model

FROM validation_comparison
WHERE hs_vid IS NOT NULL AND hs_model IS NOT NULL
GROUP BY model_type
ORDER BY mape_percentage;

-- Display results
SELECT * FROM validation_metrics;


-- ============================================================================
-- PART 5: WIND-WAVE CORRELATION ANALYSIS
-- ============================================================================
-- Description: Analyze relationship between wind speed and wave height
-- Purpose: Understand wind influence on video measurement accuracy
-- ============================================================================

DROP TABLE IF EXISTS wind_wave_analysis;

CREATE TABLE wind_wave_analysis AS
SELECT 
    model_type,
    CASE 
        WHEN wind_speed < 5 THEN '0-5 m/s (Calm)'
        WHEN wind_speed < 7 THEN '5-7 m/s (Moderate)'
        WHEN wind_speed < 10 THEN '7-10 m/s (Rough)'
        ELSE '>10 m/s (Very Rough)'
    END AS wind_category,
    COUNT(*) AS n_measurements,
    ROUND(AVG(hs_vid), 3) AS avg_hs_vid,
    ROUND(AVG(hs_model), 3) AS avg_hs_model,
    ROUND(AVG(ABS((hs_model - hs_vid) / hs_model)) * 100, 2) AS mape_percentage,
    ROUND(AVG(wind_speed), 2) AS avg_wind_speed
FROM validation_comparison
WHERE hs_vid IS NOT NULL AND hs_model IS NOT NULL AND wind_speed IS NOT NULL
GROUP BY model_type, wind_category
ORDER BY model_type, avg_wind_speed;

-- Display results
SELECT * FROM wind_wave_analysis;


-- ============================================================================
-- DATA QUALITY CHECKS
-- ============================================================================

-- Check 1: Verify join success rate
SELECT 
    'Video-Model Join Success Rate' AS check_type,
    CONCAT(
        ROUND(
            (SELECT COUNT(*) FROM validation_comparison) / 
            (SELECT COUNT(*) FROM video_measurements) * 100, 
            2
        ), 
        '%'
    ) AS success_rate;

-- Check 2: Identify any missing data patterns
SELECT 
    model_type,
    SUM(CASE WHEN hs_vid IS NULL THEN 1 ELSE 0 END) AS null_hs_vid,
    SUM(CASE WHEN hs_model IS NULL THEN 1 ELSE 0 END) AS null_hs_model,
    SUM(CASE WHEN wind_speed IS NULL THEN 1 ELSE 0 END) AS null_wind_speed
FROM validation_comparison
GROUP BY model_type;

-- Check 3: Verify no duplicate timestamps per model
SELECT 
    model_type,
    date_time,
    COUNT(*) AS duplicate_count
FROM validation_comparison
GROUP BY model_type, date_time
HAVING COUNT(*) > 1;

-- Check 4: Operational availability range check
SELECT 
    MIN(availability_percentage) AS min_availability_pct,
    MAX(availability_percentage) AS max_availability_pct,
    ROUND(AVG(availability_percentage), 2) AS avg_availability_pct
FROM operational_availability;


-- ============================================================================
-- EXPORT-READY VIEWS FOR POWER BI
-- ============================================================================

-- View 1: All validation data (for detailed analysis)
CREATE OR REPLACE VIEW vw_all_validation_data AS
SELECT * FROM validation_comparison;

-- View 2: Monthly availability (for trend analysis)
CREATE OR REPLACE VIEW vw_monthly_availability AS
SELECT * FROM operational_availability;

-- View 3: Annual summary (for long-term planning)
CREATE OR REPLACE VIEW vw_annual_summary AS
SELECT * FROM annual_availability_summary;

-- View 4: Model performance metrics (for comparison)
CREATE OR REPLACE VIEW vw_model_metrics AS
SELECT * FROM validation_metrics;

-- View 5: Wind-wave relationship (for correlation analysis)
CREATE OR REPLACE VIEW vw_wind_wave_correlation AS
SELECT * FROM wind_wave_analysis;


-- ============================================================================
-- SUMMARY STATISTICS FOR DOCUMENTATION
-- ============================================================================

SELECT '=== VALIDATION DATASET SUMMARY ===' AS info;
SELECT 
    COUNT(DISTINCT date_time) AS unique_timestamps,
    COUNT(*) AS total_comparisons,
    COUNT(DISTINCT model_type) AS model_variants,
    MIN(date_time) AS earliest_measurement,
    MAX(date_time) AS latest_measurement
FROM validation_comparison;

SELECT '=== OPERATIONAL AVAILABILITY SUMMARY ===' AS info;
SELECT 
    COUNT(DISTINCT year) AS years_analyzed,
    ROUND(AVG(availability_percentage), 2) AS avg_annual_availability_pct,
    ROUND(MIN(availability_percentage), 2) AS worst_year_pct,
    ROUND(MAX(availability_percentage), 2) AS best_year_pct
FROM annual_availability_summary;

SELECT '=== MODEL PERFORMANCE SUMMARY ===' AS info;
SELECT 
    model_type,
    mape_percentage,
    rmse_meters,
    n_measurements
FROM validation_metrics
ORDER BY mape_percentage;


-- ============================================================================
-- END OF DATA INTEGRATION AND ANALYSIS PREPARATION
-- ============================================================================
-- Tables created:
--   1. validation_comparison         - Integrated video-model comparisons
--   2. operational_availability      - Monthly wind availability (2015-2024)
--   3. annual_availability_summary   - Yearly operational feasibility
--   4. validation_metrics            - Statistical performance by model
--   5. wind_wave_analysis           - Wind-wave correlation patterns
--
-- Views created (for Power BI):
--   1. vw_all_validation_data
--   2. vw_monthly_availability
--   3. vw_annual_summary
--   4. vw_model_metrics
--   5. vw_wind_wave_correlation
--
-- Next steps:
--   1. Import views into Power BI
--   2. Apply DAX measures from DAX.txt
--   3. Create validation dashboard visualizations
-- ============================================================================
