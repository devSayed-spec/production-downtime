SELECT
    operator,
    SUM(downtime_minutes) AS total_downtime_minutes,
    COUNT(*) AS jumlah_insiden,
    ROUND(AVG(downtime_minutes)::numeric, 1) AS rata_rata_durasi_per_insiden
FROM downtime_master
GROUP BY operator
ORDER BY rata_rata_durasi_per_insiden DESC;