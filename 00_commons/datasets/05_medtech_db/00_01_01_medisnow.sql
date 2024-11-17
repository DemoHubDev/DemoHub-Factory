/*------------------------------------------------------------------------------
  Snowflake Demo Script: MedTech Database Setup and Analysis
  
  Description: 
  This script implements a comprehensive medical device management system for MediSnow,
  a leading medical device company. The database enables tracking and analysis of:
  - Device lifecycle management
  - Customer feedback and complaints
  - Regulatory compliance
  - Maintenance scheduling
  - Financial performance
  
  Script Sections:
  1. Database Setup
     - Database creation
     - Schema definition
     - Table creation
  
  2. Data Loading
     - Device data population
     - Customer complaints data
  
  3. Analysis Queries
     - Device performance metrics
     - Financial analytics
     - Compliance monitoring
     - Customer satisfaction analysis
  
  4. Reset Functionality
     - Database reset commands
  
  Author: DemoHub Labs, All rights reserved.
  Website: DemoHub.dev
  Date: 2024-03-19
  Version: 1.0
  
  Copyright: (c) 2024 DemoHub.dev. All rights reserved.
------------------------------------------------------------------------------*/

/*==============================================================================
  SECTION 1: DATABASE SETUP
  Description: Initialize database and create required tables
==============================================================================*/

-- Reset and create database
DROP DATABASE IF EXISTS medtech_db;
CREATE DATABASE medtech_db;
USE DATABASE medtech_db;

-- Create devices table
CREATE OR REPLACE TABLE devices (
  DeviceID INT AUTOINCREMENT PRIMARY KEY,
  DeviceName VARCHAR(100),
  DeviceType VARCHAR(100),
  Manufacturer VARCHAR(100),
  ModelNumber VARCHAR(50),
  SerialNumber VARCHAR(50),
  ManufacturingDate DATE,
  ExpirationDate DATE,
  DeviceStatus VARCHAR(50),
  DeviceVersion VARCHAR(50),
  SoftwareVersion VARCHAR(50),
  RegulatoryApproval VARCHAR(100),
  ApprovalDate DATE,
  LastMaintenanceDate DATE,
  NextMaintenanceDate DATE,
  WarrantyStartDate DATE,
  WarrantyEndDate DATE,
  PurchaseDate DATE,
  PurchasePrice DECIMAL(10,2),
  BusinessUnit VARCHAR(50)
);

-- Create customer_complaints table
CREATE OR REPLACE TABLE customer_complaints (
  ComplaintID INT AUTOINCREMENT PRIMARY KEY,
  DeviceID INT,
  ComplaintDate DATE,
  CustomerName VARCHAR(100),
  DeviceName VARCHAR(100),
  ComplaintDetails TEXT,
  FOREIGN KEY (DeviceID) REFERENCES devices(DeviceID)
);

/*==============================================================================
  SECTION 2: DATA LOADING
  Description: Populate tables with sample data
==============================================================================*/

-- Clear existing data
TRUNCATE TABLE IF EXISTS customer_complaints;
TRUNCATE TABLE IF EXISTS devices;

