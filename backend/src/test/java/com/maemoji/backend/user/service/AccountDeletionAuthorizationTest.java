package com.maemoji.backend.user.service;

import com.maemoji.backend.common.auth.AuthenticatedUserResolver;
import com.maemoji.backend.common.auth.AuthTokenHasher;
import com.maemoji.backend.user.controller.UserProfileController;
import com.maemoji.backend.user.domain.UserSessionRecord;
import com.maemoji.backend.user.mapper.UserMapper;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class AccountDeletionAuthorizationTest {
    @Test void rejectsMissingTokenAndIgnoresCallerSuppliedUserId() throws Exception {
        var mapper = mock(UserMapper.class);
        var hasher = new AuthTokenHasher();
        var deletion = mock(AccountDeletionService.class);
        var user = new UserSessionRecord();
        user.setId(7L);
        user.setAuthTokenHash(hasher.hash("test-token"));
        when(mapper.findSessionUserByAuthToken("test-token", hasher.hash("test-token"))).thenReturn(user);
        var mvc = MockMvcBuilders.standaloneSetup(new UserProfileController(
                new AuthenticatedUserResolver(mapper, hasher), mock(RiskProfileService.class),
                mock(UserProfileService.class), deletion)).build();
        mvc.perform(delete("/api/users/me")).andExpect(status().isUnauthorized());
        verifyNoInteractions(deletion);
        mvc.perform(delete("/api/users/me?userId=999").header("Authorization", "Bearer test-token"))
                .andExpect(status().isOk());
        verify(deletion).deleteAccount(7L);
        verifyNoMoreInteractions(deletion);
    }
}
