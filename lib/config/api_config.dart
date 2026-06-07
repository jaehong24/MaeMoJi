/// Flutter 앱이 사용할 WAS 주소를 한 곳에서 관리합니다.
///
/// - 개발용 기본값: Android 에뮬레이터는 `10.0.2.2:8081`, 그 외는 `localhost:8081`
/// - 운영용 예시: `--dart-define=API_BASE_URL=https://maemoji.onrender.com`
class ApiConfig {
  const ApiConfig._();

  static const String _baseUrlFromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String resolveBaseUrl({
    required bool isWeb,
    required String platformName,
  }) {
    final definedUrl = _baseUrlFromDefine.trim();
    if (definedUrl.isNotEmpty) {
      return _normalizeBaseUrl(definedUrl);
    }

    if (isWeb) {
      return 'http://localhost:8081';
    }

    if (platformName == 'android') {
      return 'http://10.0.2.2:8081';
    }

    return 'http://localhost:8081';
  }

  static Uri buildUri(
    String path, {
    required bool isWeb,
    required String platformName,
    Map<String, dynamic>? queryParameters,
  }) {
    final baseUri = Uri.parse(
      resolveBaseUrl(isWeb: isWeb, platformName: platformName),
    );
    return baseUri.replace(
      path: path,
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value?.toString()),
      ),
    );
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
