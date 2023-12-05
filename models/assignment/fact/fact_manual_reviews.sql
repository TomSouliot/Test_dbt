{{ config(materialized='table') }}

with manual_ratings_agg as(
    select
        manual_review_id,
        count(*) as nr_ratings_performed,
        count(distinct category_id) as nr_categories_rated -- if data quality is good those 2 metrics should be the same
        
    from {{ ref('raw_manual_ratings') }}

    group by 1
),

manual_reviews as (
    select
        rv.manual_review_id,
        rv.unique_conversation_id,
        rv.conversation_external_id,
        rv.payment_id,
        rv.payment_token_id,
        rv.review_created_at,
        rv.review_updated_at,
        rv.review_imported_at,
        rv.conversation_created_at_utc,
        rv.conversation_created_at_date,
        rv.team_id,
        rv.reviewer_id,
        rv.reviewee_id,
        rv.comment_id,
        rv.updated_by,
        rv.scorecard_id,
        rv.scorecard_tag,
        rv.score,
        rv.is_seen,
        rv.is_disputed,
        rv.review_time_seconds,
        rv.is_assignment_reviewed,
        rv.assignment_name,
        --ratings' metrics
        rt.nr_ratings_performed,
        rt.nr_categories_rated

    from {{ ref('raw_manual_reviews') }} as rv
    left join manual_ratings_agg as rt
        on rv.manual_review_id = rt.manual_review_id
)

select
    manual_review_id,
    unique_conversation_id,
    conversation_external_id,
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
    review_time_seconds,
    is_assignment_reviewed,
    assignment_name,
    --ratings' metrics
    nr_ratings_performed,
    nr_categories_rated
    
from manual_reviews