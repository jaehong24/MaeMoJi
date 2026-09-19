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
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable(named = "LIVE_DB_REPORTS", matches = "true")
class LatestNullThirtyDayClassificationReportTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    private static final int RECENT_PRICE_HISTORY_WINDOW_DAYS = 32;

    @Test
    void generatesLatestNullThirtyDayClassificationReport() throws Exception {
        final DatabaseConfig databaseConfig = loadDatabaseConfig();
        final List<Row> rows = new ArrayList<>();
        long noSnapshotCount = 0L;

        try (Connection connection = DriverManager.getConnection(
                databaseConfig.url(),
                databaseConfig.username(),
                databaseConfig.password()
        )) {
            final String sql = """
                    with latest_snapshot as (
                        select distinct on (sps.stock_id)
                            sps.stock_id,
                            sps.snapshot_date,
                            sps.change_rate_7d,
                            sps.change_rate_30d,
                            sps.source
                        from stock_price_snapshots sps
                        order by sps.stock_id, sps.snapshot_date desc, sps.id desc
                    ),
                    oldest_snapshot as (
                        select
                            stock_id,
                            min(snapshot_date) as oldest_snapshot_date
                        from stock_price_snapshots
                        group by stock_id
                    ),
                    portfolio_stock_ids as (
                        select distinct stock_id
                        from portfolio_items
                        where is_active = true
                    )
                    select
                        s.id,
                        s.ticker,
                        coalesce(s.name_ko, s.name_en, s.ticker) as company_name,
                        s.asset_type,
                        s.ipo_date,
                        s.created_at::date as stock_created_date,
                        ls.snapshot_date,
                        os.oldest_snapshot_date,
                        ls.change_rate_7d is not null as has_price_7d,
                        ls.change_rate_30d is not null as has_price_30d,
                        ls.source,
                        recovery.recovery_status,
                        recovery.retry_after::text as recovery_retry_after,
                        exists (
                            select 1
                            from portfolio_stock_ids psi
                            where psi.stock_id = s.id
                        ) as in_portfolio
                    from stocks s
                    join latest_snapshot ls on ls.stock_id = s.id
                    left join oldest_snapshot os on os.stock_id = s.id
                    left join stock_price_history_recovery_states recovery on recovery.stock_id = s.id
                    where s.is_active = true
                      and s.finnhub_symbol is not null
                      and ls.change_rate_30d is null
                    order by
                        exists (
                            select 1
                            from portfolio_stock_ids psi
                            where psi.stock_id = s.id
                        ) desc,
                        s.ticker asc
                    """;

            try (PreparedStatement statement = connection.prepareStatement(sql);
                 ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    rows.add(new Row(
                            resultSet.getLong("id"),
                            resultSet.getString("ticker"),
                            resultSet.getString("company_name"),
                            resultSet.getString("asset_type"),
                            toDateString(resultSet, "ipo_date"),
                            toDateString(resultSet, "stock_created_date"),
                            toDateString(resultSet, "snapshot_date"),
                            toDateString(resultSet, "oldest_snapshot_date"),
                            resultSet.getBoolean("has_price_7d"),
                            resultSet.getBoolean("has_price_30d"),
                            resultSet.getString("source"),
                            resultSet.getString("recovery_status"),
                            resultSet.getString("recovery_retry_after"),
                            resultSet.getBoolean("in_portfolio")
                    ));
                }
            }

            try (PreparedStatement statement = connection.prepareStatement("""
                    with latest_snapshot as (
                        select distinct on (sps.stock_id)
                            sps.stock_id,
                            sps.snapshot_date
                        from stock_price_snapshots sps
                        order by sps.stock_id, sps.snapshot_date desc, sps.id desc
                    )
                    select count(*)
                    from stocks s
                    left join latest_snapshot ls on ls.stock_id = s.id
                    where s.is_active = true
                      and s.finnhub_symbol is not null
                      and ls.stock_id is null
                    """);
                 ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    noSnapshotCount = resultSet.getLong(1);
                }
            }
        }

        writeReport(rows, noSnapshotCount);
    }

    private String toDateString(ResultSet resultSet, String columnName) throws Exception {
        return resultSet.getDate(columnName) == null
                ? null
                : resultSet.getDate(columnName).toLocalDate().toString();
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

    private void writeReport(List<Row> rows, long noSnapshotCount) throws IOException {
        final long portfolioRows = rows.stream().filter(Row::inPortfolio).count();
        final long excludedEtfRows = rows.stream().filter(row -> "EXCLUDED_ETF".equals(row.status())).count();
        final long actionableRows = rows.size() - excludedEtfRows;
        final long recentListingRows = rows.stream().filter(row -> "RECENTLY_LISTED_30D_PENDING".equals(row.status())).count();
        final long historyWindowRows = rows.stream().filter(row -> "HISTORY_WINDOW_INSUFFICIENT".equals(row.status())).count();
        final long sourceGapRows = rows.stream().filter(row -> "SOURCE_UNSUPPORTED_OR_GAPPED".equals(row.status())).count();
        final long retryRows = rows.stream().filter(row -> "BACKFILL_RETRY_REQUIRED".equals(row.status())).count();
        final long partialRows = rows.stream().filter(row -> "PARTIAL_NEEDS_REVIEW".equals(row.status())).count();

        final StringBuilder markdown = new StringBuilder();
        markdown.append("# MaeMoJi latest_null_30d 분류 리포트").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- 생성 시각: ")
                .append(OffsetDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss xxx")))
                .append(System.lineSeparator());
        markdown.append("- latest_null_30d 종목 수: ").append(rows.size()).append(System.lineSeparator());
        markdown.append("- ETF 제외 대상: ").append(excludedEtfRows).append(System.lineSeparator());
        markdown.append("- 실제 복구/점검 대상(ETF 제외): ").append(actionableRows).append(System.lineSeparator());
        markdown.append("- latest_null_portfolio 종목 수: ").append(portfolioRows).append(System.lineSeparator());
        markdown.append("- no_snapshot 종목 수: ").append(noSnapshotCount).append(System.lineSeparator()).append(System.lineSeparator());

        markdown.append("- 최근 상장 30일 대기: ").append(recentListingRows).append(System.lineSeparator());
        markdown.append("- 30일 히스토리 부족: ").append(historyWindowRows).append(System.lineSeparator());
        markdown.append("- 소스 미지원/히스토리 공백: ").append(sourceGapRows).append(System.lineSeparator());
        markdown.append("- 즉시 백필 재시도 필요: ").append(retryRows).append(System.lineSeparator());
        markdown.append("- 수동 점검 필요: ").append(partialRows).append(System.lineSeparator()).append(System.lineSeparator());

        markdown.append("## 운영 판정").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- ETF는 기업형 추천 모델의 30일 복구 대상이 아니며, 가격 스냅샷 정책으로 별도 관리합니다.").append(System.lineSeparator());
        markdown.append("- 즉시 백필 재실행 대상은 ETF를 제외한 `BACKFILL_RETRY_REQUIRED` 종목입니다.").append(System.lineSeparator());
        markdown.append("- `SOURCE_UNSUPPORTED_OR_GAPPED` 종목은 limit 상향보다 데이터 소스/히스토리 예외 처리를 먼저 확인해야 합니다.").append(System.lineSeparator()).append(System.lineSeparator());

        markdown.append("| 종목 | 회사명 | 포트폴리오 | 상태 | 상태 설명 | 복구 상태 | 재시도 시각 | 최신 스냅샷 | 최초 스냅샷 | IPO | 소스 | 7일 | 30일 |").append(System.lineSeparator());
        markdown.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|").append(System.lineSeparator());
        for (Row row : rows) {
            markdown.append("| ")
                    .append(row.ticker()).append(" | ")
                    .append(row.companyName()).append(" | ")
                    .append(row.inPortfolio() ? "Y" : "N").append(" | ")
                    .append(row.status()).append(" | ")
                    .append(row.message()).append(" | ")
                    .append(valueOrDash(row.recoveryStatus())).append(" | ")
                    .append(valueOrDash(row.recoveryRetryAfter())).append(" | ")
                    .append(valueOrDash(row.snapshotDate())).append(" | ")
                    .append(valueOrDash(row.oldestSnapshotDate())).append(" | ")
                    .append(valueOrDash(row.ipoDate())).append(" | ")
                    .append(valueOrDash(row.source())).append(" | ")
                    .append(row.hasPrice7d() ? "Y" : "N").append(" | ")
                    .append(row.hasPrice30d() ? "Y" : "N").append(" |")
                    .append(System.lineSeparator());
        }

        final Path outputPath = Path.of("..", "docs", "recommendation", "latest-null-30d-classification-report.md").normalize();
        Files.createDirectories(outputPath.getParent());
        Files.writeString(outputPath, markdown.toString(), StandardCharsets.UTF_8);
    }

    private String valueOrDash(String value) {
        return value == null || value.isBlank() ? "-" : value;
    }

    private record DatabaseConfig(
            String url,
            String username,
            String password
    ) {
    }

    private record Row(
            Long stockId,
            String ticker,
            String companyName,
            String assetType,
            String ipoDate,
            String stockCreatedDate,
            String snapshotDate,
            String oldestSnapshotDate,
            boolean hasPrice7d,
            boolean hasPrice30d,
            String source,
            String recoveryStatus,
            String recoveryRetryAfter,
            boolean inPortfolio
    ) {
        String status() {
            if ("ETF".equalsIgnoreCase(assetType == null ? "" : assetType.trim())) {
                return "EXCLUDED_ETF";
            }
            if (isRecentPriceListing()) {
                return "RECENTLY_LISTED_30D_PENDING";
            }
            if ("HISTORY_UNAVAILABLE".equals(recoveryStatus)) {
                return "SOURCE_UNSUPPORTED_OR_GAPPED";
            }
            if ("INSUFFICIENT_HISTORY".equals(recoveryStatus)) {
                return "HISTORY_WINDOW_INSUFFICIENT";
            }
            if ("SOURCE_RETRY".equals(recoveryStatus)) {
                return "BACKFILL_RETRY_REQUIRED";
            }
            if (oldestSnapshotDate == null) {
                return "BACKFILL_RETRY_REQUIRED";
            }
            final LocalDate oldest = LocalDate.parse(oldestSnapshotDate);
            if (oldest.isAfter(LocalDate.now(KST).minusDays(30))) {
                return "HISTORY_WINDOW_INSUFFICIENT";
            }
            if (hasPrice7d && !hasPrice30d) {
                return "SOURCE_UNSUPPORTED_OR_GAPPED";
            }
            if (!hasPrice7d && !hasPrice30d) {
                return "BACKFILL_RETRY_REQUIRED";
            }
            return "PARTIAL_NEEDS_REVIEW";
        }

        String message() {
            return switch (status()) {
                case "EXCLUDED_ETF" -> "ETF는 기업형 추천 모델과 분리되어 있어요.";
                case "RECENTLY_LISTED_30D_PENDING" -> "최근 상장 종목이라 30일 가격 흐름이 아직 충분히 쌓이지 않았어요.";
                case "HISTORY_WINDOW_INSUFFICIENT" -> "30일 전 기준 가격이 충분하지 않아 다음 예정 시점에 다시 확인해요.";
                case "SOURCE_UNSUPPORTED_OR_GAPPED" -> "가격 제공자에서 30일 이력을 받지 못해 다음 예정 시점에 다시 확인해요.";
                case "BACKFILL_RETRY_REQUIRED" -> "스냅샷 또는 가격 흐름 백필을 다시 시도해야 해요.";
                default -> "일부 지표만 비어 있어 수동 점검이 필요해요.";
            };
        }

        private boolean isRecentPriceListing() {
            if (ipoDate == null) {
                return false;
            }
            return LocalDate.parse(ipoDate)
                    .isAfter(LocalDate.now(KST).minusDays(RECENT_PRICE_HISTORY_WINDOW_DAYS));
        }
    }
}
