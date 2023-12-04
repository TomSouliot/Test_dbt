
{{ config(materialized='table') }}

with auto_reviews as(
    select
        cast(autoqa_review_id as STRING) as autoqa_review_id,
        cast(payment_id	as INTEGER) as payment_id,
        cast(payment_token_id as INTEGER) as payment_token_id,
        cast(external_ticket_id	as INTEGER) as external_ticket_id,
        cast(team_id as INTEGER) as team_id,
        cast(reviewee_internal_id as INTEGER) as reviewee_internal_id,
        cast(created_at as TIMESTAMP) as review_created_at_utc,
        cast(updated_at as TIMESTAMP) as review_updated_at_utc,
        cast(conversation_created_at as TIMESTAMP) as conversation_created_at_utc,
        cast(conversation_created_date as DATE) as conversation_created_at_date

    from {{ source('dbt_ts_assignment' , 'seed_autoqa_reviews_test') }}

    where autoqa_review_id is not null
)

select 
    autoqa_review_id,
    {{ dbt_utils.generate_surrogate_key(['external_ticket_id','payment_id','payment_token_id'] )}} as unique_conversation_id,
    payment_id,
    payment_token_id,
    external_ticket_id,
    team_id,
    reviewee_internal_id,
    review_created_at_utc,
    review_updated_at_utc,
    conversation_created_at_utc,
    conversation_created_at_date

from auto_reviews