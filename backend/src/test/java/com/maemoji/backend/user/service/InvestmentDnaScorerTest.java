package com.maemoji.backend.user.service;

import org.junit.jupiter.api.Test;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class InvestmentDnaScorerTest {

    private final InvestmentDnaScorer scorer = new InvestmentDnaScorer();

    @Test
    void classifiesEveryScoreBoundary() {
        assertType(24, "SAFE_FIRST");
        assertType(25, "BALANCE_SEEKER");
        assertType(36, "BALANCE_SEEKER");
        assertType(37, "GROWTH_SEEKER");
        assertType(48, "GROWTH_SEEKER");
        assertType(49, "AGGRESSIVE_INVESTOR");
        assertType(54, "AGGRESSIVE_INVESTOR");
        assertType(55, "WEALTH_MASTER");
        assertType(60, "WEALTH_MASTER");
    }

    @Test
    void calculatesScoreFromTwelveAnswers() {
        final List<Integer> answers = Collections.nCopies(12, 5);

        final InvestmentDnaScorer.ScoringResult result = scorer.calculate(answers);

        assertEquals(60, result.score());
        assertEquals("WEALTH_MASTER", result.investmentDnaType());
        assertEquals("AGGRESSIVE", result.riskProfile());
    }

    @Test
    void rejectsIncompleteOrOutOfRangeAnswers() {
        assertThrows(
                IllegalArgumentException.class,
                () -> scorer.calculate(Collections.nCopies(11, 3))
        );
        assertThrows(
                IllegalArgumentException.class,
                () -> scorer.calculate(List.of(1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 1, 6))
        );
    }

    private void assertType(int score, String expectedType) {
        assertEquals(expectedType, scorer.resolveProfile(score).investmentDnaType());
    }
}
