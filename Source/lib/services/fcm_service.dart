import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:stundaa/model/contact_summary.dart';
import 'package:stundaa/provider/contacts_provider.dart';
import 'package:stundaa/screens/whatsapp/screens/chatbox.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/services/auth.dart' as auth;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message handled by OS notification — no action needed
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _androidChannel = AndroidNotificationChannel(
    'stundaa_chat_channel',
    'Chat Notifications',
    description: 'Incoming WhatsApp chat messages',
    importance: Importance.high,
    playSound: true,
  );

  Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup local notifications with tap handler
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground message — show local notification with payload
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        final contactUid = message.data['contactUid']?.toString() ?? '';
        _localNotifications.show(
          notification.hashCode,
          notification.title ?? 'New Message',
          notification.body ?? '',
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: contactUid.isNotEmpty ? contactUid : null,
        );
      }
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToChat(message.data['contactUid']?.toString());
    });

    // Check if app was opened from terminated state via notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _navigateToChat(initialMessage.data['contactUid']?.toString());
    }

    // Register token with backend
    await _registerToken();

    // Re-register on token refresh
    _messaging.onTokenRefresh.listen(_sendTokenToBackend);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final contactUid = response.payload;
    if (contactUid != null && contactUid.isNotEmpty) {
      _navigateToChat(contactUid);
    }
  }

  void _navigateToChat(String? contactUid) {
    if (contactUid == null || contactUid.isEmpty) return;

    // Use a small delay to ensure app is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      final context = Get.context;
      if (context == null || !context.mounted) return;

      final contactProvider = Provider.of<ContactProvider>(context, listen: false);
      final contactEntry = contactProvider.contactsList
          .firstWhereOrNull((e) => e.value['_uid'] == contactUid);

      if (contactEntry != null) {
        final contactSummary = ContactSummary.fromEntry(contactEntry);
        Get.to(() => ChatboxScreen(contact: contactSummary));
      }
    });
  }

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      pr('FCM token registration error: $e');
    }
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString('device_id');
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      await prefs.setString('device_id', deviceId);
    }
    return deviceId;
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final authToken = auth.getAuthToken();
      if (authToken.isEmpty) return;
      final deviceId = await _getOrCreateDeviceId();
      final url = apiUrl('vendor/user-device/token');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'device_token': token,
          'device_id': deviceId,
          'device_type': 'android',
        }),
      );
      pr('FCM token registered: $token');
    } catch (e) {
      pr('FCM token send error: $e');
    }
  }
}
