--UDERSTANDING MEASURES

--outcomes table
SELECT 
	MIN(TotalSessions) AS min_session,
	MAX(TotalSessions) AS max_sesssion,
	AVG(TotalSessions) AS avg_totalsession,
	STDEV(TotalSessions) AS std_deviation
FROM outcomes
--patients have a minimum of 1 and maximum of 12 sesions 
--patients have an average of 6 sessions while the overall recommended sessions according to NHS is 6 to 12 sessions 
--standard deviation of 3.4 tells that patients have sessions close to each other

--referrals table
SELECT 
	MIN(WaitingDays) AS min_waitingdays,
	MAX(WaitingDays) AS max_waitingdays,
	AVG(WaitingDays) AS avg_waitingdays,
	STDEV(WaitingDays) AS std_deviation
FROM referrals
--patients wait a minimum of 1 and maximum of 59 days with an average wait of 27 days which lower than the NHS requiremnet of
--42 days. However, a high standard deviation of 11.6 tells that some patients wait extremely longer times compared to others.
---outliers are present in the distribution

--demographics table
SELECT 
	MIN(Age) AS min_age,
	MAX(Age) AS max_age,
	AVG(Age) AS avg_age,
	STDEV(Age) AS std_deviation
FROM demographics
-- patients accessing service are aged between 18 and 85 with patients averagely aged 42.
--This implies the service is accessed by middle aged population. A high standard deviation suggest
--some patients are way older than other patients 


--UNDERSTANDING CATEGORIES 
--outcomes table

--completed treatment
SELECT
   treatmentcompleted,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM outcomes
GROUP BY TreatmentCompleted
ORDER BY total DESC
--57.8% OF PATIENTS COMPLETE THEIR TREATMENT WHICH IS OVER THE 50% BENCHMARK SET BY THE NHS. HOWEVER IT IS STILLL ON A 
--LOW END OF COMPLETION WITH 42.2% UNCOMPLETED TREATMENTS. 



--dropoutstage
SELECT
   dropoutstage,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM outcomes
GROUP BY DropoutStage
ORDER BY total DESC
--It is hown that 17.5% of patients drop out after their first sessions 
--12% after second and mid treatment

--treatment type
SELECT
   treatmenttype,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM outcomes
GROUP BY treatmenttype
ORDER BY total DESC
--36% OF patients are being referred for Cognitive behavioural therapy (CBT), 23.9% counselling,16.9% group therapy,
--13.9% EMDR And 9.3% for mindfulness sessions

--REFERRALS TABLE

--referralsource
   SELECT 
	referralsource,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM referrals
GROUP BY referralsource
ORDER BY total DESC
--Most patients are being referred by their GP  followed by self referrral 




--region
SELECT
    Region,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM referrals
GROUP BY Region
ORDER BY total DESC

--London region has the highest referral cases

--dermographics table
--age-group
SELECT
   AgeGroup,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM demographics
GROUP BY AgeGroup
ORDER BY total DESC
--patients between the age of 36-50 are being referred the most and 65+ the least. 
--This tallys with the average earlier calculated as  42




--Gender
SELECT
   Gender,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM demographics
GROUP BY Gender
ORDER BY total DESC
--Female patients have the highest portion of referral of 51.3%


--ethnicity
SELECT
    Ethnicity,
    COUNT(*) AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM demographics
GROUP BY Ethnicity
ORDER BY total DESC

--White British tops the charts of ethnic group being referred with about 50.4%


---TIME ANALYSIS

--Patient referral by year
SELECT 
    YEAR(R.referraldate) AS yr_referred,
    COUNT(D.patientID) AS TOTALPATIENTS    
FROM demographics AS D 
JOIN referrals AS R
ON D.PatientID=R.PatientID
GROUP BY YEAR(R.referraldate)
ORDER BY COUNT(D.patientID) DESC;
--THERE HAS BEEN A DECREASE IN PATIENT REFERRALS 
--WHICH MIGHT INDICATE MORE PATIENTS NO LONGER NEED SERVICE OR WERE NOT REFERRED

--SESSION COMPLETIONS BY YEAR

SELECT 
    YEAR(R.referraldate) AS yr_referred,
    COUNT(O.Patientid) AS totalcompletions
FROM outcomes AS O
JOIN referrals AS R
ON O.PatientID=R.PatientID
WHERE O.TreatmentCompleted=1
GROUP BY YEAR(R.referraldate)
ORDER BY  COUNT(O.Patientid) DESC;
--COMPLETIONS decreased over the years with just 117 completions in 2023


--Completion rate per year

WITH TotalReferral AS (
    SELECT 
        YEAR(R.referraldate) AS yr_referred,
        COUNT(O.PatientID) AS Total_referrals  
    FROM outcomes AS O
    JOIN referrals AS R
        ON O.PatientID = R.PatientID
    GROUP BY YEAR(R.referraldate))



, Totalcompletions AS (
    SELECT 
        YEAR(R.referraldate) AS yr_referred,
        COUNT(O.PatientID) AS total_completions
    FROM outcomes AS O
    JOIN referrals AS R
        ON O.PatientID = R.PatientID
    WHERE O.TreatmentCompleted = 1
    GROUP BY YEAR(R.referraldate)
)

SELECT 
    T.yr_referred,
    T.Total_referrals,
    C.total_completions,
    CAST(C.total_completions * 100.0 / T.total_referrals AS DECIMAL(10,2)) AS completion_rate_percent
