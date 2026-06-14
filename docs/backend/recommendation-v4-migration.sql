alter table recommendations
    add column if not exists price_momentum_score integer,
    add column if not exists price_stability_score integer,
    add column if not exists fundamental_quality_score integer,
    add column if not exists user_fit_score integer,
    add column if not exists cross_factor_adjustment integer,
    add column if not exists user_adjustment integer,
    add column if not exists risk_profile_applied varchar(30),
    add column if not exists confidence_breakdown_json jsonb;

alter table recommendations
    drop constraint if exists ck_recommendations_price_momentum_score,
    add constraint ck_recommendations_price_momentum_score
        check (price_momentum_score is null or price_momentum_score between 0 and 100),
    drop constraint if exists ck_recommendations_price_stability_score,
    add constraint ck_recommendations_price_stability_score
        check (price_stability_score is null or price_stability_score between 0 and 100),
    drop constraint if exists ck_recommendations_fundamental_quality_score,
    add constraint ck_recommendations_fundamental_quality_score
        check (fundamental_quality_score is null or fundamental_quality_score between 0 and 100),
    drop constraint if exists ck_recommendations_user_fit_score,
    add constraint ck_recommendations_user_fit_score
        check (user_fit_score is null or user_fit_score between 0 and 100);

create table if not exists recommendation_factor_details (
    id bigserial primary key,
    recommendation_id bigint not null,
    factor_code varchar(40) not null,
    factor_score integer not null,
    factor_weight integer not null,
    factor_summary varchar(255),
    factor_raw_json jsonb,
    created_at timestamptz not null default now(),
    constraint ck_recommendation_factor_details_score
        check (factor_score between 0 and 100),
    constraint ck_recommendation_factor_details_weight
        check (factor_weight between 0 and 100),
    constraint fk_recommendation_factor_details_recommendation
        foreign key (recommendation_id) references recommendations (id)
);

create index if not exists idx_recommendation_factor_details_recommendation_id
    on recommendation_factor_details (recommendation_id);

create index if not exists idx_recommendation_factor_details_factor_code
    on recommendation_factor_details (factor_code);
