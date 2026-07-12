package com.maemoji.backend.portfolioinsight.service;

import com.maemoji.backend.portfolioinsight.dto.UserAlertEventResponse;
import com.maemoji.backend.portfolioinsight.mapper.PortfolioInsightMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@Service
public class UserAlertEventService {

    private final PortfolioInsightMapper portfolioInsightMapper;

    public UserAlertEventService(PortfolioInsightMapper portfolioInsightMapper) {
        this.portfolioInsightMapper = portfolioInsightMapper;
    }

    public List<UserAlertEventResponse> getAlerts(Long userId) {
        return portfolioInsightMapper.findAlertsByUserId(userId).stream()
                .map(record -> new UserAlertEventResponse(
                        record.getId(),
                        record.getPortfolioItemId(),
                        record.getStockId(),
                        record.getAlertType(),
                        record.getTitle(),
                        record.getBody(),
                        record.getSentAt(),
                        record.getReadAt(),
                        record.getCreatedAt()
                ))
                .toList();
    }

    @Transactional
    public UserAlertEventResponse markAsRead(Long userId, Long alertId) {
        final int updated = portfolioInsightMapper.markAlertRead(userId, alertId);
        if (updated == 0) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "알림을 찾을 수 없습니다.");
        }
        return portfolioInsightMapper.findAlertById(userId, alertId)
                .map(record -> new UserAlertEventResponse(
                        record.getId(),
                        record.getPortfolioItemId(),
                        record.getStockId(),
                        record.getAlertType(),
                        record.getTitle(),
                        record.getBody(),
                        record.getSentAt(),
                        record.getReadAt(),
                        record.getCreatedAt()
                ))
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "알림을 찾을 수 없습니다."));
    }
}