-- Load device data
INSERT INTO devices (DeviceName, DeviceType, Manufacturer, ModelNumber, SerialNumber, ManufacturingDate, ExpirationDate, DeviceStatus, DeviceVersion, SoftwareVersion, RegulatoryApproval, ApprovalDate, LastMaintenanceDate, NextMaintenanceDate, WarrantyStartDate, WarrantyEndDate, PurchaseDate, PurchasePrice, BusinessUnit)
VALUES
('GloboMedic 5000', 'Heart Monitor', 'MediHealth', 'GM5000', 'GH123456', '2022-05-15', '2025-05-15', 'Active', '2.1', '3.0', 'FDA', '2022-04-20', '2023-04-20', '2024-04-20', '2022-05-15', '2025-05-15', '2022-04-20', 2500.00, 'Cardiovascular Devices'),
('roScan Plus', 'Dialysis Machine', 'RenalTech', 'NSP1000', 'RNT789012', '2022-06-20', '2026-06-20', 'Active', '1.5', '2.0', 'CE Mark', '2022-06-01', '2023-06-01', '2024-06-01', '2022-06-20', '2026-06-20', '2022-06-01', 5000.00, 'Renal Care'),
('NeuroSync Pro', 'Neurostimulator', 'NeuroLife Inc.', 'NSP2000', 'NL456789', '2022-07-10', '2027-07-10', 'Active', '3.0', '3.5', 'FDA', '2022-07-01', '2023-07-01', '2024-07-01', '2022-07-10', '2027-07-10', '2022-07-01', 7500.00, 'Neuromodulation'),
('ApexCore 3000', 'Surgical Robot', 'SurgiTech', 'SBX3000', 'ST234567', '2022-08-15', '2028-08-15', 'Active', '2.0', '2.5', 'FDA', '2022-08-01', '2023-08-01', '2024-08-01', '2022-08-15', '2028-08-15', '2022-08-01', 10000.00, 'Medical-Surgical Solutions'),
('OrthoFlex 2000', 'Joint Implant', 'OrthoTech', 'OF2000', 'OT123456', '2022-09-20', '2029-09-20', 'Active', '1.8', '2.2', 'CE Mark', '2022-09-01', '2023-09-01', '2024-09-01', '2022-09-20', '2029-09-20', '2022-09-01', 6000.00, 'Orthopedics'),
('QuantumNova X5', 'Vascular Scanner', 'VascuTech', 'VSU4000', 'VT789012', '2022-10-25', '2028-10-25', 'Active', '1.5', '2.0', 'FDA', '2022-10-01', '2023-10-01', '2024-10-01', '2022-10-25', '2028-10-25', '2022-10-01', 4500.00, 'Vascular Therapy'),
('MediScan Pro', 'Diagnostic Imaging', 'MediTech', 'MDP500', 'MT567890', '2022-11-05', '2027-11-05', 'Active', '2.2', '3.0', 'FDA', '2022-11-01', '2023-11-01', '2024-11-01', '2022-11-05', '2027-11-05', '2022-11-01', 8500.00, 'Diagnostic Imaging'),
('EndoView 3000', 'Endoscopy', 'EndoTech', 'EV3000', 'ET234567', '2022-12-10', '2028-12-10', 'Active', '1.0', '1.5', 'CE Mark', '2022-12-01', '2023-12-01', '2024-12-01', '2022-12-10', '2028-12-10', '2022-12-01', 7000.00, 'Endoscopy'),
('NeoSync 7G', 'Patient Monitor', 'CareTech', 'CCP1000', 'CT123456', '2023-01-15', '2029-01-15', 'Active', '2.5', '3.0', 'FDA', '2023-01-01', '2024-01-01', '2025-01-01', '2023-01-15', '2029-01-15', '2023-01-01', 9500.00, 'Critical Care'),
('VitaFlex 6000', 'Insulin Pump', 'VitaLife', 'VF6000', 'VL567890', '2023-02-20', '2028-02-20', 'Active', '1.8', '2.2', 'CE Mark', '2023-02-01', '2024-02-01', '2025-02-01', '2023-02-20', '2028-02-20', '2023-02-01', 3000.00, 'Diabetes Care'),
('NanoGlow 4.2', 'Bone Scanner', 'OrthoScan', 'OV1000', 'OS234567', '2023-03-25', '2028-03-25', 'Active', '1.2', '1.5', 'FDA', '2023-03-01', '2024-03-01', '2025-03-01', '2023-03-25', '2028-03-25', '2023-03-01', 6000.00, 'Orthopedics'),
('CardioTech Xpress', 'ECG Machine', 'CardioMed', 'CTX2000', 'CM567890', '2023-04-30', '2028-04-30', 'Active', '1.5', '2.0', 'CE Mark', '2023-04-01', '2024-04-01', '2025-04-01', '2023-04-30', '2028-04-30', '2023-04-01', 4000.00, 'Cardiovascular Devices'),
('EchoScan 3000', 'Ultrasound Machine', 'UltraHealth', 'ES3000', 'UH123456', '2023-05-05', '2028-05-05', 'Active', '2.0', '2.5', 'FDA', '2023-05-01', '2024-05-01', '2025-05-01', '2023-05-05', '2028-05-05', '2023-05-01', 9000.00, 'Diagnostic Imaging'),
('GastroView Pro', 'Gastroscopy System', 'GastroTech', 'GVP1000', 'GT567890', '2023-06-10', '2028-06-10', 'Active', '1.5', '2.0', 'CE Mark', '2023-06-01', '2024-06-01', '2025-06-01', '2023-06-10', '2028-06-10', '2023-06-01', 7500.00, 'Endoscopy'),
('Ventilife 5000', 'Ventilator', 'LifeCare', 'VL5000', 'LC234567', '2023-07-15', '2028-07-15', 'Active', '2.5', '3.0', 'FDA', '2023-07-01', '2024-07-01', '2025-07-01', '2023-07-15', '2028-07-15', '2023-07-01', 12000.00, 'Critical Care'),
('SynthoWave 2000', 'Glucose Monitor', 'GlucoTech', 'GT2000', 'GT567890', '2023-08-20', '2028-08-20', 'Active', '1.8', '2.2', 'CE Mark', '2023-08-01', '2024-08-01', '2025-08-01', '2023-08-20', '2028-08-20', '2023-08-01', 3500.00, 'Diabetes Care'),
('MusculoScan 1000', 'Muscle Scanner', 'MuscleTech', 'MS1000', 'MT123456', '2023-09-25', '2028-09-25', 'Active', '1.2', '1.5', 'FDA', '2023-09-01', '2024-09-01', '2025-09-01', '2023-09-25', '2028-09-25', '2023-09-01', 5000.00, 'Orthopedics'),
('VascuCheck 500', 'Vascular Monitor', 'VascuCare', 'VC500', 'VC567890', '2023-10-30', '2028-10-30', 'Active', '1.5', '2.0', 'CE Mark', '2023-10-01', '2024-10-01', '2025-10-01', '2023-10-30', '2028-10-30', '2023-10-01', 4200.00, 'Vascular Therapy'),
('NexGen 4000', 'Biomedical Device', 'BioTech', 'NG4000', 'BT456789', '2023-08-05', '2028-08-05', 'Active', '2.0', '2.5', 'FDA', '2023-08-01', '2024-08-01', '2025-08-01', '2023-08-05', '2028-08-05', '2023-08-01', 7000.00, 'Medical-Surgical Solutions'),
('QuantumMatrix', 'Healthcare Device', 'MediTech', 'QM2000', 'MT234567', '2023-09-10', '2028-09-10', 'Active', '1.5', '2.0', 'CE Mark', '2023-09-01', '2024-09-01', '2025-09-01', '2023-09-10', '2028-09-10', '2023-09-01', 6500.00, 'Renal Care'),
('VitaSphere 3000', 'Health Monitor', 'VitaLife', 'VS3000', 'VL567890', '2023-10-15', '2028-10-15', 'Active', '2.5', '3.0', 'FDA', '2023-10-01', '2024-10-01', '2025-10-01', '2023-10-15', '2028-10-15', '2023-10-01', 8000.00, 'Neuromodulation'),
('ZenithPro', 'Monitoring System', 'ZenTech', 'ZP1000', 'ZT123456', '2023-11-20', '2028-11-20', 'Active', '2.0', '2.5', 'CE Mark', '2023-11-01', '2024-11-01', '2025-11-01', '2023-11-20', '2028-11-20', '2023-11-01', 6000.00, 'Diabetes Care'),
('FlexiTech 2000', 'Healthcare System', 'FlexiMed', 'FT2000', 'FM567890', '2023-12-25', '2028-12-25', 'Active', '1.8', '2.2', 'FDA', '2023-12-01', '2024-12-01', '2025-12-01', '2023-12-25', '2028-12-25', '2023-12-01', 7500.00, 'Orthopedics'),
('ProHealthPlus', 'Medical Device', 'LifeCare', 'PHP5000', 'LC234567', '2024-01-30', '2029-01-30', 'Active', '2.2', '2.7', 'CE Mark', '2024-01-01', '2025-01-01', '2026-01-01', '2024-01-30', '2029-01-30', '2024-01-01', 9000.00, 'Cardiovascular Devices'),
('NovaWave 6000', 'Medical Equipment', 'MediTech', 'NW6000', 'MT123456', '2024-02-05', '2029-02-05', 'Active', '2.5', '3.0', 'FDA', '2024-02-01', '2025-02-01', '2026-02-01', '2024-02-05', '2029-02-05', '2024-02-01', 8500.00, 'Neuromodulation'),
('SpectraMed 3000', 'Health Monitoring System', 'BioCare', 'SM3000', 'BC234567', '2024-03-10', '2029-03-10', 'Active', '1.8', '2.2', 'CE Mark', '2024-03-01', '2025-03-01', '2026-03-01', '2024-03-10', '2029-03-10', '2024-03-01', 7500.00, 'Cardiovascular Devices'),
('AlphaSense', 'Medical Device', 'MediSys', 'AS1000', 'MS567890', '2024-04-15', '2029-04-15', 'Active', '1.5', '2.0', 'FDA', '2024-04-01', '2025-04-01', '2026-04-01', '2024-04-15', '2029-04-15', '2024-04-01', 6000.00, 'Critical Care'),
('EchoCare 8000', 'Diagnostic Equipment', 'EchoTech', 'EC8000', 'ET123456', '2024-05-20', '2029-05-20', 'Active', '2.2', '2.7', 'CE Mark', '2024-05-01', '2025-05-01', '2026-05-01', '2024-05-20', '2029-05-20', '2024-05-01', 8000.00, 'Diagnostic Imaging'),
('BioFlex 4000', 'Medical Device', 'BioTech', 'BF4000', 'BT456789', '2024-06-25', '2029-06-25', 'Active', '2.0', '2.5', 'FDA', '2024-06-01', '2025-06-01', '2026-06-01', '2024-06-25', '2029-06-25', '2024-06-01', 7000.00, 'Renal Care'),
('NeuroSense 2000', 'Neurological Device', 'NeuroTech', 'NS2000', 'NT234567', '2024-07-30', '2029-07-30', 'Active', '1.5', '2.0', 'CE Mark', '2024-07-01', '2025-07-01', '2026-07-01', '2024-07-30', '2029-07-30', '2024-07-01', 5500.00, 'Neuromodulation'),
('XenoGenix 5000', 'Biomedical Equipment', 'BioCorp', 'XG5000', 'BC123456', '2024-08-05', '2029-08-05', 'Active', '2.0', '2.5', 'FDA', '2024-08-01', '2025-08-01', '2026-08-01', '2024-08-05', '2029-08-05', '2024-08-01', 7500.00, 'Vascular Therapy'),
('QuantaDrive', 'Healthcare Device', 'QuantumMed', 'QD3000', 'QM234567', '2024-09-10', '2029-09-10', 'Active', '1.5', '2.0', 'CE Mark', '2024-09-01', '2025-09-01', '2026-09-01', '2024-09-10', '2029-09-10', '2024-09-01', 6000.00, 'Neuromodulation'),
('VeloScan 2000', 'Diagnostic System', 'VeloTech', 'VS2000', 'VT567890', '2024-10-15', '2029-10-15', 'Active', '2.5', '3.0', 'FDA', '2024-10-01', '2025-10-01', '2026-10-01', '2024-10-15', '2029-10-15', '2024-10-01', 8500.00, 'Critical Care'),
('BioPulse 3.8', 'Monitoring System', 'OmniHealth', 'OLP1000', 'OH123456', '2024-11-20', '2029-11-20', 'Active', '2.0', '2.5', 'CE Mark', '2024-11-01', '2025-11-01', '2026-11-01', '2024-11-20', '2029-11-20', '2024-11-01', 7000.00, 'Diagnostic Imaging'),
('CryoTech 4000', 'Therapeutic Device', 'CryoMed', 'CT4000', 'CM234567', '2024-12-25', '2029-12-25', 'Active', '1.8', '2.2', 'FDA', '2024-12-01', '2025-12-01', '2026-12-01', '2024-12-25', '2029-12-25', '2024-12-01', 8000.00, 'Orthopedics'),
('VitaScan 1000', 'Health Monitor', 'VitaCare', 'VS1000', 'VC567890', '2025-01-30', '2030-01-30', 'Active', '2.2', '2.7', 'CE Mark', '2025-01-01', '2026-01-01', '2027-01-01', '2025-01-30', '2030-01-30', '2025-01-01', 9000.00, 'Diabetes Care'),
('EvoTech 7000', 'Biometric Device', 'BioSync', 'ET7000', 'BS123456', '2025-02-05', '2030-02-05', 'Active', '2.0', '2.5', 'FDA', '2025-02-01', '2026-02-01', '2027-02-01', '2025-02-05', '2030-02-05', '2025-02-01', 7600.00, 'Neuromodulation'),
('NebulaSync', 'Healthcare Monitor', 'NebulaMed', 'NS3000', 'NM234567', '2025-03-10', '2030-03-10', 'Active', '1.5', '2.0', 'CE Mark', '2025-03-01', '2026-03-01', '2027-03-01', '2025-03-10', '2030-03-10', '2025-03-01', 6200.00, 'Cardiovascular Devices'),
('SynthraSys 9000', 'Patient Monitoring Device', 'SynthraMed', 'SS9000', 'SM567890', '2025-04-15', '2030-04-15', 'Active', '2.5', '3.0', 'FDA', '2025-04-01', '2026-04-01', '2027-04-01', '2025-04-15', '2030-04-15', '2025-04-01', 8800.00, 'Critical Care'),
('TechVision Pro', 'Healthcare System', 'TechMed', 'TVP1000', 'TM123456', '2025-05-20', '2030-05-20', 'Active', '2.0', '2.5', 'CE Mark', '2025-05-01', '2026-05-01', '2027-05-01', '2025-05-20', '2030-05-20', '2025-05-01', 7200.00, 'Diagnostic Imaging'),
('MediSync 6000', 'Therapeutic Equipment', 'MediTech', 'MS6000', 'MT234567', '2025-06-25', '2030-06-25', 'Active', '1.8', '2.2', 'FDA', '2025-06-01', '2026-06-01', '2027-06-01', '2025-06-25', '2030-06-25', '2025-06-01', 8200.00, 'Orthopedics'),
('AquaSense 2000', 'Health Tracker', 'AquaCare', 'AS2000', 'AC567890', '2025-07-30', '2030-07-30', 'Active', '2.2', '2.7', 'CE Mark', '2025-07-01', '2026-07-01', '2027-07-01', '2025-07-30', '2030-07-30', '2025-07-01', 9200.00, 'Vascular Therapy'),
('Xerocore 2000', 'Biomedical Device', 'XeroMed', 'XC2000', 'XM123456', '2025-02-05', '2030-02-05', 'Active', '2.0', '2.5', 'FDA', '2025-02-01', '2026-02-01', '2027-02-01', '2025-02-05', '2030-02-05', '2025-02-01', 7600.00, 'Neuromodulation'),
('FlexiCore 600', 'Healthcare Monitor', 'InnoTech', 'IP5000', 'IT234567', '2025-03-10', '2030-03-10', 'Active', '1.5', '2.0', 'CE Mark', '2025-03-01', '2026-03-01', '2027-03-01', '2025-03-10', '2030-03-10', '2025-03-01', 6200.00, 'Cardiovascular Devices'),
('MediPulse 7000', 'Patient Monitoring System', 'MediTech', 'MP7000', 'MT567890', '2025-04-15', '2030-04-15', 'Active', '2.5', '3.0', 'FDA', '2025-04-01', '2026-04-01', '2027-04-01', '2025-04-15', '2030-04-15', '2025-04-01', 8800.00, 'Critical Care'),
('TechNova 3000', 'Healthcare System', 'TechMed', 'TN3000', 'TM123456', '2025-05-20', '2030-05-20', 'Active', '2.0', '2.5', 'CE Mark', '2025-05-01', '2026-05-01', '2027-05-01', '2025-05-20', '2030-05-20', '2025-05-01', 7200.00, 'Diagnostic Imaging'),
('SynthoGen 4000', 'Therapeutic Equipment', 'SynthoMed', 'SG4000', 'SM234567', '2025-06-25', '2030-06-25', 'Active', '1.8', '2.2', 'FDA', '2025-06-01', '2026-06-01', '2027-06-01', '2025-06-25', '2030-06-25', '2025-06-01', 8200.00, 'Orthopedics'),
('NeuraScan 1000', 'Health Monitor', 'NeuraCare', 'NS1000', 'NC567890', '2025-07-30', '2030-07-30', 'Active', '2.2', '2.7', 'CE Mark', '2025-07-01', '2026-07-01', '2027-07-01', '2025-07-30', '2030-07-30', '2025-07-01', 9200.00, 'Vascular Therapy'),
('BioSpectra 8000', 'Healthcare Device', 'BioTech', 'BS8000', 'BT123456', '2025-08-05', '2030-08-05', 'Active', '2.0', '2.5', 'FDA', '2025-08-01', '2026-08-01', '2027-08-01', '2025-08-05', '2030-08-05', '2025-08-01', 7600.00, 'Neuromodulation'),
('EcoView 6000', 'Healthcare Monitor', 'EcoMed', 'EV6000', 'EM234567', '2025-09-10', '2030-09-10', 'Active', '1.5', '2.0', 'CE Mark', '2025-09-01', '2026-09-01', '2027-09-01', '2025-09-10', '2030-09-10', '2025-09-01', 6200.00, 'Cardiovascular Devices'),
('MediLink Pro', 'Patient Monitoring System', 'MediTech', 'MLP1000', 'MT567890', '2025-10-15', '2030-10-15', 'Active', '2.5', '3.0', 'FDA', '2025-10-01', '2026-10-01', '2027-10-01', '2025-10-15', '2030-10-15', '2025-10-01', 8800.00, 'Critical Care'),
('TechSync 2000', 'Healthcare System', 'TechMed', 'TS2000', 'TM123456', '2025-11-20', '2030-11-20', 'Active', '2.0', '2.5', 'CE Mark', '2025-11-01', '2026-11-01', '2027-11-01', '2025-11-20', '2030-11-20', '2025-11-01', 7200.00, 'Diagnostic Imaging'),
('SynthoPulse 3000', 'Therapeutic Equipment', 'SynthoMed', 'SP3000', 'SM234567', '2025-12-25', '2030-12-25', 'Active', '1.8', '2.2', 'FDA', '2025-12-01', '2026-12-01', '2027-12-01', '2025-12-25', '2030-12-25', '2025-12-01', 8200.00, 'Orthopedics'),
('NeuraSync 4000', 'Health Monitor', 'NeuraCare', 'NS4000', 'NC567890', '2026-01-30', '2031-01-30', 'Active', '2.2', '2.7', 'CE Mark', '2026-01-01', '2027-01-01', '2028-01-01', '2026-01-30', '2031-01-30', '2026-01-01', 9200.00, 'Vascular Therapy');

