from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
from dataclasses import dataclass
from io import StringIO
from typing import Iterable
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

import pandas as pd

USER_AGENT = "Mozilla/5.0 (MaeMoJi stock-name generator)"
SP500_URL = "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
NASDAQ100_URL = "https://en.wikipedia.org/wiki/Nasdaq-100"

BAD_LETTER_TOKENS = {
    "에이",
    "비",
    "씨",
    "디",
    "이",
    "에프",
    "지",
    "에이치",
    "아이",
    "제이",
    "케이",
    "엘",
    "엠",
    "엔",
    "오",
    "피",
    "큐",
    "알",
    "에스",
    "티",
    "유",
    "브이",
    "더블유",
    "엑스",
    "와이",
}
BAD_PATTERN_REGEX = re.compile(
    r"(에이|비|씨|디|이|에프|지|에이치|아이|제이|케이|엘|엠|엔|오|피|큐|알|에스|티|유|브이|더블유|엑스|와이)(\s+(에이|비|씨|디|이|에프|지|에이치|아이|제이|케이|엘|엠|엔|오|피|큐|알|에스|티|유|브이|더블유|엑스|와이)){3,}"
)
TRAILING_METADATA_REGEX = re.compile(
    r"\s*-\s*(Class\s+[A-Z0-9]+\s+)?(Common Stock|Ordinary Shares?|American Depositary Shares?|ADS|ADR|Depositary Shares?|ETF|Trust|Units?)\s*$",
    re.IGNORECASE,
)
TRAILING_COMMON_WORDS_REGEX = re.compile(
    r"\b(Common Stock|Ordinary Shares?|Depositary Shares?|American Depositary Shares?|ADS|ADR)\b",
    re.IGNORECASE,
)


MANUAL_OVERRIDES = {
    "AAPL": "애플",
    "MSFT": "마이크로소프트",
    "NVDA": "엔비디아",
    "AMZN": "아마존",
    "META": "메타 플랫폼스",
    "GOOGL": "알파벳 A",
    "GOOG": "알파벳 C",
    "TSLA": "테슬라",
    "AVGO": "브로드컴",
    "AMD": "AMD",
    "QCOM": "퀄컴",
    "NFLX": "넷플릭스",
    "PLTR": "팔란티어",
    "ORCL": "오라클",
    "CRM": "세일즈포스",
    "INTC": "인텔",
    "TSM": "TSMC",
    "ASML": "ASML",
    "MU": "마이크론",
    "JPM": "JP모건체이스",
    "GS": "골드만삭스",
    "MS": "모건 스탠리",
    "WFC": "웰스파고",
    "C": "씨티그룹",
    "HD": "홈디포",
    "CAT": "캐터필러",
    "UNH": "유나이티드헬스 그룹",
    "PG": "프록터 앤 갬블",
    "GE": "GE 에어로스페이스",
    "GEV": "GE 버노바",
    "AMAT": "어플라이드 머티리얼즈",
    "LRCX": "램리서치",
    "PANW": "팔로알토 네트웍스",
    "TXN": "텍사스 인스트루먼트",
    "DELL": "델 테크놀로지스",
    "ARM": "Arm 홀딩스",
    "SHEL": "셸",
    "LIN": "린데",
    "TM": "도요타자동차",
    "SAP": "SAP",
    "AZN": "아스트라제네카",
    "NVS": "노바티스",
    "MRVL": "마벨 테크놀로지",
    "MUFG": "미쓰비시 UFJ 파이낸셜",
    "BRK.B": "버크셔 해서웨이 B",
    "NEE": "넥스트에라 에너지",
    "QQQ": "인베스코 QQQ",
    "SPY": "SPDR S&P500 ETF",
    "VOO": "뱅가드 S&P500 ETF",
    "IVV": "아이셰어즈 코어 S&P500 ETF",
    "VTI": "뱅가드 토탈 주식시장 ETF",
    "SCHD": "슈왑 미국 배당 ETF",
    "JEPI": "JP모건 배당 프리미엄 ETF",
    "JEPQ": "JP모건 나스닥 배당 프리미엄 ETF",
    "VYM": "뱅가드 고배당 ETF",
    "SOXX": "아이셰어즈 반도체 ETF",
    "SMH": "반에크 반도체 ETF",
    "IBIT": "아이셰어즈 비트코인 ETF",
    "FBTC": "피델리티 비트코인 ETF",
    "ETHA": "아이셰어즈 이더리움 ETF",
    "ARKK": "ARK 혁신 ETF",
    "ARKG": "ARK 유전체 혁신 ETF",
    "ARKF": "ARK 핀테크 혁신 ETF",
    "XOVR": "ERShares 프라이빗-퍼블릭 크로스오버 ETF",
}

