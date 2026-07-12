create table if not exists portfolio_item_reasons (
    id bigserial primary key,
    portfolio_item_id bigint not null,
    reason_code varchar(50) not null,
    display_order integer not null default 0,
    created_at timestamptz not null default now(),
    constraint fk_portfolio_item_reasons_item
        foreign key (portfolio_item_id) references portfolio_items (id)
);

create unique index if not exists uk_portfolio_item_reasons_item_code
    on portfolio_item_reasons (portfolio_item_id, reason_code);

create table if not exists portfolio_weekly_reports (
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

create unique index if not exists uk_portfolio_weekly_reports_user_week
    on portfolio_weekly_reports (user_id, report_week);

create table if not exists portfolio_weekly_report_items (
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

create index if not exists idx_portfolio_weekly_report_items_report_id
    on portfolio_weekly_report_items (report_id, display_order asc, id asc);

create table if not exists user_alert_events (
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

create unique index if not exists uk_user_alert_events_dedupe_key
    on user_alert_events (dedupe_key);
