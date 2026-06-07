
  
    

  create  table "flights_db"."analytics_marts"."mart_airline_performance__dbt_tmp"
  
  
    as
  
  (
    WITH base AS (
    SELECT * FROM "flights_db"."analytics_intermediate"."int_flight_delays"
),

airlines AS (
    SELECT * FROM "flights_db"."analytics"."airline_names"
)

SELECT
    DATE_TRUNC('month', flight_date)::date       AS month,
    base.airline_code,
    airlines.airline_name,
    airlines.airline_type,
    COUNT(*)                                      AS total_flights,
    SUM(is_cancelled)                             AS total_cancelled,
    SUM(CASE WHEN is_severely_delayed
        THEN 1 ELSE 0 END)                        AS severely_delayed_flights,
    ROUND(AVG(departure_delay_min)::numeric, 2)   AS avg_dep_delay_min,
    ROUND(AVG(arrival_delay_min)::numeric, 2)     AS avg_arr_delay_min,
    ROUND(100.0 * SUM(is_cancelled)
        / COUNT(*)::numeric, 2)                   AS cancellation_rate_pct,
    ROUND(100.0 * SUM(
        CASE WHEN flight_status = 'On Time'
        THEN 1 ELSE 0 END)
        / COUNT(*)::numeric, 2)                   AS on_time_rate_pct
FROM base
LEFT JOIN airlines ON base.airline_code = airlines.airline_code
GROUP BY 1, 2, 3, 4
ORDER BY 1, 5 DESC
  );
  