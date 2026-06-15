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
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint fk_portfolio_items_user
        foreign key (user_id) references users (id),
    constraint fk_portfolio_items_stock
        foreign key (stock_id) references stocks (id)
);

create unique index uk_portfolio_items_user_stock
    on portfolio_items (user_id, stock_id);

create index idx_portfolio_items_user_id
    on portfolio_items (user_id);

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
