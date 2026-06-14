package com.maemoji.backend.user.service;

import com.maemoji.backend.auth.dto.AuthUserResponse;
import com.maemoji.backend.user.domain.UserSessionRecord;
import com.maemoji.backend.user.dto.NicknameAvailabilityResponse;
import com.maemoji.backend.user.mapper.UserMapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.Locale;
import java.util.regex.Pattern;

@Service
public class UserProfileService {

    private static final Pattern NICKNAME_PATTERN =
            Pattern.compile("^[0-9A-Za-z가-힣_]{2,12}$");

    private final UserMapper userMapper;

    public UserProfileService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @Transactional(readOnly = true)
    public NicknameAvailabilityResponse checkNicknameAvailability(Long userId, String rawNickname) {
        final String nickname = normalizeNickname(rawNickname);
        validateNickname(nickname);
        final boolean exists = userMapper.existsByNicknameNormalizedExcludingUserId(
                normalizeNicknameKey(nickname),
                userId
        );
        return new NicknameAvailabilityResponse(
                nickname,
                !exists,
                exists ? "이미 사용 중인 닉네임이에요." : "사용할 수 있는 닉네임이에요."
        );
    }

    @Transactional
    public AuthUserResponse updateNickname(Long userId, String rawNickname) {
        final String nickname = normalizeNickname(rawNickname);
        validateNickname(nickname);
        final String normalizedKey = normalizeNicknameKey(nickname);
        final boolean exists = userMapper.existsByNicknameNormalizedExcludingUserId(
                normalizedKey,
                userId
        );
        if (exists) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 사용 중인 닉네임이에요.");
        }

        try {
            userMapper.updateNickname(userId, nickname, normalizedKey);
        } catch (DuplicateKeyException exception) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 사용 중인 닉네임이에요.");
        }
        final UserSessionRecord user = userMapper.findById(userId);
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자 정보를 찾지 못했어요.");
        }
        return toResponse(user);
    }

    private void validateNickname(String nickname) {
        if (nickname.length() < 2) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "닉네임이 너무 짧아요. 2자 이상 입력해주세요.");
        }
        if (nickname.length() > 12) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "닉네임이 너무 길어요. 12자 이하로 입력해주세요.");
        }
        if (nickname.contains(" ")) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "닉네임에는 띄어쓰기를 사용할 수 없어요.");
        }
        if (!NICKNAME_PATTERN.matcher(nickname).matches()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "닉네임에는 한글, 영문, 숫자, 밑줄(_)만 사용할 수 있어요.");
        }
    }

    private String normalizeNickname(String rawNickname) {
        final String nickname = rawNickname == null ? "" : rawNickname.trim().replaceAll("\\s+", " ");
        if (nickname.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "닉네임을 입력해주세요.");
        }
        return nickname;
    }

    private String normalizeNicknameKey(String nickname) {
        return nickname.trim().toLowerCase(Locale.ROOT);
    }

    private AuthUserResponse toResponse(UserSessionRecord user) {
        return new AuthUserResponse(
                user.getId(),
                user.getEmail(),
                user.getNickname(),
                user.getProfileImageUrl(),
                Boolean.TRUE.equals(user.getNicknameConfirmed()),
                user.getRiskProfile(),
                user.getInvestmentDnaType(),
                user.getRiskProfileScore(),
                user.getRiskProfileConfidence(),
                user.getRiskProfileSource()
        );
    }
}
