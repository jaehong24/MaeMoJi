package com.maemoji.backend.common.config;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

import java.net.URI;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Normalizes hosted Postgres environment variables such as Render or Neon DATABASE_URL
 * into Spring Boot datasource properties before the DataSource is created.
 */
public class DatasourceEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    private static final String PROPERTY_SOURCE_NAME = "maemojiHostedDatasource";

    @Override
    public void postProcessEnvironment(
            ConfigurableEnvironment environment,
            SpringApplication application
    ) {
        final Map<String, Object> overrides = new LinkedHashMap<>();

        final String datasourceUrl = blankToNull(environment.getProperty("spring.datasource.url"));
        final String datasourceUsername = blankToNull(environment.getProperty("spring.datasource.username"));
        final String datasourcePassword = blankToNull(environment.getProperty("spring.datasource.password"));
        final String explicitDatasourceUrl = firstNonBlank(
                environment.getProperty("SPRING_DATASOURCE_URL"),
                environment.getProperty("MAEMOJI_DB_URL")
        );
        final String explicitDatasourceUsername = firstNonBlank(
                environment.getProperty("DATABASE_USERNAME"),
                environment.getProperty("SPRING_DATASOURCE_USERNAME"),
                environment.getProperty("MAEMOJI_DB_USER")
        );
        final String explicitDatasourcePassword = firstNonBlank(
                environment.getProperty("DATABASE_PASSWORD"),
                environment.getProperty("SPRING_DATASOURCE_PASSWORD"),
                environment.getProperty("MAEMOJI_DB_PASSWORD")
        );

        final HostedDatasource hostedDatasource = HostedDatasource.from(
                firstNonBlank(
                        environment.getProperty("NEON_DATABASE_URL"),
                        environment.getProperty("DATABASE_URL"),
                        environment.getProperty("POSTGRES_URL"),
                        environment.getProperty("RENDER_DATABASE_URL")
                )
        );

        if (hostedDatasource.url() != null
                && (datasourceUrl == null || isDefaultLocalDatasourceUrl(datasourceUrl, explicitDatasourceUrl))) {
            overrides.put("spring.datasource.url", hostedDatasource.url());
        }

        if (explicitDatasourceUsername == null) {
            final String username = firstNonBlank(
                    environment.getProperty("DATABASE_USERNAME"),
                    environment.getProperty("SPRING_DATASOURCE_USERNAME"),
                    environment.getProperty("MAEMOJI_DB_USER"),
                    hostedDatasource.username()
            );
            if (username != null) {
                overrides.put("spring.datasource.username", username);
            }
        }

        if (explicitDatasourcePassword == null) {
            final String password = firstNonBlank(
                    environment.getProperty("DATABASE_PASSWORD"),
                    environment.getProperty("SPRING_DATASOURCE_PASSWORD"),
                    environment.getProperty("MAEMOJI_DB_PASSWORD"),
                    hostedDatasource.password()
            );
            if (password != null) {
                overrides.put("spring.datasource.password", password);
            }
        }

        if (!overrides.isEmpty()) {
            overrides.putIfAbsent("spring.datasource.driver-class-name", "org.postgresql.Driver");
            environment.getPropertySources().addFirst(new MapPropertySource(PROPERTY_SOURCE_NAME, overrides));
        }
    }

    @Override
    public int getOrder() {
        return Ordered.HIGHEST_PRECEDENCE;
    }

    private static String firstNonBlank(String... values) {
        for (String value : values) {
            final String normalized = blankToNull(value);
            if (normalized != null) {
                return normalized;
            }
        }
        return null;
    }

    private static String blankToNull(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static boolean isDefaultLocalDatasourceUrl(String datasourceUrl, String explicitDatasourceUrl) {
        if (explicitDatasourceUrl != null) {
            return false;
        }

        final String normalized = blankToNull(datasourceUrl);
        if (normalized == null) {
            return true;
        }

        return normalized.contains("jdbc:postgresql://localhost:")
                || normalized.contains("jdbc:postgresql://127.0.0.1:")
                || normalized.contains("jdbc:postgresql://10.0.2.2:");
    }

    record HostedDatasource(String url, String username, String password) {

        static HostedDatasource from(String rawUrl) {
            final String normalizedRawUrl = normalizeRawUrl(rawUrl);
            if (normalizedRawUrl == null) {
                return new HostedDatasource(null, null, null);
            }

            try {
                final URI uri = URI.create(normalizedRawUrl);
                final String userInfo = uri.getUserInfo();
                final String jdbcUrl = toJdbcUrlWithoutUserInfo(uri);

                if (userInfo == null || userInfo.isBlank()) {
                    return new HostedDatasource(jdbcUrl, null, null);
                }

                final String[] parts = userInfo.split(":", 2);
                final String username = parts.length > 0 ? blankToNull(parts[0]) : null;
                final String password = parts.length > 1 ? blankToNull(parts[1]) : null;
                return new HostedDatasource(jdbcUrl, username, password);
            } catch (Exception ignored) {
                return new HostedDatasource(normalizeJdbcUrl(rawUrl), null, null);
            }
        }

        private static String normalizeRawUrl(String rawUrl) {
            final String value = blankToNull(rawUrl);
            if (value == null) {
                return null;
            }
            if (value.startsWith("postgresql://") || value.startsWith("postgres://")) {
                return value.replaceFirst("^postgres://", "postgresql://");
            }
            return value;
        }

        private static String normalizeJdbcUrl(String rawUrl) {
            final String value = blankToNull(rawUrl);
            if (value == null) {
                return null;
            }
            if (value.startsWith("jdbc:")) {
                return value;
            }
            if (value.startsWith("postgresql://") || value.startsWith("postgres://")) {
                return "jdbc:" + value.replaceFirst("^postgres://", "postgresql://");
            }
            return value;
        }

        private static String toJdbcUrlWithoutUserInfo(URI uri) {
            final StringBuilder jdbcUrl = new StringBuilder("jdbc:postgresql://")
                    .append(uri.getHost());
            if (uri.getPort() > 0) {
                jdbcUrl.append(':').append(uri.getPort());
            }
            jdbcUrl.append(uri.getPath());
            final String query = withRequiredSslMode(uri);
            if (query != null && !query.isBlank()) {
                jdbcUrl.append('?').append(query);
            }
            return jdbcUrl.toString();
        }

        private static String withRequiredSslMode(URI uri) {
            final String query = blankToNull(uri.getQuery());
            final String host = blankToNull(uri.getHost());
            final boolean isNeonHost = host != null && host.contains(".neon.tech");

            if (!isNeonHost) {
                return query;
            }
            if (query == null) {
                return "sslmode=require";
            }
            if (query.toLowerCase().contains("sslmode=")) {
                return query;
            }
            return query + "&sslmode=require";
        }
    }
}
