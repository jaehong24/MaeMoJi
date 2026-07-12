import 'package:flutter/material.dart';

import '../screens/stock_detail_screen.dart';

class AppNavigationService {
  AppNavigationService._();

  static final AppNavigationService instance = AppNavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  _PendingAlertNavigation? _pendingAlertNavigation;

  void openPortfolioItemFromAlert({
    required int portfolioItemId,
    required String alertType,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingAlertNavigation = _PendingAlertNavigation(
        portfolioItemId: portfolioItemId,
        alertType: alertType,
      );
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(
          portfolioItemId: portfolioItemId,
          initialFocusSection: _focusSectionForAlertType(alertType),
        ),
      ),
    );
  }

  void flushPendingIfAny() {
    final pending = _pendingAlertNavigation;
    if (pending == null) {
      return;
    }
    _pendingAlertNavigation = null;
    openPortfolioItemFromAlert(
      portfolioItemId: pending.portfolioItemId,
      alertType: pending.alertType,
    );
  }

  StockDetailFocusSection _focusSectionForAlertType(String alertType) {
    switch (alertType.toUpperCase()) {
      case 'NEWS_WEAKENED':
        return StockDetailFocusSection.news;
      case 'PRICE_RISK':
      case 'STATUS_DOWNGRADED':
      case 'STATUS_CHANGED':
      default:
        return StockDetailFocusSection.recommendation;
    }
  }
}

class _PendingAlertNavigation {
  const _PendingAlertNavigation({
    required this.portfolioItemId,
    required this.alertType,
  });

  final int portfolioItemId;
  final String alertType;
}
