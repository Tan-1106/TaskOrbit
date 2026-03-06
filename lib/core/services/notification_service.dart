import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings: initSettings);
  }

  Future<void> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _notificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_orbit_channel',
            'Task Reminders',
            channelDescription: 'Notifications for your upcoming tasks',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint('Failed to cancel notification: $e');
    }
  }

  // ── Pomodoro background notifications ──────────────────────────────
  static const int _pomodoroPhaseEndId = 9000;
  static const int _pomodoroOngoingId = 9001;

  /// Schedule a notification that fires when the current Pomodoro phase ends.
  Future<void> schedulePomodoroPhaseEnd({
    required DateTime phaseEndTime,
    required String title,
    required String body,
  }) async {
    try {
      await _notificationsPlugin.zonedSchedule(
        id: _pomodoroPhaseEndId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(phaseEndTime, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'pomodoro_channel',
            'Pomodoro Timer',
            channelDescription: 'Pomodoro phase transition alerts',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Failed to schedule pomodoro phase-end notification: $e');
    }
  }

  /// Show an ongoing (sticky) notification while the Pomodoro is running in background.
  Future<void> showPomodoroOngoing({
    required String title,
    required String body,
  }) async {
    try {
      await _notificationsPlugin.show(
        id: _pomodoroOngoingId,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'pomodoro_ongoing_channel',
            'Pomodoro Running',
            channelDescription: 'Shows while a Pomodoro session is active in background',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            playSound: false,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('Failed to show ongoing pomodoro notification: $e');
    }
  }

  /// Cancel all Pomodoro-related notifications.
  Future<void> cancelPomodoroNotifications() async {
    try {
      await _notificationsPlugin.cancel(id: _pomodoroPhaseEndId);
      await _notificationsPlugin.cancel(id: _pomodoroOngoingId);
    } catch (e) {
      debugPrint('Failed to cancel pomodoro notifications: $e');
    }
  }
}
