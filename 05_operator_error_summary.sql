SELECT 
    operator_error,
    SUM(downtime_minutes) AS total_downtime,
    COUNT(*) AS jumlah_kejadian,
    ROUND(SUM(downtime_minutes) * 100.0 / SUM(SUM(downtime_minutes)) OVER (), 2) AS persentase
FROM downtime_master
GROUP BY operator_error; 	