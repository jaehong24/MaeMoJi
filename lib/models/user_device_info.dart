class UserDeviceInfo {
  const UserDeviceInfo({
    required this.deviceTokenId,
    required this.devicePlatform,
    required this.deviceIdentifier,
    required this.appVersion,
    required this.pushEnabled,
    required this.active,
    required this.lastSeenAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int deviceTokenId;
  final String devicePlatform;
  final String? deviceIdentifier;
  final String? appVersion;
  final bool pushEnabled;
  final bool active;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