POPULAR_ETFS = {
    "QQQ",
    "SPY",
    "VOO",
    "IVV",
    "VTI",
    "SCHD",
    "JEPI",
    "JEPQ",
    "VYM",
    "SOXX",
    "SMH",
    "IBIT",
    "FBTC",
    "ETHA",
    "ARKK",
    "ARKG",
    "ARKF",
    "XOVR",
}


@dataclass
class TranslationJob:
    ticker: str
    name_en: str
    asset_type: str
    priority_group: str


def fetch_html(url: str) -> str:
    request = Request(url, headers={"User-Agent": USER_AGENT})
    with urlopen(request, timeout=30) as response:
        return response.read().decode("utf-8")


def read_tables(url: str) -> list[pd.DataFrame]:
    return pd.read_html(StringIO(fetch_html(url)))


def fetch_priority_lists() -> tuple[set[str], set[str]]:
    sp500 = read_tables(SP500_URL)[0]
    sp500_symbols = {
        normalize_ticker(value)
        for value in sp500["Symbol"].astype(str).tolist()
    }

    nasdaq_tables = read_tables(NASDAQ100_URL)
    nasdaq_table = next(
        table for table in nasdaq_tables
        if list(table.columns[:2]) == ["Ticker", "Company"]
    )
    nasdaq_symbols = {
        normalize_ticker(value)
        for value in nasdaq_table["Ticker"].astype(str).tolist()
    }
    return sp500_symbols, nasdaq_symbols


def normalize_ticker(value: str) -> str:
    return str(value).strip().upper()


def clean_name_en(name_en: str) -> str:
    value = str(name_en).strip()
    value = TRAILING_METADATA_REGEX.sub("", value)
    value = TRAILING_COMMON_WORDS_REGEX.sub("", value)
    value = re.sub(r"\s+", " ", value).strip(" ,.-")
    return value


def is_bad_korean_name(name_ko: str) -> bool:
    normalized = str(name_ko).strip()
    if not normalized:
        return True
    if BAD_PATTERN_REGEX.search(normalized):
        return True
    tokens = normalized.split()
    consecutive = 0
    for token in tokens:
        if token in BAD_LETTER_TOKENS:
            consecutive += 1
            if consecutive >= 4:
                return True
        else:
            consecutive = 0
    return False


def chunks(items: list[TranslationJob], size: int) -> Iterable[list[TranslationJob]]:
    for start in range(0, len(items), size):
        yield items[start:start + size]


