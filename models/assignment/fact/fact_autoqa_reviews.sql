{{ config(materialized='table') }}

with auto_ratings_agg as(
    select
        autoqa_review_id,
        count(*) as nr_ratings_submitted,
        count(distinct rating_category_id) as nr_categories_rated,
        avg(score) as avg_score_rated
        
    from {{ ref('fact_autoqa_ratings') }}

    group by 1
),

autoqa_reviews as (
    select
        rv.autoqa_review_id,
        rv.unique_conversation_id,
        rv.payment_id,
        rv.payment_token_id,
        rv.external_ticket_id,
        rv.team_id,
        rv.reviewee_internal_id,
        rv.review_created_at_utc,
        rv.review_updated_at_utc,
        rv.conversation_created_at_utc,
        rv.conversation_created_at_date,
        --ratings' metrics
        rt.nr_ratings_submitted,
        rt.nr_categories_rated,
        rt.avg_score_rated

    from {{ ref('raw_autoqa_reviews') }} as rv
    left join auto_ratings_agg as rt
        on rv.autoqa_review_id = rt.autoqa_review_id
)

select
    autoqa_review_id,
    unique_conversation_id,
    payment_id,
    payment_token_id,
    external_ticket_id,
    team_id,
    reviewee_internal_id,
    review_created_at_utc,
    review_updated_at_utc,
    conversation_created_at_utc,
    conversation_created_at_date,
    --ratings' metrics
    nr_ratings_submitted,
    nr_categories_rated,
    avg_score_rated
    
from autoqa_reviews