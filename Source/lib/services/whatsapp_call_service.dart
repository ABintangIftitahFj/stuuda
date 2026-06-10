import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:stundaa/screens/whatsapp/screens/calling_screen.dart';
import 'data_transport.dart' as data_transport;
import 'utils.dart';
import 'webrtc_manager.dart';

class WhatsAppCallService {
  static final WebRTCManager _webRTCManager = WebRTCManager();

  /// Memulai panggilan bisnis (Business Initiated Call)
  /// contactUid: UID dari kontak yang akan dipanggil
  static Future<void> startCall(BuildContext context, String contactUid) async {
    // 1. Request Permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    bool isMicrophoneDenied = statuses[Permission.microphone] != PermissionStatus.granted;
    bool isCameraDenied = statuses[Permission.camera] != PermissionStatus.granted;

    if (isMicrophoneDenied || isCameraDenied) {
      if (!context.mounted) return;

      bool isPermanentlyDenied = statuses[Permission.microphone]!.isPermanentlyDenied ||
          statuses[Permission.camera]!.isPermanentlyDenied;

      if (isPermanentlyDenied) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permissions Required'),
            content: const Text(
                'Microphone and Camera permissions are permanently denied. Please enable them in settings to use calling features.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  openAppSettings();
                  Navigator.pop(context);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      } else {
        showToastMessage(context, 'Microphone and Camera permissions are required for calling',
            type: 'error');
      }
      return;
    }

    // Tampilkan loading dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 2. Setup Signaling Callback
      _webRTCManager.onSignalingData = (data) async {
        await data_transport.post(
          'vendor-console/whatsapp-calling/update-call-details',
          inputData: {
            'contact_uid': contactUid,
            'signaling_data': data,
          },
        );
      };

      // 3. Initialize WebRTC and Create SDP Offer
      await _webRTCManager.initLocalStream(video: false); // Audio call by default
      String sdpOffer = await _webRTCManager.createOffer();

      // 4. Send Call Request with SDP
      await data_transport.post(
        'vendor-console/whatsapp-calling/business-initiated-call',
        inputData: {
          'contact_uid': contactUid,
          'sdp': sdpOffer,
        },
        onSuccess: (responseData) {
          if (!context.mounted) return;
          Navigator.pop(context); // Tutup loading
          
          Get.to(() => CallingScreen(
            contactName: 'WhatsApp Contact', // Should ideally get from context/provider
            isIncoming: false,
          ));
        },
        onFailed: (responseData) async {
          _webRTCManager.onSignalingData = null;
          await _webRTCManager.dispose();
          if (!context.mounted) return;
          Navigator.pop(context); // Tutup loading
          String message = responseData?['data']?['message'] ?? 'Gagal melakukan panggilan';
          showToastMessage(context, message, type: 'error');
        },
      );
    } catch (e) {
      _webRTCManager.onSignalingData = null;
      await _webRTCManager.dispose();
      if (!context.mounted) return;
      Navigator.pop(context); // Tutup loading
      showToastMessage(context, 'Terjadi kesalahan koneksi', type: 'error');
    }
  }

  /// Mengecek izin panggilan user
  static Future<void> checkPermissions(BuildContext context, String contactUid) async {
    if (!context.mounted) return;
    await data_transport.get(
      'vendor-console/whatsapp-calling/get-user-call-permissions/$contactUid',
      context: context,
      onSuccess: (responseData) {
        // Logika pengecekan izin jika diperlukan
      },
    );
  }
}
