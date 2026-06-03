{{ config(materialized='table') }}

-- Per-reading anomaly flag using a per-(device, metric) z-score.
-- z = (value - mean) / stddev, flagged when |z| > 2.

with readings as (
    select * from {{ ref('stg_readings') }}
),

stats as (
    select
        device,
        metric,
        avg(value)        as mean_value,
        stddev_pop(value) as std_value
    from readings
    group by device, metric
)

select
    r.id,
    r.device,
    r.metric,
    r.value,
    r.ts,
    round(s.mean_value::numeric, 4) as mean_value,
    round(s.std_value::numeric, 4)  as std_value,
    case
        when s.std_value is null or s.std_value = 0 then 0
        else round(((r.value - s.mean_value) / s.std_value)::numeric, 4)
    end as z_score,
    case
        when s.std_value is null or s.std_value = 0 then false
        else abs((r.value - s.mean_value) / s.std_value) > 2
    end as is_anomaly
from readings r
join stats s
    on  r.device = s.device
    and r.metric = s.metric
order by r.device, r.ts