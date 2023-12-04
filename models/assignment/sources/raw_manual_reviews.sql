{{ config(materialized='table') }}

with manual_reviews as(
    select
        cast(review_id as INTEGER) as manual_review_id,
        cast(conversation_external_id as INTEGER) as conversation_external_id,
        cast(payment_id as INTEGER) as payment_id,
        cast(payment_token_id as INTEGER) as payment_token_id,
        cast(created as DATETIME) as review_created_at,
        cast(updated_at as DATETIME) as review_updated_at,
        cast(imported_at as DATETIME) as review_imported_at,
        cast(conversation_created_at as TIMESTAMP) as conversation_created_at_utc,
        cast(conversation_created_date as DATE) as conversation_created_at_date,
        cast(team_id as INTEGER) as team_id,
        cast(reviewer_id as INTEGER) as reviewer_id,
        cast(reviewee_id as INTEGER) as reviewee_id,
        cast(comment_id as INTEGER) as comment_id,
        cast(updated_by as INTEGER) as updated_by,
        cast(scorecard_id as INTEGER) as scorecard_id,
        cast(scorecard_tag as STRING) as scorecard_tag,
        cast(score as NUMERIC) as score,
        cast(seen as BOOLEAN) as is_seen,
        cast(disputed as BOOLEAN) as is_disputed,
        cast(review_time_seconds as NUMERIC) as review_time_seconds, -- no data, guess numeric
        cast(assignment_review as BOOLEAN) as is_assignment_reviewed,
        cast(assignment_name as STRING) as assignment_name

    from {{ source('dbt_ts_assignment' , 'seed_manual_reviews_test') }}

    where review_id is not null

)

select 
    manual_review_id,
    {{ dbt_utils.generate_surrogate_key(['conversation_external_id','payment_id','payment_token_id'] )}} as unique_conversation_id,
    conversation_external_id, --seems that corresponds to external_ticket_id, maybe it would make sense to rename for data consistency
    payment_id,
    payment_token_id,
    review_created_at,
    review_updated_at,
    review_imported_at,
    conversation_created_at_utc,
    conversation_created_at_date,
    team_id,
    reviewer_id,
    reviewee_id,
    comment_id,
    updated_by,
    scorecard_id,
    scorecard_tag,
    score,
    is_seen,
    is_disputed,
    review_time_seconds, -- no data, guess numeric
    is_assignment_reviewed,
    assignment_name

from manual_reviews

-- we need to apply not null testing on the individual fields forming the unqiue conversation id in order to avoid any potential duplicates