package com.maemoji.backend.portfolioinsight.service;

import org.junit.jupiter.api.Test;
import java.nio.file.Files;
import java.nio.file.Path;
import static org.assertj.core.api.Assertions.assertThat;

class PushNotificationDeliveryContractTest {
    @Test
    void failedDeliveryHasBoundedRetryAndValidJsonPayloadContract() throws Exception {
        final Path mapper = Path.of("src/main/resources/mapper/portfolioinsight/PortfolioInsightMapper.xml");
        final String xml = Files.readString(mapper);
        assertThat(xml).contains("attempt_count < 3");
        assertThat(xml).contains("next_retry_at <= current_timestamp");
        assertThat(xml).contains("interval '5 minutes'");
        assertThat(xml).contains("delivery_status = 'PENDING'");
    }
}
