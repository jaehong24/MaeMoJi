package com.maemoji.backend.batch.service;

import org.apache.ibatis.builder.xml.XMLMapperBuilder;
import org.apache.ibatis.session.Configuration;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;

import static org.assertj.core.api.Assertions.assertThat;

class MapperLoadingTest {
    @Test
    void allMappersLoadUsingMyBatisWithoutDatabaseAccess() throws Exception {
        var configuration = new Configuration();
        var resources = new PathMatchingResourcePatternResolver().getResources("classpath*:mapper/**/*.xml");
        assertThat(resources).isNotEmpty();
        for (var resource : resources) {
            try (var input = resource.getInputStream()) {
                new XMLMapperBuilder(input, configuration, resource.toString(),
                        configuration.getSqlFragments()).parse();
            }
        }
        assertThat(configuration.getMappedStatementNames()).isNotEmpty();
    }
}
