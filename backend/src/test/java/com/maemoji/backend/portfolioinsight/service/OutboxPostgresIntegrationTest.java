package com.maemoji.backend.portfolioinsight.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.maemoji.backend.common.startup.PushNotificationSchemaInitializer;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import com.maemoji.backend.portfolioinsight.dto.UserDeviceTokenUpsertRequest;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import java.time.OffsetDateTime;
import java.util.List;
import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;
import static org.mockito.ArgumentMatchers.*;

/** Uses only a dedicated loopback PostgreSQL database, never application .env credentials. */
@EnabledIfEnvironmentVariable(named="LOCAL_OUTBOX_TEST", matches="true")
class OutboxPostgresIntegrationTest {
    JdbcTemplate jdbc;
    PortfolioInsightMapper mapper;
    PushNotificationRetryService worker;
    FirebaseMessagingGateway firebase;
    TransactionTemplate transaction;
    DriverManagerDataSource ds;
    String schema;

    @BeforeEach void setup() throws Exception {
        schema = "outbox_" + java.util.UUID.randomUUID().toString().replace("-", "");
        ds = new DriverManagerDataSource("jdbc:postgresql://127.0.0.1:55439/postgres", "testadmin", "");
        new JdbcTemplate(ds).execute("create schema " + schema);
        ds.setUrl(ds.getUrl() + "?currentSchema=" + schema);
        jdbc = new JdbcTemplate(ds);
        jdbc.execute("create table users(id bigint primary key, nickname text)");
        jdbc.execute("create table user_alert_events(id bigint primary key)");
        jdbc.execute("create table portfolio_weekly_reports(id bigint primary key)");
        jdbc.update("insert into users values (1, 'test_android_owner'), (2, 'test_web_owner')");
        jdbc.update("insert into portfolio_weekly_reports values (11)");
        var initializer = new PushNotificationSchemaInitializer(jdbc);
        initializer.run(null);
        var factory = new SqlSessionFactoryBean();
        factory.setDataSource(ds);
        var config = new org.apache.ibatis.session.Configuration();
        config.setMapUnderscoreToCamelCase(true);
        factory.setConfiguration(config);
        factory.setMapperLocations(new ClassPathResource("mapper/portfolioinsight/PortfolioInsightMapper.xml"));
        mapper = new SqlSessionTemplate(factory.getObject()).getMapper(PortfolioInsightMapper.class);
        var settings = new PushNotificationSettingsService(mapper);
        settings.upsertDevice(1L, new UserDeviceTokenUpsertRequest("ANDROID", "fake-android", "test-a", "test", true));
        settings.upsertDevice(2L, new UserDeviceTokenUpsertRequest("WEB", "fake-web", "test-b", "test", true));
        firebase = mock(FirebaseMessagingGateway.class);
        when(firebase.sendEach(anyList())).thenReturn(List.of(FirebaseMessagingGateway.SendResult.success("fake-provider-id")));
        var dispatch = new PushNotificationDispatchService(mapper, new PushNotificationPolicyService(), firebase,
                new PushDeliveryOutboxNotifier(event -> {}));
        worker = new PushNotificationRetryService(mapper, firebase, new ObjectMapper(), dispatch, initializer);
        transaction = new TransactionTemplate(new DataSourceTransactionManager(ds));
    }

    @AfterEach void cleanup() {
        if (jdbc != null) jdbc.execute("drop schema " + schema + " cascade");
    }

    void enqueue(long user, String key) {
        long device = mapper.findDeviceTokensByUserId(user).get(0).getId();
        mapper.insertPushNotificationDelivery(null, null, user, device, "IMMEDIATE", "PRICE_RISK",
                key, "Test", "Fake device message", "{\"type\":\"ALERT_EVENT\",\"focusSection\":\"HISTORY\"}");
    }

    @Test void twoAccountsAndDevicesAreIsolatedAndRepeatedRunsDoNotResend() throws Exception {
        assertThat(mapper.findDeviceTokensByUserId(1L)).extracting(d -> d.getFcmToken()).containsExactly("fake-android");
        assertThat(mapper.findDeviceTokenByUserIdAndToken(1L, "fake-web")).isNull();
        assertThat(mapper.deactivateDeviceToken(1L, "fake-web", OffsetDateTime.now())).isZero();
        enqueue(1, "a"); enqueue(2, "b"); enqueue(1, "a");
        worker.retryFailedDeliveries(); worker.retryFailedDeliveries();
        verify(firebase, times(2)).sendEach(anyList());
        assertThat(jdbc.queryForObject("select count(*) from push_notification_deliveries where delivery_status='SENT'", Integer.class)).isEqualTo(2);
    }

