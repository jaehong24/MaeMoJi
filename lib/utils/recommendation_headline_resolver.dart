import '../models/recommendation_item.dart';

class RecommendationHeadline {
  const RecommendationHeadline({
    required this.label,
    required this.semanticKey,
  });

  final String label;
  final String semanticKey;
}

RecommendationHeadline resolveRecommendationHeadline(RecommendationItem item) {
  final note = item.note.trim();

  if (note.isEmpty) {
    return _fallbackHeadline(item);
  }

  if (_containsAny(note, const ['데이터 부족'])) {
    return const RecommendationHeadline(
      label: '데이터 부족',
      semanticKey: 'data_gap',
    );
  }
  if (_containsAny(note, const ['변동성 감액', '하방 리스크', '흔들림'])) {
    return const RecommendationHeadline(
      label: '변동성',
      semanticKey: 'volatility',
    );
  }
  if (_containsAny(note, const ['가격 부담 감액', '가격 부담'])) {
    return const RecommendationHeadline(
      label: '가격 부담',
      semanticKey: 'price_burden',
    );
  }
  if (_containsAny(note, const ['가격 반영 유지', '기대가 가격에', '가격 반영'])) {
    return const RecommendationHeadline(
      label: '가격 반영',
      semanticKey: 'price_reflected',
    );
  }
  if (_containsAny(note, const ['성장 둔화 감액', '성장 질이 약', '이익 재가속 신호가 약'])) {
    return const RecommendationHeadline(
      label: '성장 둔화',
      semanticKey: 'growth_slowdown',
    );
  }
  if (_containsAny(note, const ['성장 확인 유지', '추가 확신', '성장 탄력', '한 단계 더 확인'])) {
    return const RecommendationHeadline(
      label: '성장 확인',
      semanticKey: 'growth_check',
    );
  }
  if (_containsAny(note, const ['방어형 유지', '방어 성격', '방어력'])) {
    return const RecommendationHeadline(
      label: '방어형',
      semanticKey: 'defensive',
    );
  }
  if (_containsAny(note, const ['중단', '관망', '하방 리스크 관리'])) {
    return const RecommendationHeadline(
      label: '위험 관리',
      semanticKey: 'risk_control',
    );
  }
  if (_containsAny(note, const ['증액', '더 모으는'])) {
    return const RecommendationHeadline(
      label: '증액 우세',
      semanticKey: 'increase',
    );
  }

  return _fallbackHeadline(item);
}

String buildCompactRecommendationSummary(RecommendationItem item) {
  final headline = resolveRecommendationHeadline(item);

  switch (headline.semanticKey) {
    case 'price_reflected':
      return '좋은 흐름이 이미 가격에 반영돼 있어 지금은 유지 쪽이 자연스러워요.';
    case 'price_burden':
      return '현재 가격 메리트가 낮아 조금 더 보수적으로 보고 있어요.';
    case 'growth_check':
      return '기본 체력은 괜찮지만 한 단계 더 확인이 필요한 구간이에요.';
    case 'growth_slowdown':
      return '성장 속도와 재가속 신호가 약해 감액 쪽으로 보고 있어요.';
    case 'volatility':
      return '최근 흔들림이 커서 변동성 관리 관점이 더 중요해요.';
    case 'data_gap':
      return '핵심 데이터가 더 쌓여야 판단 정확도가 올라가요.';
    case 'defensive':
      return '방어력은 괜찮지만 공격적으로 늘릴 구간은 아니에요.';
    case 'risk_control':
      return '지금은 수익보다 리스크 관리가 우선인 구간이에요.';
    case 'increase':
      return '핵심 팩터가 고르게 강해 한 단계 더 모아볼 수 있어요.';
    default:
      return item.note.trim().isEmpty
          ? '현재 판단의 핵심 이유를 간단히 정리했어요.'
          : _truncateSingleSentence(item.note.trim());
  }
}

RecommendationHeadline _fallbackHeadline(RecommendationItem item) {
  final status = item.status.name.toUpperCase();
  switch (status) {
    case 'INCREASE':
      return const RecommendationHeadline(
        label: '증액 우세',
        semanticKey: 'increase',
      );
    case 'MAINTAIN':
      return const RecommendationHeadline(
        label: '핵심 확인',
        semanticKey: 'maintain',
      );
    case 'REDUCE':
      return const RecommendationHeadline(
        label: '감액 검토',
        semanticKey: 'reduce',
      );
    case 'STOP':
      return const RecommendationHeadline(
        label: '위험 관리',
        semanticKey: 'risk_control',
      );
    default:
      return const RecommendationHeadline(
        label: '핵심 확인',
        semanticKey: 'default',
      );
  }
}

bool _containsAny(String source, List<String> candidates) {
  for (final candidate in candidates) {
    if (source.contains(candidate)) {
      return true;
    }
  }
  return false;
}

String _truncateSingleSentence(String value) {
  final normalized = value.replaceAll('\n', ' ').trim();
  if (normalized.isEmpty) {
    return '';
  }

  final sentenceBreaks = ['. ', '요. ', '니다. ', '! ', '? '];
  for (final marker in sentenceBreaks) {
    final index = normalized.indexOf(marker);
    if (index > 0) {
      return normalized.substring(0, index + marker.trim().length);
    }
  }

  return normalized.length <= 48
      ? normalized
      : '${normalized.substring(0, 48).trim()}...';
}
