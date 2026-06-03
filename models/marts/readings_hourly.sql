{{ config(materialized='table') }}

with readings as (
    select * from {{ ref('stg_readings') }}
)

select
    device,
    metric,
    date_trunc('hour', ts)        as hour,
    count(*)                      as n_readings,
    round(avg(value)::numeric, 4) as avg_value,
    min(value)                    as min_value,
    max(value)                    as max_value
from readings
group by device, metric, date_trunc('hour', ts)
order by device, metric, hour