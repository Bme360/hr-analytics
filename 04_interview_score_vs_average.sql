SELECT
  interview_id,
  interview_score,
  ROUND(AVG(interview_score) OVER (), 2) AS global_avg,
  ROUND(interview_score -
    AVG(interview_score) OVER (), 2) AS diff_from_avg
FROM interviews
ORDER BY diff_from_avg DESC;
