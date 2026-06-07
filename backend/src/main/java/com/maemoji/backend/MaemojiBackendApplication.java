package com.maemoji.backend;

import com.maemoji.backend.stock.config.TopStockSyncProperties;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableScheduling
@SpringBootApplication
@EnableConfigurationProperties({
        TopStockSyncProperties.class,
        PriceSnapshotBatchProperties.class
})
public class MaemojiBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(MaemojiBackendApplication.class, args) ;
        
    }
}
