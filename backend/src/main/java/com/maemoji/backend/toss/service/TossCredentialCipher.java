package com.maemoji.backend.toss.service;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import javax.crypto.Cipher;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

@Component
public class TossCredentialCipher {

    private static final int GCM_TAG_LENGTH_BITS = 128;
    private static final int GCM_IV_LENGTH = 12;

    private final SecureRandom secureRandom = new SecureRandom();

    public String encrypt(String plainText) {
        try {
            final byte[] iv = new byte[GCM_IV_LENGTH];
            secureRandom.nextBytes(iv);

            final Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(resolveKey(), "AES"), new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv));
            final byte[] encrypted = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(iv)
                    + ":"
                    + Base64.getEncoder().encodeToString(encrypted);
        } catch (ResponseStatusException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "토스 연결 정보 암호화에 실패했습니다.", exception);
        }
    }

    public String decrypt(String encryptedText) {
        try {
            final String[] parts = encryptedText.split(":", 2);
            if (parts.length != 2) {
                throw new IllegalArgumentException("암호문 형식이 올바르지 않습니다.");
            }

            final byte[] iv = Base64.getDecoder().decode(parts[0]);
            final byte[] cipherBytes = Base64.getDecoder().decode(parts[1]);
            final Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(resolveKey(), "AES"), new GCMParameterSpec(GCM_TAG_LENGTH_BITS, iv));
            return new String(cipher.doFinal(cipherBytes), StandardCharsets.UTF_8);
        } catch (ResponseStatusException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "토스 연결 정보 복호화에 실패했습니다.", exception);
        }
    }

    private byte[] resolveKey() {
        final String rawSecret = System.getenv("MAEMOJI_TOSS_SECRET_KEY");
        if (rawSecret == null || rawSecret.isBlank()) {
            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "MAEMOJI_TOSS_SECRET_KEY 환경변수가 설정되지 않았습니다."
            );
        }

        try {
            final MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return digest.digest(rawSecret.getBytes(StandardCharsets.UTF_8));
        } catch (Exception exception) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "토스 암호화 키를 준비하지 못했습니다.", exception);
        }
    }
}
