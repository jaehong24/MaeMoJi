package com.maemoji.backend.common.config;

import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import org.springframework.mock.env.MockEnvironment;

import static org.assertj.core.api.Assertions.assertThat;

class DatasourceEnvironmentPostProcessorTest {

    private final DatasourceEnvironmentPostProcessor postProcessor =
            new DatasourceEnvironmentPostProcessor();

    @Test
    void renderStyleDatabaseUrlIsConvertedToJdbcDatasourceProperties() {
        final MockEnvironment environment = new MockEnvironment()
                .withProperty("DATABASE_URL", "postgresql://demo-user:demo-pass@render.example.com/demo_db");

        postProcessor.postProcessEnvironment(environment, new SpringApplication(Object.class));

        assertThat(environment.getProperty("spring.datasource.url"))
                .isEqualTo("jdbc:postgresql://render.example.com/demo_db");
        assertThat(environment.getProperty("spring.datasource.username"))
                .isEqualTo("demo-user");
        assertThat(environment.getProperty("spring.datasource.password"))
                .isEqualTo("demo-pass");
        assertThat(environment.getProperty("spring.datasource.driver-class-name"))
                .isEqualTo("org.postgresql.Driver");
    }

    @Test
    void explicitSpringDatasourceEnvironmentValuesAreNotOverridden() {
        final MockEnvironment environment = new MockEnvironment()
                .withProperty("DATABASE_URL", "postgresql://demo-user:demo-pass@render.example.com/demo_db")
                .withProperty("SPRING_DATASOURCE_URL", "jdbc:postgresql://localhost:5432/local_db")
                .withProperty("SPRING_DATASOURCE_USERNAME", "local-user")
                .withProperty("SPRING_DATASOURCE_PASSWORD", "local-pass")
                .withProperty("spring.datasource.url", "jdbc:postgresql://localhost:5432/local_db")
                .withProperty("spring.datasource.username", "local-user")
                .withProperty("spring.datasource.password", "local-pass");

        postProcessor.postProcessEnvironment(environment, new SpringApplication(Object.class));

        assertThat(environment.getProperty("spring.datasource.url"))
                .isEqualTo("jdbc:postgresql://localhost:5432/local_db");
        assertThat(environment.getProperty("spring.datasource.username"))
                .isEqualTo("local-user");
        assertThat(environment.getProperty("spring.datasource.password"))
                .isEqualTo("local-pass");
    }

    @Test
    void neonDatabaseUrlGetsRequiredSslModeAutomatically() {
        final MockEnvironment environment = new MockEnvironment()
                .withProperty(
                        "NEON_DATABASE_URL",
                        "postgresql://demo-user:demo-pass@ep-example-123456.us-east-1.aws.neon.tech/neondb"
                );

        postProcessor.postProcessEnvironment(environment, new SpringApplication(Object.class));

        assertThat(environment.getProperty("spring.datasource.url"))
                .isEqualTo(
                        "jdbc:postgresql://ep-example-123456.us-east-1.aws.neon.tech/neondb?sslmode=require"
                );
        assertThat(environment.getProperty("spring.datasource.username"))
                .isEqualTo("demo-user");
        assertThat(environment.getProperty("spring.datasource.password"))
                .isEqualTo("demo-pass");
    }
}
