import 'package:flutter/material.dart';

import '../screens/stock_detail_screen.dart';
import '../screens/weekly_reports_screen.dart';

class AppNavigationService {
  AppNavigationService._();

  static final AppNavigationService instance = AppNavigationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  _PendingAlertNavigation? _pendingAlertNavigation;
  bool _pendingWeeklyReportNavigation = false;

  void openWeeklyReports() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingWeeklyReportNavigation = true;
      return;
    }
    navigator.push(
      MaterialPageRoute<void>(builder: (_) => const WeeklyReportsScreen()),
    );
  }

  void openPortfolioItemFromAlert({
    required int portfolioItemId,
    required String alertType,
    int? alertId,
    String? focusSection,
  }) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingAlertNavigation = _PendingAlertNavigation(
        portfolioItemId: portfolioItemId,
        alertType: alertType,
        alertId: alertId,
        focusSection: focusSection,
      );
      return;
    }

    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(
          portfolioItemId: portfolioItemId,
          initialFocusSection: _resolveFocusSection(alertType, focusSection),
        ),
      ),
    );
  }

  void flushPendingIfAny() {
    if (_pendingWeeklyReportNavigation) {
      _pendingWeeklyReportNavigation = false;
      openWeeklyReports();
      return;
    }
    final pending = _pendingAlertNavigation;
    if (pending == null) {
      return;
    }
    _pendingAlertNavigation = null;
    openPortfolioItemFromAlert(
      portfolioItemId: pending.portfolioItemId,
      alertType: pending.alertType,
      alertId: pending.alertId,
      focusSection: pending.focusSection,
    );
  }

  StockDetailFocusSection _resolveFocusSection(
    String alertType,
    String? focusSection,
  ) {
    final normalizedFocus = (focusSection ?? '').trim().toUpperCase();
    switch (normalizedFocus) {
      case 'NEWS':
        return StockDetailFocusSection.news;
      case 'RECOMMENDATION':
        return StockDetailFocusSection.recommendation;
      case 'HISTORY':
        return StockDetailFocusSection.history;
      case 'TOP':
        return StockDetailFocusSection.top;
    }

    return _focusSectionForAlertType(alertType);
  }

  StockDetailFocusSection _focusSectionForAlertType(String alertType) {
    switch (alertType.toUpperCase()) {
      case 'NEWS_WEAKENED':
        return StockDetailFocusSection.news;
      case 'PRICE_RISK':
      case 'STATUS_DOWNGRADED':
      case 'STATUS_CHANGED':
        return StockDetailFocusSection.history;
      default:
        return StockDetailFocusSection.recommendation;
    }
  }
}

class _PendingAlertNavigation {
  const _PendingAlertNavigation({
    required this.portfolioItemId,
    required this.alertType,
    required this.alertId,
    required this.focusSection,
  });

  final int portfolioItemId;
  final String alertType;
  final int? alertId;
  final String? focusSection;
}
