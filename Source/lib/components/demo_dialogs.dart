import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/screens/landing.dart';

class DemoDialogs {
  static void showMobileNumberDialog(BuildContext context, {required bool showSavedNumber}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => MobileNumberDialogContent(showSavedNumber: showSavedNumber),
    );
  }

  static void showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const QRDialogContent(),
    );
  }
}

class MobileNumberDialogContent extends StatefulWidget {
  final bool showSavedNumber;
  const MobileNumberDialogContent({super.key, required this.showSavedNumber});

  @override
  State<MobileNumberDialogContent> createState() => _MobileNumberDialogContentState();
}

class _MobileNumberDialogContentState extends State<MobileNumberDialogContent> {
  final TextEditingController _mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.showSavedNumber) {
      _loadSavedNumber();
    }
  }

  Future<void> _loadSavedNumber() async {
    final savedNumber = await getPreferences('user_mobile_number') ?? '';
    if (mounted) {
      setState(() {
        _mobileController.text = savedNumber;
      });
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: app_theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(
          color: Color.fromRGBO(167, 223, 255, 0.16),
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      contentPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      actionsPadding: const EdgeInsets.all(16),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            context.lwTranslate.onlyForDemo,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: app_theme.lavenderWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.lwTranslate.addYourMobileNumber,
            style: const TextStyle(
              fontSize: 14,
              color: app_theme.iceBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  context.lwTranslate.youCanAddComma,
                  style: const TextStyle(
                    fontSize: 13,
                    color: app_theme.secondary,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: app_theme.lavenderWhite),
                  decoration: InputDecoration(
                    labelText: context.lwTranslate.mobileNumber,
                    labelStyle: const TextStyle(color: app_theme.iceBlue),
                    prefixIcon: const Icon(Icons.phone, color: app_theme.iceBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color.fromRGBO(167, 223, 255, 0.20)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.lwTranslate.pleaseEnterMobile;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  context.lwTranslate.addYourMobileNumberTest,
                  style: const TextStyle(
                    fontSize: 13,
                    color: app_theme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_theme.primary,
                  foregroundColor: app_theme.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.lwTranslate.update,
                  style: const TextStyle(
                    color: app_theme.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await setPreferences('user_mobile_number', _mobileController.text);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    showSuccessMessage(
                      context,
                      context.lwTranslate.mobileNumberUpdated,
                    );
                    
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LandingPage(
                          skipMobileDialog: true,
                        ),
                      ),
                      (route) => false,
                    );
                    DemoDialogs.showQRDialog(context);
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: app_theme.surfaceElevated,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.lwTranslate.notNow,
                  style: const TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QRDialogContent extends StatelessWidget {
  const QRDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    const qrData = "https://wa.me/919270075740";
    const testNumber = "919270075740";
    return AlertDialog(
      backgroundColor: app_theme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
        side: const BorderSide(
          color: Color.fromRGBO(167, 223, 255, 0.16),
        ),
      ),
      contentPadding: EdgeInsets.zero,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                gradient: app_theme.primaryGradient,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.0),
                  topRight: Radius.circular(16.0),
                ),
              ),
              child: Text(
                context.lwTranslate.scanQrCode,
                style: const TextStyle(
                  color: app_theme.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    context.lwTranslate.youCanUseFollowing,
                    style: const TextStyle(
                      fontSize: 14,
                      color: app_theme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(167, 223, 255, 0.18),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      color: app_theme.backgroundColor,
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "STUNDAA",
                          style: TextStyle(
                            color: app_theme.lavenderWhite,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          testNumber,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 180.0,
                            embeddedImage: const AssetImage('assets/images/whatsapp_logo.png'),
                            embeddedImageStyle: const QrEmbeddedImageStyle(
                              size: Size(40, 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: app_theme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: const Size(double.infinity, 0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/whatsapp_mini_logo.png',
                      width: 22,
                      height: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.lwTranslate.whatsAppNow,
                      style: const TextStyle(
                        color: app_theme.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  const whatsappUrl = "https://api.whatsapp.com/send?phone=919270075740";
                  if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                    await launchUrl(Uri.parse(whatsappUrl));
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.lwTranslate.couldNotLaunch)),
                    );
                  }
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
