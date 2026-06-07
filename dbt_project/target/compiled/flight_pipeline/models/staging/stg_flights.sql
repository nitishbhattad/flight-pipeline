WITH source AS (
    SELECT * FROM "flights_db"."raw"."flights_raw"
),

cleaned AS (
    SELECT
        fl_date::date                               AS flight_date,
        TRIM(op_unique_carrier)                     AS airline_code,
        TRIM(origin)                                AS origin_airport,
        TRIM(dest)                                  AS dest_airport,
        NULLIF(dep_delay::text, '')::float          AS departure_delay_min,
        NULLIF(arr_delay::text, '')::float          AS arrival_delay_min,
        cancelled::int                              AS is_cancelled,
        diverted::int                               AS is_diverted,
        NULLIF(actual_elapsed_time::text,'')::float AS elapsed_time_min,
        distance::float                             AS distance_miles,
        month::int                                  AS month_num,
        day_of_week::int                            AS day_of_week
    FROM source
    WHERE fl_date IS NOT NULL
)

SELECT * FROM cleaned