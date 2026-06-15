package com.maemoji.backend.stock.service;

import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/// 미국 종목명을 한국어 검색/표시용 문자열로 보정합니다.
///
/// 원칙:
/// 1. 사람이 직접 정한 예외 사전을 최우선으로 사용합니다.
/// 2. ETF는 긴 영문 펀드명을 억지로 번역하지 않고, 티커 음차를 기본값으로 사용합니다.
/// 3. 일반 주식은 회사명에서 불필요한 꼬리 표현을 제거한 뒤 단어 사전 기반으로 음차합니다.
///
/// 장기적으로 운영하면서 예외 사전과 단어 사전을 계속 보강할 수 있도록
/// 규칙을 한 클래스에 모아 둡니다.
@Service
public class StockKoreanNameService {

    private static final Pattern TOKEN_PATTERN =
            Pattern.compile("[A-Za-z0-9]+(?:\\.[A-Za-z0-9]+)?|&|\\+");
    private static final Pattern TRAILING_METADATA_PATTERN = Pattern.compile(
            "\\s+-\\s+.*$"
    );
    private static final Pattern CLASS_PATTERN = Pattern.compile(
            "\\bclass\\s+[a-z0-9-]+\\b",
            Pattern.CASE_INSENSITIVE
    );
    private static final Pattern SHARE_PATTERN = Pattern.compile(
            "\\b(common stock|ordinary shares?|depositary shares?|adr|ads|american depositary shares?)\\b",
            Pattern.CASE_INSENSITIVE
    );
    private static final Pattern CORPORATE_SUFFIX_PATTERN = Pattern.compile(
            "(?i)\\b(incorporated|inc|corp|corporation|company|co|limited|ltd|plc|lp|llc|sa|nv|ag|se|holdings? company)\\b"
    );

    private static final Map<String, String> SYMBOL_EXCEPTIONS = createSymbolExceptions();
    private static final Map<String, String> PHRASE_EXCEPTIONS = createPhraseExceptions();
    private static final Map<String, String> WORD_EXCEPTIONS = createWordExceptions();
    private static final Map<Character, String> TICKER_SYLLABLES = createTickerSyllables();
    private static final Set<String> ETF_KEYWORDS = Set.of(
            "ETF",
            "TRUST",
            "FUND",
            "INDEX",
            "SHARES",
            "TREASURY",
            "BOND"
    );

    public String resolveNameKo(
            String symbol,
            String nameEn,
            String assetType
    ) {
        final String normalizedSymbol = normalizeSymbol(symbol);
        if (normalizedSymbol.isBlank()) {
            return null;
        }

        final String exception = SYMBOL_EXCEPTIONS.get(normalizedSymbol);
        if (exception != null) {
            return exception;
        }

        if (isEtf(assetType, nameEn)) {
            return transliterateTicker(normalizedSymbol);
        }

        final String cleanedName = cleanupCompanyName(nameEn);
        if (cleanedName.isBlank()) {
            return transliterateTicker(normalizedSymbol);
        }

        final String phraseException = PHRASE_EXCEPTIONS.get(
                cleanedName.toUpperCase(Locale.ROOT)
        );
        if (phraseException != null) {
            return phraseException;
        }

        final String transliterated = transliteratePhrase(cleanedName);
        if (!transliterated.isBlank()) {
            return transliterated;
        }

        return transliterateTicker(normalizedSymbol);
    }

    private boolean isEtf(String assetType, String nameEn) {
        if ("ETF".equalsIgnoreCase(assetType)) {
            return true;
        }
        if (nameEn == null || nameEn.isBlank()) {
            return false;
        }

        final String uppercase = nameEn.toUpperCase(Locale.ROOT);
        return ETF_KEYWORDS.stream().anyMatch(uppercase::contains);
    }

    private String cleanupCompanyName(String nameEn) {
        if (nameEn == null) {
            return "";
        }

        String cleaned = TRAILING_METADATA_PATTERN.matcher(nameEn).replaceFirst("");
        cleaned = CLASS_PATTERN.matcher(cleaned).replaceAll(" ");
        cleaned = SHARE_PATTERN.matcher(cleaned).replaceAll(" ");
        cleaned = cleaned.replace("&", " & ");
        cleaned = cleaned.replace("+", " + ");
        cleaned = cleaned.replace(",", " ");
        cleaned = cleaned.replace("'", "");
        cleaned = cleaned.replace("/", " ");
        cleaned = cleaned.replace("(", " ");
        cleaned = cleaned.replace(")", " ");
        cleaned = cleaned.replace(".", " ");
        cleaned = CORPORATE_SUFFIX_PATTERN.matcher(cleaned).replaceAll(" ");
        cleaned = cleaned.replaceAll("\\s+", " ").trim();
        return cleaned;
    }