def call_gemini_batch(
    jobs: list[TranslationJob],
    gemini_api_key: str,
    model: str,
) -> dict[str, str]:
    if not jobs:
        return {}

    payload_jobs = [
        {
            "ticker": job.ticker,
            "nameEn": clean_name_en(job.name_en),
            "assetType": job.asset_type,
            "priorityGroup": job.priority_group,
        }
        for job in jobs
    ]

    prompt = (
        "미국 상장 주식/ETF 이름을 한국 증권사 앱에서 자연스럽게 보이는 한글명으로 변환하세요.\n"
        "중요 규칙:\n"
        "1. 영문자를 한 글자씩 읽지 마세요. 예: '에이 비 씨', '엔 이 엑스 티' 금지.\n"
        "2. AMD, ASML, SAP, TSMC, ARM, IBM, GE처럼 한국 투자자에게 영문 약칭이 더 자연스러우면 영문 그대로 유지해도 됩니다.\n"
        "3. ETF는 가능하면 브랜드/지수 의미가 드러나게 번역하고 끝에 ETF를 유지하세요.\n"
        "4. 한국 투자자 기준으로 널리 쓰이는 표기를 우선하세요.\n"
        "5. 출력은 반드시 JSON 배열만 반환하세요.\n"
        "6. 각 원소 형식: {\"ticker\":\"AAPL\",\"nameKo\":\"애플\"}\n"
        "7. 입력 순서를 유지하세요.\n\n"
        f"입력 데이터:\n{json.dumps(payload_jobs, ensure_ascii=False)}"
    )

    request_body = {
        "generationConfig": {
            "responseMimeType": "application/json",
            "temperature": 0.1,
        },
        "contents": [
            {
                "parts": [
                    {"text": prompt}
                ]
            }
        ]
    }

    request = Request(
        url=(
            "https://generativelanguage.googleapis.com/v1beta/models/"
            f"{model}:generateContent?key={gemini_api_key}"
        ),
        data=json.dumps(request_body).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "User-Agent": USER_AGENT,
        },
        method="POST",
    )

    for attempt in range(5):
        try:
            with urlopen(request, timeout=120) as response:
                body = json.loads(response.read().decode("utf-8"))
            text = (
                body["candidates"][0]["content"]["parts"][0]["text"]
                .strip()
            )
            rows = json.loads(text)
            result: dict[str, str] = {}
            for row in rows:
                ticker = normalize_ticker(row["ticker"])
                result[ticker] = str(row["nameKo"]).strip()
            return result
        except HTTPError as error:
            if error.code == 429:
                wait_seconds = 20 + attempt * 20
            else:
                wait_seconds = 3 + attempt * 3
            if attempt == 4:
                raise RuntimeError(
                    f"Gemini batch failed after retries: {error}"
                ) from error
            time.sleep(wait_seconds)
        except (URLError, KeyError, IndexError, json.JSONDecodeError) as error:
            if attempt == 4:
                raise RuntimeError(
                    f"Gemini batch failed after retries: {error}"
                ) from error
            time.sleep(2 + attempt * 2)
    return {}


def translate_with_gemini(
    jobs: list[TranslationJob],
    gemini_api_key: str,
    model: str,
    batch_size: int,
    cache_file: str,
    sleep_seconds: float,
) -> dict[str, str]:
    translated: dict[str, str] = load_cache(cache_file)
    remaining = [
        job for job in jobs
        if job.ticker not in translated
    ]
    for index, batch in enumerate(chunks(remaining, batch_size), start=1):
        batch_result = call_gemini_batch(batch, gemini_api_key, model)
        translated.update(batch_result)
        save_cache(cache_file, translated)
        print(
            f"[Gemini] batch {index} complete: {len(batch_result)}/{len(batch)}, total={len(translated)}",
            flush=True,
        )
        if sleep_seconds > 0:
            time.sleep(sleep_seconds)
    return translated


def load_cache(cache_file: str) -> dict[str, str]:
    if not cache_file or not os.path.exists(cache_file):
        return {}
    with open(cache_file, "r", encoding="utf-8") as file:
        data = json.load(file)
    return {normalize_ticker(key): str(value).strip() for key, value in data.items()}


def save_cache(cache_file: str, translated: dict[str, str]) -> None:
    if not cache_file:
        return
    with open(cache_file, "w", encoding="utf-8") as file:
        json.dump(translated, file, ensure_ascii=False, indent=2)


def build_jobs(
    frame: pd.DataFrame,
    sp500_symbols: set[str],
    nasdaq100_symbols: set[str],
) -> list[TranslationJob]:
    jobs: list[TranslationJob] = []
    for row in frame.itertuples(index=False):
        ticker = normalize_ticker(row.ticker)
        if ticker in MANUAL_OVERRIDES:
            continue
        if ticker in POPULAR_ETFS:
            continue

        if ticker in sp500_symbols:
            group = "SP500"
        elif ticker in nasdaq100_symbols:
            group = "NASDAQ100"
        elif str(row.asset_type).upper() == "ETF":
            group = "ETF"
        else:
            group = "GENERAL"

        jobs.append(
            TranslationJob(
                ticker=ticker,
                name_en=str(row.name_en),
                asset_type=str(row.asset_type),
                priority_group=group,
            )
        )
    return jobs


