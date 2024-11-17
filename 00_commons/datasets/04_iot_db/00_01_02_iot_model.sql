/*------------------------------------------------------------------------------
  Snowflake Demo Script: IoT Data Model for Predictive Maintenance
  
  Description: 
  This script sets up an IoT data model in Snowflake, loads data from an
  external stage, and prepares the environment for future predictive 
  maintenance demos. The model enables:
  - Predictive maintenance analysis
  - Equipment failure forecasting
  - Sensor data trend analysis
  - Performance monitoring
  
  Author: DemoHub Labs, All rights reserved.
  Website: DemoHub.dev
  Date: May 28, 2024
  Version: 1.2.7
  
  Copyright: (c) 2024 DemoHub.dev. All rights reserved.
------------------------------------------------------------------------------*/

--==============================================================================
-- 1. DATABASE AND SCHEMA SETUP
--==============================================================================
CREATE OR REPLACE DATABASE iot_db;
USE iot_db.public;

--==============================================================================
-- 2. CREATE FILE FORMAT
--==============================================================================
-- File format: Defines structure for ingesting IoT sensor data from CSV files
CREATE OR REPLACE FILE FORMAT csv_format
    TYPE = CSV
    PARSE_HEADER = TRUE
    SKIP_BLANK_LINES = TRUE
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

--==============================================================================
-- 3. CREATE STAGE
--==============================================================================
-- Stage: Links to external S3 bucket containing sensor data files
CREATE OR REPLACE STAGE demohub_s3_int 
    URL = 's3://demohubpublic/data/'
    DIRECTORY = ( ENABLE = true )
    COMMENT = 'DemoHub S3 datasets';

--==============================================================================
-- 4. CREATE TABLE USING SCHEMA INFERENCE
--==============================================================================
-- Create and populate the table using schema inference from staged files
CREATE OR REPLACE TABLE sensor_data USING TEMPLATE (
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE (
        INFER_SCHEMA(
            LOCATION=>'@demohub_s3_int/iot/sensor_data/',
            FILE_FORMAT=>'csv_format'
        )
    )
);

--==============================================================================
-- 5. LOAD DATA FROM STAGE
--==============================================================================
-- Load the actual sensor data from the stage into the table
COPY INTO sensor_data 
FROM '@demohub_s3_int/iot/sensor_data/'
FILE_FORMAT = 'csv_format'
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

--==============================================================================
-- 6. ADD COLUMN COMMENTS
--==============================================================================
-- Equipment identification
ALTER TABLE sensor_data MODIFY COLUMN unit_number 
    SET COMMENT 'Unique identifier for the equipment unit';
ALTER TABLE sensor_data MODIFY COLUMN time_in_cycles 
    SET COMMENT 'Operating time of the unit in cycles';

-- Operational settings
ALTER TABLE sensor_data MODIFY COLUMN setting_1 
    SET COMMENT 'Operating setting 1 (e.g., temperature)';
ALTER TABLE sensor_data MODIFY COLUMN setting_2 
    SET COMMENT 'Operating setting 2 (e.g., pressure)';
ALTER TABLE sensor_data MODIFY COLUMN TRA 
    SET COMMENT 'Sensor reading: Total runs to alarm';

-- Temperature sensors
ALTER TABLE sensor_data MODIFY COLUMN T2 
    SET COMMENT 'Sensor reading: Temperature at sensor 2';
ALTER TABLE sensor_data MODIFY COLUMN T24 
    SET COMMENT 'Sensor reading: Temperature at sensor 24';
ALTER TABLE sensor_data MODIFY COLUMN T30 
    SET COMMENT 'Sensor reading: Temperature at sensor 30';
ALTER TABLE sensor_data MODIFY COLUMN T50 
    SET COMMENT 'Sensor reading: Temperature at sensor 50';

-- Pressure sensors
ALTER TABLE sensor_data MODIFY COLUMN P2 
    SET COMMENT 'Sensor reading: Pressure at sensor 2';
ALTER TABLE sensor_data MODIFY COLUMN P15 
    SET COMMENT 'Sensor reading: Pressure at sensor 15';
ALTER TABLE sensor_data MODIFY COLUMN P30 
    SET COMMENT 'Sensor reading: Pressure at sensor 30';

-- Speed and efficiency metrics
ALTER TABLE sensor_data MODIFY COLUMN Nf 
    SET COMMENT 'Sensor reading: Fan speed';
ALTER TABLE sensor_data MODIFY COLUMN Nc 
    SET COMMENT 'Sensor reading: Core speed';
ALTER TABLE sensor_data MODIFY COLUMN epr 
    SET COMMENT 'Sensor reading: Engine pressure ratio';
