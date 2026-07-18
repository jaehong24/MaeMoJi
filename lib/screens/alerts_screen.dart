import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_alert_event.dart';
import '../services/portfolio_insight_service.dart';
import '../theme/app_theme.dart';
import '../utils/alert_event_presentation.dart';
import '../widgets/app_section_card.dart';
import 'stock_detail_screen.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final PortfolioInsightService _portfolioInsightService =
      const PortfolioInsightService();
  final DateFormat _dateFormat = DateFormat('M월 d일 HH:mm');

  late Future<List<UserAlertEvent>> _alertsFuture;
  List<UserAlertEvent> _alerts = const [];

  @override
  void initState() {
    super.initState();
    _alertsFuture = _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('알림'),
      ),
      body: FutureBuilder<List<UserAlertEvent>>(
        future: _alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _alerts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _alerts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AppSectionCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알림을 불러오지 못했어요.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '잠시 후 다시 시도해 주세요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _reload,
                      child: const Text('다시 불러오기'),
                    ),
                  ],
                ),
              ),
            );
          }

          final alerts = snapshot.data ?? _alerts;
          if (alerts.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '새로운 알림이 아직 없어요.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이번 주 추천 변화가 생기면 이곳에 차곡차곡 보여드릴게요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: alerts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                final isUnread = alert.readAt == null;

                return AppSectionCard(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _presentation(alert).softColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _presentation(alert).icon,
                              size: 18,
                              color: isUnread
                                  ? _presentation(alert).color
                                  : MaeMojiColors.inkMuted,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        alert.title,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          color: MaeMojiColors.ink,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _AlertTypePill(
                                      label: _presentation(alert).label,
                                      color: isUnread
                                          ? _presentation(alert).color
                                          : MaeMojiColors.inkMuted,
                                      backgroundColor: isUnread
                                          ? _presentation(alert).softColor
                                          : MaeMojiColors.paperAccent,
                                    ),
                                  ],
                                ),
                                if (alert.supplementalPriceRisk) ...[
                                  const SizedBox(height: 8),
                                  const _SupplementalPriceRiskPill(),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  alert.body,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _dateLabel(alert),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: MaeMojiColors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (isUnread)
                            TextButton(
                              onPressed: () => _markAsRead(alert),
                              child: const Text('읽음 처리'),
                            ),
                          const Spacer(),
                          FilledButton.tonal(
                            onPressed: () => _openAlert(alert),
                            child: const Text('상세 보기'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<List<UserAlertEvent>> _loadAlerts() async {
    final alerts = await _portfolioInsightService.fetchAlerts();
    _alerts = alerts;
    return alerts;
  }

  Future<void> _refresh() async {
    final alerts = await _portfolioInsightService.fetchAlerts();
    if (!mounted) {
      return;
    }
    setState(() {
      _alerts = alerts;
      _alertsFuture = Future<List<UserAlertEvent>>.value(alerts);
    });
  }

  void _reload() {
    setState(() {
      _alertsFuture = _loadAlerts();
    });
  }

  Future<void> _markAsRead(UserAlertEvent alert) async {
    if (alert.readAt != null) {
      return;
    }

    try {
      final updated = await _portfolioInsightService.markAlertAsRead(
        alert.alertId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _alerts = _alerts.map((item) {
          return item.alertId == updated.alertId ? updated : item;
        }).toList();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알림 읽음 처리에 실패했어요.')),
      );
    }
  }

  Future<void> _openAlert(UserAlertEvent alert) async {
    await _markAsRead(alert);
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StockDetailScreen(
          portfolioItemId: alert.portfolioItemId,
          initialFocusSection: _focusSectionForAlert(alert.alertType),
        ),
      ),
    );
    if (mounted) {
      _reload();
    }
  }

  String _dateLabel(UserAlertEvent alert) {
    final base = alert.sentAt ?? alert.createdAt;
    if (base == null) {
      return '방금 생성된 알림';
    }
    return '${_dateFormat.format(base.toLocal())} 기준';
  }

  AlertEventPresentation _presentation(UserAlertEvent alert) {
    return alertEventPresentation(alert.alertType);
  }

  StockDetailFocusSection _focusSectionForAlert(String alertType) {
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

class _SupplementalPriceRiskPill extends StatelessWidget {
  const _SupplementalPriceRiskPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: MaeMojiColors.maintain.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: MaeMojiColors.maintain.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        '가격 흔들림 동반',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: MaeMojiColors.inkSoft,
        ),
      ),
    );
  }
}

class _AlertTypePill extends StatelessWidget {
  const _AlertTypePill({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