-- Load customer complaints data
INSERT INTO customer_complaints (DeviceID, ComplaintDate, CustomerName, DeviceName, ComplaintDetails)
VALUES
(1, '2023-01-05', 'John Doe', 'GloboMedic 5000', 'The GloboMedic 5000 has been a disappointment. Despite following the instructions carefully, I have not experienced any noticeable improvement in my condition. I am very disappointed and feel like I wasted my money on this device.'),
(2, '2023-02-10', 'Jane Smith', 'roScan Plus', 'The roScan Plus has greatly improved my quality of life. The machine is easy to use, and I feel confident in its ability to provide me with the care I need.'),
(3, '2023-03-15', 'Alice Johnson', 'NeuroSync Pro', 'The NeuroSync Pro has helped me monitor my health effectively, and I am grateful for the peace of mind it provides.'),
(4, '2023-04-20', 'Robert Brown', 'ApexCore 3000', 'I recently underwent surgery with the assistance of the ApexCore 3000 surgical robot, and I am amazed at how smoothly the procedure went.'),
(5, '2023-05-25', 'Michael Davis', 'OrthoFlex 2000', 'The OrthoFlex 2000 joint implant has been a lifesaver for me. It has significantly improved my mobility and quality of life.'),
(6, '2023-06-30', 'Emily Wilson', 'QuantumNova X5', 'The QuantumNova X5 vascular scanner has been very helpful in diagnosing vascular issues in my patients. It is easy to use and provides accurate results.'),
(7, '2023-07-05', 'David Brown', 'MediScan Pro', 'The MediScan Pro has been a disappointment. Despite following the instructions carefully, I have not experienced any noticeable improvement in my condition. I am very disappointed and feel like I wasted my money on this device.'),
(8, '2023-08-10', 'Samantha Wilson', 'EndoView 3000', 'I have been using the EndoView 3000 for a few months now, and it has greatly improved my quality of life. The device is easy to use, and I feel confident in its ability to provide me with the care I need.'),
(9, '2023-09-15', 'Chris Evans', 'NeoSync 7G', 'The NeoSync 7G has helped me monitor my health effectively, and I am grateful for the peace of mind it provides.'),
(10, '2023-10-20', 'Emma Johnson', 'VitaFlex 6000', 'I recently underwent surgery with the assistance of the VitaFlex 6000 insulin pump, and I am amazed at how smoothly the procedure went.'),
(11, '2023-11-25', 'Olivia Brown', 'NanoGlow 4.2', 'The NanoGlow 4.2 bone scanner has been a lifesaver for me. It has significantly improved my mobility and quality of life.'),
(12, '2023-12-30', 'Daniel Smith', 'CardioTech Xpress', 'The CardioTech Xpress ECG machine has been very helpful in diagnosing heart issues in my patients. It is easy to use and provides accurate results.'),
(13, '2024-01-05', 'Sophia Miller', 'EchoScan 3000', 'The EchoScan 3000 has been a disappointment. Despite following the instructions carefully, I have not experienced any noticeable improvement in my condition. I am very disappointed and feel like I wasted my money on this device.'),
(14, '2024-02-10', 'Matthew Wilson', 'GastroView Pro', 'I have been using the GastroView Pro for a few months now, and it has greatly improved my quality of life. The device is easy to use, and I feel confident in its ability to provide me with the care I need.'),
(15, '2024-03-15', 'Chloe Garcia', 'Ventilife 5000', 'The Ventilife 5000 has helped me monitor my health effectively, and I am grateful for the peace of mind it provides.'),
(16, '2024-04-20', 'Liam Davis', 'SynthoWave 2000', 'I recently underwent surgery with the assistance of the SynthoWave 2000 glucose monitor, and I am amazed at how smoothly the procedure went.'),
(17, '2024-05-25', 'Ella White', 'MusculoScan 1000', 'The MusculoScan 1000 muscle scanner has been a lifesaver for me. It has significantly improved my mobility and quality of life.'),
(18, '2024-06-30', 'James Taylor', 'VascuCheck 500', 'The VascuCheck 500 vascular monitor has been very helpful in diagnosing vascular issues in my patients. It is easy to use and provides accurate results.'),
(25, '2024-07-05', 'Eva Anderson', 'NexGen 4000', 'I have been using the NexGen 4000 for a few months now, and it has greatly improved my quality of life. The device is easy to use, and I feel confident in its ability to provide me with the care I need.'),
(26, '2024-08-10', 'Noah Martinez', 'QuantumMatrix', 'The QuantumMatrix has been a disappointment. Despite following the instructions carefully, I have not experienced any noticeable improvement in my condition. I am very disappointed and feel like I wasted my money on this device.'),
(27, '2024-09-15', 'Ava Garcia', 'VitaSphere 3000', 'The VitaSphere 3000 has helped me monitor my health effectively, and I am grateful for the peace of mind it provides.'),
(28, '2024-10-20', 'Liam Taylor', 'ZenithPro', 'I recently underwent surgery with the assistance of the ZenithPro monitoring system, and I am amazed at how smoothly the procedure went.'),
(29, '2024-11-25', 'Sophia Miller', 'FlexiTech 2000', 'The FlexiTech 2000 healthcare system has been a lifesaver for me. It has significantly improved my mobility and quality of life.'),
(30, '2024-12-30', 'Matthew Wilson', 'ProHealthPlus', 'The ProHealthPlus medical device has been very helpful in diagnosing health issues in my patients. It is easy to use and provides accurate results.'),
(31, '2024-07-05', 'Olivia Brown', 'NovaWave 6000', 'I have been using the NovaWave 6000 for a few months now, and it has greatly improved my quality of life. The device is easy to use, and I feel confident in its ability to provide me with the care I need.'),
(32, '2024-08-10', 'William Lee', 'SpectraMed 3000', 'The SpectraMed 3000 has been a disappointment. Despite following the instructions carefully, I have not experienced any noticeable improvement in my condition. I am very disappointed and feel like I wasted my money on this device.'),
(33, '2024-09-15', 'Charlotte Garcia', 'AlphaSense', 'The AlphaSense has helped me monitor my health effectively, and I am grateful for the peace of mind it provides.'),
(34, '2024-10-20', 'James Smith', 'EchoCare 8000', 'I recently underwent a diagnosis with the assistance of the EchoCare 8000 diagnostic equipment, and I am amazed at how smoothly the process went.'),
(35, '2024-11-25', 'Emily Johnson', 'BioFlex 4000', 'The BioFlex 4000 medical device has been a lifesaver for me. It has significantly improved my quality of life and provided me with accurate monitoring.'),
(36, '2024-12-30', 'Daniel Thompson', 'NeuroSense 2000', 'The NeuroSense 2000 neurological device has been very helpful in diagnosing neurological issues in my patients. It is easy to use and provides accurate results.'),
(37, '2024-07-05', 'Aiden Thompson', 'XenoGenix 5000', 'The XenoGenix 5000 has been an excellent addition to my health routine. It has significantly improved my condition, and I am grateful for its reliability.'),
(38, '2024-08-10', 'Sophia White', 'QuantaDrive', 'I am disappointed with the QuantaDrive. Despite using it diligently, I have not noticed any improvements in my health.'),
(39, '2024-09-15', 'Jackson Brown', 'VeloScan 2000', 'The VeloScan 2000 has provided me with accurate diagnostics, giving me peace of mind about my health.'),
(40, '2024-10-20', 'Olivia Johnson', 'BioPulse 3.8', 'I recently had a procedure with the BioPulse 3.8 monitoring system, and it was a smooth experience.'),
(41, '2024-11-25', 'William Davis', 'CryoTech 4000', 'The CryoTech 4000 has been instrumental in my recovery process. Its effectiveness has exceeded my expectations.'),
(42, '2024-12-30', 'Emma Martinez', 'VitaScan 1000', 'I have had a positive experience using the VitaScan 1000. It has helped me track my health accurately and efficiently.'),
(43, '2025-07-05', 'Liam Brown', 'EvoTech 7000', 'I am extremely satisfied with the EvoTech 7000. It has revolutionized the way I monitor my health, and I couldnt be happier with the results.'),
(44, '2025-08-10', 'Emma Wilson', 'NebulaSync', 'The NebulaSync has been a disappointment. Despite my high hopes, it has not met my expectations, and I am left feeling frustrated.'),
(45, '2025-09-15', 'Oliver Garcia', 'SynthraSys 9000', 'The SynthraSys 9000 has been an invaluable tool in managing my health. Its accuracy and reliability have provided me with peace of mind.'),
(46, '2025-10-20', 'Sophia Smith', 'TechVision Pro', 'I recently underwent a procedure with the TechVision Pro healthcare system, and I am pleased with the outcome. The process was smooth, and I felt well taken care of.'),
(47, '2025-11-25', 'Noah Johnson', 'MediSync 6000', 'The MediSync 6000 has exceeded my expectations. It has helped me manage my condition effectively, and I am grateful for its impact on my life.'),
(48, '2025-12-30', 'Ava Martinez', 'AquaSense 2000', 'The AquaSense 2000 has been a lifesaver for me. Its accuracy and ease of use have made it an essential part of my daily routine.'),
(13, '2025-08-01', 'Ethan Harris', 'Xerocore 2000', 'I am quite satisfied with the performance of the Xerocore 2000. It has been reliable and efficient in monitoring my health.'),
(14, '2025-08-15', 'Olivia Clark', 'FlexiCore 600', 'Unfortunately, the FlexiCore 600 has not lived up to my expectations. It seems to have technical issues frequently, causing inconvenience.'),
(15, '2025-09-01', 'William Young', 'MediPulse 7000', 'The MediPulse 7000 is an exceptional device. Its accuracy and ease of use have been incredibly helpful in managing my health condition.'),
(16, '2025-09-15', 'Sophia Rodriguez', 'TechNova 3000', 'I had a positive experience with the TechNova 3000. It is intuitive and provides accurate data that I can rely on.'),
(17, '2025-10-01', 'Daniel Martinez', 'SynthoGen 4000', 'Unfortunately, the SynthoGen 4000 has been a disappointment. It seems to have compatibility issues with other devices, making it unreliable.'),
(18, '2025-10-15', 'Isabella Hernandez', 'NeuraScan 1000', 'The NeuraScan 1000 has been instrumental in monitoring my health. It is user-friendly and provides comprehensive data that I find valuable.'),
(19, '2025-11-01', 'Alexander Lopez', 'BioSpectra 8000', 'I am extremely satisfied with the BioSpectra 8000. It has exceeded my expectations and has become an essential part of my daily routine.'),
(20, '2025-11-15', 'Mia Gonzalez', 'EcoView 6000', 'The EcoView 6000 has been a letdown. Despite its promising features, it seems to have reliability issues, which is concerning.'),
(21, '2025-12-01', 'Michael Perez', 'MediLink Pro', 'The MediLink Pro is a reliable device. It has helped me manage my health effectively, and I appreciate its performance.'),
(22, '2025-12-15', 'Charlotte Carter', 'TechSync 2000', 'Unfortunately, the TechSync 2000 has not met my expectations. It seems to have technical glitches that affect its performance.'),
(23, '2026-01-01', 'Benjamin Torres', 'SynthoPulse 3000', 'The SynthoPulse 3000 has been a game-changer for me. Its effectiveness in managing my health condition has been remarkable.'),
(24, '2026-01-15', 'Amelia Flores', 'NeuraSync 4000', 'I am quite satisfied with the NeuraSync 4000. It has been reliable and efficient in monitoring my health.');

