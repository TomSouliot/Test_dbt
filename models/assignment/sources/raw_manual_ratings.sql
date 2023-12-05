{{ config(materialized='table') }}

with manual_ratings as(
    select
        cast(review_id as INTEGER) as manual_review_id,
        cast(category_id as INTEGER) as category_id,
        cast(category_name as STRING) as category_name,
        cast(rating as INTEGER) as rating,
        cast(rating_max as INTEGER) as rating_max,
        cast(weight as NUMERIC) as weight,
        cast(if(cause = '[]',null,cause) as STRING) as cause, -- potentially this could be a JSON if it has many causes together
        cast(critical as BOOLEAN) as is_critical,
        cast(payment_id as INTEGER) as payment_id,
        cast(team_id as INTEGER) as team_id

    from {{ source('dbt_ts_assignment' , 'seed_manual_ratings_test') }}

    -- we do not want to bring in rows without those attributes, as those attributes combined form the primary key.
    -- mising any of those could potentially lead to falsely duplicate primary keys
    where review_id is not null
        and category_id is not null
)

select 
    {{ dbt_utils.generate_surrogate_key(['manual_review_id','category_id'] )}} as manual_rating_id,
    manual_review_id,
    category_id,
    category_name,
    rating,
    rating_max,
    weight,
    cause,
    is_critical,
    payment_id,
    team_id
from manual_ratings

-- deduplication (ideally we would need a timestamp of when each row was loaded in the landing table to order properly)
--- indicatively ordering happens with the rating_category_id, will serve the intended purpose but not correct approach
qualify row_number() over (partition by manual_rating_id order by category_id desc) = 1