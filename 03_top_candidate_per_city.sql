SELECT DISTINCT city, ROUND(linkedin_score,1) as linkedin_score
from    (select city as city,
        linkedin_score as linkedin_score,   
        RANK()OVER(PARTITION BY city ORDER BY linkedin_score desc) as rn
        FROM candidates)a
        where rn=1
        ORDER BY linkedin_score desc
