-- 기존 로컬 DB에 stocks 무결성 인덱스를 추가할 때 사용하는 수동 실행 스크립트입니다.
-- 중복 finnhub_symbol이 이미 들어있는 경우를 먼저 정리한 뒤 인덱스를 만듭니다.

update stocks s
set finnhub_symbol = null
from (
    select
        id,
        row_number() over (
            partition by finnhub_symbol
            order by id asc
        ) as row_number
    from stocks
    where finnhub_symbol is not null
) duplicated
where s.id = duplicated.id
  and duplicated.row_number > 1;

create unique index if not exists uk_stocks_finnhub_symbol
    on stocks (finnhub_symbol)
    where finnhub_symbol is not null;
