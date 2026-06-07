select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select dest_airport
from "flights_db"."analytics_staging"."stg_flights"
where dest_airport is null



      
    ) dbt_internal_test