ALTER TABLE sensor_data MODIFY COLUMN Ps30 
    SET COMMENT 'Sensor reading: Static pressure at stage 30';
ALTER TABLE sensor_data MODIFY COLUMN phi 
    SET COMMENT 'Sensor reading: Physical fan speed';
ALTER TABLE sensor_data MODIFY COLUMN NRf 
    SET COMMENT 'Sensor reading: Fan efficiency';
ALTER TABLE sensor_data MODIFY COLUMN NRc 
    SET COMMENT 'Sensor reading: Core efficiency';

-- Performance ratios
ALTER TABLE sensor_data MODIFY COLUMN BPR 
    SET COMMENT 'Sensor reading: Bypass ratio';
ALTER TABLE sensor_data MODIFY COLUMN farB 
    SET COMMENT 'Sensor reading: Burner fuel-air ratio';
ALTER TABLE sensor_data MODIFY COLUMN htBleed 
    SET COMMENT 'Sensor reading: High-pressure turbine bleed';

-- Demand metrics
ALTER TABLE sensor_data MODIFY COLUMN Nf_dmd 
    SET COMMENT 'Sensor reading: Demanded fan speed';
ALTER TABLE sensor_data MODIFY COLUMN PCNfR_dmd 
    SET COMMENT 'Sensor reading: Demanded corrected fan speed';

-- Coolant readings
ALTER TABLE sensor_data MODIFY COLUMN W31 
    SET COMMENT 'Sensor reading: HPT coolant bleed';
ALTER TABLE sensor_data MODIFY COLUMN W32 
    SET COMMENT 'Sensor reading: LPT coolant bleed';

--==============================================================================
-- 7. CREATE VIEWS FOR ANALYSIS
--==============================================================================
-- View: Latest readings for active monitoring
CREATE OR REPLACE VIEW v_latest_readings AS
SELECT 
    unit_number,
    time_in_cycles,
    T2, T24, T30, T50,  -- Temperature readings
    P2, P15, P30,       -- Pressure readings
    Nf, Nc,             -- Speed readings
    created_at
FROM sensor_data
QUALIFY ROW_NUMBER() OVER (PARTITION BY unit_number ORDER BY time_in_cycles DESC) = 1;

-- View: Equipment performance metrics
CREATE OR REPLACE VIEW v_performance_metrics AS
SELECT 
    unit_number,
    AVG(Nf) as avg_fan_speed,
    AVG(Nc) as avg_core_speed,
    MAX(T50) as max_temperature,
    MAX(P30) as max_pressure,
    COUNT(*) as total_readings
FROM sensor_data
GROUP BY unit_number;

--==============================================================================
-- 8. CREATE FUNCTIONS
--==============================================================================
-- Function: Calculate time since last maintenance
CREATE OR REPLACE FUNCTION f_time_since_maintenance(unit_id INT)
RETURNS INT
LANGUAGE SQL
AS
$$
    SELECT MAX(time_in_cycles)
    FROM sensor_data
    WHERE unit_number = unit_id
$$;

-- Function: Get average readings for specific sensor
CREATE OR REPLACE FUNCTION f_get_sensor_average(unit_id INT, cycles_back INT)
RETURNS OBJECT
LANGUAGE SQL
AS
$$
    SELECT OBJECT_CONSTRUCT(
        'avg_temp', AVG(T50),
        'avg_pressure', AVG(P30),
        'avg_fan_speed', AVG(Nf)
    )
    FROM sensor_data
    WHERE unit_number = unit_id
    AND time_in_cycles >= (SELECT MAX(time_in_cycles) - cycles_back 
                          FROM sensor_data 
                          WHERE unit_number = unit_id)
$$;

/*------------------------------------------------------------------------------
  Usage Examples:
  
  1. Monitor current equipment status:
     SELECT * FROM v_latest_readings WHERE unit_number = 1;
  
  2. Analyze performance trends:
     SELECT * FROM v_performance_metrics ORDER BY avg_fan_speed DESC;
  
  3. Check maintenance timing:
     SELECT f_time_since_maintenance(1) as cycles_since_maintenance;
  
  4. Get recent averages:
     SELECT f_get_sensor_average(1, 100) as recent_averages;

  Analysis Capabilities:
  - Trend Analysis: Identify patterns in sensor data over time
  - Feature Engineering: Create derived metrics from raw sensor data
  - Machine Learning: Train predictive models for failure forecasting
  - Root Cause Analysis: Investigate historical patterns leading to failures
  
  Reset Instructions:
  USE ROLE ACCOUNTADMIN;
  DROP DATABASE IF EXISTS iot_db CASCADE;
------------------------------------------------------------------------------*/ 