import 'package:flutter/material.dart';

import '../models/user_alert_event.dart';
import '../theme/app_theme.dart';
import '../utils/alert_event_presentation.dart';
import 'app_section_card.dart';

class RecentAlertsPreviewCard extends StatelessWidget {
  const RecentAlertsPreviewCard({
    super.key,
    required this.title,
    required this.alerts,
    required this.emptyMessage,
    required this.onOpenAll,
    required this.onOpenAlert,
    this.maxItems = 2,
  });

  final String title;
  final List<UserAlertEvent> alerts;
  final String emptyMessage;
  final VoidCallback onOpenAll;
  final ValueChanged<UserAlertEvent> onOpenAlert;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewItems = alerts.take(maxItems).toList();
    final unreadCount = alerts.where((item) => item.readAt == null).length;

    return AppSectionCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: MaeMojiColors.paperSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '새 알림 $unreadCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: MaeMojiColors.maintain,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (previewItems.isEmpty)
            Text(
              emptyMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: MaeMojiColors.inkMuted,
              ),
            )
          else
            ...previewItems.map(
              (alert) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onOpenAlert(alert),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: MaeMojiColors.paperSoft,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: MaeMojiColors.stroke),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AlertPreviewIcon(alert: alert),
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
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: MaeMojiColors.ink,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _AlertTypeTag(alert: alert),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                alert.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: MaeMojiColors.inkSoft,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onOpenAll,
              child: const Text('전체 보기'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertPreviewIcon extends StatelessWidget {
  const _AlertPreviewIcon({required this.alert});

  final UserAlertEvent alert;

  @override
  Widget build(BuildContext context) {
    final presentation = alertEventPresentation(alert.alertType);

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: alert.readAt == null
            ? presentation.softColor
            : MaeMojiColors.paperAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        presentation.icon,
        size: 16,
        color: alert.readAt == null
            ? presentation.color
            : MaeMojiColors.inkMuted,
      ),
    );
  }
}

class _AlertTypeTag extends StatelessWidget {
  const _AlertTypeTag({required this.alert});

  final UserAlertEvent alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presentation = alertEventPresentation(alert.alertType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: alert.readAt == null
            ? presentation.softColor
            : MaeMojiColors.paperAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        presentation.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: alert.readAt == null
              ? presentation.color
              : MaeMojiColors.inkMuted,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
