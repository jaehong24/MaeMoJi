alter table portfolio_items
    add column if not exists source_type varchar(20) not null default 'MANUAL',
    add column if not exists source_connection_id bigint,
    add column if not exists linked_broker_position boolean not null default false;

alter table portfolio_items
    drop constraint if exists ck_portfolio_items_source_type;

alter table portfolio_items
    add constraint ck_portfolio_items_source_type
        check (source_type in ('MANUAL', 'TOSS_SYNC'));

create table if not exists toss_connections (
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
    constraint fk_toss_connections_user
        foreign key (user_id) references users (id)
);

alter table toss_connections
    drop constraint if exists ck_toss_connections_status;

alter table toss_connections
    add constraint ck_toss_connections_status
        check (status in ('ACTIVE', 'INVALID_CREDENTIAL', 'DISCONNECTED', 'SYNC_FAILED'));

create unique index if not exists uk_toss_connections_user_client
    on toss_connections (user_id, client_id);

create index if not exists idx_toss_connections_user_id
    on toss_connections (user_id);

create unique index if not exists uk_toss_connections_primary_per_user
    on toss_connections (user_id)
    where is_primary = true;

create table if not exists toss_accounts (
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
    constraint fk_toss_accounts_connection
        foreign key (connection_id) references toss_connections (id)
);

alter table toss_accounts
    drop constraint if exists ck_toss_accounts_status;

alter table toss_accounts
    add constraint ck_toss_accounts_status
        check (status in ('ACTIVE', 'INACTIVE'));

create unique index if not exists uk_toss_accounts_connection_seq
    on toss_accounts (connection_id, account_seq);

create unique index if not exists uk_toss_accounts_selected_per_connection
    on toss_accounts (connection_id)
    where is_selected = true;

create table if not exists toss_portfolio_snapshots (
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

create index if not exists idx_toss_snapshots_account_captured
    on toss_portfolio_snapshots (account_id, captured_at desc);

create table if not exists toss_portfolio_mappings (
    id bigserial primary key,
    user_id bigint not null,
    account_id bigint not null,
    stock_id bigint not null,
    portfolio_item_id bigint not null,
    latest_snapshot_id bigint,
    sync_status varchar(20) not null default 'LINKED',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
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

alter table toss_portfolio_mappings
    drop constraint if exists ck_toss_mappings_sync_status;

alter table toss_portfolio_mappings
    add constraint ck_toss_mappings_sync_status
        check (sync_status in ('LINKED', 'UNMATCHED', 'INACTIVE'));

create unique index if not exists uk_toss_mappings_user_account_stock
    on toss_portfolio_mappings (user_id, account_id, stock_id);

create table if not exists portfolio_sync_jobs (
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
    constraint fk_portfolio_sync_jobs_user
        foreign key (user_id) references users (id),
    constraint fk_portfolio_sync_jobs_connection
        foreign key (connection_id) references toss_connections (id),
    constraint fk_portfolio_sync_jobs_account
        foreign key (account_id) references toss_accounts (id)
);

alter table portfolio_sync_jobs
    drop constraint if exists ck_portfolio_sync_jobs_type;

alter table portfolio_sync_jobs
    add constraint ck_portfolio_sync_jobs_type
        check (job_type in ('MANUAL_SYNC', 'AUTO_SYNC', 'REPAIR_SYNC'));

alter table portfolio_sync_jobs
    drop constraint if exists ck_portfolio_sync_jobs_status;

alter table portfolio_sync_jobs
    add constraint ck_portfolio_sync_jobs_status
        check (job_status in ('RUNNING', 'SUCCESS', 'PARTIAL_SUCCESS', 'FAILED'));

create table if not exists portfolio_profile_settings (
    id bigserial primary key,
    user_id bigint not null,
    profile_visibility varchar(20) not null default 'PRIVATE',
    show_profit_rate boolean not null default false,
    show_holdings boolean not null default true,
    show_badges boolean not null default true,
    show_weight_percent boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    constraint fk_portfolio_profile_settings_user
        foreign key (user_id) references users (id)
);

alter table portfolio_profile_settings
    drop constraint if exists ck_portfolio_profile_settings_visibility;

alter table portfolio_profile_settings
    add constraint ck_portfolio_profile_settings_visibility
        check (profile_visibility in ('PRIVATE', 'FOLLOWERS', 'PUBLIC'));

create unique index if not exists uk_portfolio_profile_settings_user
    on portfolio_profile_settings (user_id);