FROM TotalReferral T
LEFT JOIN TotalCompletions C
    ON T.yr_referred = C.yr_referred
ORDER BY T.yr_referred DESC;
--THE RESULT SHOWS A DECLINE IN COMPLETION RATE OVER THE YEARS WITH 2021 BEING 59.65%, 2022 56.19% AND 2023 56.80%
--overall, the completion rates have been over the 50% bench mark and seems to have been consistent with differences between completions very low. 
--However investigation stll need to be carried out on the high portion of referrals not completed

---RELATIONSHIP ANALYSIS

--WAITINGTIME VS COMPLETIONRATE
WITH treatment_completed AS (
SELECT
    CASE WHEN WaitingDays < 42 THEN 'Within standard'
    WHEN WaitingDays BETWEEN 42 AND 56 THEN'Borderline'
    ELSE 'Above standard' END AS waiting_class,
COUNT (D.PatientID) AS total
FROM referrals AS R
    JOIN demographics AS D
ON R.PatientID=D.PatientID
JOIN outcomes AS O ON
D.PatientID=O.PatientID
WHERE O.TreatmentCompleted=1
GROUP BY 
    CASE WHEN WaitingDays < 42 THEN 'Within standard'
    WHEN WaitingDays BETWEEN 42 AND 56 THEN'Borderline'
    ELSE 'Above standard' END )

,
TOTALReferrals AS (
SELECT
    CASE WHEN WaitingDays < 42 THEN 'Within standard'
    WHEN WaitingDays BETWEEN 42 AND 56 THEN'Borderline'
    ELSE 'Above standard' END AS waiting_classall,
COUNT (D.PatientID) AS overall_total
FROM referrals AS R
    JOIN demographics AS D
ON R.PatientID=D.PatientID

GROUP BY 
    CASE WHEN WaitingDays < 42 THEN 'Within standard'
    WHEN WaitingDays BETWEEN 42 AND 56 THEN'Borderline'
    ELSE 'Above standard' END)


    SELECT Waiting_class,
    total,
    total*100.0/overall_total AS completionrate

    FROM treatment_completed AS T
    JOIN TOTALReferrals AS TR
    ON T.waiting_class=TR.waiting_classall


    --66.7% OF completion rate is seen for patients waiting abov ethe satndard wait period, however, it is represented by just
    --2 patients so it is not enough represntation of the whole sample to draw conclusion from.
    --it can also be seen that 61.1% of patients  within stand waiting days completed their appointments and 36.1% who are in the border completed theirs.
    -- this difference in completion rates can be accounted for by the increased waiting time.
    --Therefore null hypothesis is rejected.
    --waiting time does have effect on completion rate

    -- RECOMMENDATION
    --Reducing borderline waiting times below 42 days
    --could potentially increase completion rates by up to 25%
-- ALos, Investigate which regions have highest borderline waiting 
-- times as they are likely driving the overall dropout rate



--completion rate by region
WITH Comleted_region AS (
SELECT  
    R.Region,
    COUNT(R.PatientID) AS Total_completed
FROM referrals AS R
JOIN outcomes AS O
    ON R.PatientID=O.PatientID
WHERE TreatmentCompleted=1
GROUP BY Region),

overall AS (
SELECT  Region,COUNT(PatientID) AS Totalpatients
FROM referrals 
GROUP BY Region)

SELECT C.Region,
C.Total_completed*100.0/O.Totalpatients AS completion_rate
FROM Comleted_region AS C
JOIN overall AS O
ON C.Region=O.Region
ORDER BY completion_rate DESC

--4 regions have high completion rate above the benchmark of 50% with
--Birmingham sitting on the borderline with 50.7% completion rate
--and London and Newcastle both  have  below benchmark completion rate
-- These same regions showed the highest  waiting times in the dataset
-- This suggests waiting time is a key factor of regional performance gaps
-- There is a diffrence of 30.9% between highest performing regions and lowest which
--indicates that regions do not perform equally
--Thus, safe to reject null hypothesis

--Recommendation
--investigation should be done into what is driving completion rate in other regions
--and be  implemented for low performing regions to create symmetry between completion rates







--completion rate by agegroup
WITH Agegroup_completion AS (
SELECT 
       D.AgeGroup, 
    COUNT(D.Patientid) AS totalpatients
FROM demographics AS D
JOIN outcomes AS O
    ON D.PatientID=O.PatientID
WHERE O.TreatmentCompleted=1
GROUP BY D.AgeGroup)
, 
Agegroup_overall AS (
SELECT 
    AgeGroup, 
    COUNT(Patientid) AS overallpatients
FROM demographics 
GROUP BY AgeGroup)

SELECT 
AC.AgeGroup,
AC.totalpatients*100.0/AO.overallpatients AS Completionrate

FROM Agegroup_completion AS AC JOIN 
Agegroup_overall AS AO
ON AC.AgeGroup=AO.AgeGroup
ORDER BY Completionrate DESC;

-- While all age groups exceed the 50% NHS benchmark,younger adults aged 18-35 consistently show lower completion rates
-- sitting closest to the benchmark threshold at 54.2% and 54.3%

-- Recommendation: Investigate whether treatment types offered
-- are appropriate and engaging for younger adults
-- Early intervention programmes tailored to 18-35 age group
-- could improve completion rates in this demographic

