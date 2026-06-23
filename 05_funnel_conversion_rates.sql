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