    private String transliteratePhrase(String phrase) {
        final Matcher matcher = TOKEN_PATTERN.matcher(phrase);
        final List<String> translatedTokens = new ArrayList<>();
        while (matcher.find()) {
            final String token = matcher.group();
            final String translated = transliterateToken(token);
            if (translated != null && !translated.isBlank()) {
                translatedTokens.add(translated);
            }
        }
        return String.join(" ", translatedTokens).trim();
    }

    private String transliterateToken(String token) {
        if (token == null || token.isBlank()) {
            return "";
        }
        if ("&".equals(token)) {
            return "앤";
        }
        if ("+".equals(token)) {
            return "플러스";
        }
        if (token.chars().allMatch(Character::isDigit)) {
            return token;
        }

        final String normalized = token.toLowerCase(Locale.ROOT);
        final String exception = WORD_EXCEPTIONS.get(normalized);
        if (exception != null) {
            return exception;
        }

        // ETF/지수 약어, 클래스 문자 등은 영문 글자 소리를 그대로 읽는 편이 안정적입니다.
        if (isAcronymToken(token)) {
            return transliterateTicker(token.toUpperCase(Locale.ROOT));
        }

        if (token.contains(".")) {
            return transliterateTicker(
                    token.replace(".", "").toUpperCase(Locale.ROOT)
            );
        }

        // 장기적으로 사전이 더 커지기 전까지는 긴 영문 단어를 억지로 기계 번역하지 않고,
        // 마지막 안전장치로 글자 단위 한글 음차를 사용합니다.
        return transliterateWordByLetters(token);
    }

    private boolean isAcronymToken(String token) {
        if (token.length() <= 1 || token.length() > 6) {
            return false;
        }
        return token.chars().allMatch(character ->
                Character.isUpperCase(character) || Character.isDigit(character)
        );
    }

    private String transliterateWordByLetters(String token) {
        final String uppercase = token.toUpperCase(Locale.ROOT);
        final StringBuilder builder = new StringBuilder();
        for (int index = 0; index < uppercase.length(); index++) {
            final char letter = uppercase.charAt(index);
            if (Character.isDigit(letter)) {
                builder.append(letter);
                continue;
            }
            final String syllable = TICKER_SYLLABLES.get(letter);
            if (syllable != null) {
                if (!builder.isEmpty()) {
                    builder.append(' ');
                }
                builder.append(syllable);
            }
        }
        return builder.toString().replaceAll("\\s+", " ").trim();
    }

    public String transliterateTicker(String symbol) {
        final String uppercase = normalizeSymbol(symbol);
        if (uppercase.isBlank()) {
            return "";
        }

        final StringBuilder builder = new StringBuilder();
        for (int index = 0; index < uppercase.length(); index++) {
            final char letter = uppercase.charAt(index);
            if (letter == '.' || letter == '-' || letter == '/') {
                continue;
            }
            if (Character.isDigit(letter)) {
                builder.append(letter);
                continue;
            }
            final String syllable = TICKER_SYLLABLES.get(letter);
            if (syllable != null) {
                builder.append(syllable);
            }
        }
        return builder.toString();
    }

    public Map<String, String> symbolExceptions() {
        return SYMBOL_EXCEPTIONS;
    }

    private String normalizeSymbol(String symbol) {
        return symbol == null ? "" : symbol.trim().toUpperCase(Locale.ROOT);
    }

