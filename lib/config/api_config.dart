/// Flutter 앱이 사용할 WAS 주소를 한 곳에서 관리합니다.
///
/// - 개발용 기본값: Android 에뮬레이터는 `10.0.2.2:8081`, 그 외는 `localhost:8081`
/// - 운영용 예시: `--dart-define=API_BASE_URL=https://maemoji-ig16.onrender.com`
class ApiConfig {
  const ApiConfig._();

  static const String productionBaseUrl = 'https://maemoji-ig16.onrender.com';

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

  static bool isLocalDevelopment({
    required bool isWeb,
    required String platformName,
  }) {
    final baseUrl = resolveBaseUrl(isWeb: isWeb, platformName: platformName);
    final uri = Uri.tryParse(baseUrl);
    if (uri == null) {
      return false;
    }

    final host = uri.host.toLowerCase();
    return host == 'localhost' || host == '127.0.0.1' || host == '10.0.2.2';
  }

  static bool isProductionUrl(String baseUrl) {
    final normalized = _normalizeBaseUrl(baseUrl);
    return normalized == productionBaseUrl;
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

  static String resolveLogoUrl(
    String? remoteUrl, {
    required bool isWeb,
    required String platformName,
  }) {
    final trimmed = (remoteUrl ?? '').trim();
    if (trimmed.isEmpty) {
      return '';
    }

    if (!isWeb) {
      return trimmed;
    }

    return buildUri(
      '/api/assets/logo-proxy',
      isWeb: isWeb,
      platformName: platformName,
      queryParameters: {'url': trimmed},
    ).toString();
  }

  static String _normalizeBaseUrl(String value) {
    var trimmed = value.trim();
    // Guard against a common manual deployment typo.
    if (trimmed == 'https://maemoji.onrender.co') {
      trimmed = productionBaseUrl;
    }
    if (trimmed == 'https://maemoji.onrender.com') {
      trimmed = productionBaseUrl;
    }
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
