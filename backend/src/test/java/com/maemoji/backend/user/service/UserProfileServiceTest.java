package com.maemoji.backend.user.service;

import com.maemoji.backend.user.domain.UserSessionRecord;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.server.ResponseStatusException;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class UserProfileServiceTest {

    @Test
    void rejectsUnsupportedNicknameCharacters() {
        final UserMapper userMapper = mock(UserMapper.class);
        final UserProfileService service = new UserProfileService(userMapper);

        assertThatThrownBy(() -> service.updateNickname(1L, "매모지!"))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("한글, 영문, 숫자");
    }

    @Test
    void rejectsNicknameAlreadyUsedByAnotherUser() {
        final UserMapper userMapper = mock(UserMapper.class);
        when(userMapper.existsByNicknameNormalizedExcludingUserId("매모지", 2L))
                .thenReturn(true);
        final UserProfileService service = new UserProfileService(userMapper);

        assertThatThrownBy(() -> service.updateNickname(2L, "매모지"))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("이미 사용 중");
    }

    @Test
    void convertsDatabaseNicknameCollisionToConflict() {
        final UserMapper userMapper = mock(UserMapper.class);
        when(userMapper.existsByNicknameNormalizedExcludingUserId("maemoji", 3L))
                .thenReturn(false);
        doThrow(new DuplicateKeyException("uk_users_confirmed_nickname"))
                .when(userMapper)
                .updateNickname(3L, "MaeMoji", "maemoji");
        final UserProfileService service = new UserProfileService(userMapper);

        assertThatThrownBy(() -> service.updateNickname(3L, "MaeMoji"))
                .isInstanceOf(ResponseStatusException.class)
                .hasMessageContaining("이미 사용 중");
    }

    @Test
    void savesAvailableNicknameAndReturnsUpdatedUser() {
        final UserMapper userMapper = mock(UserMapper.class);
        final UserSessionRecord user = new UserSessionRecord();
        user.setId(4L);
        user.setEmail("user@maemoji.test");
        user.setNickname("매모지4");
        user.setNicknameConfirmed(true);
        when(userMapper.existsByNicknameNormalizedExcludingUserId("매모지4", 4L))
                .thenReturn(false);
        when(userMapper.findById(4L)).thenReturn(user);
        final UserProfileService service = new UserProfileService(userMapper);

        final var response = service.updateNickname(4L, "  매모지4  ");

        assertThat(response.nickname()).isEqualTo("매모지4");
        assertThat(response.nicknameConfirmed()).isTrue();
        verify(userMapper).updateNickname(4L, "매모지4", "매모지4");
    }
}