/*==============================================================================
  SECTION 3: ANALYSIS QUERIES
  Description: Comprehensive analysis suite for device management
==============================================================================*/

/*------------------------------------------------------------------------------
  3.1 Device Performance Analysis
------------------------------------------------------------------------------*/
-- Device complaint rates and costs
SELECT 
    d.DeviceType,
    COUNT(c.ComplaintID) as ComplaintCount,
    AVG(d.PurchasePrice) as AvgPrice
FROM devices d
LEFT JOIN customer_complaints c ON d.DeviceID = c.DeviceID
GROUP BY d.DeviceType
ORDER BY ComplaintCount DESC;

/*------------------------------------------------------------------------------
  3.2 Maintenance and Warranty Analysis
------------------------------------------------------------------------------*/
-- Warranty status check
SELECT 
    DeviceName,
    WarrantyEndDate,
    DATEDIFF('day', CURRENT_DATE(), WarrantyEndDate) as DaysUntilExpiration
FROM devices
WHERE WarrantyEndDate < DATEADD('month', 3, CURRENT_DATE())
ORDER BY DaysUntilExpiration;

/*------------------------------------------------------------------------------
  3.3 Regulatory Compliance
------------------------------------------------------------------------------*/
-- Compliance monitoring
SELECT 
    DeviceName,
    RegulatoryApproval,
    ApprovalDate,
    DATEDIFF('month', ApprovalDate, CURRENT_DATE()) as MonthsSinceApproval
