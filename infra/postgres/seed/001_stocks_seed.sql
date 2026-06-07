-- MaeMoJi 종목 검색과 포트폴리오 등록 흐름을 바로 확인하기 위한 샘플 종목 데이터입니다.

insert into stocks (
    ticker,
    exchange_code,
    finnhub_symbol,
    name_ko,
    name_en,
    logo_url,
    market_type
) values
    ('AAPL', 'NASDAQ', 'AAPL', '애플', 'Apple Inc.', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AAPL.png', 'COMMON_STOCK'),
    ('AMZN', 'NASDAQ', 'AMZN', '아마존', 'Amazon.com, Inc.', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/AMZN.png', 'COMMON_STOCK'),
    ('GOOGL', 'NASDAQ', 'GOOGL', '구글', 'Alphabet Class A', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/GOOGL.png', 'COMMON_STOCK'),
    ('MSFT', 'NASDAQ', 'MSFT', '마이크로소프트', 'Microsoft Corporation', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/MSFT.png', 'COMMON_STOCK'),
    ('NVDA', 'NASDAQ', 'NVDA', '엔비디아', 'NVIDIA Corporation', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/NVDA.png', 'COMMON_STOCK'),
    ('META', 'NASDAQ', 'META', '메타', 'Meta Platforms, Inc.', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/META.png', 'COMMON_STOCK'),
    ('TSLA', 'NASDAQ', 'TSLA', '테슬라', 'Tesla, Inc.', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/stock_logo/TSLA.png', 'COMMON_STOCK'),
    ('QQQ', 'NASDAQ', 'QQQ', '인베스코 QQQ', 'Invesco QQQ Trust', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/etf_logo/qqq.png', 'ETF'),
    ('SPY', 'NYSE_ARCA', 'SPY', 'SPY ETF', 'SPDR S&P 500 ETF Trust', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/etf_logo/spdr.png', 'ETF'),
    ('SOXX', 'NASDAQ', 'SOXX', '반도체 ETF', 'iShares Semiconductor ETF', 'https://static2.finnhub.io/file/publicdatany/finnhubimage/etf_logo/soxx.png', 'ETF')
on conflict (ticker, exchange_code) do update
set
    finnhub_symbol = excluded.finnhub_symbol,
    name_ko = excluded.name_ko,
    name_en = excluded.name_en,
    logo_url = excluded.logo_url,
    market_type = excluded.market_type,
    is_active = true,
    updated_at = now();