def apply_results(
    frame: pd.DataFrame,
    translated: dict[str, str],
    sp500_symbols: set[str],
    nasdaq100_symbols: set[str],
) -> pd.DataFrame:
    output = frame.copy()
    name_kos: list[str] = []
    sources: list[str] = []

    for row in output.itertuples(index=False):
        ticker = normalize_ticker(row.ticker)
        if ticker in MANUAL_OVERRIDES:
            name_ko = MANUAL_OVERRIDES[ticker]
            source = "manual"
        else:
            name_ko = translated.get(ticker, "").strip()
            source = "gemini"

        if is_bad_korean_name(name_ko):
            cleaned = clean_name_en(row.name_en)
            # 최후 수단: 영문 약칭/브랜드를 그대로 두되 잘못된 한글 음차는 남기지 않습니다.
            if re.fullmatch(r"[A-Za-z0-9 .&+'/-]+", cleaned):
                name_ko = cleaned
                source = f"{source}-fallback-en"
            else:
                name_ko = ticker
                source = f"{source}-fallback-ticker"

        name_kos.append(name_ko)
        sources.append(source)

    output["name_ko"] = name_kos
    output["source"] = sources
    output["is_sp500"] = output["ticker"].map(
        lambda value: normalize_ticker(value) in sp500_symbols
    )
    output["is_nasdaq100"] = output["ticker"].map(
        lambda value: normalize_ticker(value) in nasdaq100_symbols
    )
    output["is_popular_etf"] = output["ticker"].map(
        lambda value: normalize_ticker(value) in POPULAR_ETFS
    )
    return output


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--errors-output", required=True)
    parser.add_argument("--batch-size", type=int, default=80)
    parser.add_argument("--gemini-model", default="gemini-2.5-flash-lite")
    parser.add_argument("--cache-file", required=True)
    parser.add_argument("--sleep-seconds", type=float, default=4.0)
    args = parser.parse_args()

    gemini_api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not gemini_api_key:
        raise SystemExit("GEMINI_API_KEY is required.")

    frame = pd.read_csv(args.input, dtype=str).fillna("")
    frame["ticker"] = frame["ticker"].map(normalize_ticker)
    frame["exchange_code"] = frame["exchange_code"].astype(str)
    frame["finnhub_symbol"] = frame["finnhub_symbol"].astype(str)
    frame["asset_type"] = frame["asset_type"].astype(str)
    frame["name_en"] = frame["name_en"].astype(str)

    sp500_symbols, nasdaq100_symbols = fetch_priority_lists()
    jobs = build_jobs(frame, sp500_symbols, nasdaq100_symbols)
    translated = translate_with_gemini(
        jobs=jobs,
        gemini_api_key=gemini_api_key,
        model=args.gemini_model,
        batch_size=args.batch_size,
        cache_file=args.cache_file,
        sleep_seconds=args.sleep_seconds,
    )

    output = apply_results(frame, translated, sp500_symbols, nasdaq100_symbols)
    output.to_csv(args.output, index=False, encoding="utf-8-sig")

    errors = output[output["name_ko"].map(is_bad_korean_name)].copy()
    errors.to_csv(args.errors_output, index=False, encoding="utf-8-sig")

    print(
        json.dumps(
            {
                "totalRows": int(len(output)),
                "translatedRows": int(sum(output["source"].str.startswith("gemini"))),
                "manualRows": int(sum(output["source"] == "manual")),
                "errorRows": int(len(errors)),
                "sp500Count": int(len(sp500_symbols)),
                "nasdaq100Count": int(len(nasdaq100_symbols)),
            },
            ensure_ascii=False,
        )
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
