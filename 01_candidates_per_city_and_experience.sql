-- Candidates count per city
SELECT city, COUNT(*) as count
FROM candidates
GROUP BY city

-- Experience statistics
SELECT avg(years_experience) as avg, MIN(years_experience) as min, MAX(years_experience) as max
FROM candidates

-- Applications by status
SELECT [status], COUNT(*) as count
FROM applications
GROUP BY status
