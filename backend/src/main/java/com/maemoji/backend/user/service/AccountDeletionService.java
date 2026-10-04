package com.maemoji.backend.user.service;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AccountDeletionService {
    private final JdbcTemplate jdbc;

    public AccountDeletionService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @Transactional
    public void deleteAccount(long userId) {
        // Serialize against portfolio creation, then lock the account against new FK references.
        jdbc.queryForList("select pg_advisory_xact_lock(?)", userId);
        if (jdbc.queryForList("select id from users where id = ? for update", userId).isEmpty()) {
            return;
        }
        for (String table : new String[]{"push_notification_deliveries", "weekly_notification_jobs",
                "user_device_tokens", "user_notification_preferences", "user_alert_events"}) {
            jdbc.update("delete from " + table + " where user_id = ?", userId);
        }
        jdbc.update("delete from portfolio_weekly_report_items where report_id in "
                + "(select id from portfolio_weekly_reports where user_id = ?)", userId);
        jdbc.update("delete from portfolio_weekly_reports where user_id = ?", userId);
        for (String table : new String[]{"toss_portfolio_mappings", "portfolio_sync_jobs", "portfolio_profile_settings"}) {
            jdbc.update("delete from " + table + " where user_id = ?", userId);
        }
        jdbc.update("delete from toss_portfolio_snapshots where connection_id in "
                + "(select id from toss_connections where user_id = ?)", userId);
        jdbc.update("delete from toss_accounts where connection_id in "
                + "(select id from toss_connections where user_id = ?)", userId);
        jdbc.update("delete from toss_connections where user_id = ?", userId);
        for (String table : new String[]{"recommendation_performance_evaluations",
                "recommendation_factor_details", "recommendation_evidence"}) {
            jdbc.update("delete from " + table + " where recommendation_id in "
                    + "(select id from recommendations where user_id = ?)", userId);
        }
        jdbc.update("delete from recommendations where user_id = ?", userId);
        jdbc.update("delete from portfolio_item_reasons where portfolio_item_id in "
                + "(select id from portfolio_items where user_id = ?)", userId);
        jdbc.update("delete from portfolio_items where user_id = ?", userId);
        jdbc.update("delete from users where id = ?", userId);
    }
}
