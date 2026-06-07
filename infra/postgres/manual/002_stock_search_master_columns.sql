-- 이미 생성된 로컬 DB를 검색 마스터 구조로 맞출 때 사용하는 수동 실행 스크립트입니다.

alter table stocks
    alter column name_ko type text,
    alter column name_en type text;

alter table stocks
    add column if not exists ticker_normalized varchar(30),
    add column if not exists name_ko_normalized text,
    add column if not exists name_en_normalized text,
    add column if not exists search_text text;

alter table stocks
    alter column name_ko_normalized type text,
    alter column name_en_normalized type text;

update stocks
set
    ticker_normalized = lower(trim(ticker)),
    name_ko_normalized = case
        when name_ko is null then null
        else lower(trim(name_ko))
    end,
    name_en_normalized = lower(trim(name_en)),
    search_text = trim(
        concat_ws(
            ' ',
            lower(trim(ticker)),
            lower(trim(name_en)),
            lower(trim(coalesce(name_ko, '')))
        )
    )
where ticker_normalized is null
   or name_en_normalized is null
   or search_text is null;

alter table stocks
    alter column ticker_normalized set not null,
    alter column name_en_normalized set not null,
    alter column search_text set not null;

create index if not exists idx_stocks_ticker_normalized
    on stocks (ticker_normalized);

create index if not exists idx_stocks_name_ko_normalized
    on stocks (name_ko_normalized);

create index if not exists idx_stocks_name_en_normalized
    on stocks (name_en_normalized);
