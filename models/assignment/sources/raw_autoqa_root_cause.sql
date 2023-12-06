
{{ config(materialized='table') }}

with root_causes as(
    select
        cast(autoqa_rating_id as string) as autoqa_rating_id,
        cast(category as string) as category,
        cast(count as integer) as count,
        cast(root_cause as string) as root_cause
        
    from {{ source('dbt_ts_assignment' , 'seed_autoqa_root_cause_test') }}

    where autoqa_rating_id is not null
        and root_cause is not null
)

select * from root_causes

-- deduplication is not performed because we cannot form a primary key