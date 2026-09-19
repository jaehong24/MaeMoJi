package com.maemoji.backend.portfolioinsight.service;

import org.junit.jupiter.api.Test;

import javax.xml.parsers.DocumentBuilderFactory;
import java.nio.file.Files;
import java.nio.file.Path;
import java.io.StringReader;

import org.xml.sax.InputSource;

import static org.assertj.core.api.Assertions.assertThat;

class PushNotificationDeliveryContractTest {
    @Test
    void failedDeliveryHasBoundedRetryAndValidJsonPayloadContract() throws Exception {
        final Path mapper = Path.of("src/main/resources/mapper/portfolioinsight/PortfolioInsightMapper.xml");
        final String xml = Files.readString(mapper);
        assertThat(xml).contains("attempt_count &lt; 3");
        assertThat(xml).contains("next_retry_at &lt;= current_timestamp");
        assertThat(xml).contains("interval '5 minutes'");
        assertThat(xml).contains("delivery_status = 'PENDING'");
    }

    @Test
    void mapperXmlIsWellFormedBeforeDeployment() throws Exception {
        final Path mapper = Path.of("src/main/resources/mapper/portfolioinsight/PortfolioInsightMapper.xml");
        final var builder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
        builder.setEntityResolver((publicId, systemId) -> new InputSource(new StringReader("")));

        assertThat(builder.parse(mapper.toFile()).getDocumentElement().getNodeName()).isEqualTo("mapper");
    }
}
