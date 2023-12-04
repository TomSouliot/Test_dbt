{{ config(materialized='table') }}

with manual_ratings as(
    select
        cast(review_id as INTEGER) as manual_review_id,
        cast(category_id as INTEGER) as category_id,
        cast(category_name as STRING) as category_name,
        cast(rating as INTEGER) as rating,
        cast(rating_max as INTEGER) as rating_max,
        cast(weight as NUMERIC) as weight, -- in google docs, there is numeric or decimal, seems this is not an integer
        cast(if(cause = '[]',null,cause) as STRING) as cause, -- not sure, potentially this could be a JSON if it has many causes together
        cast(critical as BOOLEAN) as is_critical,
        cast(payment_id as INTEGER) as payment_id,
        cast(team_id as INTEGER) as team_id

    from {{ source('dbt_ts_assignment' , 'seed_manual_ratings_test') }}

    where review_id is not null
        and category_id is not null -- debatable, with the current approach we will use it to form the unique key
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

-- the grain of the model should be rating_id, a surrogate key that ensures uniqueness is review_id + category_id