
{{ config(materialized='table') }}

with auto_ratings as(
    select
        cast(autoqa_rating_id as STRING) as autoqa_rating_id,
        cast(autoqa_review_id as STRING) as autoqa_review_id,
        cast(external_ticket_id	as INTEGER) as external_ticket_id,
        cast(payment_id	as INTEGER) as payment_id,
        cast(payment_token_id as INTEGER) as payment_token_id,
        cast(team_id as INTEGER) as team_id,
        cast(rating_category_id	as INTEGER) as rating_category_id,
        cast(rating_category_name as STRING) as rating_category_name, -- normally needs cleaning or mapping
        cast(rating_scale_score	as INTEGER) as rating_scale_score,
        cast(score as INTEGER) as rating_score,
        cast(reviewee_internal_id as INTEGER) as reviewee_internal_id

    from {{ source('dbt_ts_assignment' , 'seed_autoqa_ratings_test') }}

    where autoqa_rating_id is not null
)

select 
    autoqa_rating_id,
    autoqa_review_id,
    {{ dbt_utils.generate_surrogate_key(['external_ticket_id','payment_id','payment_token_id'] )}} as unique_conversation_id,
    external_ticket_id,
    payment_id,
    payment_token_id,
    team_id,
    rating_category_id,
    case 
        when lower(rating_category_name) like 'grammar%' then 'Grammar'
        when lower(rating_category_name) like 'greeting%' and lower(rating_category_name) not like 'greeting a%' then 'Greeting'
        when lower(rating_category_name) like 'empathy%' and lower(rating_category_name) not like 'empathy a%' then 'Empathy'
        else rating_category_name
    end as rating_category_name,
    rating_scale_score,
    rating_score, -- almost 5500 rows with null score
    reviewee_internal_id

from auto_ratings

-- deduplication (ideally we would need a timestamp of when each row was loaded in the landing table to order properly)
--- indicatively ordering happens with the rating_category_id, will serve the intended purpose but not correct approach
qualify row_number() over (partition by autoqa_rating_id order by rating_category_id desc) = 1