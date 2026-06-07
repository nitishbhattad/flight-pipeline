select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select airline_code
from "flights_db"."analytics_staging"."stg_flights"
where airline_code is null



      
    ) dbt_internal_test