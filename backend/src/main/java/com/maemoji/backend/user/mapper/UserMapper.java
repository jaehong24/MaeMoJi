package com.maemoji.backend.user.mapper;

import com.maemoji.backend.user.domain.UserSessionRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.time.OffsetDateTime;

@Mapper
public interface UserMapper {

    Long findIdByEmail(@Param("email") String email);

    UserSessionRecord findByGoogleSubject(@Param("googleSubject") String googleSubject);

    Long upsertGoogleUserByEmail(
            @Param("email") String email,
            @Param("nickname") String nickname,
            @Param("profileImageUrl") String profileImageUrl,
            @Param("googleSubject") String googleSubject,
            @Param("lastLoginAt") OffsetDateTime lastLoginAt
    );

    void updateGoogleUserProfileById(
            @Param("userId") Long userId,
            @Param("email") String email,
            @Param("nickname") String nickname,
            @Param("profileImageUrl") String profileImageUrl,
            @Param("googleSubject") String googleSubject,
            @Param("lastLoginAt") OffsetDateTime lastLoginAt
    );

    void updateAuthSession(
            @Param("userId") Long userId,
            @Param("authToken") String authToken,
            @Param("authTokenExpiresAt") OffsetDateTime authTokenExpiresAt,
            @Param("lastLoginAt") OffsetDateTime lastLoginAt
    );

    void clearAuthSession(@Param("userId") Long userId);

    UserSessionRecord findSessionUserByAuthToken(@Param("authToken") String authToken);

    void updateRiskProfile(
            @Param("userId") Long userId,
            @Param("riskProfile") String riskProfile,
            @Param("investmentDnaType") String investmentDnaType,
            @Param("riskProfileScore") Integer riskProfileScore,
            @Param("riskProfileConfidence") Integer riskProfileConfidence,
            @Param("riskProfileSource") String riskProfileSource,
            @Param("riskProfileUpdatedAt") OffsetDateTime riskProfileUpdatedAt
    );

    List<Long> findActiveUserIdsWithPortfolioItems();

    void insertDevUser();
}
