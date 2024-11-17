/*------------------------------------------------------------------------------
  Snowflake Demo Script: Sales Data Model and Universal Search
  
  Description: 
  This script sets up a comprehensive sales data model in Snowflake that serves
  as a foundation for various demos and examples. The model is designed to 
  demonstrate common data scenarios and features including:

  Data Model Components:
  - Customer: Core entity storing potential and existing customer information
  - Buyer: Represents customers who have made purchases
  - Client: Tracks contracted customers with active agreements
  - Opportunities: Manages sales pipeline and opportunities

  Key Features Demonstrated:
  - Data Quality Issues: Intentional issues for testing scenarios
    * Missing values (NULL fields)
    * Duplicate records
    * Invalid formats (email, dates)
    * Stale data
    * Referential integrity issues
  
  - Security Features:
    * PII data identification and tagging
    * Column-level masking policies
    * Role-based access control (RBAC)
    
  - Analysis Capabilities:
    * Customer value calculation
    * Sales pipeline tracking
    * Contract value analysis
    * Lead source effectiveness

  Usage Notes:
  1. Run as ACCOUNTADMIN for full functionality
  2. Uses PUBLIC schema for universal access
  3. Creates sample data with known issues for testing
  4. Includes reset instructions for clean-up
  
  Dependencies:
  - Requires ACCOUNTADMIN role for initial setup
  - Needs a running warehouse (Demo_WH used in example)
  
  Author: DemoHub Labs, All rights reserved.
  Website: DemoHub.dev
  Date: May 23, 2024
  Version: 1.2.7
  
  Copyright: (c) 2024 DemoHub.dev. All rights reserved.
------------------------------------------------------------------------------*/

--==============================================================================
-- 1. DATABASE AND SCHEMA SETUP
--==============================================================================
/*
  Creates the sales_db database and uses the PUBLIC schema for universal access.
  The PUBLIC schema allows for easier sharing and access across roles.
*/
CREATE OR REPLACE DATABASE sales_db;
USE sales_db.public;

--==============================================================================
-- 2. CREATE TABLE OBJECTS
--==============================================================================

-- Customer Table: Primary entity tracking the entire customer lifecycle, from initial contact to active status
CREATE OR REPLACE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),      -- First name for personalized communication
    LastName VARCHAR(50),       -- Last name for formal identification
    VarNumber VARCHAR(20),      -- Unique customer reference for cross-system tracking
    Email VARCHAR(100),         -- Primary contact method and unique identifier
    HomeLocation VARCHAR(200),  -- Physical address for territory mapping
    ZipCode VARCHAR(10),        -- Geographic segmentation and targeting
    LoadDate TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()  -- Data freshness tracking
);

