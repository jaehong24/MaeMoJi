class UserAlertEvent {
  const UserAlertEvent({
    required this.alertId,
    required this.portfolioItemId,
    required this.stockId,
    required this.alertType,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.readAt,
    required this.createdAt,
  });

  final int alertId;
  final int portfolioItemId;
  final int stockId;
  final String alertType;
  final String title;
  final String body;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? createdAt;
}
