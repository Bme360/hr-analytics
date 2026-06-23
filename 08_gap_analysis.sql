-- Find all the jobs that received applications but no candidate met the experience requirement
SELECT j.job_title, j.company_name,
        j.required_experience,
        COUNT(a.[status]) as count,
        MAX(c.years_experience) as max
from applications a JOIN candidates c
on a.candidate_id= c.candidate_id
join jobs j
on a.job_id=j.job_id
GROUP BY j.job_title, j.company_name, j.required_experience
HAVING MAX(c.years_experience) < j.required_experience
