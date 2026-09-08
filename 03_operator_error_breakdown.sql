SELECT 
	operator, 
	description,
	SUM (downtime_minutes) AS total_downtime_minutes
FROM downtime_master
WHERE operator_error = 'Yes'
GROUP BY operator, description
ORDER BY SUM(downtime_minutes) DESC;