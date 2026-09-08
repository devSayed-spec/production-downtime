SELECT 
    SUM(pr.total_minutes) AS total_waktu_aktual,
    SUM(p.min_batch_time) AS total_waktu_minimum,
    ROUND(
        SUM(p.min_batch_time)::numeric / SUM(pr.total_minutes) * 100, 
        2
    ) AS persentase_efisiensi
FROM productivity pr
JOIN products p ON pr.product = p.product;