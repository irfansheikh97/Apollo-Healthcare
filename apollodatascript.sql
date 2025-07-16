CREATE DATABASE papollo_healthcare_db;

USE papollo_healthcare_db;

/************** DATA EXPLORATION, DATA CLEANING, HANDLING NULL VALUES, REMOVING DUPLICATES AND NULL VALUES ***************/

-- CHANGED COLUMN NAMES FROM TABLE
ALTER TABLE apollohealthcare 
RENAME COLUMN `Followup Date` TO `Followup_Date`, 
RENAME COLUMN `Billing Amount` TO `Billing_Amount`,
RENAME COLUMN `Health Insurance Amount` TO `Health_Insurance_Amount`;

-- CHANGED DATE FORMATS OF COLUMNS FROM TABLE
UPDATE apollohealthcare 
SET Admit_Date = STR_TO_DATE(Admit_Date, '%m/%d/%Y');

UPDATE apollohealthcare 
SET Discharge_Date = STR_TO_DATE(Discharge_Date, '%m/%d/%Y');

UPDATE apollohealthcare 
SET Followup_Date = STR_TO_DATE(Followup_Date, '%m/%d/%Y');

-- NULL VALUES CHECK
SELECT * FROM apollohealthcare
WHERE Patient_ID IS NULL OR Admit_Date IS NULL OR Discharge_Date IS NULL OR Diagnosis IS NULL OR Bed_Occupancy IS NULL OR Test IS NULL OR Doctor IS NULL
OR Followup_Date IS NULL OR Feedback IS NULL OR Billing_Amount IS NULL OR Health_Insurance_Amount IS NULL;

-- REMOVED WHITE SPACES FROM TEXT COLUMNS
UPDATE apollohealthcare
SET Diagnosis = TRIM(Diagnosis);

/****************************************** DATA EXPLORATIONS *****************************************************/
-- Total Records in database
SELECT COUNT(*) AS TOTAL_RECORDS FROM apollohealthcare;
-- OR
SELECT COUNT(DISTINCT Patient_ID) AS TOTAL_RECORDS FROM apollohealthcare;

-- What is the total Billing_Amount for all recorded admissions?
SELECT
SUM(Billing_Amount) AS TOTAL_AMOUNT
FROM apollohealthcare;

-- Duplicates Values check on patient_id
SELECT Patient_ID, COUNT(*) AS DuplicatesCount FROM apollohealthcare
GROUP BY Patient_ID
HAVING COUNT(*) > 1;

/************************************ DATA ANALYSIS AND FINDINGS ***************************************************/

-- 1.Write a SQL query to retrieve all columns for patients admitted on '2023-1-05'
SELECT 
* 
FROM apollohealthcare
WHERE Admit_Date = '2023-01-09';

-- 2) Write a SQL query to calculate the total Billing amount and Average Billing amount for each diagnosis.
SELECT 
Diagnosis, 
SUM(Billing_Amount) AS TotalBillingAmount,
ROUND(AVG(Billing_Amount)) AS AverageBillingAmount
FROM apollohealthcare
GROUP BY Diagnosis
ORDER BY TotalBillingAmount DESC, AverageBillingAmount;

-- 3) Write a SQL query to retrieve all patients who has Viral Infection and feedback given is greater than 4.
SELECT
*
FROM apollohealthcare
WHERE Diagnosis = 'Viral Infection'
AND Feedback >= 3;

-- 4) Write a SQL query to find the average feedback for each Doctors.
SELECT
Doctor, 
ROUND(AVG(Feedback),1) AS AverageFeedback
FROM apollohealthcare
GROUP BY Doctor
ORDER BY AverageFeedback DESC;

-- 5) Write SQL query to find all billing amount greater then 5000 by diagnosis.
SELECT
Patient_ID,
Diagnosis,
Billing_Amount
FROM apollohealthcare
WHERE Billing_Amount > 5000
ORDER BY Diagnosis;

-- 6) Write a SQL query to find the total number of patients affected by diagnosis.
SELECT
Diagnosis,
COUNT(*) AS TotalPatients
FROM apollohealthcare
GROUP BY Diagnosis
ORDER BY TotalPatients DESC;

-- 7) Write a SQL query to find the Doctors who looked for each diagnosis and total Billing amount.
SELECT
Doctor,
Diagnosis,
SUM(Billing_Amount) AS TotalAmount
FROM apollohealthcare
GROUP BY Doctor, Diagnosis
ORDER BY Doctor;

-- 8) Write a SQL query to calculate the total billing amount for each month.
SELECT
YEAR(Discharge_Date) AS YEAR,
MONTHNAME(Discharge_Date) AS MONTH,
SUM(Billing_Amount) AS BillingAmountPerMonth
FROM apollohealthcare
GROUP BY YEAR(Discharge_Date), MONTHNAME(Discharge_Date);

-- 9) What is the distribution of patients(count) across different Bed_Occupancytypes?
SELECT
Bed_Occupancy,
COUNT(Patient_ID) AS DistributionOfBeds
FROM apollohealthcare
GROUP BY Bed_Occupancy;

-- 10. What is the distribution of diagnoses(count) for patients specifically admitted to the 'ICU' Bed_Occupancy type?
SELECT
Diagnosis,
Bed_Occupancy,
COUNT(Patient_ID) AS DiagnosisCounts
FROM apollohealthcare
WHERE Bed_Occupancy = 'ICU'
GROUP BY Diagnosis
ORDER BY DiagnosisCounts;

-- 11.How many patients were admitted each month and year?
SELECT
YEAR(Admit_Date) AS YEAR,
MONTHNAME(Admit_Date) AS MONTH,
COUNT(Patient_ID) AS PatientsAdmitted
FROM apollohealthcare
GROUP BY YEAR(Admit_Date), MONTHNAME(Admit_Date);

-- 12. Show the count of patients for each combination of Diagnosis and Bed_Occupancytype.
SELECT
Bed_Occupancy,
Diagnosis,
COUNT(Patient_ID) AS Count
FROM apollohealthcare
GROUP BY Bed_Occupancy, Diagnosis
ORDER BY Bed_Occupancy;






