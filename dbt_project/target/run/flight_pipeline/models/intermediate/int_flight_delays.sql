
  create view "flights_db"."analytics_intermediate"."int_flight_delays__dbt_tmp"
    
    
  as (
    WITH stg AS (
    SELECT * FROM "flights_db"."analytics_staging"."stg_flights"
)

SELECT
    flight_date,
    airline_code,
    origin_airport,
    dest_airport,
    departure_delay_min,
    arrival_delay_min,
    is_cancelled,
    is_diverted,
    distance_miles,
    elapsed_time_min,
    month_num,
    day_of_week,

    CASE
        WHEN is_cancelled = 1          THEN 'Cancelled'
        WHEN departure_delay_min > 15  THEN 'Delayed'
        WHEN departure_delay_min < -5  THEN 'Early'
        ELSE                                'On Time'
    END AS flight_status,

    CASE
        WHEN distance_miles < 500                    THEN 'Short Haul'
        WHEN distance_miles BETWEEN 500 AND 1500     THEN 'Medium Haul'
        ELSE                                              'Long Haul'
    END AS route_type,

    CASE
        WHEN departure_delay_min > 60  THEN TRUE
        ELSE                                FALSE
    END AS is_severely_delayed

FROM stg
  );