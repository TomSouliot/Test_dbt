{{ config(materialized='table') }}

with auto_root_causes_agg as(
    select
        autoqa_rating_id,
        count(*) as nr_root_causes_provided,
        count(distinct root_cause) as nr_distinct_root_causes
        -- array_agg(root_cause) as root_causes_together

    from {{ ref('raw_autoqa_root_cause') }}

    group by 1
),

autoqa_ratings as (
    select
        ar.autoqa_rating_id,
        ar.autoqa_review_id,
        ar.unique_conversation_id,
        ar.external_ticket_id,
        ar.payment_id,
        ar.payment_token_id,
        ar.team_id,
        ar.rating_category_id,
        ar.rating_category_name,
        ar.rating_scale_score,
        ar.rating_score,
        ar.reviewee_internal_id,
        -- root cause metrics
        if(coalesce(arca.nr_root_causes_provided,0) >0 ,true,false) as has_root_cause_provided,
        arca.nr_root_causes_provided,
        arca.nr_distinct_root_causes

    from {{ ref('raw_autoqa_ratings') }} as ar
    left join auto_root_causes_agg as arca
        on ar.autoqa_rating_id = arca.autoqa_rating_id
)

select
    autoqa_rating_id,
    autoqa_review_id,
    unique_conversation_id,
    external_ticket_id,
    payment_id,
    payment_token_id,
    team_id,
    rating_category_id,
    rating_category_name,
    rating_scale_score,
    rating_score,
    reviewee_internal_id,
    -- root cause metrics
    has_root_cause_provided,
    nr_root_causes_provided,
    nr_distinct_root_causes
    
from autoqa_ratings