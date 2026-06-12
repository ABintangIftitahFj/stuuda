import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'webrtc_manager.dart';
import 'data_transport.dart' as data_transport;
import 'utils.dart';

/// CallService manages incoming call notifications and call events.
///
/// DEPRECATED: flutter_callkit_incoming is no longer actively maintained.
/// Consider migration to:
/// - Firebase Cloud Messaging (FCM) for notifications
/// - Native platform channels for call handling
class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final WebRTCManager _webRTCManager = WebRTCManager();

  /// Configuration for production should come from secure storage, not hardcoded values
  static const String _appName = 'Stunnda';
  static const int _callDuration = 30000; // milliseconds

  Future<void> showIncomingCall({
    required String callerName,
    required String avatar,
    String? handle, // e.g., phone number
    String? userId, // Should be passed instead of hardcoded
    String? apiKey, // Should be passed or fetched from secure storage
  }) async {
    if (kIsWeb) return;
    final String callId = const Uuid().v4();

    CallKitParams callKitParams = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: _appName,
      avatar: avatar,
      handle: handle ?? 'Incoming Call',
      type: 0, // 0 - Audio Call, 1 - Video Call
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
      duration: _callDuration,
      extra: <String, dynamic>{'userId': userId ?? 'unknown_user'},
      headers: <String, dynamic>{'apiKey': apiKey ?? ''},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'assets/test.png',
        actionColor: '#4CAF50',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: '',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
  }

  void listenToCallEvents() {
    if (kIsWeb) return;
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
      if (event == null) {
        debugPrint('Warning: CallEvent is null');
        return;
      }

      switch (event.event) {
        case Event.actionCallAccept:
          _handleCallAccept(event);
          break;
        case Event.actionCallDecline:
          _handleCallDecline(event);
          break;
        case Event.actionCallEnded:
          _handleCallEnded(event);
          break;
        case Event.actionCallTimeout:
          _handleCallTimeout(event);
          break;
        default:
          debugPrint('Unknown call event: ${event.event}');
          break;
      }
    });
  }

  /// Handle when call is accepted
  /// Implementation: Navigator.push to call screen with callId and callerInfo
  void _handleCallAccept(CallEvent event) async {
    debugPrint('✓ Call Accepted - Event: ${event.body}');

    final String? contactUid = event.body?['extra']?['userId'] as String?;
    final String? callId = event.body?['id'] as String?;

    if (contactUid != null) {
      try {
        // 1. Setup Signaling Callback
        _webRTCManager.onSignalingData = (data) async {
          await data_transport.post(
            'vendor-console/whatsapp-calling/update-call-details',
            inputData: {
              'contact_uid': contactUid,
              'call_id': callId,
              'signaling_data': data,
            },
          );
        };

        // 2. Get Remote SDP (stored during offer reception)
        String? remoteSdp = await getPreferences('remote_sdp');
        if (remoteSdp != null) {
          // 3. Create Answer
          await _webRTCManager.initLocalStream(video: false);
          String sdpAnswer = await _webRTCManager.createAnswer(remoteSdp);

          // 4. Send Answer to Backend
          await data_transport.post(
            'vendor-console/whatsapp-calling/answer-user-initiated-call',
            inputData: {
              'contact_uid': contactUid,
              'call_id': callId,
              'type': 'accept',
              'sdp': sdpAnswer,
            },
          );
        }
      } catch (e) {
        debugPrint('Error answering call: $e');
        _webRTCManager.onSignalingData = null;
        await _webRTCManager.dispose();
      }
    }
  }

  /// Handle when call is declined
  void _handleCallDecline(CallEvent event) async {
    debugPrint('✗ Call Declined - Event: ${event.body}');

    final String? contactUid = event.body?['extra']?['userId'] as String?;
    final String? callId = event.body?['id'] as String?;

    if (contactUid != null) {
      await data_transport.post(
        'vendor-console/whatsapp-calling/answer-user-initiated-call',
        inputData: {
          'contact_uid': contactUid,
          'call_id': callId,
          'type': 'decline',
        },
      );
    }
    _webRTCManager.onSignalingData = null;
    await _webRTCManager.dispose();
  }

  /// Handle when call ends
  void _handleCallEnded(CallEvent event) async {
    debugPrint('⊘ Call Ended - Event: ${event.body}');

    final String? contactUid = event.body?['extra']?['userId'] as String?;
    final String? callId = event.body?['id'] as String?;

    if (contactUid != null) {
      await data_transport.post(
        'vendor-console/whatsapp-calling/stop-in-progress-call',
        inputData: {
          'contact_uid': contactUid,
          'call_id': callId,
        },
      );
    }

    _webRTCManager.onSignalingData = null;
    await _webRTCManager.dispose();
  }

  /// Handle when call times out (no answer)
  void _handleCallTimeout(CallEvent event) async {
    debugPrint('⏱ Call Timeout - Event: ${event.body}');

    final String? contactUid = event.body?['extra']?['userId'] as String?;
    final String? callId = event.body?['id'] as String?;

    if (contactUid != null) {
      // Send missed call status to backend
      await data_transport.post(
        'vendor-console/whatsapp-calling/answer-user-initiated-call',
        inputData: {
          'contact_uid': contactUid,
          'call_id': callId,
          'type': 'timeout',
        },
      );
    }
    
    _webRTCManager.onSignalingData = null;
    await _webRTCManager.dispose();
  }
}
