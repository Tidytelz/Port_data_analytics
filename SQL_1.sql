-- VIDEO DATA
DROP TABLE IF EXISTS New_video_2025;

CREATE TABLE New_video_2025 (
    dt VARCHAR(20),
    Raw_Hs FLOAT,
    Corrected_Hs FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New_video_2025.csv'
INTO TABLE New_video_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@Date_time, @Raw_Hs)
SET
    Date_time = NULLIF(@dt, ''),
    Raw_Hs = NULLIF(@Raw_Hs, '')
   
 ;
 
-- MODEL DATASETS
-- March 2025 data
DROP TABLE IF EXISTS New_synthetic_2025;

CREATE TABLE New_synthetic_2025 (
	Date_time VARCHAR(20),
    Hs_M1 FLOAT,
    Hs_M2 FLOAT,
    Hs_M3 FLOAT,
    Hs_M4 FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New_synthetic_2025.csv'
INTO TABLE New_synthetic_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@Date_time, @Hs_M1, @ Hs_M2, @Hs_M3, @Hs_M4)
SET
    Date_time = NULLIF(@dt, ''),
    Hs_M1 = NULLIF(@Hs, ''),
    Hs_M2 = NULLIF(@S1_Hs, ''),
    Hs_M3 = NULLIF(@S2_Hs, ''),
    Hs_M4 = NULLIF(@Ws_Hs, '')
 ;
 

-- Historic data
-- 2019-2024 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Wind_15_25.csv'
INTO TABLE wind_15_24
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@date_time, @WS)
SET
    Date_time = STR_TO_DATE(@date_time, '%Y %m %d %H %i'),
    WS = @WS
 ;



