{{ config(materialized='view') }}

with source as (
    select * from {{ source('telemetry', 'readings') }}
)

select
    id,
    device,
    metric,
    value,
    ts
from source