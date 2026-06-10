import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/foundation.dart';

class WebRTCManager {
  static final WebRTCManager _instance = WebRTCManager._internal();
  factory WebRTCManager() => _instance;
  WebRTCManager._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  Function(Map<String, dynamic> data)? onSignalingData;

  // Configuration for STUN/TURN servers
  // In production, consider using a reliable TURN server provider
  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  /// Initialize local media stream (Microphone and Camera)
  Future<MediaStream> initLocalStream({bool video = true}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': video ? {
        'facingMode': 'user',
        'width': '640',
        'height': '480',
      } : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    return _localStream!;
  }

  /// Create a new Peer Connection
  Future<RTCPeerConnection> createPeerConnectionInstance() async {
    _peerConnection = await createPeerConnection(_iceServers, _config);

    if (_localStream != null) {
      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });
    }

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      debugPrint('New ICE Candidate: ${candidate.candidate}');
      if (onSignalingData != null) {
        onSignalingData!({
          'type': 'ice-candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          }
        });
      }
    };

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      debugPrint('Remote track received: ${event.track.kind}');
      // TODO: Handle remote stream UI update
    };

    return _peerConnection!;
  }

  /// Generate SDP Offer for outgoing call
  Future<String> createOffer() async {
    if (_peerConnection == null) await createPeerConnectionInstance();
    
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    
    return offer.sdp ?? '';
  }

  /// Generate SDP Answer for incoming call
  Future<String> createAnswer(String remoteSdp) async {
    if (_peerConnection == null) await createPeerConnectionInstance();

    RTCSessionDescription description = RTCSessionDescription(remoteSdp, 'offer');
    await _peerConnection!.setRemoteDescription(description);

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    return answer.sdp ?? '';
  }

  /// Set Remote Description (used when receiving answer)
  Future<void> setRemoteDescription(String remoteSdp, String type) async {
    if (_peerConnection == null) return;
    RTCSessionDescription description = RTCSessionDescription(remoteSdp, type);
    await _peerConnection!.setRemoteDescription(description);
  }

  /// Add ICE Candidate from remote peer
  Future<void> addIceCandidate(Map<String, dynamic> candidateData) async {
    if (_peerConnection == null) return;
    RTCIceCandidate candidate = RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    );
    await _peerConnection!.addCandidate(candidate);
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _localStream?.dispose();
    await _peerConnection?.dispose();
    _localStream = null;
    _peerConnection = null;
  }
}
