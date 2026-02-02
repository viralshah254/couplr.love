import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_models.dart';

const String _prefDailyReminders = 'notifications_daily_reminders';
const String _prefQuietHours = 'notifications_quiet_hours';
const String _prefQuietStart = 'notifications_quiet_start'; // hour 0-23
const String _prefQuietEnd = 'notifications_quiet_end';

/// Smart daily reminders: catchy, urgent copy with clear CTAs.
/// At least 3 per day (morning, afternoon, evening); optional 4th "urgency" slot.
class NotificationService {
  NotificationService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get plugin => _plugin;

  static const String _channelId = 'couplr_reminders';
  static const String _channelName = 'Couplr reminders';

  /// Morning slot (e.g. 9:00) — score / check-in urgency
  static const _morningCopy = (
    title: "Your relationship score could drop today",
    body: "One check-in keeps it strong. Open Couplr now.",
    route: '/home',
  );

  /// Afternoon slot (e.g. 14:00) — partner / Talk & Heal
  static const _afternoonCopy = (
    title: "Something's left unsaid",
    body: "Your partner might be waiting. Open Talk & Heal.",
    route: '/talk',
  );

  /// Evening slot (e.g. 19:00) — streak
  static const _eveningCopy = (
    title: "Don't let your streak die tonight",
    body: "You're one tap away. Open Couplr before midnight.",
    route: '/home',
  );

  /// Extra urgency slot (e.g. 12:00) — FOMO / open app
  static const _urgencyCopy = (
    title: "You have unfinished business",
    body: "Things to do are piling up. Open Couplr and fix it.",
    route: '/things-to-do',
  );

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> get dailyRemindersEnabled async {
    final prefs = await _getPrefs();
    return prefs.getBool(_prefDailyReminders) ?? true;
  }

  Future<void> setDailyRemindersEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_prefDailyReminders, value);
    if (value) {
      await scheduleDailyReminders();
    } else {
      await cancelAllReminders();
    }
  }

  Future<bool> get quietHoursEnabled async {
    final prefs = await _getPrefs();
    return prefs.getBool(_prefQuietHours) ?? false;
  }

  Future<void> setQuietHoursEnabled(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_prefQuietHours, value);
    await scheduleDailyReminders();
  }

  /// Quiet period start hour (0-23). Default 22 (10 PM).
  Future<int> get quietStartHour async {
    final prefs = await _getPrefs();
    return prefs.getInt(_prefQuietStart) ?? 22;
  }

  Future<void> setQuietStartHour(int hour) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_prefQuietStart, hour.clamp(0, 23));
    await scheduleDailyReminders();
  }

  /// Quiet period end hour (0-23). Default 7 (7 AM).
  Future<int> get quietEndHour async {
    final prefs = await _getPrefs();
    return prefs.getInt(_prefQuietEnd) ?? 7;
  }

  Future<void> setQuietEndHour(int hour) async {
    final prefs = await _getPrefs();
    await prefs.setInt(_prefQuietEnd, hour.clamp(0, 23));
    await scheduleDailyReminders();
  }

  /// Initialize plugin and timezone. Call once when app has router.
  Future<bool> initialize({
    required void Function(String? payload) onDidReceiveNotificationResponse,
  }) async {
    try {
      tz_data.initializeTimeZones();
      try {
        final timeZoneName = await _getTimeZoneName();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.local);
      }

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final settings = InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          final payload = response.payload;
          if (payload != null && payload.isNotEmpty) {
            onDidReceiveNotificationResponse(payload);
          }
        },
      );

      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        await androidPlugin?.requestExactAlarmsPermission();
      }

      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp == true &&
          launchDetails?.notificationResponse?.payload != null) {
        final route = launchDetails!.notificationResponse!.payload;
        if (route != null && route.isNotEmpty) {
          onDidReceiveNotificationResponse(route);
        }
      }

      return true;
    } catch (e, st) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('NotificationService.initialize error: $e $st');
      }
      return false;
    }
  }

  Future<String> _getTimeZoneName() async {
    try {
      return await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      return 'UTC';
    }
  }

  Future<void> scheduleDailyReminders() async {
    final enabled = await dailyRemindersEnabled;
    if (!enabled) {
      await cancelAllReminders();
      return;
    }

    final quiet = await quietHoursEnabled;
    final quietStart = await quietStartHour;
    final quietEnd = await quietEndHour;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily reminders to check in and stay connected.',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Couplr',
    );
    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    // Morning 9:00
    await _scheduleAt(
      id: NotificationIds.morning,
      title: _morningCopy.title,
      body: _morningCopy.body,
      route: _morningCopy.route,
      hour: 9,
      minute: 0,
      details: details,
      skipQuiet: (h) => _inQuiet(quiet, quietStart, quietEnd, h),
    );

    // Afternoon 14:00
    await _scheduleAt(
      id: NotificationIds.afternoon,
      title: _afternoonCopy.title,
      body: _afternoonCopy.body,
      route: _afternoonCopy.route,
      hour: 14,
      minute: 0,
      details: details,
      skipQuiet: (h) => _inQuiet(quiet, quietStart, quietEnd, h),
    );

    // Evening 19:00
    await _scheduleAt(
      id: NotificationIds.evening,
      title: _eveningCopy.title,
      body: _eveningCopy.body,
      route: _eveningCopy.route,
      hour: 19,
      minute: 0,
      details: details,
      skipQuiet: (h) => _inQuiet(quiet, quietStart, quietEnd, h),
    );

    // Urgency 12:00 (4th notification)
    await _scheduleAt(
      id: NotificationIds.urgency,
      title: _urgencyCopy.title,
      body: _urgencyCopy.body,
      route: _urgencyCopy.route,
      hour: 12,
      minute: 0,
      details: details,
      skipQuiet: (h) => _inQuiet(quiet, quietStart, quietEnd, h),
    );
  }

  bool _inQuiet(bool quietEnabled, int start, int end, int hour) {
    if (!quietEnabled) return false;
    if (start > end) {
      return hour >= start || hour < end;
    }
    return hour >= start && hour < end;
  }

  Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required String route,
    required int hour,
    required int minute,
    required NotificationDetails details,
    required bool Function(int hour) skipQuiet,
  }) async {
    if (skipQuiet(hour)) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      payload: route,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllReminders() async {
    for (final id in NotificationIds.all) {
      await _plugin.cancel(id);
    }
  }

  /// Request permission (iOS/macOS). Android already requested in initialize.
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    if (Platform.isMacOS) {
      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      return await macos?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return true;
  }
}
