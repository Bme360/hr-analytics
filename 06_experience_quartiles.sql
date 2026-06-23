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
