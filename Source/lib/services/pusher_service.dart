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
      pr("Initializing Pusher...");
      await _pusher.init(
        apiKey: configItem('services.pusher.apiKey'),
        cluster: configItem('services.pusher.cluster'),
        logToConsole: configItem('debug'),
        authEndpoint: apiUrl("broadcasting/auth", queryParameters: {
          'auth_token': authToken,
        }).toString(),
        onError: (message, code, exception) {
          pr("Pusher Error: $message (code: $code, exception: $exception)");
        },
        onConnectionStateChange: (currentState, previousState) {
          pr("Pusher Connection State changed from $previousState to $currentState");
        },
      );
      await _pusher.connect();
      pr("Pusher connect called.");
    } catch (e) {
      pr("Error initializing Pusher: $e");
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
