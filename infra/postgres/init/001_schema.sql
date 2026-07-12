-- Docker PostgreSQL 초기 구동 시 자동 실행되는 MaeMoJi 스키마입니다.

create table users (
    id bigserial primary key,
    email varchar(255) not null,
    password_hash varchar(255) not null,
    nickname varchar(100) not null,
    status varchar(30) not null default 'ACTIVE',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index uk_users_email on users (email);

create table stocks (
    id bigserial primary key,
    symbol varchar(30) not null,
    ticker varchar(30) not null,
    exchange varchar(30) not null,
    exchange_code varchar(30) not null,
    finnhub_symbol varchar(50),
    name_ko text,
    name_en text not null,
    ticker_normalized varchar(30) not null,
    name_ko_normalized text,
    name_en_normalized text not null,
    search_text text not null,
    logo_url text,
    logo_status varchar(20),
    logo_checked_at timestamptz,
    market_type varchar(50),
    asset_type varchar(30) not null,
    currency varchar(10) not null default 'USD',
    country varchar(10) not null default 'US',
    sector text,
    industry text,
    is_active boolean not null default true,
    last_master_sync_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index uk_stocks_symbol on stocks (symbol);
create unique index uk_stocks_ticker_exchange
    on stocks (ticker, exchange_code);

create unique index uk_stocks_finnhub_symbol
    on stocks (finnhub_symbol)
    where finnhub_symbol is not null;

create index idx_stocks_name_ko on stocks (name_ko);
create index idx_stocks_name_en on stocks (name_en);
create index idx_stocks_ticker_normalized on stocks (ticker_normalized);
create index idx_stocks_name_ko_normalized on stocks (name_ko_normalized);
create index idx_stocks_name_en_normalized on stocks (name_en_normalized);

create table portfolio_items (
    id bigserial primary key,
    user_id bigint not null,
    stock_id bigint not null,
    daily_invest_amount numeric(15, 2) not null,
    holding_quantity numeric(18, 6),
    investment_start_date date,
    memo text,
    source_type varchar(20) not null default 'MANUAL',
    source_connection_id bigint,
    linked_broker_position boolean not null default false,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ck_portfolio_items_source_type
        check (source_type in ('MANUAL', 'TOSS_SYNC')),
    constraint fk_portfolio_items_user
        foreign key (user_id) references users (id),
    constraint fk_portfolio_items_stock
        foreign key (stock_id) references stocks (id)
);

create unique index uk_portfolio_items_user_stock
    on portfolio_items (user_id, stock_id);

create index idx_portfolio_items_user_id
    on portfolio_items (user_id);

create table toss_connections (
    id bigserial primary key,
    user_id bigint not null,
    connection_name varchar(100) not null,
    client_id varchar(255) not null,
    client_secret_encrypted text not null,
    client_secret_masked varchar(100) not null,
    status varchar(30) not null default 'ACTIVE',
    last_token_issued_at timestamptz,
    last_sync_at timestamptz,
    last_sync_status varchar(30),
    last_sync_error_code varchar(100),
    last_sync_error_message text,
    is_primary boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ck_toss_connections_status
        check (status in ('ACTIVE', 'INVALID_CREDENTIAL', 'DISCONNECTED', 'SYNC_FAILED')),
    constraint fk_toss_connections_user
        foreign key (user_id) references users (id)
);

create unique index uk_toss_connections_user_client
    on toss_connections (user_id, client_id);

create unique index uk_toss_connections_primary_per_user
    on toss_connections (user_id)
    where is_primary = true;

create table toss_accounts (
    id bigserial primary key,
    connection_id bigint not null,
    account_seq bigint not null,
    account_type varchar(50) not null,
    account_no_masked varchar(50),
    display_name varchar(100) not null,
    status varchar(30) not null default 'ACTIVE',
    is_selected boolean not null default false,
    is_active boolean not null default true,
    last_synced_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ck_toss_accounts_status
        check (status in ('ACTIVE', 'INACTIVE')),
    constraint fk_toss_accounts_connection
        foreign key (connection_id) references toss_connections (id)
);

create unique index uk_toss_accounts_connection_seq
    on toss_accounts (connection_id, account_seq);

create unique index uk_toss_accounts_selected_per_connection
    on toss_accounts (connection_id)
    where is_selected = true;

create table toss_portfolio_snapshots (
    id bigserial primary key,
    connection_id bigint not null,
    account_id bigint not null,
    sync_batch_id bigint,
    stock_id bigint,
    symbol varchar(30) not null,
    stock_name varchar(255) not null,
    market_country varchar(20),
    currency varchar(10),
    quantity numeric(20, 6),
    average_purchase_price numeric(20, 6),
    current_price numeric(20, 6),
    profit_rate numeric(12, 6),
    weight_percent numeric(12, 6),
    is_closed_position boolean not null default false,
    captured_at timestamptz not null,
    created_at timestamptz not null default now(),
    constraint fk_toss_snapshots_connection
        foreign key (connection_id) references toss_connections (id),
    constraint fk_toss_snapshots_account
        foreign key (account_id) references toss_accounts (id),
    constraint fk_toss_snapshots_stock
        foreign key (stock_id) references stocks (id)
);

create index idx_toss_snapshots_account_captured
    on toss_portfolio_snapshots (account_id, captured_at desc);

create table toss_portfolio_mappings (
    id bigserial primary key,
    user_id bigint not null,
    account_id bigint not null,
    stock_id bigint not null,
    portfolio_item_id bigint not null,
    latest_snapshot_id bigint,
    sync_status varchar(20) not null default 'LINKED',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ck_toss_mappings_sync_status
        check (sync_status in ('LINKED', 'UNMATCHED', 'INACTIVE')),
    constraint fk_toss_mappings_user
        foreign key (user_id) references users (id),
    constraint fk_toss_mappings_account
        foreign key (account_id) references toss_accounts (id),
    constraint fk_toss_mappings_stock
        foreign key (stock_id) references stocks (id),
    constraint fk_toss_mappings_portfolio_item
        foreign key (portfolio_item_id) references portfolio_items (id),
    constraint fk_toss_mappings_snapshot
        foreign key (latest_snapshot_id) references toss_portfolio_snapshots (id)
);

create unique index uk_toss_mappings_user_account_stock
    on toss_portfolio_mappings (user_id, account_id, stock_id);

create table portfolio_sync_jobs (
    id bigserial primary key,
    user_id bigint not null,
    connection_id bigint not null,
    account_id bigint,
    job_type varchar(30) not null,
    job_status varchar(30) not null,
    started_at timestamptz not null,
    finished_at timestamptz,
    synced_stock_count integer not null default 0,
    created_portfolio_item_count integer not null default 0,
    updated_portfolio_item_count integer not null default 0,
    failed_stock_count integer not null default 0,
    error_code varchar(100),
    error_message text,
    created_at timestamptz not null default now(),
    constraint ck_portfolio_sync_jobs_type
        check (job_type in ('MANUAL_SYNC', 'AUTO_SYNC', 'REPAIR_SYNC')),
    constraint ck_portfolio_sync_jobs_status
        check (job_status in ('RUNNING', 'SUCCESS', 'PARTIAL_SUCCESS', 'FAILED')),
    constraint fk_portfolio_sync_jobs_user
        foreign key (user_id) references users (id),
    constraint fk_portfolio_sync_jobs_connection
        foreign key (connection_id) references toss_connections (id),
    constraint fk_portfolio_sync_jobs_account
        foreign key (account_id) references toss_accounts (id)
);

create table portfolio_profile_settings (
    id bigserial primary key,
    user_id bigint not null,
    profile_visibility varchar(20) not null default 'PRIVATE',
    show_profit_rate boolean not null default false,
    show_holdings boolean not null default true,
    show_badges boolean not null default true,
    show_weight_percent boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint ck_portfolio_profile_settings_visibility
        check (profile_visibility in ('PRIVATE', 'FOLLOWERS', 'PUBLIC')),
    constraint fk_portfolio_profile_settings_user
        foreign key (user_id) references users (id)
);

create unique index uk_portfolio_profile_settings_user
    on portfolio_profile_settings (user_id);

create table portfolio_item_reasons (
    id bigserial primary key,
    portfolio_item_id bigint not null,
    reason_code varchar(50) not null,
    display_order integer not null default 0,
    created_at timestamptz not null default now(),
    constraint fk_portfolio_item_reasons_item
        foreign key (portfolio_item_id) references portfolio_items (id)
);

create unique index uk_portfolio_item_reasons_item_code
    on portfolio_item_reasons (portfolio_item_id, reason_code);

create table portfolio_weekly_reports (
    id bigserial primary key,
    user_id bigint not null,
    report_week date not null,
    generated_at timestamptz not null,
    headline varchar(200) not null,
    summary text not null,
    changed_item_count integer not null default 0,
    alert_item_count integer not null default 0,
    positive_item_count integer not null default 0,
    negative_item_count integer not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint fk_portfolio_weekly_reports_user
        foreign key (user_id) references users (id)
);

create unique index uk_portfolio_weekly_reports_user_week
    on portfolio_weekly_reports (user_id, report_week);

create table portfolio_weekly_report_items (
    id bigserial primary key,
    report_id bigint not null,
    portfolio_item_id bigint not null,
    stock_id bigint not null,
    current_status varchar(20) not null,
    previous_status varchar(20),
    score_delta integer not null default 0,
    headline_label varchar(50) not null,
    change_type varchar(50) not null,
    summary text not null,
    display_order integer not null default 0,
    created_at timestamptz not null default now(),
    constraint fk_portfolio_weekly_report_items_report
        foreign key (report_id) references portfolio_weekly_reports (id),
    constraint fk_portfolio_weekly_report_items_portfolio_item
        foreign key (portfolio_item_id) references portfolio_items (id),
    constraint fk_portfolio_weekly_report_items_stock
        foreign key (stock_id) references stocks (id)
);

create index idx_portfolio_weekly_report_items_report_id
    on portfolio_weekly_report_items (report_id, display_order asc, id asc);

create table user_alert_events (
    id bigserial primary key,
    user_id bigint not null,
    portfolio_item_id bigint,
    stock_id bigint,
    alert_type varchar(50) not null,
    title varchar(200) not null,
    body text not null,
    dedupe_key varchar(200) not null,
    sent_at timestamptz,
    read_at timestamptz,
    created_at timestamptz not null default now(),
    constraint fk_user_alert_events_user
        foreign key (user_id) references users (id),
    constraint fk_user_alert_events_portfolio_item
        foreign key (portfolio_item_id) references portfolio_items (id),
    constraint fk_user_alert_events_stock
        foreign key (stock_id) references stocks (id)
);

create unique index uk_user_alert_events_dedupe_key
    on user_alert_events (dedupe_key);

create table user_notification_preferences (
    id bigserial primary key,
    user_id bigint not null unique,
    instant_alert_enabled boolean not null default true,
    weekly_digest_enabled boolean not null default true,
    price_risk_alert_enabled boolean not null default true,
    news_weakened_alert_enabled boolean not null default true,
    status_changed_alert_enabled boolean not null default true,
    quiet_hours_enabled boolean not null default false,
    quiet_hours_start time,
    quiet_hours_end time,
    timezone varchar(64) not null default 'Asia/Seoul',
    weekly_digest_day varchar(16) not null default 'MONDAY',
    weekly_digest_time time not null default '08:30:00',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint fk_user_notification_preferences_user
        foreign key (user_id) references users (id)
);

create index idx_user_notification_preferences_user_id
    on user_notification_preferences (user_id);

create table user_device_tokens (
    id bigserial primary key,
    user_id bigint not null,
    device_platform varchar(20) not null,
    device_identifier varchar(191),
    fcm_token varchar(512) not null,
    app_version varchar(50),
    push_enabled boolean not null default true,
    is_active boolean not null default true,
    last_seen_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deactivated_at timestamptz,
    constraint fk_user_device_tokens_user
        foreign key (user_id) references users (id)
);

create unique index uk_user_device_tokens_token
    on user_device_tokens (fcm_token);

create index idx_user_device_tokens_user_active
    on user_device_tokens (user_id, is_active, push_enabled);

create table push_notification_deliveries (
    id bigserial primary key,
    alert_event_id bigint,
    user_id bigint not null,
    device_token_id bigint not null,
    notification_kind varchar(30) not null,
    alert_type varchar(40) not null,
    dedupe_key varchar(255) not null,
    title varchar(255) not null,
    body text not null,
    payload_json text,
    delivery_status varchar(30) not null default 'PENDING',
    provider_message_id varchar(255),
    provider_error_code varchar(120),
    provider_error_message text,
    sent_at timestamptz,
    delivered_at timestamptz,
    created_at timestamptz not null default now(),
    constraint fk_push_notification_deliveries_alert
        foreign key (alert_event_id) references user_alert_events (id),
    constraint fk_push_notification_deliveries_user
        foreign key (user_id) references users (id),
    constraint fk_push_notification_deliveries_token
        foreign key (device_token_id) references user_device_tokens (id)
);

create unique index uk_push_notification_deliveries_dedupe_key
    on push_notification_deliveries (dedupe_key);

create index idx_push_notification_deliveries_user_created
    on push_notification_deliveries (user_id, created_at desc);

create table weekly_notification_jobs (
    id bigserial primary key,
    user_id bigint not null,
    report_id bigint not null,
    report_week date not null,
    job_status varchar(30) not null default 'PENDING',
    target_device_count integer not null default 0,
    success_count integer not null default 0,
    failure_count integer not null default 0,
    scheduled_at timestamptz,
    started_at timestamptz,
    completed_at timestamptz,
    error_message text,
    created_at timestamptz not null default now(),
    constraint fk_weekly_notification_jobs_user
        foreign key (user_id) references users (id),
    constraint fk_weekly_notification_jobs_report
        foreign key (report_id) references portfolio_weekly_reports (id)
);

create unique index uk_weekly_notification_jobs_user_week
    on weekly_notification_jobs (user_id, report_week);

create table recommendations (
    id bigserial primary key,
    user_id bigint not null,
    portfolio_item_id bigint not null,
    recommendation_date date not null,
    recommendation_status varchar(20) not null,
    engine_score integer not null,
    confidence_score integer,
    current_amount numeric(15, 2) not null,
    recommended_amount numeric(15, 2) not null,
    final_note text,
    engine_version varchar(50),
    formula_version varchar(50),
    raw_score integer,
    risk_adjustment integer,
    price_score integer,
    news_score integer,
    price_weight integer,
    news_weight integer,
    price_return_30d numeric(10, 4),
    news_sentiment_score integer,
    increase_eligible boolean,
    created_at timestamptz not null default now(),
    constraint ck_recommendations_raw_score
        check (raw_score between 0 and 100),
    constraint ck_recommendations_price_score
        check (price_score between 0 and 100),
    constraint ck_recommendations_news_score
        check (news_score between 0 and 100),
    constraint ck_recommendations_price_weight
        check (price_weight between 0 and 100),
    constraint ck_recommendations_news_weight
        check (news_weight between 0 and 100),
    constraint ck_recommendations_news_sentiment_score
        check (news_sentiment_score between -100 and 100),
    constraint fk_recommendations_user
        foreign key (user_id) references users (id),
    constraint fk_recommendations_portfolio_item
        foreign key (portfolio_item_id) references portfolio_items (id)
);

create unique index uk_recommendations_portfolio_item_date
    on recommendations (portfolio_item_id, recommendation_date);

create index idx_recommendations_user_id_date
    on recommendations (user_id, recommendation_date desc);

create index idx_recommendations_portfolio_item_id
    on recommendations (portfolio_item_id);

create table recommendation_evidence (
    id bigserial primary key,
    recommendation_id bigint not null,
    evidence_type varchar(30) not null,
    title varchar(100) not null,
    body text not null,
    score_impact integer,
    display_order integer not null default 0,
    created_at timestamptz not null default now(),
    constraint fk_recommendation_evidence_recommendation
        foreign key (recommendation_id) references recommendations (id)
);

create index idx_recommendation_evidence_recommendation_id
    on recommendation_evidence (recommendation_id);

create table stock_price_snapshots (
    id bigserial primary key,
    stock_id bigint not null,
    snapshot_date date not null,
    current_price numeric(15, 4),
    change_rate_1d numeric(8, 4),
    change_rate_7d numeric(8, 4),
    change_rate_30d numeric(8, 4),
    market_cap numeric(20, 2),
    per_value numeric(12, 4),
    source varchar(30),
    created_at timestamptz not null default now(),
    constraint fk_stock_price_snapshots_stock
        foreign key (stock_id) references stocks (id)
);

create index idx_stock_price_snapshots_stock_date
    on stock_price_snapshots (stock_id, snapshot_date desc);

create unique index uk_stock_price_snapshots_stock_date
    on stock_price_snapshots (stock_id, snapshot_date);

create table news_analysis_cache (
    id bigserial primary key,
    stock_id bigint not null,
    news_id varchar(100),
    symbol varchar(30) not null,
    news_published_at timestamptz,
    headline varchar(500) not null,
    summary text,
    source_name varchar(100),
    news_url text,
    sentiment_label varchar(20),
    sentiment_score integer,
    keyword_score integer,
    relevance_score integer,
    impact_level varchar(20),
    reason text,
    recency_weight numeric(6, 4),
    impact_weight numeric(6, 4),
    weighted_score numeric(10, 4),
    content_hash varchar(64) not null,
    analysis_batch_hash varchar(64) not null,
    llm_model varchar(100),
    analyzed_at timestamptz not null default now(),
    created_at timestamptz not null default now(),
    constraint ck_news_analysis_sentiment_score
        check (sentiment_score between -100 and 100),
    constraint ck_news_analysis_keyword_score
        check (keyword_score between -100 and 100),
    constraint ck_news_analysis_relevance_score
        check (relevance_score between 0 and 100),
    constraint ck_news_analysis_impact_level
        check (impact_level in ('LOW', 'MEDIUM', 'HIGH')),
    constraint fk_news_analysis_cache_stock
        foreign key (stock_id) references stocks (id)
);

create index idx_news_analysis_cache_stock_published_at
    on news_analysis_cache (stock_id, news_published_at desc);

create unique index uk_news_analysis_cache_stock_content
    on news_analysis_cache (stock_id, content_hash);

create index idx_news_analysis_cache_symbol_analyzed_at
    on news_analysis_cache (symbol, analyzed_at desc);
