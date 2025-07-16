USE papollo_healthcare_db;
## 🔰 Beginner Level Questions

-- What are the top 5 most common diagnoses?
SELECT
Diagnosis, COUNT(*)
FROM apollohealthcare
GROUP BY Diagnosis;

-- What is the distribution of diagnoses(count) for patients specifically admitted to the 'ICU' Bed_Occupancy type?
SELECT
Diagnosis,
COUNT(Patient_ID) AS DiagnosisCounts
FROM apollohealthcare
WHERE Bed_Occupancy = 'ICU'
GROUP BY Diagnosis
ORDER BY DiagnosisCounts;

-- Which Doctor has attended to the most admission records?
SELECT
Doctor,
COUNT(Patient_ID) AS PatientCounts
FROM apollohealthcare
GROUP BY Doctor;

-- How many patients have a Followup_Date scheduled (i.e., Followup_Date is not null)?
SELECT
COUNT(*)
FROM apollohealthcare
WHERE Followup_Date IS NOT NULL;

-- What is the average Billing_Amount per admission record?
SELECT
ROUND(AVG(Billing_Amount)) AS AverageBillingAmount
FROM apollohealthcare;

-- What is the total Health_Insurance_Amount claimed across all records?
SELECT
SUM(Health_Insurance_Amount) AS TOTAL_HEALTH_INSURANCE_AMOUNT
FROM apollohealthcare;

-- What is the average Health_Insurance_Amount per record?
SELECT
ROUND(AVG(Health_Insurance_Amount)) AS TOTAL_HEALTH_INSURANCE_AMOUNT
FROM apollohealthcare;

-- What is the average Billing_Amount for each Bed_Occupancy type?
SELECT
Bed_Occupancy,
ROUND(AVG(Billing_Amount)) AS AverageBillingAmount
FROM apollohealthcare
GROUP BY Bed_Occupancy;

-- What is the total outstanding amount(sum of Billing Amount - Health Insurance Amount) across all records?
SELECT
SUM(Billing_Amount - Health_Insurance_Amount) AS TotalOutstandingAmount
FROM apollohealthcare;

-- What percentage of admission records show a `Health_Insurance_Amount` greater than 0?
SELECT
    (COUNT(CASE WHEN Health_Insurance_Amount > 0 THEN 1 END) * 100.0) / COUNT(*) AS PercentageWithInsurance
FROM apollohealthcare;

## 🔷 Intermediate Level Questions

-- How many patients were admitted each month and year?
SELECT
YEAR(Admit_Date) AS YEAR,
MONTHNAME(Admit_Date) AS MONTH,
COUNT(Patient_ID) AS PatientsAdmitted
FROM apollohealthcare
GROUP BY YEAR(Admit_Date), MONTHNAME(Admit_Date);

-- What is the overall average length of stay for patients (Discharge Date - Admit Date)?
SELECT
ROUND(AVG(DATEDIFF(Discharge_Date, Admit_date))) AS AvgStayInDAYS
FROM apollohealthcare;

-- What is the average number of distinct Tests mentioned per unique patient?
WITH PatientTestCounts AS (
    SELECT Patient_ID, COUNT(DISTINCT Test) AS NumberOfDistinctTests
    FROM apollohealthcare
    WHERE Test IS NOT NULL
    GROUP BY Patient_ID
)
SELECT AVG(NumberOfDistinctTests) AS AvgDistinctTestsPerPatient
FROM PatientTestCounts;

-- Show the count of patients for each combination of Diagnosis and Bed_Occupancytype.
SELECT
Bed_Occupancy,
Diagnosis,
COUNT(Patient_ID) AS Count
FROM apollohealthcare
GROUP BY Bed_Occupancy, Diagnosis
ORDER BY Bed_Occupancy;

-- List Doctors who have treated more than a certain number of patients (e.g., >10 patients) for a specific Diagnosis(e.g., 'Pneumonia').
SELECT
Doctor,
COUNT(Patient_ID) AS PatientCount
FROM apollohealthcare
WHERE Diagnosis = 'Fracture'
GROUP BY Doctor
HAVING COUNT(*) > 10;

-- What is the average time (in days) between a patient's Discharge_Date and their Followup_Date?
SELECT
ROUND(AVG(DATEDIFF(Followup_Date, Discharge_Date))) AS AvgFollowupDAYS
FROM apollohealthcare;

-- What is the average length of stay for each Diagnosis?
SELECT
Diagnosis,
ROUND(AVG(DATEDIFF(Discharge_Date, Admit_date))) AS AvgStayinDAYS
FROM apollohealthcare
GROUP BY Diagnosis;

