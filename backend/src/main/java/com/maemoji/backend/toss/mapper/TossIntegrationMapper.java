package com.maemoji.backend.toss.mapper;

import com.maemoji.backend.toss.domain.TossAccountRecord;
import com.maemoji.backend.toss.domain.TossConnectionRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.OffsetDateTime;
import java.util.List;

@Mapper
public interface TossIntegrationMapper {

    void insertConnection(@Param("connection") TossConnectionRecord connection);

    List<TossConnectionRecord> findConnectionsByUserId(@Param("userId") Long userId);

    TossConnectionRecord findConnectionByIdAndUserId(
            @Param("connectionId") Long connectionId,
            @Param("userId") Long userId
    );

    void clearPrimaryConnectionForUser(@Param("userId") Long userId);

    void markConnectionAsPrimary(@Param("connectionId") Long connectionId);

    void updateConnectionHeartbeat(
            @Param("connectionId") Long connectionId,
            @Param("lastTokenIssuedAt") OffsetDateTime lastTokenIssuedAt
    );

    void upsertAccount(
            @Param("connectionId") Long connectionId,
            @Param("accountSeq") Long accountSeq,
            @Param("accountType") String accountType,
            @Param("accountNoMasked") String accountNoMasked,
            @Param("displayName") String displayName,
            @Param("lastSyncedAt") OffsetDateTime lastSyncedAt
    );

    List<TossAccountRecord> findAccountsByConnectionId(@Param("connectionId") Long connectionId);

    TossAccountRecord findAccountByIdAndUserId(
            @Param("accountId") Long accountId,
            @Param("userId") Long userId
    );

    void clearSelectedAccountByConnectionId(@Param("connectionId") Long connectionId);

    void markAccountSelected(@Param("accountId") Long accountId);
}
