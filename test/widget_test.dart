import 'package:flutter_test/flutter_test.dart';

import 'package:maemoji/app.dart';

void main() {
  testWidgets('홈 화면에 투자 메모와 주요 탭이 보인다', (tester) async {
    await tester.pumpWidget(const MaeMojiApp());

    expect(find.text('오늘의 투자 메모'), findsOneWidget);
    expect(find.text('포트폴리오'), findsOneWidget);
    expect(find.text('추천'), findsOneWidget);
    expect(find.text('설정'), findsOneWidget);
    expect(find.text('화면 설계도 보기'), findsOneWidget);
  });
}
