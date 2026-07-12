package com.maemoji.backend.toss.service;

import com.maemoji.backend.market.service.ExchangeRateService;
import com.maemoji.backend.portfolio.mapper.PortfolioMapper;
import com.maemoji.backend.stock.domain.Stock;
import com.maemoji.backend.stock.mapper.StockMapper;
import com.maemoji.backend.toss.client.TossOpenApiClient;
import com.maemoji.backend.toss.domain.TossAccountRecord;
import com.maemoji.backend.toss.domain.TossConnectionRecord;
import com.maemoji.backend.toss.dto.TossAccountResponse;
import com.maemoji.backend.toss.dto.TossAccountSelectionResponse;
import com.maemoji.backend.toss.dto.TossConnectionCreateRequest;
import com.maemoji.backend.toss.dto.TossConnectionCreateResponse;
import com.maemoji.backend.toss.dto.TossConnectionResponse;
import com.maemoji.backend.toss.dto.TossHoldingPreviewItemResponse;
import com.maemoji.backend.toss.dto.TossHoldingsPreviewResponse;
import com.maemoji.backend.toss.mapper.TossIntegrationMapper;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Service
public class TossIntegrationService {

    private final TossOpenApiClient tossOpenApiClient;
    private final TossCredentialCipher tossCredentialCipher;
    private final TossIntegrationMapper tossIntegrationMapper;
    private final StockMapper stockMapper;
    private final PortfolioMapper portfolioMapper;
    private final ExchangeRateService exchangeRateService;

    public TossIntegrationService(
            TossOpenApiClient tossOpenApiClient,
            TossCredentialCipher tossCredentialCipher,
            TossIntegrationMapper tossIntegrationMapper,
            StockMapper stockMapper,
            PortfolioMapper portfolioMapper,
            ExchangeRateService exchangeRateService
    ) {
        this.tossOpenApiClient = tossOpenApiClient;
        this.tossCredentialCipher = tossCredentialCipher;
        this.tossIntegrationMapper = tossIntegrationMapper;
        this.stockMapper = stockMapper;
        this.portfolioMapper = portfolioMapper;
        this.exchangeRateService = exchangeRateService;
    }

    @Transactional
    public TossConnectionCreateResponse createConnection(Long userId, TossConnectionCreateRequest request) {
        final var token = tossOpenApiClient.issueAccessToken(request.clientId(), request.clientSecret());

        final TossConnectionRecord connection = new TossConnectionRecord();
        connection.setUserId(userId);
        connection.setConnectionName(request.connectionName().trim());
        connection.setClientId(request.clientId().trim());
        connection.setClientSecretEncrypted(tossCredentialCipher.encrypt(request.clientSecret().trim()));
        connection.setClientSecretMasked(maskSecret(request.clientSecret().trim()));
        connection.setStatus("ACTIVE");
        connection.setIsPrimary(true);

        tossIntegrationMapper.clearPrimaryConnectionForUser(userId);
        tossIntegrationMapper.insertConnection(connection);
        tossIntegrationMapper.markConnectionAsPrimary(connection.getId());
        tossIntegrationMapper.updateConnectionHeartbeat(connection.getId(), OffsetDateTime.now());

        final int accountCount = refreshAccounts(connection, token.accessToken()).size();
        return new TossConnectionCreateResponse(
                connection.getId(),
                "ACTIVE",
                "토스증권 연결이 등록되었습니다.",
                accountCount
        );
    }

    public List<TossConnectionResponse> getMyConnections(Long userId) {
        return tossIntegrationMapper.findConnectionsByUserId(userId).stream()
                .map(connection -> new TossConnectionResponse(
                        connection.getId(),
                        connection.getConnectionName(),
                        connection.getStatus(),
                        maskClientId(connection.getClientId()),
                        Boolean.TRUE.equals(connection.getIsPrimary()),
                        connection.getLastSyncAt(),
                        connection.getLastSyncStatus()
                ))
                .toList();
    }

    @Transactional
    public List<TossAccountResponse> getAccounts(Long userId, Long connectionId) {
        final TossConnectionRecord connection = requireConnection(userId, connectionId);
        final String clientSecret = tossCredentialCipher.decrypt(connection.getClientSecretEncrypted());
        final var token = tossOpenApiClient.issueAccessToken(connection.getClientId(), clientSecret);
        tossIntegrationMapper.updateConnectionHeartbeat(connectionId, OffsetDateTime.now());
        return refreshAccounts(connection, token.accessToken()).stream()
                .map(this::toAccountResponse)
                .toList();
    }

