import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'utils.dart';

class PusherService {
  static final PusherService _instance = PusherService._internal();
  final PusherChannelsFlutter _pusher = PusherChannelsFlutter();

  factory PusherService() => _instance;

  PusherService._internal();

  Future<void> initPusher(String authToken) async {
    try {
      await _pusher.init(
        apiKey: configItem('services.pusher.apiKey'),
        cluster: configItem('services.pusher.cluster'),
        logToConsole: configItem('debug'),
        authEndpoint: apiUrl("broadcasting/auth", queryParameters: {
          'auth_token': authToken,
        }).toString(),
        onError: (message, code, exception) {
          // ignore
        },
      );
      await _pusher.connect();
    } catch (e) {
      // ignore
    }
  }

  Future<void> subscribeToChannel({
    required String channelName,
    required Function(String eventName, Map<String, dynamic> eventData) onEvent,
    Function(String? error)? onSubscriptionError,
  }) async {
    try {
      await _pusher.subscribe(
        channelName: channelName,
        onEvent: (eventResponseData) {
          try {
            final data = jsonDecode(eventResponseData.data);
            onEvent(eventResponseData.eventName, data);
          } catch (e) {
            // ignore
          }
        },
        onSubscriptionError: (error) {
          if (onSubscriptionError != null) onSubscriptionError(error);
        },
      );
    } catch (e) {
      // ignore
    }
  }
}
