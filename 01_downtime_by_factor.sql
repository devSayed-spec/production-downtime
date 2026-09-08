SELECT 
	description,
	SUM(downtime_minutes) AS total_dwontime_minutes
FROM downtime_master
GROUP BY description
ORDER BY SUM(downtime_minutes) DESC;