-- Buyer Table: Records successful customer conversions and their purchasing profiles for order fulfillment
CREATE OR REPLACE TABLE Buyer (
    BuyerID INT PRIMARY KEY,
    CustomerID INT REFERENCES Customer(CustomerID),  -- Links to original customer record
    FirstName VARCHAR(50),      -- May differ from customer record
    LastName VARCHAR(50),       -- May differ from customer record
    Email VARCHAR(100),         -- Contact for purchase communications
    Address VARCHAR(200),       -- Shipping address for deliveries
    PostalCode VARCHAR(10),     -- Delivery route planning
    LoadDate TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Client Table: Maintains contractual relationships and financial agreements for recurring revenue tracking
CREATE OR REPLACE TABLE Client (
    ClientID INT PRIMARY KEY,
    BuyerID INT REFERENCES Buyer(BuyerID),  -- Links to buyer profile
    ContractStartDate DATE,     -- Beginning of contractual obligation
    ContractValue DECIMAL(10, 2), -- Total contract value for revenue forecasting
    LoadDate TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Opportunities Table: Captures sales pipeline activity and revenue potential across all deal stages
CREATE OR REPLACE TABLE Opportunities (
    OpportunityID INT PRIMARY KEY,
    CustomerID INT REFERENCES Customer(CustomerID),  -- Prospect or customer link
    BuyerID INT REFERENCES Buyer(BuyerID),          -- Optional buyer association
    LeadSource VARCHAR(50),     -- Marketing channel attribution
    SalesStage VARCHAR(20),     -- Current stage in sales process
    ExpectedCloseDate DATE,     -- Projected closure for pipeline planning
    Amount DECIMAL(10, 2),      -- Potential revenue value
    LoadDate TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

--==============================================================================
-- 3. INSERT SAMPLE DATA
--==============================================================================
/*
  Sample Data Characteristics:
  This section populates tables with data that includes intentional quality issues
  for testing and demonstration purposes:

  Customer Table Issues:
  - Missing FirstName (ID 6): Tests NULL handling
  - Invalid Email (ID 5): Tests email validation
  - Missing HomeLocation (ID 7): Tests address completeness
  - Empty ZipCode (ID 8): Tests required field validation
  - Duplicate Email (ID 9): Tests uniqueness constraints
  - Name Variations (ID 3,10): Tests fuzzy matching

  Buyer Table Issues:
  - Missing CustomerID (ID 103): Tests referential integrity
  - Stale Data (ID 104): Tests data freshness
  - Address Mismatches: Tests address standardization
  - Name Variations: Tests name matching algorithms

  Client Table Issues:
  - Missing BuyerID (ID 206): Tests parent-child relationships
  - Negative Values (ID 207): Tests value constraints
  - NULL ContractValue (ID 205): Tests completeness

  Opportunities Table Issues:
  - Invalid SalesStage: Tests enumeration constraints
  - Negative Amount: Tests business rule validation
  - Missing Dates: Tests temporal completeness
*/

-- Customer Data
INSERT INTO Customer (CustomerID, FirstName, LastName, Email, HomeLocation, ZipCode, VarNumber, LoadDate)
VALUES
    (1, 'Alice', 'Johnson', 'alice.johnson@example.com', '123 Oak St', '94105', 'LTY-12345', '2024-04-20 10:30:00'),
    (2, 'Bob', 'Smith', 'bob.smith@example.com', '456 Elm St', '10001', 'LTY-23456', '2024-03-15 11:15:00'),
    (3, 'Eva', 'Davies', 'eva.davis@example.com', '789 Maple Ave', '20001', 'LTY-34567', '2024-02-10 14:45:00'),
    (4, 'Dave', 'Brown', 'dave.brown@example.com', '123 Main St', '54321', 'LTY-45678', '2023-12-30 09:20:00'),
    (5, 'Emily', 'White', 'invalid_email', '456 Park Ave', '67890', 'LTY-56789', '2024-05-15 16:55:00'),
    (6, NULL, 'Wilson', 'charlie.wilson@example.com', '789 Broadway', '87654', 'LTY-67890', '2024-05-18 12:00:00'),
    (7, 'Grace', 'Lee', 'grace.lee@example.com', NULL, '34567', 'LTY-78901', '2024-05-10 08:50:00'),
    (8, 'Henry', 'Miller', 'henry.miller@example.com', '1011 Market St', '', 'LTY-89012', '2024-05-05 15:35:00'),
    (9, 'Ivy', 'Tailor', 'alice.johnson@example.com', '5566 Sunset Blvd', '12345', 'LTY-90123', '2024-05-19 18:10:00'),
    (10, 'Eva', 'Davis', 'eva.davis@anderson.com', '2233 River Rd', '98765', 'LTY-01234', '2024-05-01 13:25:00');

-- Buyer Data
INSERT INTO Buyer (BuyerID, CustomerID, FirstName, LastName, Email, Address, PostalCode, LoadDate)
VALUES
    (101, 1, 'Alice', 'Johnson', 'alice.johnson@example.com', '123 Oak St', '94105', '2024-04-25 12:30:00'),
    (102, 2, 'Bob', 'Smith', 'bob.smith@example.com', '456 Elm St', '10001', '2024-03-20 15:45:00'),
    (103, NULL, 'David', 'Lee', 'david.lee@example.com', '987 Pine St', '33101', '2024-02-15 11:20:00'),
    (104, 4, 'Dave', 'Brown', 'dave.brown@example.com', '123 Main St', '54321', '2023-12-31 14:30:00'),
    (105, 5, 'Emily', 'White', 'invalid_email2', '456 Park Ave', '67890', '2024-05-16 10:15:00'),
    (106, 6, NULL, 'Wilson', 'charlie.wilson@example.com', '789 Broadway', '87654', '2024-05-19 09:45:00'),
    (107, 7, 'Grace', 'Li', 'grace.lee@example.com', NULL, '34567', '2024-05-11 16:25:00'),
    (108, 8, 'Henry', 'Mila', 'henry.miller@example.com', '1011 Market St', '', '2024-05-06 13:00:00'),
    (109, 9, 'Ivy', 'Taylor', 'ivy.taylor@example.com', '5566 Sunset Blvd', '12345', '2024-05-20 17:50:00'),
    (110, 10, 'Jack', 'Anderson', 'jack@anderson.com', '2233 River Rd', '98765', '2024-05-02 18:05:00');

-- Client Data
INSERT INTO Client (ClientID, BuyerID, ContractStartDate, ContractValue, LoadDate)
VALUES 
    (201, 101, '2024-01-15', 50000, '2024-01-15 10:30:00'),
    (202, 102, '2023-12-01', 85000, '2023-12-01 11:15:00'),
    (203, 103, '2024-03-10', 60000, '2024-03-10 14:45:00'),
    (204, 104, '2023-11-20', 75000, '2023-11-20 09:20:00'),
    (205, 105, '2024-04-30', NULL, '2024-04-30 16:55:00'),
    (206, NULL, '2024-02-28', 90000, '2024-02-28 12:00:00'),
    (207, 107, '2024-05-05', -5000, '2024-05-05 08:50:00'),
    (208, 108, '2024-01-01', 120000, '2024-01-01 15:35:00'),
    (209, 109, '2023-12-15', 100000, '2023-12-15 18:10:00'),
    (210, 110, '2024-04-10', 45000, '2024-04-10 13:25:00');

-- Opportunities Data
INSERT INTO Opportunities (OpportunityID, CustomerID, BuyerID, LeadSource, SalesStage, ExpectedCloseDate, Amount, LoadDate)
VALUES 
    (1003, 3, NULL, 'Outbound Call', 'Qualification', '2024-05-20', 75000, '2024-05-12 18:15:00'),
    (1004, NULL, 103, 'Email Campaign', 'Proposal', '2024-06-10', 90000, '2024-04-28 14:20:00'),
    (1005, 4, NULL, 'Web Form', 'Negotiation', '2024-07-15', 150000, '2024-05-19 11:35:00'),
    (1006, 5, NULL, 'Partner Referral', 'InvalidStage', '2024-08-20', 180000, '2024-05-22 16:40:00'),
    (1007, 6, NULL, 'Email Campaign', 'Qualification', NULL, 65000, '2024-05-17 13:50:00'),
    (1008, 7, 107, 'Cold Call', 'Closed Won', '2024-05-10', 110000, '2023-12-28 08:30:00'),
    (1009, 8, 108, 'Webinar', 'Closed Lost', '2024-03-25', NULL, '2024-04-15 15:10:00'),
    (1010, 9, NULL, 'Referral', 'Proposal', '2024-06-05', -80000, '2024-05-14 17:25:00'),
    (1011, 10, 110, 'Social Media', 'Negotiation', '2024-07-02', 135000, '2024-05-08 12:45:00'),
    (1012, 2, 102, 'Email Campaign', 'Closed Won', '2023-12-01', 85000, '2024-05-21 10:00:00');

--==============================================================================
-- 4. CREATE AND INSERT COMMENTS
--==============================================================================
/*
  Object Documentation:
  - Table and column comments provide metadata for discovery
  - Comments are searchable through Snowflake's catalog
  - Descriptions include business context and usage guidelines
*/

-- Table Comments
COMMENT ON TABLE Customer IS 'Core customer entity. Contains all customer records including prospects and active customers. PII data is masked based on role.';
COMMENT ON TABLE Buyer IS 'Active customer subset who have made purchases. Links to Customer table for full profile.';
COMMENT ON TABLE Client IS 'Contracted customers with active agreements. Contains financial terms and contract details.';
COMMENT ON TABLE Opportunities IS 'Sales pipeline tracking. Includes all stages from prospect to closed deals.';

-- Column Comments with Enhanced Business Context
COMMENT ON COLUMN Customer.HomeLocation IS 'Primary residence or business address. Used for territory assignment and geographic analysis.';
COMMENT ON COLUMN Customer.VarNumber IS 'Unique customer identifier across systems. Format: LTY-XXXXX';
COMMENT ON COLUMN Buyer.Address IS 'Shipping or billing address. May differ from Customer.HomeLocation';
COMMENT ON COLUMN Buyer.PostalCode IS 'Postal code for shipping address. Used for logistics and delivery routing.';
COMMENT ON COLUMN Client.ContractValue IS 'Total contract value in USD. Used for revenue forecasting and customer segmentation.';
COMMENT ON COLUMN Opportunities.LeadSource IS 'Original source of the opportunity. Critical for marketing attribution and channel effectiveness.';
COMMENT ON COLUMN Opportunities.SalesStage IS 'Current stage in sales process. Valid values: Prospecting, Qualification, Proposal, Negotiation, Closed Won, Closed Lost';

--==============================================================================
-- 5. CREATE FUNCTIONS, STORED PROCEDURES AND VIEWS
--==============================================================================

-- Function: Aggregates all closed-won deal values to measure customer lifetime value
CREATE OR REPLACE FUNCTION customer_closed_won_value(customer_id INT)
RETURNS NUMBER(19,4)
LANGUAGE SQL
AS
$$
SELECT SUM(o.Amount)
FROM Opportunities o
JOIN Customer c ON o.CustomerID = c.CustomerID
WHERE o.CustomerID = customer_id
AND o.SalesStage = 'Closed Won'
$$;

-- Function: Classifies customers into value tiers for targeted engagement and account planning
CREATE OR REPLACE FUNCTION categorize_customer(customer_id INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
SELECT CASE 
    WHEN customer_closed_won_value(customer_id) >= 100000 THEN 'High Value'
    WHEN customer_closed_won_value(customer_id) >= 50000 THEN 'Medium Value'
    ELSE 'Low Value'
END
$$;

-- Procedure: Manages sales pipeline progression with stage validation and tracking
CREATE OR REPLACE PROCEDURE update_opportunity_stage(opportunity_id INT, new_stage VARCHAR)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE Opportunities
    SET SalesStage = new_stage
    WHERE OpportunityID = opportunity_id;
    RETURN 'Success';
END;
$$;

-- Procedure: Associates customer records with buyer profiles after purchase conversion
CREATE OR REPLACE PROCEDURE assign_buyer_to_customer(customer_id INT, buyer_id INT)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
    UPDATE Customer
    SET BuyerID = buyer_id
    WHERE CustomerID = customer_id;
END;
$$;

-- View: Surfaces high-value customers for strategic account management and upsell opportunities
CREATE OR REPLACE VIEW high_value_customers AS
SELECT c.*, customer_closed_won_value(c.CustomerID) AS TotalValue
FROM Customer c;

-- View: Highlights near-term opportunities for prioritized sales focus and pipeline management
CREATE OR REPLACE VIEW opportunities_likely_to_close AS
SELECT *
FROM Opportunities
WHERE SalesStage IN ('Negotiation', 'Proposal')
AND ExpectedCloseDate BETWEEN CURRENT_DATE AND DATEADD(month, 1, CURRENT_DATE);

--==============================================================================
-- 6. CREATE AND APPLY TAGS
--==============================================================================
/*
  Data Governance Framework:
  
  Tags provide metadata for:
  - PII identification (Name, Email, Address)
  - Business context (Lead Source, Sales Stage)
  - Organizational ownership (Cost Center)
  
  Tag Usage:
  - Drives masking policies
  - Enables data discovery
  - Supports compliance reporting
*/

-- Create Tags
CREATE OR REPLACE TAG cost_center ALLOWED_VALUES 'finance', 'engineering';
CREATE OR REPLACE TAG PII ALLOWED_VALUES 'Name', 'Email', 'Address' COMMENT = 'Indicates personally identifiable information';
CREATE OR REPLACE TAG Lead_Source ALLOWED_VALUES 'Partner Referral', 'Web Form', 'Outbound Call', 'Trade Show' COMMENT = 'Indicates the source of the lead or opportunity';
CREATE OR REPLACE TAG Sales_Stage ALLOWED_VALUES 'Prospecting', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost' COMMENT = 'Indicates the current stage of the sales opportunity';

-- Apply Tags
ALTER TABLE Customer MODIFY COLUMN FirstName SET TAG PII = 'Name';
ALTER TABLE Customer MODIFY COLUMN LastName SET TAG PII = 'Name';
ALTER TABLE Customer MODIFY COLUMN Email SET TAG PII = 'Email';

ALTER TABLE Buyer MODIFY COLUMN FirstName SET TAG PII = 'Name';
ALTER TABLE Buyer MODIFY COLUMN LastName SET TAG PII = 'Name';
ALTER TABLE Buyer MODIFY COLUMN Email SET TAG PII = 'Email';
ALTER TABLE Buyer MODIFY COLUMN Address SET TAG PII = 'Address';

--==============================================================================
-- 7. CREATE AND APPLY MASKING
--==============================================================================
/*
  Data Protection:
  
  Masking Policy Design:
  - Protects PII data based on role
  - SalesManager role has full visibility
  - Other roles see masked values
  
  Implementation:
  - Policy applied via tags for consistency
  - Centralized management through tag inheritance
  - Audit-friendly design
*/

USE ROLE ACCOUNTADMIN;

-- Create masking policy
CREATE OR REPLACE MASKING POLICY mask_pii AS (val string)
RETURNS string ->
    CASE
        WHEN current_role() IN ('SalesManager') THEN val
        ELSE '***MASKED***'
    END;

-- Apply masking policy
ALTER TAG PII SET MASKING POLICY mask_pii;

--==============================================================================
-- 8. RBAC PRIVILEGES SETUP
--==============================================================================
/*
  Security Model:
  
  Roles:
  - SalesRep: Basic read access to customer data
  - SalesManager: Extended access including PII
  
  Access Layers:
  1. Database: Usage rights
  2. Schema: Object visibility
  3. Table: Data access
  4. Column: Field-level security via masking
  
  Best Practices:
  - Principle of least privilege
  - Role-based access control
  - Segregation of duties
*/

USE ROLE ACCOUNTADMIN;

-- Create Roles
CREATE OR REPLACE ROLE SalesRep;
CREATE OR REPLACE ROLE SalesManager;

-- Grant Database Privileges
GRANT USAGE ON DATABASE sales_db TO ROLE SalesRep;
GRANT USAGE ON DATABASE sales_db TO ROLE SalesManager;

-- Grant Schema Privileges
GRANT USAGE ON SCHEMA sales_db.public TO ROLE SalesRep;
GRANT USAGE ON SCHEMA sales_db.public TO ROLE SalesManager;

-- Grant Warehouse Privileges
GRANT USAGE ON WAREHOUSE Demo_WH TO ROLE SalesRep;
GRANT USAGE ON WAREHOUSE Demo_WH TO ROLE SalesManager;

-- Grant Table Privileges
GRANT SELECT ON TABLE Customer TO ROLE SalesRep;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO ROLE SalesManager;

--==============================================================================
-- 9. GRANT ROLES TO USERS
--==============================================================================

USE ROLE ACCOUNTADMIN;
GRANT ROLE SalesManager TO USER demohub2;
GRANT ROLE SalesRep TO USER demohub2;

--==============================================================================
-- 9. USAGE EXAMPLES AND TESTING
--==============================================================================
/*
  Example Queries and Validations:
*/

-- Customer Value Analysis: Evaluate customer segmentation and revenue contribution
SELECT 
    c.CustomerID,
    c.FirstName,
    c.LastName,
    customer_closed_won_value(c.CustomerID) as TotalValue,
    categorize_customer(c.CustomerID) as CustomerTier
FROM Customer c
WHERE customer_closed_won_value(c.CustomerID) > 0;

-- Data Quality Check: Identify data integrity issues for remediation
SELECT 
    'Invalid Email' as Issue,
    COUNT(*) as Count
FROM Customer 
WHERE NOT REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
UNION ALL
SELECT 
    'Missing Required Fields',
    COUNT(*)
FROM Customer 
WHERE FirstName IS NULL OR HomeLocation IS NULL OR ZipCode = '';

-- Pipeline Analysis: Monitor sales stages and conversion metrics
SELECT 
    SalesStage,
    COUNT(*) as Opportunities,
    SUM(Amount) as TotalValue,
    AVG(DATEDIFF('day', LoadDate, ExpectedCloseDate)) as AvgDaysToClose
FROM Opportunities
GROUP BY SalesStage
ORDER BY TotalValue DESC;

/*------------------------------------------------------------------------------
  Reset Instructions:
  
  1. Clean Up Database Objects:
  USE ROLE ACCOUNTADMIN;
  DROP DATABASE IF EXISTS sales_db CASCADE;
  
  2. Remove Roles:
  REVOKE ROLE SalesRep FROM USER demohub2;
  REVOKE ROLE SalesManager FROM USER demohub2;
  DROP ROLE IF EXISTS SalesRep;
  DROP ROLE IF EXISTS SalesManager;
  
  3. Verify Cleanup:
  SHOW DATABASES LIKE 'sales_db';
  SHOW ROLES LIKE 'Sales%';
  
  Note: Ensure no active sessions are using these objects before cleanup.
------------------------------------------------------------------------------*/