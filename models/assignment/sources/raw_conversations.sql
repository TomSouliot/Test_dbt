{{ config(materialized='table') }}

with conversations as(
    select
        cast(external_ticket_id as INTEGER) as external_ticket_id,
        cast(payment_id as INTEGER) as payment_id,
        cast(payment_token_id as INTEGER) as payment_token_id,
        cast(conversation_created_at_date as DATE) as conversation_created_at_date,
        cast(conversation_created_at as TIMESTAMP) as conversation_created_at_utc,
        cast(updated_at as TIMESTAMP) as updated_at_utc, -- not sure where it refers to, because the business context gor the grain of the model is not clear to me
        cast(closed_at as TIMESTAMP) as closed_at_utc,
        cast(channel as STRING) as channel, -- #
        cast(assignee_id as INTEGER) as assignee_id,
        cast(message_count as INTEGER) as message_count,
        cast(last_reply_at as TIMESTAMP) as last_reply_at_utc,
        cast(language as STRING) as language,
        cast(unique_public_agent_count as INTEGER) as unique_public_agent_count,
        cast(public_mean_character_count as NUMERIC) as public_mean_character_count,
        cast(public_mean_word_count as NUMERIC) as public_mean_word_count,  -- #
        cast(private_message_count as INTEGER) as private_message_count,
        cast(public_message_count as INTEGER) as public_message_count,
        cast(klaus_sentiment as STRING) as klaus_sentiment,
        cast(is_closed as BOOLEAN) as is_closed,
        cast(agent_most_public_messages as INTEGER) as agent_most_public_messages,
        cast(first_response_time as INTEGER) as first_response_time_secs, -- not sure if corresponds to seconds
        cast(first_resolution_time_seconds as INTEGER) as first_resolution_time_secs,
        cast(full_resolution_time_seconds as INTEGER) as full_resolution_time_secs,
        cast(most_active_internal_user_id as INTEGER) as most_active_internal_user_id,
        --
        cast(imported_at as TIMESTAMP) as imported_at_utc,
        cast(deleted_at as INTEGER) as deleted_at_utc -- cannot properly treat this because it is always null in our case

    from {{ source('dbt_ts_assignment' , 'seed_conversations_test') }}

    where external_ticket_id is not null
        and payment_id is not null
        and payment_token_id is not null

)

select 
    {{ dbt_utils.generate_surrogate_key(['external_ticket_id','payment_id','payment_token_id'] )}} as unique_conversation_id,
    external_ticket_id,
    payment_id,
    payment_token_id,
    conversation_created_at_date,
    conversation_created_at_utc,
    updated_at_utc,
    closed_at_utc,
    channel,
    assignee_id,
    -- metrics
    message_count,
    last_reply_at_utc,
    language,
    unique_public_agent_count,
    public_mean_character_count,
    public_mean_word_count,
    private_message_count,
    public_message_count,
    klaus_sentiment,
    is_closed,
    agent_most_public_messages,
    first_response_time_secs -- not sure if corresponds to seconds
    first_resolution_time_secs,
    full_resolution_time_secs,
    most_active_internal_user_id,
    --
    imported_at_utc,
    deleted_at_utc

from conversations

-- maybe testing on individual fields fo the surrogate key is redundant but depends on the robustness in the control of the dwh
