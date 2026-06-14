package com.maemoji.backend.portfolio.mapper;

import com.maemoji.backend.portfolio.dto.PortfolioCreateRequest;
import com.maemoji.backend.portfolio.dto.PortfolioItemSummaryResponse;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface PortfolioMapper {

    Long lockUserPortfolio(@Param("userId") Long userId);

    Long findPortfolioItemIdByUserIdAndStockId(
            @Param("userId") Long userId,
            @Param("stockId") Long stockId
    );

    int countActivePortfolioItemsByUserId(@Param("userId") Long userId);

    void insertPortfolioItem(
            @Param("userId") Long userId,
            @Param("request") PortfolioCreateRequest request
    );

    void updatePortfolioItem(
            @Param("portfolioItemId") Long portfolioItemId,
            @Param("request") PortfolioCreateRequest request
    );

    int deactivatePortfolioItem(
            @Param("userId") Long userId,
            @Param("portfolioItemId") Long portfolioItemId
    );

    List<PortfolioItemSummaryResponse> findPortfolioItemsByUserId(@Param("userId") Long userId);
}
