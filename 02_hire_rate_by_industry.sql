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
