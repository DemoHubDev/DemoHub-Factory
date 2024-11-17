/*------------------------------------------------------------------------------
  Data Quality Metrics and Functions (DQM/DMF) Demo
  ------------------------------------------------------------------------------
  This demo showcases Snowflake's Data Metric Functions (DMFs) and Data Quality 
  Metrics (DQMs) for automating data quality monitoring.

  DMFs come in two types:
  1. System DMFs: Built-in functions for common data quality checks
     - NULL_COUNT: Detect missing values
     - UNIQUE_COUNT: Measure cardinality
     - DUPLICATE_COUNT: Identify duplicates
     - FRESHNESS: Assess data recency

  2. Custom DMFs: User-defined functions for specific business requirements
     - Email format validation
     - Data range validation
     - Complex integrity constraints

  Sample Data Model: salesdb-data-model
  Known Data Quality Issues:
  - Customer Table:
    * Missing FirstName
    * Missing HomeLocation
    * Missing ZipCode
    * Duplicate Email
    * Invalid Email
    * Stale LoadDate
  
  - Opportunities Table:
    * Missing CustomerID
    * Missing ExpectedCloseDate
    * Missing Amount
    * Negative Amount
    * Duplicate Opportunity
    * Invalid SalesStage
    * Stale LoadDate
------------------------------------------------------------------------------*/

--==============================================================================
-- 1. Role-Based Access Control (RBAC) Setup
--==============================================================================
USE ROLE ACCOUNTADMIN;
ALTER SESSION SET TIMEZONE = 'America/Chicago';

-- Grant necessary permissions to data_engineer role
GRANT DATABASE ROLE SNOWFLAKE.DATA_METRIC_USER TO ROLE data_engineer;
GRANT DATABASE ROLE SNOWFLAKE.USAGE_VIEWER TO ROLE data_engineer;
GRANT EXECUTE DATA METRIC FUNCTION ON ACCOUNT TO ROLE data_engineer;

--==============================================================================
-- 2. Testing System DMFs
--==============================================================================
-- Direct execution of built-in DMFs
SELECT SNOWFLAKE.CORE.NULL_COUNT(SELECT firstname FROM customer);
SELECT SNOWFLAKE.CORE.UNIQUE_COUNT(SELECT firstname FROM customer);
SELECT SNOWFLAKE.CORE.DUPLICATE_COUNT(SELECT email FROM customer);
SELECT SNOWFLAKE.CORE.FRESHNESS(SELECT loaddate FROM customer) / 60 AS freshness_minutes;

--==============================================================================
-- 3. Creating Custom DMFs
--==============================================================================

-- Custom DMF: Data Freshness (in hours)
-- Measures time difference between latest data and current time
CREATE OR REPLACE DATA METRIC FUNCTION data_freshness_hour(ARG_T TABLE (ARG_C TIMESTAMP_LTZ))
RETURNS NUMBER AS
'SELECT TIMEDIFF(minute, MAX(ARG_C), SNOWFLAKE.CORE.DATA_METRIC_SCHEDULED_TIME()) FROM ARG_T';

