package com.maemoji.backend.portfolioinsight.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.Optional;

@Component
public class FirebaseMessagingGateway {

    private final Object lock = new Object();
    private volatile FirebaseMessaging firebaseMessaging;
    private volatile boolean initializationAttempted = false;
    private volatile String initializationError;

    public Optional<FirebaseMessaging> getMessaging() {
        initializeIfPossible();
        return Optional.ofNullable(firebaseMessaging);
    }

    public String getInitializationError() {
        initializeIfPossible();
        return initializationError;
    }

    public List<String> sendEach(List<Message> messages) throws Exception {
        final FirebaseMessaging messaging = getMessaging()
                .orElseThrow(() -> new IllegalStateException(
                        initializationError == null
                                ? "Firebase Messaging 초기화에 실패했습니다."
                                : initializationError
                ));

        final var response = messaging.sendEach(messages, false);
        return response.getResponses().stream()
                .map(result -> result.isSuccessful() ? result.getMessageId() : null)
                .toList();
    }

    private void initializeIfPossible() {
        if (firebaseMessaging != null || initializationAttempted) {
            return;
        }
        synchronized (lock) {
            if (firebaseMessaging != null || initializationAttempted) {
                return;
            }
            initializationAttempted = true;
            try {
                final FirebaseOptions options = buildOptions();
                if (options == null) {
                    initializationError = "Firebase 서비스 계정 환경변수가 설정되지 않았습니다.";
                    return;
                }

                final FirebaseApp app;
                if (FirebaseApp.getApps().isEmpty()) {
                    app = FirebaseApp.initializeApp(options);
                } else {
                    app = FirebaseApp.getApps().get(0);
                }
                firebaseMessaging = FirebaseMessaging.getInstance(app);
            } catch (Exception exception) {
                initializationError = "Firebase Admin 초기화 실패: " + exception.getMessage();
            }
        }
    }

    private FirebaseOptions buildOptions() throws Exception {
        final String inlineJson = normalize(System.getenv("MAEMOJI_FIREBASE_SERVICE_ACCOUNT_JSON"));
        final String base64Json = normalize(System.getenv("MAEMOJI_FIREBASE_SERVICE_ACCOUNT_BASE64"));
        final String projectId = normalize(System.getenv("MAEMOJI_FIREBASE_PROJECT_ID"));

        if (inlineJson != null) {
            try (InputStream inputStream = new ByteArrayInputStream(inlineJson.getBytes(StandardCharsets.UTF_8))) {
                return FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(inputStream))
                        .setProjectId(projectId)
                        .build();
            }
        }

        if (base64Json != null) {
            final byte[] decoded = Base64.getDecoder().decode(base64Json);
            try (InputStream inputStream = new ByteArrayInputStream(decoded)) {
                return FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(inputStream))
                        .setProjectId(projectId)
                        .build();
            }
        }

        final String googleCredentialsPath = normalize(System.getenv("GOOGLE_APPLICATION_CREDENTIALS"));
        if (googleCredentialsPath != null) {
            final FirebaseOptions.Builder builder = FirebaseOptions.builder()
                    .setCredentials(GoogleCredentials.getApplicationDefault());
            if (projectId != null) {
                builder.setProjectId(projectId);
            }
            return builder.build();
        }

        return null;
    }

    private String normalize(String value) {
        if (value == null) {
            return null;
        }
        final String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }
}