    @Test void rollbackDoesNotSendAndCommitDoesNotCallFirebaseInline() throws Exception {
        var notifier = new PushDeliveryOutboxNotifier(event -> worker.dispatchQueuedDeliveries((PushDeliveryQueuedEvent) event));
        transaction.executeWithoutResult(status -> {
            enqueue(1, "rollback"); notifier.requestDispatchAfterCommit(); status.setRollbackOnly();
        });
        worker.retryFailedDeliveries();
        verifyNoInteractions(firebase);
        transaction.executeWithoutResult(status -> { enqueue(1, "commit"); notifier.requestDispatchAfterCommit(); });
        verifyNoInteractions(firebase);
        worker.retryFailedDeliveries();
        verify(firebase).sendEach(anyList());
    }

    @Test void temporaryFailureWaitsThenRetriesOnlyFailedDevice() throws Exception {
        enqueue(1, "a"); enqueue(2, "b");
        when(firebase.sendEach(anyList())).thenReturn(
                List.of(FirebaseMessagingGateway.SendResult.success("ok")),
                List.of(FirebaseMessagingGateway.SendResult.failure("UNAVAILABLE", "temporary")),
                List.of(FirebaseMessagingGateway.SendResult.success("recovered")));
        worker.retryFailedDeliveries(); worker.retryFailedDeliveries();
        verify(firebase, times(2)).sendEach(anyList());
        jdbc.update("update push_notification_deliveries set next_retry_at=now()-interval '1 minute' where delivery_status='FAILED'");
        worker.retryFailedDeliveries(); worker.retryFailedDeliveries();
        verify(firebase, times(3)).sendEach(anyList());
        assertThat(jdbc.queryForObject("select count(*) from push_notification_deliveries where delivery_status='SENT'", Integer.class)).isEqualTo(2);
    }

    @Test void accountSwitchMustNotSendPreviousOwnersQueuedMessage() throws Exception {
        enqueue(1, "old-account");
        mapper.upsertDeviceToken(2L, "ANDROID", "test-a", "fake-android", "test", true, OffsetDateTime.now());
        worker.retryFailedDeliveries();
        verifyNoInteractions(firebase);
    }

    @Test void weeklyReportMovesFromPendingToSuccessAfterRecovery() throws Exception {
        enqueue(1, "weekly-a"); enqueue(2, "weekly-b");
        jdbc.update("update user_device_tokens set user_id=1 where user_id=2");
        jdbc.update("update push_notification_deliveries set user_id=1 where user_id=2");
        jdbc.update("update push_notification_deliveries set weekly_report_id=11, notification_kind='WEEKLY_DIGEST'");
        mapper.insertWeeklyNotificationJobIfAbsent(1L, 11L, java.time.LocalDate.of(2026,9,14), OffsetDateTime.now());
        when(firebase.sendEach(anyList())).thenReturn(
                List.of(FirebaseMessagingGateway.SendResult.success("ok")),
                List.of(FirebaseMessagingGateway.SendResult.failure("UNAVAILABLE", "temporary")),
                List.of(FirebaseMessagingGateway.SendResult.success("recovered")));
        worker.retryFailedDeliveries();
        assertThat(jdbc.queryForObject("select job_status from weekly_notification_jobs", String.class)).isEqualTo("PENDING");
        jdbc.update("update push_notification_deliveries set next_retry_at=now()-interval '1 minute' where delivery_status='FAILED'");
        worker.retryFailedDeliveries();
        assertThat(jdbc.queryForObject("select job_status from weekly_notification_jobs", String.class)).isEqualTo("SUCCESS");
        assertThat(jdbc.queryForObject("select success_count from weekly_notification_jobs", Integer.class)).isEqualTo(2);
    }

    @Test void concurrentWorkersCannotBothClaimTheSamePendingDelivery() throws Exception {
        enqueue(1, "race");
        long id = mapper.findPendingPushDeliveries(50).get(0).getId();
        var executor = java.util.concurrent.Executors.newFixedThreadPool(2);
        try {
            var barrier = new java.util.concurrent.CyclicBarrier(2);
            java.util.concurrent.Callable<Integer> claim = () -> {
                barrier.await(5, java.util.concurrent.TimeUnit.SECONDS);
                return mapper.claimPendingPushNotificationDelivery(id);
            };
            var first = executor.submit(claim);
            var second = executor.submit(claim);
            assertThat(first.get(10, java.util.concurrent.TimeUnit.SECONDS)
                    + second.get(10, java.util.concurrent.TimeUnit.SECONDS)).isEqualTo(1);
        } finally { executor.shutdownNow(); }
    }

    @Test void invalidTokenIsDisabledWithoutFurtherRetries() throws Exception {
        enqueue(1, "expired");
        when(firebase.sendEach(anyList())).thenReturn(List.of(FirebaseMessagingGateway.SendResult.failure("UNREGISTERED", "expired")));
        worker.retryFailedDeliveries(); worker.retryFailedDeliveries();
        verify(firebase).sendEach(anyList());
        assertThat(mapper.findDeviceTokensByUserId(1L).get(0).getIsActive()).isFalse();
    }
}
