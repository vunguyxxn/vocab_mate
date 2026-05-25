import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../services/supabase_service.dart';
import 'local_notification_service.dart';
import 'notification_firestore_service.dart';

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static bool _listenersAttached = false;

  static Future<void> initialize() async {
    await LocalNotificationService.initialize();

    await _requestPermission();
    await _saveTokenToSupabase();

    if (!_listenersAttached) {
      _listenTokenRefresh();
      _listenForegroundMessages();
      _listenNotificationOpenedApp();
      _listenersAttached = true;
    }

    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      await _handleMessage(
        initialMessage,
        fromTerminated: true,
      );

      LocalNotificationService.openNotificationScreen();
    }
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }
  }

  static Future<void> _saveTokenToSupabase() async {
    final userId = SupabaseService.currentUserId;

    if (userId == null) return;

    final token = await _messaging.getToken();

    if (token == null || token.isEmpty) return;

    await SupabaseService.client.from('profiles').update({
      'fcm_token': token,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);

    if (kDebugMode) {
      debugPrint('FCM token saved: $token');
    }
  }

  static void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      final userId = SupabaseService.currentUserId;

      if (userId == null || token.isEmpty) return;

      await SupabaseService.client.from('profiles').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (kDebugMode) {
        debugPrint('FCM token refreshed: $token');
      }
    });
  }

  static void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleMessage(
        message,
        fromForeground: true,
      );
    });
  }

  static void _listenNotificationOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await _handleMessage(
        message,
        fromOpenedApp: true,
      );

      LocalNotificationService.openNotificationScreen();
    });
  }

  static Future<void> _handleMessage(
      RemoteMessage message, {
        bool fromForeground = false,
        bool fromOpenedApp = false,
        bool fromTerminated = false,
      }) async {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'VocabMate';

    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        'Bạn có thông báo mới';

    final type = message.data['type']?.toString() ?? 'push';

    try {
      await NotificationFirestoreService.createNotification(
        title: title,
        body: body,
        type: type,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Save notification history error: $e');
      }
    }

    if (fromForeground) {
      try {
        await LocalNotificationService.showNotification(
          title: title,
          body: body,
          type: type,
          data: message.data,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Show foreground local notification error: $e');
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        'FCM message handled | '
            'title=$title | '
            'body=$body | '
            'type=$type | '
            'foreground=$fromForeground | '
            'opened=$fromOpenedApp | '
            'terminated=$fromTerminated',
      );
    }
  }
}