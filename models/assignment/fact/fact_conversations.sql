{{ config(materialized='table') }}

with autoqa_ratings_agg as(
    select
        unique_conversation_id,
        round((sum(rating_score) * 100) / nullif((max(rating_score) * count(*)),0),2) as iqs

    from {{ ref('fact_autoqa_ratings') }}

    group by 1

),

autoqa_reviews_agg as(
    select
        unique_conversation_id,
        count(*) as nr_reviews_performed_autoqa -- no need for distinct because we have ensured uniqueness
        
    from {{ ref('fact_autoqa_reviews') }}

    group by 1
),

manual_reviews_agg as(
    select
        unique_conversation_id,
        count(*) as nr_reviews_performed_manual -- no need for distinct because we have ensured uniqueness
        
    from {{ ref('fact_manual_reviews') }}

    group by 1
),

conversations as(
    select
        c.unique_conversation_id,
        c.external_ticket_id,
        c.payment_id,
        c.payment_token_id,
        c.conversation_created_at_date,
        c.conversation_created_at_utc,
        c.updated_at_utc,
        c.closed_at_utc,
        c.channel,
        c.assignee_id,
        -- metrics
        c.message_count,
        c.last_reply_at_utc,
        c.language,
        c.unique_public_agent_count,
        c.public_mean_character_count,
        c.public_mean_word_count,
        c.private_message_count,
        c.public_message_count,
        c.klaus_sentiment,
        c.is_closed,
        c.agent_most_public_messages,
        c.first_response_time_secs,
        c.first_resolution_time_secs,
        c.full_resolution_time_secs,
        c.most_active_internal_user_id,
        c.imported_at_utc,
        c.deleted_at_utc,
        -- ratings' metrics
        art.iqs,
        -- reviews' metrics
        if(coalesce(arv.nr_reviews_performed_autoqa,0) >0 ,true,false) as is_auto_reviewed, 
        arv.nr_reviews_performed_autoqa, -- should not coalesce metrics that will be used for aggregated calculations
        if(coalesce(mrv.nr_reviews_performed_manual,0) >0 ,true,false) as is_manually_reviewed,
        mrv.nr_reviews_performed_manual

    from {{ ref('raw_conversations') }} as c
    left join autoqa_ratings_agg as art
        on c.unique_conversation_id = art.unique_conversation_id
    left join autoqa_reviews_agg as arv
        on c.unique_conversation_id = arv.unique_conversation_id
    left join manual_reviews_agg as mrv
        on c.unique_conversation_id = mrv.unique_conversation_id
)
select * from conversations