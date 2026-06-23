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
