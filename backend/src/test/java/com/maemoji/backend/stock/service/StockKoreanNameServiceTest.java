package com.maemoji.backend.stock.service;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class StockKoreanNameServiceTest {

    private final StockKoreanNameService service = new StockKoreanNameService();

    @Test
    void 예외사전종목은_사전값을_우선사용한다() {
        assertThat(service.resolveNameKo("AAPL", "Apple Inc.", "STOCK"))
                .isEqualTo("애플");
        assertThat(service.resolveNameKo("GOOGL", "Alphabet Inc. Class A", "STOCK"))
                .isEqualTo("구글");
    }

    @Test
    void ETF는_티커음차를_기본으로_사용한다() {
        assertThat(service.resolveNameKo("QQQ", "Invesco QQQ Trust", "ETF"))
                .isEqualTo("큐큐큐");
        assertThat(service.resolveNameKo("VTI", "Vanguard Total Stock Market ETF", "ETF"))
                .isEqualTo("브이티아이");
        assertThat(service.resolveNameKo("XLK", "Technology Select Sector SPDR Fund", "ETF"))
                .isEqualTo("엑스엘케이");
    }

    @Test
    void 일반종목은_회사명정리후_단어사전으로_한글명을_생성한다() {
        assertThat(service.resolveNameKo("BAC", "Bank of America Corporation", "STOCK"))
                .isEqualTo("뱅크 오브 아메리카");
        assertThat(service.resolveNameKo("JNJ", "Johnson & Johnson", "STOCK"))
                .isEqualTo("존슨 앤 존슨");
    }

    @Test
    void 미등록단어는_최후에_글자단위한글음차로_처리한다() {
        assertThat(service.resolveNameKo("ABCD", "Abcd Ventures", "STOCK"))
                .isEqualTo("에이 비 씨 디 벤처스");
    }
}