    private static Map<String, String> createSymbolExceptions() {
        final Map<String, String> overrides = new LinkedHashMap<>();
        overrides.put("AAPL", "애플");
        overrides.put("TSLA", "테슬라");
        overrides.put("NVDA", "엔비디아");
        overrides.put("MSFT", "마이크로소프트");
        overrides.put("GOOGL", "구글");
        overrides.put("GOOG", "구글");
        overrides.put("AMZN", "아마존");
        overrides.put("META", "메타");
        overrides.put("NFLX", "넷플릭스");
        overrides.put("AMD", "AMD");
        overrides.put("AVGO", "브로드컴");
        overrides.put("ORCL", "오라클");
        overrides.put("INTC", "인텔");
        overrides.put("CSCO", "시스코");
        overrides.put("QCOM", "퀄컴");
        overrides.put("ADBE", "어도비");
        overrides.put("CRM", "세일즈포스");
        overrides.put("UBER", "우버");
        overrides.put("PLTR", "팔란티어");
        overrides.put("MU", "미크론");
        overrides.put("WMT", "월마트");
        overrides.put("COST", "코스트코");
        overrides.put("KO", "코카콜라");
        overrides.put("PEP", "펩시코");
        overrides.put("MCD", "맥도날드");
        overrides.put("NKE", "나이키");
        overrides.put("DIS", "디즈니");
        overrides.put("V", "비자");
        overrides.put("MA", "마스터카드");
        overrides.put("JPM", "제이피모건");
        overrides.put("ABBV", "애브비");
        overrides.put("LLY", "일라이 릴리");
        overrides.put("PFE", "화이자");
        overrides.put("MRK", "머크");
        overrides.put("XOM", "엑슨모빌");
        overrides.put("CVX", "셰브론");
        overrides.put("BABA", "알리바바");
        overrides.put("QQQ", "큐큐큐");
        overrides.put("SPY", "스파이");
        overrides.put("VOO", "브이오오");
        overrides.put("SCHD", "슈드");
        overrides.put("TQQQ", "티큐큐큐");
        overrides.put("SQQQ", "에스큐큐큐");
        overrides.put("VTI", "브이티아이");
        overrides.put("IVV", "아이브이브이");
        overrides.put("DIA", "다이아");
        overrides.put("IWM", "아이더블유엠");
        overrides.put("ARKK", "아크");
        overrides.put("SOXX", "쏙스");
        overrides.put("SMH", "에스엠에이치");
        return Map.copyOf(overrides);
    }

    private static Map<String, String> createPhraseExceptions() {
        final Map<String, String> overrides = new LinkedHashMap<>();
        overrides.put("BANK OF AMERICA", "뱅크 오브 아메리카");
        overrides.put("AMERICAN EXPRESS", "아메리칸 익스프레스");
        overrides.put("BERKSHIRE HATHAWAY", "버크셔 해서웨이");
        overrides.put("JOHNSON JOHNSON", "존슨앤드존슨");
        overrides.put("PROCTER GAMBLE", "프록터 앤드 갬블");
        overrides.put("UNITEDHEALTH GROUP", "유나이티드헬스 그룹");
        overrides.put("TAIWAN SEMICONDUCTOR MANUFACTURING", "대만반도체제조");
        return Map.copyOf(overrides);
    }

