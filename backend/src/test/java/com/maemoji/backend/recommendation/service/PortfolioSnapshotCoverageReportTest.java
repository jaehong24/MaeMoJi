package com.maemoji.backend.recommendation.service;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.OffsetDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

class PortfolioSnapshotCoverageReportTest {
    private static final int RECENT_PRICE_HISTORY_WINDOW_DAYS = 32;
    private static final int RECENT_FUNDAMENTAL_WINDOW_DAYS = 90;

    @Test
    void generatesActivePortfolioSnapshotCoverageReport() throws Exception {
        final DatabaseConfig databaseConfig = loadDatabaseConfig();
        final List<Row> rows = new ArrayList<>();

        try (Connection connection = DriverManager.getConnection(
                databaseConfig.url(),
                databaseConfig.username(),
                databaseConfig.password()
        )) {
            try (PreparedStatement schemaStatement = connection.prepareStatement(
                    "alter table stocks add column if not exists ipo_date date"
            )) {
                schemaStatement.execute();
            }
            final String sql = """
                    with active_items as (
                        select
                            pi.id as portfolio_item_id,
                            pi.user_id,
                            s.id as stock_id,
                            s.symbol,
                            coalesce(s.name_ko, s.name_en, s.symbol) as company_name,
                            s.asset_type,
                            s.created_at::date as stock_created_date,
                            s.ipo_date
                        from portfolio_items pi
                        join stocks s on s.id = pi.stock_id
                        where pi.is_active = true
                    ),
                    latest_snapshot as (
                        select distinct on (p.stock_id)
                            p.stock_id,
                            p.snapshot_date,
                            p.eps_ttm,
                            p.roe_ttm,
                            p.revenue_growth_yoy,
                            p.operating_margin_ttm,
                            p.change_rate_7d,
                            p.change_rate_30d
                        from stock_price_snapshots p
                        order by p.stock_id, p.snapshot_date desc, p.id desc
                    ),
                    oldest_snapshot as (
                        select
                            stock_id,
                            min(snapshot_date) as oldest_snapshot_date
                        from stock_price_snapshots
                        group by stock_id
                    )
                    select
                        ai.user_id,
                        ai.portfolio_item_id,
                        ai.symbol,
                        ai.company_name,
                        ai.asset_type,
                        ai.stock_created_date,
                        ai.ipo_date,
                        ls.snapshot_date,
                        os.oldest_snapshot_date,
                        ls.eps_ttm is not null as has_eps,
                        ls.roe_ttm is not null as has_roe,
                        ls.revenue_growth_yoy is not null as has_revenue_growth,
                        ls.operating_margin_ttm is not null as has_operating_margin,
                        ls.change_rate_7d is not null as has_price_7d,
                        ls.change_rate_30d is not null as has_price_30d
                    from active_items ai
                    left join latest_snapshot ls on ls.stock_id = ai.stock_id
                    left join oldest_snapshot os on os.stock_id = ai.stock_id
                    order by ai.user_id, ai.symbol
                    """;

            try (PreparedStatement statement = connection.prepareStatement(sql);
                 ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    rows.add(new Row(
                            resultSet.getLong("user_id"),
                            resultSet.getLong("portfolio_item_id"),
                            resultSet.getString("symbol"),
                            resultSet.getString("company_name"),
                            resultSet.getString("asset_type"),
                            resultSet.getDate("stock_created_date") == null
                                    ? null
                                    : resultSet.getDate("stock_created_date").toLocalDate().toString(),
                            resultSet.getDate("ipo_date") == null
                                    ? null
                                    : resultSet.getDate("ipo_date").toLocalDate().toString(),
                            resultSet.getDate("snapshot_date") == null
                                    ? null
                                    : resultSet.getDate("snapshot_date").toLocalDate().toString(),
                            resultSet.getDate("oldest_snapshot_date") == null
                                    ? null
                                    : resultSet.getDate("oldest_snapshot_date").toLocalDate().toString(),
                            resultSet.getBoolean("has_eps"),
                            resultSet.getBoolean("has_roe"),
                            resultSet.getBoolean("has_revenue_growth"),
                            resultSet.getBoolean("has_operating_margin"),
                            resultSet.getBoolean("has_price_7d"),
                            resultSet.getBoolean("has_price_30d")
                    ));
                }
            }
        }

