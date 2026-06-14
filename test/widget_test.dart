import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maemoji/screens/brand_launch_screen.dart';
import 'package:maemoji/theme/app_theme.dart';

void main() {
  testWidgets('시작 화면에 브랜드 이미지와 매모지가 보인다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const BrandLaunchScreen(),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('매모지'), findsOneWidget);
  });
}
