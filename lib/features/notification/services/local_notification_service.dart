import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../app.dart';
import '../screens/notification_screen.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
  AndroidNotificationChannel(
    'vocabmate_foreground_channel',
    'VocabMate Notifications',
    description: 'Thông báo foreground của VocabMate',
    importance: Importance.high,
    playSound: true,
  );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;

    if (kDebugMode) {
      debugPrint('LocalNotificationService initialized');
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    if (kIsWeb) return;

    if (!_initialized) {
      await initialize();
    }

    final notificationId = Random().nextInt(2147483647);

    final payload = jsonEncode({
      'title': title,
      'body': body,
      'type': type ?? 'push',
      'data': data ?? <String, dynamic>{},
    });

    const androidDetails = AndroidNotificationDetails(
      'vocabmate_foreground_channel',
      'VocabMate Notifications',
      channelDescription: 'Thông báo foreground của VocabMate',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'VocabMate',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;

    if (kDebugMode) {
      debugPrint('Local notification tapped: $payload');
    }

    openNotificationScreen();
  }

  static void openNotificationScreen() {
    final navigator = rootNavigatorKey.currentState;

    if (navigator == null) {
      if (kDebugMode) {
        debugPrint('Navigator is not ready, cannot open NotificationScreen');
      }
      return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }
}