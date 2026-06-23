-- For each month: how many hired, previous month hires, and % change
WITH monthly as
(
  SELECT FORMAT(apply_date, 'yyyy-MM') AS month , COUNT(*) AS monthly_hires
  from applications
  where [status]='hired' 
  GROUP BY FORMAT(apply_date, 'yyyy-MM')
)
SELECT month,
        monthly_hires,
      ( cast(monthly_hires as float) - cast(LAG(monthly_hires,1)over(ORDER BY month) as float) ) / cast(NULLIF(LAG(monthly_hires,1) OVER (ORDER BY month), 0) as float)*100 as pct_change
from monthly
