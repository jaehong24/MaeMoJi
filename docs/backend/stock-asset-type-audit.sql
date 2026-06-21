-- MaeMoJi stocks.asset_type 품질 점검 쿼리
-- 목적:
-- 1. ETF처럼 보이는데 STOCK으로 저장된 종목 찾기
-- 2. STOCK처럼 보이는데 ETF로 저장된 종목 찾기
-- 3. market_type / asset_type 불일치 찾기

with classified as (
    select
        id,
        symbol,
        ticker,
        name_en,
        asset_type,
        market_type,
        case
            when upper(coalesce(market_type, '')) like '%ETF%' then 'ETF'
            when upper(coalesce(name_en, '')) similar to '%(ETF|ETN|EXCHANGE TRADED|INDEX FUND|TREASURY|BOND|INNOVATORS ETF)%' then 'ETF'
            when upper(coalesce(name_en, '')) similar to '%( TRUST| FUND| SHARES)%'
                 and upper(coalesce(name_en, '')) not similar to '%(COMMON STOCK|ORDINARY SHARES|PREFERRED STOCK)%' then 'ETF'
            else 'STOCK'
        end as suggested_asset_type,
        case
            when upper(coalesce(market_type, '')) like '%ETF%'
                 and upper(coalesce(asset_type, '')) <> 'ETF' then 'market_type says ETF'
            when upper(coalesce(asset_type, '')) = 'ETF'
                 and upper(coalesce(name_en, '')) similar to '%(COMMON STOCK|ORDINARY SHARES)%' then 'etf tag looks like common stock'
            when upper(coalesce(asset_type, '')) = 'STOCK'
                 and upper(coalesce(name_en, '')) similar to '%(ETF|ETN|EXCHANGE TRADED|INDEX FUND|TREASURY|BOND)%' then 'stock tag looks like ETF keyword'
            when upper(coalesce(asset_type, '')) = 'STOCK'
                 and upper(coalesce(name_en, '')) similar to '%( TRUST| FUND| SHARES)%'
                 and upper(coalesce(name_en, '')) not similar to '%(COMMON STOCK|ORDINARY SHARES|PREFERRED STOCK)%' then 'stock tag looks like trust/fund/share product'
            else null
        end as reason
    from stocks
    where is_active = true
      and country = 'US'
)
select
    id,
    symbol,
    ticker,
    name_en,
    asset_type,
    market_type,
    suggested_asset_type,
    reason
from classified
where reason is not null
  and upper(coalesce(asset_type, '')) <> upper(coalesce(suggested_asset_type, ''))
order by symbol asc;