-- What is the patient turnover rate(e.g., number of patients discharged per month)?
SELECT
YEAR(Discharge_Date) AS YEAR,
MONTHNAME(Discharge_Date) AS MONTH,
COUNT(*) AS DischargedPerMonth
FROM apollohealthcare
GROUP BY YEAR(Discharge_Date), MONTHNAME(Discharge_Date);


-- Are there seasonal trends in specific diagnoses(e.g., count of 'Flu' cases per month of admission)?
SELECT
    MONTHNAME(Admit_Date) AS AdmittedMonth,
    COUNT(*) AS FluCaseCount
FROM apollohealthcare
WHERE Diagnosis = 'Flu'
GROUP BY AdmittedMonth
ORDER BY AdmittedMonth;

-- What is the distribution of patient Feedback scores(e.g., count of ratings 1-1.9, 2-2.9, ..., 5)?
SELECT
Feedback,
COUNT(Patient_ID) AS PatientCounts
FROM apollohealthcare
GROUP BY Feedback
ORDER BY PatientCounts DESC;

-- OR

SELECT
    CASE
        WHEN Feedback >= 1 AND Feedback < 2 THEN '1-1.9'
        WHEN Feedback >= 2 AND Feedback < 3 THEN '2-2.9'
        WHEN Feedback >= 3 AND Feedback < 4 THEN '3-3.9'
        WHEN Feedback >= 4 AND Feedback < 5 THEN '4-4.9'
        WHEN Feedback = 5 THEN '5'
        ELSE 'Other'
    END AS FeedbackRange,
    COUNT(*) AS NumberOfFeedbacks
FROM apollohealthcare
GROUP BY FeedbackRange
ORDER BY FeedbackRange;

-- Which Doctors have an average Feedback rating below 3.0?
SELECT
Doctor,
AVG(Feedback) AS AvgFeedback
FROM apollohealthcare
GROUP BY Doctor
HAVING AVG(Feedback) < 3;


## 🚀 Advanced Level Questions

-- For each Diagnosis, what are the top 2 most frequently conducted Tests?
SELECT
Diagnosis,
Test,
TestsCounts
FROM(
	SELECT
	Diagnosis,
	Test,
	COUNT(Test) AS TestsCounts,
	RANK() OVER(PARTITION BY Diagnosis ORDER BY COUNT(Test) DESC) AS rnks
	FROM apollohealthcare
	GROUP BY Diagnosis, Test
) t
WHERE rnks < 3;

-- OR

WITH RankedTests AS (
    SELECT
        Diagnosis,
        Test,
        COUNT(*) AS TestCount,
        ROW_NUMBER() OVER(PARTITION BY Diagnosis ORDER BY COUNT(*) DESC) as rn
    FROM apollohealthcare
    WHERE Test IS NOT NULL
    GROUP BY Diagnosis, Test
)
SELECT Diagnosis, Test, TestCount
FROM RankedTests
WHERE rn <= 2
ORDER BY Diagnosis, rn;

-- Do patients in the top 25% of Billing_Amounts give significantly different average Feedback compared to the other 75%?
WITH PatientBillingPercentiles AS (
    SELECT
        Patient_ID,
        Feedback,
        Billing_Amount,
        NTILE(4) OVER (ORDER BY Billing_Amount DESC) as BillingQuartile -- 1 is top 25%
    FROM apollohealthcare
)
SELECT
    CASE
        WHEN BillingQuartile = 1 THEN 'Top 25% Billing'
        ELSE 'Bottom 75% Billing'
    END AS BillingGroup,
    AVG(Feedback) AS AverageFeedback,
    COUNT(Patient_ID) AS NumberOfPatients
FROM PatientBillingPercentiles
GROUP BY BillingGroup;


-- For each Diagnosis, what is the median length of stay(Note: median is harder in SQL than average, often requiring window functions or specific dialect functions)?
-- Calculate a "Doctor Performance Score" where the score is `(Average Feedback 0.6) + (Number of Unique Patients Treated 0.4 / Max Patients Treated by Any Doctor)`. (This requires defining a custom formula and potentially subqueries to get max values).
-- What is the month-over-month growth rate of patient admissions?
-- Are there any Doctors who consistently receive low Feedback scores (e.g., average < 3) across multiple different diagnoses(e.g., for at least 3 distinct diagnoses they handle)?
-- Which Diagnosis has the highest variance or standard deviation in Billing_Amounts?
-- Identify peak admission days/timesif `Admit_Date` also contained a time component (not specified, but a common advanced analysis).