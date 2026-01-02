-- VIDEO DATA
DROP TABLE IF EXISTS New_video_2025;

CREATE TABLE New_video_2025 (
    dt VARCHAR(20),
    Raw_vid FLOAT
   
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New_video_2025.csv'
INTO TABLE New_video_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@dt, @Raw_vid)
SET
    Date_time = NULLIF(@dt, ''),
    Raw_Hs = NULLIF(@Raw_vid, '')
   
 ;
 
-- MODEL DATASETS
-- March 2025 data
DROP TABLE IF EXISTS New_synthetic_2025;

CREATE TABLE New_synthetic_2025 (
	dt VARCHAR(20),
    Hs FLOAT,
    S1_Hs FLOAT,
    S2_Hs FLOAT,
    Ws_Hs FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/New_synthetic_2025.csv'
INTO TABLE New_synthetic_2025
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@dt, @Hs, @S1_Hs, @S2_Hs, @Ws_Hs)
SET
    Date_time = NULLIF(@dt, ''),
    Hs = NULLIF(@Hs, ''),
    S1_Hs = NULLIF(@S1_Hs, ''),
    S2_Hs = NULLIF(@S2_Hs, ''),
    Ws_Hs = NULLIF(@Ws_Hs, '')
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



