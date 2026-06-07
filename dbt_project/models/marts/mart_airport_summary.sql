WITH departures AS (
    SELECT
        origin_airport                               AS airport,
        COUNT(*)                                     AS total_departures,
        ROUND(AVG(departure_delay_min)::numeric, 2)  AS avg_dep_delay_min,
        SUM(is_cancelled)                            AS total_cancelled
    FROM {{ ref('int_flight_delays') }}
    GROUP BY 1
),

arrivals AS (
    SELECT
        dest_airport                                 AS airport,
        COUNT(*)                                     AS total_arrivals,
        ROUND(AVG(arrival_delay_min)::numeric, 2)    AS avg_arr_delay_min
    FROM {{ ref('int_flight_delays') }}
    GROUP BY 1
)

SELECT
    d.airport,
    d.total_departures,
    a.total_arrivals,
    d.total_departures + a.total_arrivals            AS total_operations,
    d.avg_dep_delay_min,
    a.avg_arr_delay_min,
    d.total_cancelled,
    ROUND(100.0 * d.total_cancelled
        / d.total_departures::numeric, 2)            AS cancellation_rate_pct
FROM departures d
JOIN arrivals a ON d.airport = a.airport
ORDER BY total_operations DESC
