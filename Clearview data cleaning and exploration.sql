--ROWS COUNT FOR ALL TABLES

SELECT COUNT(* )FROM appointments
SELECT COUNT(*) FROM demographics
SELECT COUNT(*) FROM outcomes
SELECT COUNT(*) FROM referrals
--match total before loading 

-- UNDERSTANDING DATA COLUMNS
SELECT TOP 5 * FROM appointments
SELECT TOP 5 * FROM demographics
SELECT TOP 5 * FROM outcomes
SELECT TOP 5 * FROM referrals
--all tables contain relevant fields for analysis 
--column names make sense and contain relevant information




---CHECKING FOR NULLS IN EACH TABLE - nulls checked  based on how important columns are to analysis

--appointmnet table
SELECT 
	COUNT(*) AS total,
	COUNT(*)- COUNT(AppointmentID) AS appointment_null,
	COUNT(*) - COUNT(PatientID) AS patient_null,
	COUNT(*) - COUNT(AppointmentDate) AS date_null,
	COUNT(*) - COUNT(Attendance) AS attendance_null
FROM appointments
-- no nulls present


--demographics table

SELECT 
	COUNT(*) AS totalcount,
	COUNT(*)-COUNT(PatientID) AS nullpatient,
	COUNT(*)-COUNT(Gender) AS nullgender,
	COUNT(*)- COUNT(Ethnicity) AS nullethnicity,
	COUNT(*) - COUNT(AgeGroup) AS agegroup_null,
	COUNT(*) - COUNT(Region) AS region_null
FROM demographics
--gender and ethnicity columns have nulls ; 15 and 40 respectively


--outcomes table
SELECT 
	COUNT(*) AS totalcount,
	COUNT(*)-COUNT(PatientID) AS null_patient,
	COUNT(*)-COUNT(TreatmentCompleted) AS null_completed,
	COUNT(*)- COUNT(TotalSessions) AS null_sessions,
	COUNT(*) - COUNT(DropoutStage) AS null_dropout
FROM outcomes
--dropout column has 20 nulls 



--referrals table 

SELECT 
	COUNT(*) AS totalcount,
	COUNT(*)-COUNT(PatientID) AS nullpatient,
	COUNT(*)-COUNT(ReferralDate) AS nullreferraldate,
	COUNT(*)- COUNT(WaitingDays) AS nullwaitingdays,
	COUNT(*) - COUNT(ReferralSource) AS nullreferralsource
FROM referrals
--waiting days=10 nulls
--referral source= 25 nulls 


--CHECK FOR DUPLICATES

--appointment table
SELECT appointmentID,
COUNT(*) AS totalcount
FROM appointments
GROUP BY AppointmentID
HAVING COUNT(*) > 1
--15 DUPLICATES FOUND 


--Demographics table
SELECT patientID,
COUNT(*) AS totalcount
FROM demographics
GROUP BY PatientID
HAVING COUNT(*) > 1
--no duplicate


--outcomes table
SELECT patientID,
COUNT(*) AS totalcount
FROM outcomes
GROUP BY PatientID
HAVING COUNT(*) > 1
--no duplicate

--referrals table
SELECT patientID,
COUNT(*) AS totalcount
FROM referrals
GROUP BY PatientID
HAVING COUNT(*) > 1;
--no duplicate




--Handle duplicates 

WITH duplicate AS (
SELECT * ,
ROW_NUMBER() OVER( PARTITION BY appointmentID ORDER BY 
appointmentID ) AS rnk
FROM appointments
)

DELETE FROM duplicate
WHERE rnk>1 ;

SELECT COUNT(*) FROM appointments



--handle nulls in outcomes table
UPDATE outcomes
SET DropoutStage='Completed'
WHERE TreatmentCompleted =1 AND DropoutStage IS NULL

UPDATE outcomes
SET DropoutStage='unknown'
WHERE TreatmentCompleted =0 AND DropoutStage IS NULL

SELECT * FROM outcomes
WHERE DropoutStage IS NULL

--handle nulls in demographics  table

UPDATE demographics
SET Gender= 'Not stated'
WHERE Gender IS NULL 


UPDATE demographics
SET Ethnicity ='Not stated'
WHERE Ethnicity IS NULL


SELECT * FROM demographics
WHERE gender IS NULL AND Ethnicity IS NULL

--handle nulls in referrals  table

UPDATE referrals
SET ReferralSource= 'Unknown'
WHERE ReferralSource IS NULL 

UPDATE referrals
SET WaitingDays= DATEDIFF(DAY,ReferralDate, FirstAppointmentDate)
WHERE WaitingDays IS NULL

SELECT * 
FROM referrals WHERE WaitingDays IS NULL
AND ReferralSource IS NULL



--CHECK DATA TYPE 

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'appointments'

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'outcomes'

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'referrals'

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'demographics'

 --PatientID imported as money data type and Values are consistent across all tables and joins are unaffected
--Data type converted  to integer in Power Query on import to Power BI





