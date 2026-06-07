import 'package:flutter/widgets.dart';

import 'currency_controller.dart';

class CurrencyScope extends InheritedNotifier<CurrencyController> {
  const CurrencyScope({
    super.key,
    required CurrencyController controller,
    required super.child,
  }) : super(notifier: controller);

  static CurrencyController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    assert(scope != null, 'CurrencyScope가 필요합니다.');
    return scope!.notifier!;
  }
}