FROM devices
WHERE DATEDIFF('month', ApprovalDate, CURRENT_DATE()) > 24;

/*------------------------------------------------------------------------------
  3.4 Customer Satisfaction Analysis
------------------------------------------------------------------------------*/
-- Satisfaction scoring
SELECT 
    d.DeviceName,
    d.DeviceType,
    COUNT(c.ComplaintID) as ComplaintCount,
    AVG(CASE 
        WHEN LOWER(c.ComplaintDetails) LIKE '%disappointed%' OR 
             LOWER(c.ComplaintDetails) LIKE '%issue%' OR 
             LOWER(c.ComplaintDetails) LIKE '%problem%' THEN 0
        ELSE 1
    END) as SatisfactionScore
FROM devices d
LEFT JOIN customer_complaints c ON d.DeviceID = c.DeviceID
GROUP BY d.DeviceName, d.DeviceType
ORDER BY SatisfactionScore DESC;

/*==============================================================================
  SECTION 4: RESET FUNCTIONALITY
  Description: Commands to reset the database to its initial state
==============================================================================*/

-- Full reset command (drops and recreates everything):
-- DROP DATABASE IF EXISTS medtech_db;

-- Partial reset (keeps schema, clears data):
-- TRUNCATE TABLE customer_complaints;
-- TRUNCATE TABLE devices;

/*------------------------------------------------------------------------------
  Copyright (c) 2024 DemoHub.dev. All rights reserved.
------------------------------------------------------------------------------*/ 