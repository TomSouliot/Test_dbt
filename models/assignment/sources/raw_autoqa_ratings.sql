
{{ config(materialized='table') }}

with auto_ratings as(
    select
        cast(autoqa_rating_id as STRING) as autoqa_rating_id,
        cast(autoqa_review_id as STRING) as autoqa_review_id, -- test gia na xtupaei an einai null, h na anhkei sta reviews
        cast(external_ticket_id	as INTEGER) as external_ticket_id, -- also should not be zero
        cast(payment_id	as INTEGER) as payment_id,
        cast(payment_token_id as INTEGER) as payment_token_id,
        cast(team_id as INTEGER) as team_id,
        cast(rating_category_id	as INTEGER) as rating_category_id,
        cast(rating_category_name as STRING) as rating_category_name, -- needs some cleaning, or mapping
        cast(rating_scale_score	as INTEGER) as rating_scale_score,
        cast(score as INTEGER) as score, -- tha mporuses na valeis testing accepted values
        cast(reviewee_internal_id as INTEGER) as reviewee_internal_id -- could be string as well since it is an id, but potentially in join it will be faster with INT

    from {{ source('dbt_ts_assignment' , 'seed_autoqa_ratings_test') }}

    where autoqa_rating_id is not null
)
select * from auto_ratings

-- no direct need to create here the conversation_unique_id as we are 2 grains below