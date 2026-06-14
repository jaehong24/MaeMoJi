String riskProfileLabel(String? raw) {
  switch ((raw ?? '').trim().toUpperCase()) {
    case 'CONSERVATIVE':
      return '안전 우선형';
    case 'BALANCED':
      return '균형형';
    case 'AGGRESSIVE':
      return '공격 투자형';
    default:
      return '-';
  }
}

String investmentDnaTypeLabel(String? raw) {
  switch ((raw ?? '').trim().toUpperCase()) {
    case 'SAFE_FIRST':
      return '안전제일형';
    case 'BALANCE_SEEKER':
      return '균형추구형';
    case 'GROWTH_SEEKER':
      return '성장추구형';
    case 'AGGRESSIVE_INVESTOR':
      return '공격투자형';
    case 'WEALTH_MASTER':
      return '자산증식 마스터형';
    default:
      return '-';
  }
}
