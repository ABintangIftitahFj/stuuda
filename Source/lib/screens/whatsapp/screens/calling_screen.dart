import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/webrtc_manager.dart';

class CallingScreen extends StatefulWidget {
  final String contactName;
  final String? contactPhoneNumber;
  final bool isIncoming;

  const CallingScreen({
    super.key,
    required this.contactName,
    this.contactPhoneNumber,
    this.isIncoming = false,
  });

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final WebRTCManager _webRTCManager = WebRTCManager();
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  Duration _duration = Duration.zero;
  late final Stream<int> _timerStream;
  
  @override
  void initState() {
    super.initState();
    _timerStream = Stream.periodic(const Duration(seconds: 1), (i) => i);
    _timerStream.listen((event) {
      if (mounted) {
        setState(() {
          _duration = Duration(seconds: event);
        });
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      // TODO: Implement actual mute logic in WebRTCManager
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
      // TODO: Implement actual speaker logic
    });
  }

  void _endCall() async {
    await _webRTCManager.dispose();
    Get.back();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.deepNavy,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              app_theme.deepNavy,
              app_theme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Avatar/Icon
              CircleAvatar(
                radius: 60,
                backgroundColor: app_theme.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: app_theme.primary,
                ),
              ),
              const SizedBox(height: 24),
              // Contact Name
              Text(
                widget.contactName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: app_theme.lavenderWhite,
                ),
              ),
              const SizedBox(height: 8),
              // Call Status / Timer
              Text(
                _formatDuration(_duration),
                style: TextStyle(
                  fontSize: 18,
                  color: app_theme.secondary,
                ),
              ),
              const Spacer(),
              // Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildControlButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      label: "Mute",
                      onPressed: _toggleMute,
                      isActive: _isMuted,
                    ),
                    _buildEndCallButton(),
                    _buildControlButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                      label: "Speaker",
                      onPressed: _toggleSpeaker,
                      isActive: _isSpeakerOn,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? app_theme.lavenderWhite : Colors.white10,
            ),
            child: Icon(
              icon,
              color: isActive ? app_theme.black : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: _endCall,
          borderRadius: BorderRadius.circular(35),
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.redAccent,
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "End",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
