import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/app_router.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Runs once when app has router: init plugin + schedule daily reminders.
/// Watch this from the root app so bootstrap runs.
final notificationBootstrapProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(notificationServiceProvider);
  final router = ref.read(appRouterProvider);

  await service.initialize(
    onDidReceiveNotificationResponse: (payload) {
      final route = payload ?? '/home';
      router.go(route);
    },
  );

  final enabled = await service.dailyRemindersEnabled;
  if (enabled) {
    await service.scheduleDailyReminders();
  }
  return true;
});
