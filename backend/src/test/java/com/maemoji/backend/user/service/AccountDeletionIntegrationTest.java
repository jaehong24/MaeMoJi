package com.maemoji.backend.user.service;

import org.junit.jupiter.api.*;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import java.util.UUID;
import static org.assertj.core.api.Assertions.*;

@EnabledIfEnvironmentVariable(named = "LOCAL_OUTBOX_TEST", matches = "true")
class AccountDeletionIntegrationTest {
    JdbcTemplate jdbc;
    TransactionTemplate tx;
    String schema;
    AccountDeletionService service;

    @BeforeEach void setup() {
        schema = "deletion_" + UUID.randomUUID().toString().replace("-", "");
        var ds = new DriverManagerDataSource("jdbc:postgresql://127.0.0.1:55439/postgres", "testadmin", "");
        new JdbcTemplate(ds).execute("create schema " + schema);
        ds.setUrl(ds.getUrl() + "?currentSchema=" + schema);
        jdbc = new JdbcTemplate(ds);
        tx = new TransactionTemplate(new DataSourceTransactionManager(ds));
        service = new AccountDeletionService(jdbc);
        jdbc.execute("create table users(id bigint primary key)");
        jdbc.update("insert into users values (1), (2)");
        for (String table : new String[]{"portfolio_items", "recommendations", "portfolio_weekly_reports",
                "toss_connections", "push_notification_deliveries", "weekly_notification_jobs",
                "user_device_tokens", "user_notification_preferences", "user_alert_events",
                "toss_portfolio_mappings", "portfolio_sync_jobs", "portfolio_profile_settings"}) {
            jdbc.execute("create table " + table + " (id bigint primary key, user_id bigint references users(id))");
            jdbc.update("insert into " + table + " values (1,1), (2,2)");
        }
        child("portfolio_weekly_report_items", "report_id", "portfolio_weekly_reports");
        child("toss_portfolio_snapshots", "connection_id", "toss_connections");
        child("toss_accounts", "connection_id", "toss_connections");
        child("recommendation_performance_evaluations", "recommendation_id", "recommendations");
        child("recommendation_factor_details", "recommendation_id", "recommendations");
        child("recommendation_evidence", "recommendation_id", "recommendations");
        child("portfolio_item_reasons", "portfolio_item_id", "portfolio_items");
    }

    void child(String table, String key, String parent) {
        jdbc.execute("create table " + table + " (id bigint primary key, " + key + " bigint references " + parent + "(id))");
        jdbc.update("insert into " + table + " values (1,1), (2,2)");
    }

    @AfterEach void cleanup() {
        if (jdbc != null) jdbc.execute("drop schema " + schema + " cascade");
    }

    @Test void removesOnlyAuthenticatedOwnersData() {
        tx.executeWithoutResult(s -> service.deleteAccount(1));
        for (String table : jdbc.queryForList("select tablename from pg_tables where schemaname = ?", String.class, schema)) {
            assertThat(jdbc.queryForList("select id from " + table, Long.class)).containsExactly(2L);
        }
        tx.executeWithoutResult(s -> service.deleteAccount(1));
        assertThat(jdbc.queryForObject("select count(*) from users", Integer.class)).isEqualTo(1);
    }

    @Test void unexpectedForeignKeyRollsBackAllDeletions() {
        jdbc.execute("create table future_dependency(user_id bigint references users(id))");
        jdbc.update("insert into future_dependency values (1)");
        assertThatThrownBy(() -> tx.executeWithoutResult(s -> service.deleteAccount(1))).isInstanceOf(RuntimeException.class);
        assertThat(jdbc.queryForObject("select count(*) from users", Integer.class)).isEqualTo(2);
        assertThat(jdbc.queryForObject("select count(*) from user_device_tokens", Integer.class)).isEqualTo(2);
        assertThat(jdbc.queryForObject("select count(*) from recommendation_factor_details", Integer.class)).isEqualTo(2);
    }
}
