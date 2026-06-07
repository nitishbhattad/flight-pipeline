WITH base AS (
    SELECT * FROM {{ ref('int_flight_delays') }}
)

SELECT
    origin_airport,
    dest_airport,
    route_type,
    COUNT(*)                                      AS total_flights,
    ROUND(AVG(departure_delay_min)::numeric, 2)   AS avg_dep_delay_min,
    ROUND(AVG(arrival_delay_min)::numeric, 2)     AS avg_arr_delay_min,
    ROUND(AVG(elapsed_time_min)::numeric, 2)      AS avg_flight_duration_min,
    ROUND(AVG(distance_miles)::numeric, 2)        AS avg_distance_miles,
    SUM(is_cancelled)                             AS total_cancelled,
    ROUND(100.0 * SUM(is_cancelled)
        / COUNT(*)::numeric, 2)                   AS cancellation_rate_pct
FROM base
GROUP BY 1, 2, 3
HAVING COUNT(*) > 10
ORDER BY total_flights DESC