    @Transactional
    public TossAccountSelectionResponse selectAccount(Long userId, Long accountId) {
        final TossAccountRecord account = requireAccount(userId, accountId);
        tossIntegrationMapper.clearSelectedAccountByConnectionId(account.getConnectionId());
        tossIntegrationMapper.markAccountSelected(accountId);
        return new TossAccountSelectionResponse(
                account.getId(),
                account.getAccountSeq(),
                "대표 연동 계좌가 선택되었습니다."
        );
    }

    public TossHoldingsPreviewResponse previewHoldings(Long userId, Long accountId) {
        final TossAccountRecord account = requireAccount(userId, accountId);
        final TossConnectionRecord connection = requireConnection(userId, account.getConnectionId());
        final String clientSecret = tossCredentialCipher.decrypt(connection.getClientSecretEncrypted());
        final var token = tossOpenApiClient.issueAccessToken(connection.getClientId(), clientSecret);
        final List<TossOpenApiClient.TossRemoteHolding> holdings = tossOpenApiClient.getHoldings(
                token.accessToken(),
                account.getAccountSeq()
        );

        final BigDecimal usdKrwRate = BigDecimal.valueOf(exchangeRateService.fetchUsdKrwRate().rate());
        final List<PreviewRow> previewRows = new ArrayList<>();
        BigDecimal totalMarketValueKrw = BigDecimal.ZERO;

        for (var holding : holdings) {
            final Stock stock = stockMapper.findActiveStockBySymbol(holding.symbol());
            final Long stockId = stock == null ? null : stock.getId();
            final Long matchedPortfolioItemId = stockId == null
                    ? null
                    : portfolioMapper.findPortfolioItemIdByUserIdAndStockId(userId, stockId);

            final BigDecimal positionValueKrw = toKrw(holding.marketValue(), holding.currency(), usdKrwRate);
            if (positionValueKrw != null) {
                totalMarketValueKrw = totalMarketValueKrw.add(positionValueKrw);
            }

            previewRows.add(new PreviewRow(
                    holding,
                    stockId,
                    matchedPortfolioItemId,
                    positionValueKrw
            ));
        }

        final BigDecimal total = totalMarketValueKrw;
        final List<TossHoldingPreviewItemResponse> items = previewRows.stream()
                .sorted(Comparator.comparing(PreviewRow::positionValueKrw, Comparator.nullsLast(BigDecimal::compareTo)).reversed())
                .map(row -> toPreviewItem(row, total))
                .toList();

        final int matchedStockCount = (int) items.stream().filter(item -> item.matchedStockId() != null).count();
        final int matchedPortfolioItemCount = (int) items.stream().filter(item -> item.matchedPortfolioItemId() != null).count();

        return new TossHoldingsPreviewResponse(
                accountId,
                items.size(),
                matchedStockCount,
                matchedPortfolioItemCount,
                items
        );
    }

    private List<TossAccountRecord> refreshAccounts(TossConnectionRecord connection, String accessToken) {
        final OffsetDateTime syncedAt = OffsetDateTime.now();
        final List<TossOpenApiClient.TossRemoteAccount> remoteAccounts = tossOpenApiClient.getAccounts(accessToken);
        for (var remoteAccount : remoteAccounts) {
            tossIntegrationMapper.upsertAccount(
                    connection.getId(),
                    remoteAccount.accountSeq(),
                    normalizeAccountType(remoteAccount.accountType()),
                    maskAccountNumber(remoteAccount.accountNo()),
                    buildDisplayName(remoteAccount.accountType(), remoteAccount.accountNo(), remoteAccount.accountSeq()),
                    syncedAt
            );
        }
        return tossIntegrationMapper.findAccountsByConnectionId(connection.getId());
    }

