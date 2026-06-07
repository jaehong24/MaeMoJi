import 'package:flutter/material.dart';

import '../currency/currency_controller.dart';
import '../models/display_currency.dart';
import '../theme/app_theme.dart';

class CurrencyToggle extends StatelessWidget {
  const CurrencyToggle({
    super.key,
    required this.controller,
  });

  final CurrencyController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return SegmentedButton<DisplayCurrency>(
          showSelectedIcon: false,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return MaeMojiColors.maintain.withValues(alpha: 0.18);
              }

              return Colors.white;
            }),
            side: const WidgetStatePropertyAll(
              BorderSide(color: MaeMojiColors.stroke),
            ),
            textStyle: const WidgetStatePropertyAll(
              TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          segments: const [
            ButtonSegment(
              value: DisplayCurrency.usd,
              label: Text('USD'),
            ),
            ButtonSegment(
              value: DisplayCurrency.krw,
              label: Text('KRW'),
            ),
          ],
          selected: {controller.displayCurrency},
          onSelectionChanged: (selection) {
            controller.setDisplayCurrency(selection.first);
          },
        );
      },
    );
  }
}
