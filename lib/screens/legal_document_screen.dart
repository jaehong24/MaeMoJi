import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.titleText,
    required this.body,
  });

  final String titleText;
  final String body;

  static const String privacyPolicy = '''
매모지 개인정보처리방침

1. 수집하는 정보
- Google 로그인 시 이메일, 닉네임, 프로필 이미지, Google 식별정보를 수집할 수 있습니다.
- 서비스 이용 과정에서 포트폴리오 종목, 투자성향 설문 결과, 접속 기록이 저장될 수 있습니다.

2. 이용 목적
- 로그인 및 회원 식별
- 포트폴리오 저장과 추천 결과 제공
- 투자성향 기반 개인화 추천 제공
- 서비스 안정성 개선과 고객 문의 대응

3. 보관 기간
- 회원 정보는 탈퇴 요청 전까지 보관할 수 있습니다.
- 법령상 보관이 필요한 정보는 관련 법령에 따라 별도 보관될 수 있습니다.

4. 제3자 제공
- 법령상 요구가 있는 경우를 제외하고, 이용자 동의 없이 개인정보를 외부에 판매하거나 제공하지 않습니다.

5. 이용자 권리
- 이용자는 언제든지 회원 정보 수정, 투자성향 재설문, 탈퇴 요청을 할 수 있습니다.

6. 문의
- 개인정보 관련 문의는 매모지 운영 채널을 통해 접수할 수 있습니다.
''';

  static const String serviceNotice = '''
서비스 이용안내

매모지는 미국 주식 모으기 판단을 돕기 위한 참고 정보와 추천을 제공합니다.

1. 매모지의 추천은
- 뉴스, 가격 흐름, 기업 정보, 투자성향 등을 바탕으로 계산된 참고 의견입니다.
- 수익을 보장하지 않으며, 특정 종목 매수·매도를 강제하지 않습니다.

2. 투자 유의사항
- 최종 투자 판단과 책임은 이용자 본인에게 있습니다.
- 시장 상황, 환율, 기업 실적, 뉴스 해석은 언제든 달라질 수 있습니다.
- 매모지의 점수와 상태는 실시간 체결 신호가 아니라 판단 보조 정보입니다.

3. 서비스 이용
- 닉네임, 포트폴리오, 투자성향은 더 나은 개인화 경험을 위해 사용됩니다.
- 부정확한 정보가 보이면 최신화 후 다시 확인해 주세요.
''';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: MaeMojiColors.paper,
      appBar: AppBar(title: Text(titleText)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: MaeMojiColors.stroke),
              ),
              child: SelectableText(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  color: MaeMojiColors.inkSoft,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