        writeReport(rows);
    }

    private DatabaseConfig loadDatabaseConfig() throws IOException {
        final Map<String, String> values = new LinkedHashMap<>(System.getenv());
        final Path envPath = Path.of("..", ".env").normalize();
        if (Files.exists(envPath)) {
            for (String line : Files.readAllLines(envPath, StandardCharsets.UTF_8)) {
                final String trimmed = line.trim();
                if (trimmed.isEmpty() || trimmed.startsWith("#") || !trimmed.contains("=")) {
                    continue;
                }
                final int delimiterIndex = trimmed.indexOf('=');
                final String key = trimmed.substring(0, delimiterIndex).trim();
                final String value = trimmed.substring(delimiterIndex + 1).trim();
                values.putIfAbsent(key, value);
            }
        }

        final String url = firstNonBlank(values, "SPRING_DATASOURCE_URL", "DATABASE_URL", "NEON_DATABASE_URL");
        final String username = firstNonBlank(values, "SPRING_DATASOURCE_USERNAME");
        final String password = firstNonBlank(values, "SPRING_DATASOURCE_PASSWORD");

        assertThat(url).as("database url").isNotBlank();
        assertThat(username).as("database username").isNotBlank();
        assertThat(password).as("database password").isNotBlank();
        return new DatabaseConfig(url, username, password);
    }

    private String firstNonBlank(Map<String, String> values, String... keys) {
        for (String key : keys) {
            final String value = values.get(key);
            if (value != null && !value.isBlank()) {
                return value;
            }
        }
        return null;
    }

    private void writeReport(List<Row> rows) throws IOException {
        final long total = rows.size();
        final long completeRows = rows.stream().filter(Row::isComplete).count();
        final long excludedEtfRows = rows.stream().filter(row -> "EXCLUDED_ETF".equals(row.coverageStatus())).count();
        final long recentBothRows = rows.stream().filter(row -> "RECENTLY_LISTED_BOTH_PENDING".equals(row.coverageStatus())).count();
        final long recentListingRows = rows.stream().filter(row -> "RECENTLY_LISTED_30D_EXCEPTION".equals(row.coverageStatus())).count();
        final long recentFundamentalRows = rows.stream().filter(row -> "RECENTLY_LISTED_FUNDAMENTAL_EXCEPTION".equals(row.coverageStatus())).count();
        final long accumulatingRows = rows.stream().filter(row -> "PRICE_FLOW_ACCUMULATING".equals(row.coverageStatus())).count();
        final long disclosurePendingRows = rows.stream().filter(row -> "FUNDAMENTAL_DISCLOSURE_PENDING".equals(row.coverageStatus())).count();
        final long retryRequiredRows = rows.stream().filter(row -> "IMMEDIATE_RETRY_REQUIRED".equals(row.coverageStatus())).count();
        final long partialReviewRows = rows.stream().filter(row -> "PARTIAL_NEEDS_REVIEW".equals(row.coverageStatus())).count();

        final StringBuilder markdown = new StringBuilder();
        markdown.append("# MaeMoJi 활성 포트폴리오 스냅샷 커버리지").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- 생성 시각: ")
                .append(OffsetDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss xxx")))
                .append(System.lineSeparator());
        markdown.append("- 활성 포트폴리오 종목 수: ").append(total).append(System.lineSeparator());
        markdown.append("- 핵심 지표 완전 적재 종목 수: ").append(completeRows).append(" / ").append(total)
                .append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- ETF 제외 종목 수: ").append(excludedEtfRows).append(System.lineSeparator());
        markdown.append("- 최근 상장 통합 대기 종목 수: ").append(recentBothRows).append(System.lineSeparator());
        markdown.append("- 신규 상장 30일 예외 종목 수: ").append(recentListingRows).append(System.lineSeparator());
        markdown.append("- 신규 상장 펀더멘털 예외 종목 수: ").append(recentFundamentalRows).append(System.lineSeparator());
        markdown.append("- 가격 흐름 축적 중 종목 수: ").append(accumulatingRows).append(System.lineSeparator());
        markdown.append("- 재무 공시/재수집 대기 종목 수: ").append(disclosurePendingRows).append(System.lineSeparator());
        markdown.append("- 즉시 백필 재시도 필요 종목 수: ").append(retryRequiredRows).append(System.lineSeparator());
        markdown.append("- 수동 점검 필요 종목 수: ").append(partialReviewRows).append(System.lineSeparator()).append(System.lineSeparator());

        markdown.append("| userId | portfolioItemId | 종목 | 회사명 | 자산유형 | 스냅샷일 | 최초스냅샷일 | 상태 | 상태 설명 | EPS | ROE | 매출성장 | 영업이익률 | 7일흐름 | 30일흐름 |")
                .append(System.lineSeparator());
        markdown.append("|---:|---:|---|---|---|---|---|---|---|---|---|---|---|---|---|").append(System.lineSeparator());
        for (Row row : rows) {
            markdown.append("| ")
                    .append(row.userId()).append(" | ")
                    .append(row.portfolioItemId()).append(" | ")
                    .append(row.symbol()).append(" | ")
                    .append(row.companyName()).append(" | ")
                    .append(row.assetType() == null ? "-" : row.assetType()).append(" | ")
                    .append(row.snapshotDate() == null ? "-" : row.snapshotDate()).append(" | ")
                    .append(row.oldestSnapshotDate() == null ? "-" : row.oldestSnapshotDate()).append(" | ")
                    .append(row.coverageStatus()).append(" | ")
                    .append(row.coverageMessage()).append(" | ")
                    .append(mark(row.hasEps())).append(" | ")
                    .append(mark(row.hasRoe())).append(" | ")
                    .append(mark(row.hasRevenueGrowth())).append(" | ")
                    .append(mark(row.hasOperatingMargin())).append(" | ")
                    .append(mark(row.hasPrice7d())).append(" | ")
                    .append(mark(row.hasPrice30d())).append(" |")
                    .append(System.lineSeparator());
        }

        final Path outputPath = Path.of("..", "docs", "recommendation", "portfolio-snapshot-coverage-report.md").normalize();
        Files.createDirectories(outputPath.getParent());
        Files.writeString(outputPath, markdown.toString(), StandardCharsets.UTF_8);
    }

    private String mark(boolean value) {
        return value ? "Y" : "N";
    }

    private record DatabaseConfig(
            String url,
            String username,
            String password
    ) {
    }

    private record Row(
            Long userId,
            Long portfolioItemId,
            String symbol,
            String companyName,
            String assetType,
            String stockCreatedDate,
            String ipoDate,
            String snapshotDate,
            String oldestSnapshotDate,
            boolean hasEps,
            boolean hasRoe,
            boolean hasRevenueGrowth,
            boolean hasOperatingMargin,
            boolean hasPrice7d,
            boolean hasPrice30d
    ) {
        boolean isComplete() {
            return hasEps
                    && hasRoe
                    && hasRevenueGrowth
                    && hasOperatingMargin
                    && hasPrice7d
                    && hasPrice30d;
        }

        String coverageStatus() {
            if ("ETF".equalsIgnoreCase(assetType == null ? "" : assetType.trim())) {
                return "EXCLUDED_ETF";
            }
            if (!hasPrice7d && !hasPrice30d && !hasAnyCoreFundamentals() && isRecentPriceListing() && isRecentFundamentalListing()) {
                return "RECENTLY_LISTED_BOTH_PENDING";
            }
            if (hasPrice7d && !hasPrice30d) {
                if (!hasAnyCoreFundamentals() && isRecentPriceListing()) {
                    return "RECENTLY_LISTED_30D_EXCEPTION";
                }
                if (isRecentPriceListing()) {
                    return "PRICE_FLOW_ACCUMULATING";
                }
                return "IMMEDIATE_RETRY_REQUIRED";
            }
            if (!hasAnyCoreFundamentals()) {
                if (isRecentFundamentalListing()) {
                    return "RECENTLY_LISTED_FUNDAMENTAL_EXCEPTION";
                }
                return "FUNDAMENTAL_DISCLOSURE_PENDING";
            }
            if (isComplete()) {
                return "OK";
            }
            if (snapshotDate == null) {
                return "SNAPSHOT_MISSING";
            }
            return "PARTIAL_NEEDS_REVIEW";
        }

        String coverageMessage() {
            return switch (coverageStatus()) {
                case "EXCLUDED_ETF" -> "ETF는 기업형 추천 모델과 분리되어 있어요.";
                case "RECENTLY_LISTED_BOTH_PENDING" -> "최근 상장 종목이라 30일 가격 흐름과 재무 공시가 함께 쌓이는 중입니다.";
                case "RECENTLY_LISTED_30D_EXCEPTION" -> "최근 상장 종목이라 30일 가격 흐름이 아직 충분하지 않습니다.";
                case "PRICE_FLOW_ACCUMULATING" -> "최근 가격 흐름 데이터를 더 쌓는 중입니다.";
                case "RECENTLY_LISTED_FUNDAMENTAL_EXCEPTION" -> "최근 상장 종목이라 재무 지표 공시가 아직 충분하지 않습니다.";
                case "FUNDAMENTAL_DISCLOSURE_PENDING" -> "일부 핵심 재무 지표를 재수집하거나 다음 공시를 기다리는 상태입니다.";
                case "IMMEDIATE_RETRY_REQUIRED" -> "가격 흐름 백필이 즉시 다시 필요한 상태입니다.";
                case "PARTIAL_NEEDS_REVIEW" -> "일부 지표만 비어 있어 수동 점검이 필요합니다.";
                case "SNAPSHOT_MISSING" -> "스냅샷 자체가 없어 초기 적재를 다시 확인해야 합니다.";
                default -> "핵심 지표와 가격 흐름이 모두 준비되었습니다.";
            };
        }

        private boolean hasAnyCoreFundamentals() {
            return hasEps || hasRoe || hasRevenueGrowth || hasOperatingMargin;
        }

        private boolean isRecentPriceListing() {
            final String anchorDate = ipoDate != null
                    ? ipoDate
                    : (stockCreatedDate != null ? stockCreatedDate : oldestSnapshotDate);
            if (anchorDate == null || snapshotDate == null) {
                return false;
            }
            return java.time.LocalDate.parse(anchorDate)
                    .isAfter(java.time.LocalDate.now(java.time.ZoneId.of("Asia/Seoul"))
                            .minusDays(RECENT_PRICE_HISTORY_WINDOW_DAYS));
        }

        private boolean isRecentFundamentalListing() {
            final String anchorDate = ipoDate != null
                    ? ipoDate
                    : (stockCreatedDate != null ? stockCreatedDate : oldestSnapshotDate);
            if (anchorDate == null || snapshotDate == null) {
                return false;
            }
            return java.time.LocalDate.parse(anchorDate)
                    .isAfter(java.time.LocalDate.now(java.time.ZoneId.of("Asia/Seoul"))
                            .minusDays(RECENT_FUNDAMENTAL_WINDOW_DAYS));
        }
    }
}
