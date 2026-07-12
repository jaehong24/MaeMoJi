-- MaeMoJi Phase 2.2
-- Push notification / weekly digest groundwork

create table if not exists user_notification_preferences (
    id bigserial primary key,
    user_id bigint not null unique references users (id),
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
    updated_at timestamptz not null default now()
);

create index if not exists idx_user_notification_preferences_user_id
    on user_notification_preferences (user_id);

create table if not exists user_device_tokens (
    id bigserial primary key,
    user_id bigint not null references users (id),
    device_platform varchar(20) not null,
    device_identifier varchar(191),
    fcm_token varchar(512) not null,
    app_version varchar(50),
    push_enabled boolean not null default true,
    is_active boolean not null default true,
    last_seen_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deactivated_at timestamptz
);

create unique index if not exists uq_user_device_tokens_token
    on user_device_tokens (fcm_token);

create index if not exists idx_user_device_tokens_user_id_active
    on user_device_tokens (user_id, is_active, push_enabled);

create table if not exists push_notification_deliveries (
    id bigserial primary key,
    alert_event_id bigint references user_alert_events (id),
    user_id bigint not null references users (id),
    device_token_id bigint not null references user_device_tokens (id),
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
    created_at timestamptz not null default now()
);

create unique index if not exists uq_push_notification_deliveries_dedupe_key
    on push_notification_deliveries (dedupe_key);

create index if not exists idx_push_notification_deliveries_user_created
    on push_notification_deliveries (user_id, created_at desc);

create table if not exists weekly_notification_jobs (
    id bigserial primary key,
    user_id bigint not null references users (id),
    report_id bigint not null references portfolio_weekly_reports (id),
    report_week date not null,
    job_status varchar(30) not null default 'PENDING',
    target_device_count integer not null default 0,
    success_count integer not null default 0,
    failure_count integer not null default 0,
    scheduled_at timestamptz,
    started_at timestamptz,
    completed_at timestamptz,
    error_message text,
    created_at timestamptz not null default now()
);

create unique index if not exists uq_weekly_notification_jobs_user_report_week
    on weekly_notification_jobs (user_id, report_week);

create index if not exists idx_weekly_notification_jobs_status_scheduled
    on weekly_notification_jobs (job_status, scheduled_at);