-- Custom DMF: Invalid Email Counter
-- Uses regex to validate email format
CREATE OR REPLACE DATA METRIC FUNCTION invalid_email_count(arg_t TABLE(arg_c1 VARCHAR))
RETURNS NUMBER
AS
$$
 SELECT COUNT(*) AS invalid_email_count
  FROM arg_t
 WHERE NOT REGEXP_LIKE(arg_c1, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
$$;

-- Custom DMF: Invalid Sales Stage Counter
-- Validates against predefined list of valid stages
CREATE OR REPLACE DATA METRIC FUNCTION invalid_stage_count(arg_t TABLE(arg_c1 VARCHAR))
RETURNS NUMBER
AS
$$
SELECT
  CASE
    WHEN COUNT(*) = 0 THEN NULL -- No rows in the table
    ELSE
      SUM(
        CASE
          WHEN arg_c1 IN ('Prospecting', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost') THEN 0
          ELSE 1
        END
      )
  END
FROM arg_t
$$;

-- Custom DMF: Composite Duplicate Counter
-- Identifies duplicates based on multiple columns
CREATE OR REPLACE DATA METRIC FUNCTION COMPOSITE_DUPLICATE_COUNT(arg_t TABLE(arg_c1 VARCHAR, arg_c2 VARCHAR))
RETURNS NUMBER
AS
$$
 SELECT COUNT(*)
  FROM (SELECT ARG_C1, ARG_C2, COUNT(*) CNT
      FROM ARG_T
      GROUP BY ALL
      HAVING COUNT(*) > 1)
$$;

--==============================================================================
-- 4. Testing Custom DMFs
--==============================================================================
SELECT invalid_email_count(SELECT email FROM customer);
SELECT invalid_stage_count(SELECT salesstage FROM opportunities);
SELECT COMPOSITE_DUPLICATE_COUNT(SELECT firstname, lastname FROM customer);
SELECT data_freshness_hour(SELECT loaddate FROM customer);

--==============================================================================
-- 5. Scheduling DMF Execution
--==============================================================================

-- Option 1: Run every 5 minutes
ALTER TABLE CUSTOMER SET DATA_METRIC_SCHEDULE = '5 Minutes';

-- Option 2: Use cron syntax for business hours
ALTER TABLE CUSTOMER
SET DATA_METRIC_SCHEDULE = 'USING CRON 0 12 * * MON,TUE,WED,THU,FRI EST';

-- Option 3: Trigger on data changes
ALTER TABLE CUSTOMER
SET DATA_METRIC_SCHEDULE = 'TRIGGER_ON_CHANGES';

--==============================================================================
-- 6. Attaching DMFs to Tables
--==============================================================================

-- Attach system DMFs to Customer table
ALTER TABLE CUSTOMER
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.DUPLICATE_COUNT ON (email);

ALTER TABLE CUSTOMER
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT ON (email);

ALTER TABLE CUSTOMER
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.UNIQUE_COUNT ON (email);

ALTER TABLE CUSTOMER
ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.FRESHNESS ON (loaddate);

--==============================================================================
-- 7. Monitoring and Visualization Queries
--==============================================================================

-- View all monitoring results
SELECT * 
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
ORDER BY MEASUREMENT_TIME DESC;

-- View results for specific database and schema
SELECT 
    table_name, 
    metric_name, 
    COUNT(*) AS num_issues,
    SUM(CASE WHEN value = FALSE THEN 1 ELSE 0 END) AS num_failures
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
WHERE 
    TABLE_DATABASE = 'SALESDB' AND 
    TABLE_SCHEMA = 'CUSTS' 
GROUP BY table_name, metric_name;

-- View detailed results for specific checks
SELECT * 
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
WHERE 
    TABLE_DATABASE = 'SALESDB' AND 
    table_schema = 'CUSTS' AND 
    table_name = 'CUSTOMER' AND
    metric_name = 'INVALID_EMAIL_COUNT';

-- Monitor trends over time
SELECT 
    DATE(measurement_time) AS execution_date,
    table_name, 
    metric_name, 
    SUM(value) AS measure_counts
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
WHERE 
    table_database = 'SALESDB' AND 
    table_schema = 'CUSTS' 
GROUP BY execution_date, table_name, metric_name
ORDER BY execution_date;

--==============================================================================
-- 8. Credit Usage Monitoring
--==============================================================================

-- Monitor DMF execution costs
SELECT 
    DATEDIFF(second, start_time, end_time) AS DURATION, 
    *
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_QUALITY_MONITORING_USAGE_HISTORY
WHERE START_TIME >= CURRENT_TIMESTAMP - INTERVAL '3 days'
LIMIT 100;

/*------------------------------------------------------------------------------
  Resources:
  - Introduction to Data Quality and data metric functions:
    https://docs.snowflake.com/en/user-guide/data-quality-metrics-intro
  - System data metric functions:
    https://docs.snowflake.com/en/sql-reference/data-metric-functions
  - Working with data metric functions:
    https://docs.snowflake.com/en/user-guide/data-quality-metrics-working
  - Tutorial: Getting started with data metric functions:
    https://docs.snowflake.com/en/user-guide/data-quality-metrics-tutorial
  - ALTER TABLE documentation:
    https://docs.snowflake.com/en/sql-reference/sql/alter-table
------------------------------------------------------------------------------*/
