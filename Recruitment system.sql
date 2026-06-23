

SELECT city, COUNT(*) as count
FROM candidates
GROUP BY city

SELECT avg(years_experience) as avg ,MIN(years_experience) as min,MAX(years_experience) as max
FROM candidates


SELECT [status],COUNT(*) as count
FROM applications
GROUP BY status


SELECT  j.industry,
        count(*) as total_candidate,
        sum(case
        when a.status = 'hired' then 1 end) as total_referrals,
        ROUND(CAST(
        sum(case
        when a.status = 'hired' then 1 end) as decimal(10,2))/cast (count(*) as decimal(10,2) )*100,2)  as 'total_referrals_%'
                                    
FROM jobs j join applications a
on j.job_id=a.job_id
GROUP BY j.industry
ORDER BY 'total_referrals_%' DESC






SELECT DISTINCT city,ROUND(linkedin_score,1) as linkedin_score
from    (select city as city,
        linkedin_score as linkedin_score,   
        RANK()OVER(PARTITION BY city ORDER BY linkedin_score desc) as rn
        FROM candidates)a
        where rn=1
        ORDER BY linkedin_score desc


SELECT
  interview_id,
  interview_score,
  ROUND(AVG(interview_score) OVER (), 2) AS global_avg,
  ROUND(interview_score -
    AVG(interview_score) OVER (), 2) AS diff_from_avg
FROM interviews
ORDER BY diff_from_avg DESC;


SELECT  j.industry,
        count(*) as total_candidate,
        sum(case
        when a.status = 'hired' then 1 end) as hired,
        sum(case
        when a.status = 'interview' then 1 end) as interview,
        ROUND(CAST(
        sum(case
        when a.status = 'interview' or  a.status = 'hired' then 1 end) as float)/cast (count(*) as float )*100,2)  as 'Conversion Rate hired and interview',
        ROUND(CAST(
        sum(case
        when a.status = 'hired' then 1 end)as float)/
        cast(sum(case when a.status = 'interview' or a.status = 'hired' then 1 end) as float)*100,2) as 'Candidate Conversion Rate'
                                    
FROM jobs j join applications a
on j.job_id=a.job_id
GROUP BY j.industry
ORDER BY 'Conversion Rate hired and interview','Candidate Conversion Rate' asc





WITH quartiles AS (
  SELECT
    c.candidate_id,
    c.linkedin_score,
    NTILE(4) OVER (ORDER BY c.years_experience) AS exp_quartile
  FROM candidates c
),
apps AS (
  SELECT candidate_id,
    MAX(CASE WHEN status='hired' THEN 1 ELSE 0 END) AS ever_hired
  FROM applications
  GROUP BY candidate_id
)
SELECT
  q.exp_quartile,
  COUNT(*) AS candidates,
  ROUND(AVG(q.linkedin_score), 2) AS avg_linkedin,
  ROUND(AVG(CAST(a.ever_hired AS FLOAT)) * 100, 1) AS hire_rate_pct
FROM quartiles q
LEFT JOIN apps a ON q.candidate_id = a.candidate_id
GROUP BY q.exp_quartile
ORDER BY q.exp_quartile;



WITH quartiles AS (
  SELECT
    c.candidate_id,
    c.linkedin_score,
    NTILE(4) OVER (ORDER BY c.years_experience) AS exp_quartile
  FROM candidates c
),
apps AS (
  SELECT candidate_id,status,
    MAX(CASE WHEN status='hired' THEN 1 ELSE 0 END) AS ever_hired
  FROM applications
  GROUP BY candidate_id,status
)
SELECT
  a.STATUS,
  q.exp_quartile,
  COUNT(*) AS candidates,
  ROUND(AVG(q.linkedin_score), 2) AS avg_linkedin,
  ROUND(AVG(CAST(a.ever_hired AS FLOAT)) * 100, 1) AS hire_rate_pct
FROM quartiles q
LEFT JOIN apps a ON q.candidate_id = a.candidate_id
GROUP BY q.exp_quartile,a.STATUS
ORDER BY q.exp_quartile;



-- Analyzing the full recruitment funnel and calculating conversion rates

SELECT DISTINCT COUNT(a.application_id),
  count(CASE 
  WHEN a.[status]='hired' or  a.[status]='interview'  THEN  1 END) as 'Of which passed the CV screening',
  sum(CASE 
  WHEN i.round = 1  THEN  1 END) as 'round_1',
  sum(CASE 
  WHEN i.round = 2  THEN  1 END) as 'round_2',
  sum(CASE 
  WHEN i.round = 3  THEN  1 END) as 'round_3',
  sum(CASE 
  WHEN a.[status]='hired' THEN  1 END) as 'Final status hired'

FROM applications a LEFT JOIN interviews i
on a.application_id = i.application_id


-- Find all the jobs that received applications — but no candidate met the experience requirement

SELECT j.job_title,j.company_name,
        j.required_experience,
        COUNT(a.[status]) as count,
        MAX(c.years_experience)  as max
from applications a JOIN candidates c
on a.candidate_id= c.candidate_id
join jobs j
on a.job_id=j.job_id
GROUP BY j.job_title,j.company_name,j.required_experience
HAVING  MAX(c.years_experience)<j.required_experience


--Find candidates who applied for 2 different positions at the same company.

SELECT full_name,company_name,total_date_range_days
from(
SELECT  DISTINCT c.full_name as full_name,
       j.company_name as company_name,
        count(j.job_title)over(PARTITION BY c.full_name,j.company_name) AS some_job,
        DATEDIFF(day, MIN(a.apply_date) OVER (PARTITION BY c.full_name,j.company_name), MAX(a.apply_date) OVER (PARTITION BY c.full_name,j.company_name)) AS total_date_range_days
from applications a JOIN candidates c
on a.candidate_id= c.candidate_id
join jobs j
on a.job_id=j.job_id
GROUP BY c.full_name,
        j.company_name
        ,j.job_title,
        a.apply_date)a
where some_job>1
ORDER BY total_date_range_days




SELECT  DISTINCT c.full_name as full_name,
       j.company_name as company_name,
       COUNT(DISTINCT j.job_id) as some_job,
       DATEDIFF(day, MIN(a.apply_date), MAX(a.apply_date)) as total_date_range_days
from applications a JOIN candidates c
on a.candidate_id= c.candidate_id
join jobs j
on a.job_id=j.job_id
GROUP BY c.full_name,
        j.company_name
HAVING  COUNT(DISTINCT j.job_id)>1
ORDER BY DATEDIFF(day, MIN(a.apply_date), MAX(a.apply_date))

--For each month, show: how many were recruited, how many were recruited in the previous month, and the percentage of change.


WITH monthly as
(
  SELECT FORMAT(apply_date, 'yyyy-MM') AS month , COUNT(*) AS monthly_hires
  from applications
  where [status]='hired' 
  GROUP BY FORMAT(apply_date, 'yyyy-MM')
)
SELECT month,
        monthly_hires,
      ( cast(monthly_hires as float) - cast(LAG(monthly_hires,1)over(ORDER BY month) as float) ) / cast(NULLIF(LAG(monthly_hires,1) OVER (ORDER BY month), 0) as float)*100 as a
from monthly