package com.maemoji.backend;

import com.maemoji.backend.recommendation.config.RecommendationTuningProperties;
import com.maemoji.backend.stock.config.TopStockSyncProperties;
import com.maemoji.backend.stock.config.PriceSnapshotBatchProperties;
import com.maemoji.backend.stock.config.StockMasterSyncProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@EnableAsync
@EnableScheduling
@SpringBootApplication
@EnableConfigurationProperties({
        TopStockSyncProperties.class,
        PriceSnapshotBatchProperties.class,
        StockMasterSyncProperties.class,
        RecommendationTuningProperties.class
})
public class MaemojiBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(MaemojiBackendApplication.class, args) ;
        
    }
}
