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

class NoSnapshotClassificationReportTest {

    private static final ZoneId KST = ZoneId.of("Asia/Seoul");
    private static final int RECENT_IMPORT_WINDOW_DAYS = 32;

    @Test
    void generatesNoSnapshotClassificationReport() throws Exception {
        final DatabaseConfig databaseConfig = loadDatabaseConfig();
        final List<Row> rows = new ArrayList<>();

        try (Connection connection = DriverManager.getConnection(
                databaseConfig.url(),
                databaseConfig.username(),
                databaseConfig.password()
        )) {
            final String sql = """
                    select
                        s.id,
                        s.ticker,
                        coalesce(s.name_ko, s.name_en, s.ticker) as company_name,
                        s.asset_type,
                        s.exchange_code,
                        s.finnhub_symbol,
                        s.ipo_date,
                        s.created_at::date as created_date
                    from stocks s
                    left join (
                        select distinct stock_id
                        from stock_price_snapshots
                    ) snapshots on snapshots.stock_id = s.id
                    where s.is_active = true
                      and s.finnhub_symbol is not null
                      and snapshots.stock_id is null
                    order by
                        case when coalesce(s.asset_type, '') = 'ETF' then 0 else 1 end,
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
                            resultSet.getString("exchange_code"),
                            resultSet.getString("finnhub_symbol"),
                            resultSet.getDate("ipo_date") == null
                                    ? null
                                    : resultSet.getDate("ipo_date").toLocalDate().toString(),
                            resultSet.getDate("created_date") == null
                                    ? null
                                    : resultSet.getDate("created_date").toLocalDate().toString()
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
        final long etfRows = rows.stream().filter(Row::isEtf).count();
        final long recentImportRows = rows.stream().filter(Row::isRecentNonEtfImport).count();
        final long matureRows = rows.stream().filter(row -> "MATURE_COLLECTION_GAP".equals(row.status())).count();

        final StringBuilder markdown = new StringBuilder();
        markdown.append("# MaeMoJi no_snapshot 분류 리포트").append(System.lineSeparator()).append(System.lineSeparator());
        markdown.append("- 생성 시각: ")
                .append(OffsetDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss xxx")))
                .append(System.lineSeparator());
        markdown.append("- no_snapshot 종목 수: ").append(rows.size()).append(System.lineSeparator());
        markdown.append("- ETF 미적재 종목 수: ").append(etfRows).append(System.lineSeparator());
        markdown.append("- 최근 유입 비ETF 미적재 종목 수: ").append(recentImportRows).append(System.lineSeparator());
        markdown.append("- 성숙 종목 수집 누락 종목 수: ").append(matureRows).append(System.lineSeparator()).append(System.lineSeparator());

        markdown.append("| 종목 | 회사명 | 자산유형 | 상태 | 상태 설명 | 거래소 | IPO | 등록일 |").append(System.lineSeparator());
        markdown.append("|---|---|---|---|---|---|---|---|").append(System.lineSeparator());
        for (Row row : rows) {
            markdown.append("| ")
                    .append(row.ticker()).append(" | ")
                    .append(row.companyName()).append(" | ")
                    .append(valueOrDash(row.assetType())).append(" | ")
                    .append(row.status()).append(" | ")
                    .append(row.message()).append(" | ")
                    .append(valueOrDash(row.exchangeCode())).append(" | ")
                    .append(valueOrDash(row.ipoDate())).append(" | ")
                    .append(valueOrDash(row.createdDate())).append(" |")
                    .append(System.lineSeparator());
        }

        final Path outputPath = Path.of("..", "docs", "recommendation", "no-snapshot-classification-report.md").normalize();
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
            String exchangeCode,
            String finnhubSymbol,
            String ipoDate,
            String createdDate
    ) {
        String status() {
            if (isEtf()) {
                return "ETF_DEFERRED";
            }
            if (isRecentNonEtfImport()) {
                return "RECENT_IMPORT_PENDING";
            }
            return "MATURE_COLLECTION_GAP";
        }

        String message() {
            return switch (status()) {
                case "ETF_DEFERRED" -> "ETF는 기업형 추천 모델과 분리되어 있어 초기 스냅샷 적재를 뒤로 미뤘어요.";
                case "RECENT_IMPORT_PENDING" -> "최근 유입된 비ETF 종목이라 첫 스냅샷 적재가 아직 대기 중이에요.";
                default -> "성숙 종목인데도 스냅샷이 없어 수집 누락 여부를 점검해야 해요.";
            };
        }

        boolean isEtf() {
            return "ETF".equalsIgnoreCase(assetType == null ? "" : assetType.trim());
        }

        boolean isRecentNonEtfImport() {
            if (isEtf() || createdDate == null) {
                return false;
            }
            return LocalDate.parse(createdDate)
                    .isAfter(LocalDate.now(KST).minusDays(RECENT_IMPORT_WINDOW_DAYS));
        }
    }
}
