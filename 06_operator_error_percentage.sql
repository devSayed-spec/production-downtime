SELECT 
    operator,
    SUM(downtime_minutes) AS total_downtime_minutes, 
    SUM(CASE WHEN operator_error = 'Yes' THEN downtime_minutes ELSE 0 END) AS downtime_karena_operator,
    SUM(CASE WHEN operator_error = 'No' THEN downtime_minutes ELSE 0 END) AS downtime_bukankarena_operator,
	ROUND( 
			SUM(CASE WHEN operator_error = 'Yes' THEN downtime_minutes ELSE 0 END)::numeric/
			SUM(downtime_minutes) * 100, 2
			) AS persentase_error_operator 
FROM downtime_master
GROUP BY operator
ORDER BY downtime_karena_operator DESC;