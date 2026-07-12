class UserNotificationPreference {
  const UserNotificationPreference({
    required this.instantAlertEnabled,
    required this.weeklyDigestEnabled,
    required this.priceRiskAlertEnabled,
    required this.newsWeakenedAlertEnabled,
    required this.statusChangedAlertEnabled,
    required this.quietHoursEnabled,
    required this.quietHoursStart,
    required this.quietHoursEnd,
    required this.timezone,
    required this.weeklyDigestDay,
    required this.weeklyDigestTime,
  });

  final bool instantAlertEnabled;
  final bool weeklyDigestEnabled;
  final bool priceRiskAlertEnabled;
  final bool newsWeakenedAlertEnabled;
  final bool statusChangedAlertEnabled;
  final bool quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String timezone;
  final String weeklyDigestDay;
  final String weeklyDigestTime;

  UserNotificationPreference copyWith({
    bool? instantAlertEnabled,
    bool? weeklyDigestEnabled,
    bool? priceRiskAlertEnabled,
    bool? newsWeakenedAlertEnabled,
    bool? statusChangedAlertEnabled,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? timezone,
    String? weeklyDigestDay,
    String? weeklyDigestTime,
  }) {
    return UserNotificationPreference(
      instantAlertEnabled: instantAlertEnabled ?? this.instantAlertEnabled,
      weeklyDigestEnabled: weeklyDigestEnabled ?? this.weeklyDigestEnabled,
      priceRiskAlertEnabled:
          priceRiskAlertEnabled ?? this.priceRiskAlertEnabled,
      newsWeakenedAlertEnabled:
          newsWeakenedAlertEnabled ?? this.newsWeakenedAlertEnabled,
      statusChangedAlertEnabled:
          statusChangedAlertEnabled ?? this.statusChangedAlertEnabled,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      timezone: timezone ?? this.timezone,
      weeklyDigestDay: weeklyDigestDay ?? this.weeklyDigestDay,
      weeklyDigestTime: weeklyDigestTime ?? this.weeklyDigestTime,
    );
  }
}
