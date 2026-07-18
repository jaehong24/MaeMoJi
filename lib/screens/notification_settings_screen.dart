import 'package:flutter/material.dart';

import '../models/user_device_info.dart';
import '../models/user_notification_preference.dart';
import '../services/notification_registration_service.dart';
import '../services/portfolio_insight_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_section_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final PortfolioInsightService _portfolioInsightService =
      const PortfolioInsightService();

  late Future<_NotificationSettingsBundle> _bundleFuture;
  bool _isSaving = false;
  bool _isSyncingDevice = false;
  String? _sendingTestType;
  UserNotificationPreference? _editingPreference;

  static const List<String> _weeklyDays = <String>[
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];

  static const List<String> _timeOptions = <String>[
    '07:00:00',
    '08:00:00',
    '08:30:00',
    '09:00:00',
    '18:00:00',
    '20:00:00',
    '21:00:00',
    '22:00:00',
  ];

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadBundle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('알림 설정'),
      ),
      body: FutureBuilder<_NotificationSettingsBundle>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _editingPreference == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && _editingPreference == null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AppSectionCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '알림 설정을 불러오지 못했어요.',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('잠시 후 다시 시도해 주세요.', style: theme.textTheme.bodyMedium),
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

          final bundle = snapshot.data;
          final preference = _editingPreference ?? bundle!.preference;
          final devices = bundle?.devices ?? const <UserDeviceInfo>[];

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('즉시 알림', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '강한 변화만 바로 알려드리고, 나머지는 앱 안에서 조용히 모아둘게요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _AdaptiveSwitchTile(
                      title: '중요 알림 받기',
                      subtitle: '의견 변경, 뉴스 악화, 가격 흔들림 알림을 켜요.',
                      value: preference.instantAlertEnabled,
                      onChanged: (value) => _updatePreference(
                        preference.copyWith(instantAlertEnabled: value),
                      ),
                    ),
                    _AdaptiveSwitchTile(
                      title: '의견 변경',
                      subtitle: '유지, 증액, 감액, 중단 방향이 바뀌면 알려드려요.',
                      value: preference.statusChangedAlertEnabled,
                      onChanged: preference.instantAlertEnabled
                          ? (value) => _updatePreference(
                              preference.copyWith(
                                statusChangedAlertEnabled: value,
                              ),
                            )
                          : null,
                    ),
                    _AdaptiveSwitchTile(
                      title: '뉴스 악화',
                      subtitle: '관련 뉴스 분위기가 약해질 때 알려드려요.',
                      value: preference.newsWeakenedAlertEnabled,
                      onChanged: preference.instantAlertEnabled
                          ? (value) => _updatePreference(
                              preference.copyWith(
                                newsWeakenedAlertEnabled: value,
                              ),
                            )
                          : null,
                    ),
                    _AdaptiveSwitchTile(
                      title: '가격 흔들림',
                      subtitle: '변동성과 하방 리스크가 커질 때 알려드려요.',
                      value: preference.priceRiskAlertEnabled,
                      onChanged: preference.instantAlertEnabled
                          ? (value) => _updatePreference(
                              preference.copyWith(priceRiskAlertEnabled: value),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('주간 리포트', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '이번 주 다시 볼 종목이 있을 때 묶어서 알려드려요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _AdaptiveSwitchTile(
                      title: '주간 요약 알림 받기',
                      subtitle: '매주 한 번, 포트폴리오 변화만 짧게 알려드려요.',
                      value: preference.weeklyDigestEnabled,
                      onChanged: (value) => _updatePreference(
                        preference.copyWith(weeklyDigestEnabled: value),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SelectionField<String>(
                            label: '요일',
                            value: preference.weeklyDigestDay,
                            items: _weeklyDays,
                            itemLabel: _weeklyDayLabel,
                            enabled: preference.weeklyDigestEnabled,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _updatePreference(
                                preference.copyWith(weeklyDigestDay: value),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SelectionField<String>(
                            label: '시간',
                            value: preference.weeklyDigestTime,
                            items: _timeOptions,
                            itemLabel: _timeLabel,
                            enabled: preference.weeklyDigestEnabled,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _updatePreference(
                                preference.copyWith(weeklyDigestTime: value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('방해 금지', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '잠든 시간에는 소리 없이 조용히 쌓아둘 수 있어요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    _AdaptiveSwitchTile(
                      title: '방해 금지 시간 사용',
                      subtitle: '해당 시간에는 즉시 알림 대신 앱 안에 쌓아둬요.',
                      value: preference.quietHoursEnabled,
                      onChanged: (value) => _updatePreference(
                        preference.copyWith(quietHoursEnabled: value),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SelectionField<String>(
                            label: '시작',
                            value: preference.quietHoursStart ?? '22:00:00',
                            items: _timeOptions,
                            itemLabel: _timeLabel,
                            enabled: preference.quietHoursEnabled,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _updatePreference(
                                preference.copyWith(quietHoursStart: value),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SelectionField<String>(
                            label: '종료',
                            value: preference.quietHoursEnd ?? '08:00:00',
                            items: _timeOptions,
                            itemLabel: _timeLabel,
                            enabled: preference.quietHoursEnabled,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }
                              _updatePreference(
                                preference.copyWith(quietHoursEnd: value),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppSectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('내 디바이스', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      '현재 이 기기에서 푸시 연결을 다시 확인할 수 있어요.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    FilledButton.tonal(
                      onPressed: _isSyncingDevice ? null : _syncDevice,
                      child: Text(
                        _isSyncingDevice ? '연결 확인 중...' : '이 기기 다시 연결',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '테스트 알림',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: MaeMojiColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TestNotificationButton(
                          label: '의견 변경',
                          busy: _sendingTestType == 'STATUS_CHANGED',
                          onPressed: _sendingTestType == null
                              ? () => _sendTypedTestNotification(
                                  alertType: 'STATUS_CHANGED',
                                )
                              : null,
                        ),
                        _TestNotificationButton(
                          label: '뉴스 악화',
                          busy: _sendingTestType == 'NEWS_WEAKENED',
                          onPressed: _sendingTestType == null
                              ? () => _sendTypedTestNotification(
                                  alertType: 'NEWS_WEAKENED',
                                )
                              : null,
                        ),
                        _TestNotificationButton(
                          label: '가격 흔들림',
                          busy: _sendingTestType == 'PRICE_RISK',
                          onPressed: _sendingTestType == null
                              ? () => _sendTypedTestNotification(
                                  alertType: 'PRICE_RISK',
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '현재 로그인한 기기로 테스트 푸시를 보내고, 최근 포트폴리오 종목 상세로 이동하는 흐름까지 확인할 수 있어요.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: MaeMojiColors.inkMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (devices.isEmpty)
                      Text(
                        '아직 등록된 디바이스가 없어요.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: MaeMojiColors.inkMuted,
                        ),
                      )
                    else
                      ...devices.map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _DeviceRow(device: device),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? '저장 중...' : '알림 설정 저장'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<_NotificationSettingsBundle> _loadBundle() async {
    final results = await Future.wait<dynamic>([
      _portfolioInsightService.fetchNotificationPreferences(),
      _portfolioInsightService.fetchNotificationDevices(),
    ]);

    final bundle = _NotificationSettingsBundle(
      preference: results[0] as UserNotificationPreference,
      devices: results[1] as List<UserDeviceInfo>,
    );
    _editingPreference ??= bundle.preference;
    return bundle;
  }

  void _reload() {
    setState(() {
      _bundleFuture = _loadBundle();
    });
  }

  void _updatePreference(UserNotificationPreference preference) {
    setState(() {
      _editingPreference = preference;
    });
  }

  Future<void> _save() async {
    final preference = _editingPreference;
    if (preference == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final saved = await _portfolioInsightService
          .updateNotificationPreferences(preference);
      if (!mounted) {
        return;
      }
      setState(() {
        _editingPreference = saved;
        _bundleFuture = _loadBundle();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('알림 설정을 저장했어요.')));
    } catch (exception) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _syncDevice() async {
    setState(() {
      _isSyncingDevice = true;
    });

    try {
      final device = await NotificationRegistrationService.instance.syncNow(
        reportFailure: true,
      );
      if (device == null) {
        throw Exception('푸시 알림 기기를 등록하지 못했어요.');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _bundleFuture = _loadBundle();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이 기기의 푸시 연결을 다시 확인했어요.')));
    } catch (exception) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSyncingDevice = false;
        });
      }
    }
  }

  Future<void> _sendTypedTestNotification({required String alertType}) async {
    setState(() {
      _sendingTestType = alertType;
    });

    try {
      final device = await NotificationRegistrationService.instance.syncNow(
        reportFailure: true,
      );
      if (device == null) {
        throw Exception('푸시 알림 기기를 등록하지 못했어요.');
      }
      final message = await _portfolioInsightService.sendTestNotification(
        alertType: alertType,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _bundleFuture = _loadBundle();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (exception) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exception.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sendingTestType = null;
        });
      }
    }
  }

  String _weeklyDayLabel(String value) {
    switch (value) {
      case 'MONDAY':
        return '월요일';
      case 'TUESDAY':
        return '화요일';
      case 'WEDNESDAY':
        return '수요일';
      case 'THURSDAY':
        return '목요일';
      case 'FRIDAY':
        return '금요일';
      case 'SATURDAY':
        return '토요일';
      case 'SUNDAY':
        return '일요일';
      default:
        return value;
    }
  }

  String _timeLabel(String value) => value.substring(0, 5);
}

class _AdaptiveSwitchTile extends StatelessWidget {
  const _AdaptiveSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      value: value,
      onChanged: onChanged,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: MaeMojiColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: MaeMojiColors.inkMuted,
          height: 1.45,
        ),
      ),
    );
  }
}

class _SelectionField<T> extends StatelessWidget {
  const _SelectionField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final bool enabled;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: MaeMojiColors.inkMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? MaeMojiColors.paperSoft
                : MaeMojiColors.paperAccent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: MaeMojiColors.stroke),
            ),
          ),
        ),
      ],
    );
  }
}

class _DeviceRow extends StatelessWidget {
  const _DeviceRow({required this.device});

  final UserDeviceInfo device;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: MaeMojiColors.paperSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: MaeMojiColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _platformLabel(device.devicePlatform),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: MaeMojiColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              _DeviceStatusPill(
                label: device.active && device.pushEnabled ? '연결됨' : '비활성',
                color: device.active && device.pushEnabled
                    ? MaeMojiColors.increase
                    : MaeMojiColors.inkMuted,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            device.appVersion?.isNotEmpty == true
                ? '앱 버전 ${device.appVersion}'
                : '앱 버전 정보 없음',
            style: theme.textTheme.bodySmall?.copyWith(
              color: MaeMojiColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _platformLabel(String platform) {
    switch (platform.toUpperCase()) {
      case 'ANDROID':
        return 'Android';
      case 'IOS':
        return 'iPhone';
      case 'WEB':
        return 'Web';
      default:
        return platform;
    }
  }
}

class _DeviceStatusPill extends StatelessWidget {
  const _DeviceStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
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

class _TestNotificationButton extends StatelessWidget {
  const _TestNotificationButton({
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: const BorderSide(color: MaeMojiColors.stroke),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        busy ? '$label 보내는 중...' : label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: MaeMojiColors.ink,
        ),
      ),
    );
  }
}

class _NotificationSettingsBundle {
  const _NotificationSettingsBundle({
    required this.preference,
    required this.devices,
  });

  final UserNotificationPreference preference;
  final List<UserDeviceInfo> devices;
}
