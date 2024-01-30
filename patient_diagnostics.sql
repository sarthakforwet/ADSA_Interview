use adsa;demo

-- 1. List the top 5 diagnoses in the dataset, overall, and by each site. Show diagnosis names and the counts in descending order of frequency

-- Top 5 Diagnoses Overall
SELECT dx_map.condition, COUNT(*) as diagnosis_count
FROM dx
JOIN dx_map ON dx.dx_code = dx_map.dx_code AND dx.dx_method = dx_map.dx_method
GROUP BY dx_map.condition
ORDER BY diagnosis_count DESC
LIMIT 5;

-- Top 5 Diagnoses by Each Site
WITH RankedDiagnoses AS (
    SELECT 
        demo.site, 
        dx_map.condition, 
        COUNT(demo.patient_id) as diagnosis_count,
        ROW_NUMBER() OVER (PARTITION BY demo.site ORDER BY COUNT(demo.patient_id) DESC) as row_num
    FROM dx
    JOIN dx_map ON dx.dx_code = dx_map.dx_code AND dx.dx_method = dx_map.dx_method
    JOIN demo ON dx.patient_id = demo.patient_id
    GROUP BY demo.site, dx_map.condition
)
SELECT site, `condition`, diagnosis_count
FROM RankedDiagnoses
WHERE row_num <= 5;


-- 2. What is the percentage of each gender in the dataset? 
SELECT gender, (COUNT(gender) * 100.0 / (SELECT COUNT(gender) FROM demo)) as percentage
FROM demo
GROUP BY gender;
-- Data Can be cleaned here.


-- 3. How many unique patients have been diagnosed with hypertension
SELECT COUNT(DISTINCT dx.patient_id) as 'Patients with Hypertension'
FROM dx
WHERE dx.dx_method in (SELECT DISTINCT dx_method FROM dx_map WHERE `condition`='Hypertension') 
AND dx.dx_code in (SELECT DISTINCT dx_code FROM dx_map WHERE `condition`='Hypertension');

-- 4. We are looking to do a prospective study where the inclusion criteria are all living patients 18 years of age or older. Provide the sample size of this identified cohort, both overall and by site. 

-- Overall 
SELECT COUNT(demo.patient_id)
FROM demo
WHERE STR_TO_DATE(birth_date, '%Y-%m-%d') <= CURDATE() - INTERVAL 18 YEAR 
AND (death_date IS NULL OR death_date = 'NA' OR STR_TO_DATE(death_date, '%Y-%m-%d') > CURDATE());

-- By Site
SELECT site, COUNT(demo.patient_id)
FROM demo
WHERE STR_TO_DATE(birth_date, '%Y-%m-%d') <= CURDATE() - INTERVAL 18 YEAR 
AND (death_date IS NULL OR death_date = 'NA' OR STR_TO_DATE(death_date, '%Y-%m-%d') > CURDATE())
GROUP BY site;