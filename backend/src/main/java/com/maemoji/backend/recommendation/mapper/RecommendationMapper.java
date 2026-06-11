package com.maemoji.backend.recommendation.mapper;

import com.maemoji.backend.recommendation.domain.RecommendationEvidenceRecord;
import com.maemoji.backend.recommendation.domain.RecommendationEvidenceSaveCommand;
import com.maemoji.backend.recommendation.domain.NewsAnalysisCacheRecord;
import com.maemoji.backend.recommendation.domain.NewsAnalysisSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationRecord;
import com.maemoji.backend.recommendation.domain.RecommendationSaveCommand;
import com.maemoji.backend.recommendation.domain.RecommendationTarget;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface RecommendationMapper {

    List<RecommendationTarget> findActiveRecommendationTargetsByUserId(@Param("userId") Long userId);

    List<RecommendationTarget> findDistinctActiveRecommendationTargets();

    RecommendationTarget findActiveRecommendationTargetByUserIdAndPortfolioItemId(
            @Param("userId") Long userId,
            @Param("portfolioItemId") Long portfolioItemId
    );

    Long upsertRecommendation(@Param("command") RecommendationSaveCommand command);

    void deleteRecommendationEvidence(@Param("recommendationId") Long recommendationId);

    void insertRecommendationEvidence(@Param("command") RecommendationEvidenceSaveCommand command);

    void deleteNewsAnalysisCacheByStockId(@Param("stockId") Long stockId);

    void insertNewsAnalysisCache(@Param("command") NewsAnalysisSaveCommand command);

    List<RecommendationRecord> findLatestRecommendationsByUserId(@Param("userId") Long userId);

    RecommendationRecord findLatestRecommendationByUserIdAndPortfolioItemId(
            @Param("userId") Long userId,
            @Param("portfolioItemId") Long portfolioItemId
    );

    List<RecommendationEvidenceRecord> findRecommendationEvidenceByRecommendationId(
            @Param("recommendationId") Long recommendationId
    );

    List<NewsAnalysisCacheRecord> findLatestNewsAnalysisByStockId(@Param("stockId") Long stockId);
}