    private TossConnectionRecord requireConnection(Long userId, Long connectionId) {
        final TossConnectionRecord connection = tossIntegrationMapper.findConnectionByIdAndUserId(connectionId, userId);
        if (connection == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "토스 연결 정보를 찾을 수 없습니다.");
        }
        return connection;
    }

    private TossAccountRecord requireAccount(Long userId, Long accountId) {
        final TossAccountRecord account = tossIntegrationMapper.findAccountByIdAndUserId(accountId, userId);
        if (account == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "토스 계좌 정보를 찾을 수 없습니다.");
        }
        return account;
    }

    private TossAccountResponse toAccountResponse(TossAccountRecord account) {
        return new TossAccountResponse(
                account.getId(),
                account.getAccountSeq(),
                account.getDisplayName(),
                account.getAccountType(),
                account.getStatus(),
                Boolean.TRUE.equals(account.getIsSelected())
        );
    }

    private TossHoldingPreviewItemResponse toPreviewItem(PreviewRow row, BigDecimal totalMarketValueKrw) {
        final BigDecimal profitRatePercent = row.holding().profitRate() == null
                ? null
                : row.holding().profitRate().multiply(BigDecimal.valueOf(100)).setScale(2, RoundingMode.HALF_UP);

        BigDecimal weightPercent = null;
        if (row.positionValueKrw() != null && totalMarketValueKrw != null && totalMarketValueKrw.compareTo(BigDecimal.ZERO) > 0) {
            weightPercent = row.positionValueKrw()
                    .multiply(BigDecimal.valueOf(100))
                    .divide(totalMarketValueKrw, 2, RoundingMode.HALF_UP);
        }

        return new TossHoldingPreviewItemResponse(
                row.holding().symbol(),
                row.holding().stockName(),
                scale(row.holding().quantity(), 6),
                scale(row.holding().averagePurchasePrice(), 4),
                scale(row.holding().currentPrice(), 4),
                profitRatePercent,
                weightPercent,
                row.stockId(),
                row.matchedPortfolioItemId(),
                row.stockId() != null && row.matchedPortfolioItemId() == null
        );
    }

    private BigDecimal toKrw(BigDecimal marketValue, String currency, BigDecimal usdKrwRate) {
        if (marketValue == null) {
            return null;
        }
        if ("USD".equalsIgnoreCase(currency)) {
            return marketValue.multiply(usdKrwRate);
        }
        return marketValue;
    }

    private String normalizeAccountType(String accountType) {
        return accountType == null || accountType.isBlank()
                ? "BROKERAGE"
                : accountType.trim().toUpperCase();
    }

    private String buildDisplayName(String accountType, String accountNo, long accountSeq) {
        final String prefix = switch (normalizeAccountType(accountType)) {
            case "BROKERAGE" -> "종합매매";
            case "PENSION_SAVINGS" -> "연금저축";
            case "OVERSEAS_DERIVATIVES" -> "해외파생";
            case "RESHORING_INVESTMENT" -> "국내복귀투자";
            default -> "토스증권";
        };

        final String masked = maskAccountNumber(accountNo);
        if (masked == null || masked.isBlank()) {
            return prefix + " 계좌 " + accountSeq;
        }
        return prefix + " " + masked;
    }

    private String maskAccountNumber(String accountNo) {
        if (accountNo == null || accountNo.isBlank()) {
            return null;
        }
        final String digitsOnly = accountNo.replaceAll("[^0-9]", "");
        if (digitsOnly.length() <= 4) {
            return "****";
        }
        return "****" + digitsOnly.substring(digitsOnly.length() - 4);
    }

    private String maskClientId(String clientId) {
        if (clientId == null || clientId.isBlank()) {
            return "";
        }
        if (clientId.length() <= 8) {
            return clientId.substring(0, Math.min(2, clientId.length())) + "****";
        }
        return clientId.substring(0, 4) + "..." + clientId.substring(clientId.length() - 4);
    }

    private String maskSecret(String secret) {
        if (secret == null || secret.isBlank()) {
            return "";
        }
        if (secret.length() <= 6) {
            return "******";
        }
        return secret.substring(0, 2) + "******" + secret.substring(secret.length() - 2);
    }

    private BigDecimal scale(BigDecimal value, int scale) {
        return value == null ? null : value.setScale(scale, RoundingMode.HALF_UP);
    }

    private record PreviewRow(
            TossOpenApiClient.TossRemoteHolding holding,
            Long stockId,
            Long matchedPortfolioItemId,
            BigDecimal positionValueKrw
    ) {
    }
}