    private static Map<String, String> createWordExceptions() {
        final Map<String, String> overrides = new LinkedHashMap<>();
        overrides.put("apple", "애플");
        overrides.put("tesla", "테슬라");
        overrides.put("nvidia", "엔비디아");
        overrides.put("microsoft", "마이크로소프트");
        overrides.put("alphabet", "알파벳");
        overrides.put("amazon", "아마존");
        overrides.put("meta", "메타");
        overrides.put("netflix", "넷플릭스");
        overrides.put("berkshire", "버크셔");
        overrides.put("hathaway", "해서웨이");
        overrides.put("broadcom", "브로드컴");
        overrides.put("oracle", "오라클");
        overrides.put("intel", "인텔");
        overrides.put("cisco", "시스코");
        overrides.put("qualcomm", "퀄컴");
        overrides.put("adobe", "어도비");
        overrides.put("salesforce", "세일즈포스");
        overrides.put("uber", "우버");
        overrides.put("palantir", "팔란티어");
        overrides.put("micron", "미크론");
        overrides.put("walmart", "월마트");
        overrides.put("costco", "코스트코");
        overrides.put("coca", "코카");
        overrides.put("cola", "콜라");
        overrides.put("pepsico", "펩시코");
        overrides.put("mcdonald", "맥도날드");
        overrides.put("nike", "나이키");
        overrides.put("disney", "디즈니");
        overrides.put("visa", "비자");
        overrides.put("mastercard", "마스터카드");
        overrides.put("jpmorgan", "제이피모건");
        overrides.put("abbvie", "애브비");
        overrides.put("eli", "일라이");
        overrides.put("lilly", "릴리");
        overrides.put("pfizer", "화이자");
        overrides.put("merck", "머크");
        overrides.put("exxon", "엑슨");
        overrides.put("mobil", "모빌");
        overrides.put("chevron", "셰브론");
        overrides.put("alibaba", "알리바바");
        overrides.put("bank", "뱅크");
        overrides.put("america", "아메리카");
        overrides.put("american", "아메리칸");
        overrides.put("express", "익스프레스");
        overrides.put("johnson", "존슨");
        overrides.put("procter", "프록터");
        overrides.put("gamble", "갬블");
        overrides.put("unitedhealth", "유나이티드헬스");
        overrides.put("taiwan", "대만");
        overrides.put("semiconductor", "세미컨덕터");
        overrides.put("manufacturing", "매뉴팩처링");
        overrides.put("advanced", "어드밴스드");
        overrides.put("micro", "마이크로");
        overrides.put("devices", "디바이시스");
        overrides.put("technology", "테크놀로지");
        overrides.put("technologies", "테크놀로지스");
        overrides.put("systems", "시스템즈");
        overrides.put("system", "시스템");
        overrides.put("software", "소프트웨어");
        overrides.put("service", "서비스");
        overrides.put("services", "서비스");
        overrides.put("communication", "커뮤니케이션");
        overrides.put("communications", "커뮤니케이션스");
        overrides.put("energy", "에너지");
        overrides.put("health", "헬스");
        overrides.put("healthcare", "헬스케어");
        overrides.put("medical", "메디컬");
        overrides.put("bio", "바이오");
        overrides.put("biotech", "바이오테크");
        overrides.put("biosciences", "바이오사이언시스");
        overrides.put("therapeutics", "테라퓨틱스");
        overrides.put("pharmaceuticals", "파마슈티컬스");
        overrides.put("financial", "파이낸셜");
        overrides.put("capital", "캐피털");
        overrides.put("industries", "인더스트리스");
        overrides.put("industrial", "인더스트리얼");
        overrides.put("materials", "머티리얼즈");
        overrides.put("resources", "리소시스");
        overrides.put("brands", "브랜즈");
        overrides.put("brand", "브랜드");
        overrides.put("foods", "푸즈");
        overrides.put("food", "푸드");
        overrides.put("realty", "리얼티");
        overrides.put("motors", "모터스");
        overrides.put("motor", "모터");
        overrides.put("global", "글로벌");
        overrides.put("international", "인터내셔널");
        overrides.put("digital", "디지털");
        overrides.put("enterprise", "엔터프라이즈");
        overrides.put("venture", "벤처");
        overrides.put("ventures", "벤처스");
        overrides.put("lab", "랩");
        overrides.put("labs", "랩스");
        overrides.put("group", "그룹");
        overrides.put("holding", "홀딩");
        overrides.put("holdings", "홀딩스");
        overrides.put("and", "앤드");
        overrides.put("of", "오브");
        return Map.copyOf(overrides);
    }

    private static Map<Character, String> createTickerSyllables() {
        final Map<Character, String> syllables = new LinkedHashMap<>();
        syllables.put('A', "에이");
        syllables.put('B', "비");
        syllables.put('C', "씨");
        syllables.put('D', "디");
        syllables.put('E', "이");
        syllables.put('F', "에프");
        syllables.put('G', "지");
        syllables.put('H', "에이치");
        syllables.put('I', "아이");
        syllables.put('J', "제이");
        syllables.put('K', "케이");
        syllables.put('L', "엘");
        syllables.put('M', "엠");
        syllables.put('N', "엔");
        syllables.put('O', "오");
        syllables.put('P', "피");
        syllables.put('Q', "큐");
        syllables.put('R', "알");
        syllables.put('S', "에스");
        syllables.put('T', "티");
        syllables.put('U', "유");
        syllables.put('V', "브이");
        syllables.put('W', "더블유");
        syllables.put('X', "엑스");
        syllables.put('Y', "와이");
        syllables.put('Z', "지");
        return Map.copyOf(syllables);
    }
}
