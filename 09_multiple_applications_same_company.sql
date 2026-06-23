-- Find candidates who applied for 2 different positions at the same company
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
