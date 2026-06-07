import 'package:stundaa/common/widgets/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:stundaa/screens/myprofile.dart';
import 'package:stundaa/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/screens/user/user_settings.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/global.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        context: context,
        title: context.lwTranslate.settings,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 20),
            // User information
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: app_theme.insetPanelDecoration(radius: 24).copyWith(
                gradient: app_theme.cardGradient,
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: app_theme.surfaceMuted,
                      radius: 25,
                      child: Icon(CupertinoIcons.person, color: app_theme.iceBlue),
                    ),
                    title: Text(
                      '${auth.getAuthInfo('username') ?? ""}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: app_theme.lavenderWhite,
                      ),
                    ),
                    subtitle: Text(auth.getAuthInfo('email') ?? "",
                        style: const TextStyle(
                          fontSize: 10,
                          color: app_theme.secondary,
                        )),
                    trailing: const Icon(
                      CupertinoIcons.pencil,
                      color: app_theme.iceBlue,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      navigatePage(context, const MyProfile());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Settings options
            _buildSettingsTile(
              context,
              icon: CupertinoIcons.person,
              title: context.lwTranslate.myProfile,
              onTap: () => navigatePage(context, const MyProfile()),
            ),
            // _buildSettingsTile(
            //   context,
            //   icon: Icons.lock,
            //   title: context.lwTranslate.menuChangePassword,
            //   onTap: () => navigatePage(context, const ChangePasswordPage()),
            // ),
            // _buildSettingsTile(
            //   context,
            //   icon: Icons.email,
            //   title: context.lwTranslate.menuChangeEmail,
            //   onTap: () => navigatePage(context, const ChangeEmailPage()),
            // ),
            _buildSettingsTile(
              context,
              icon: CupertinoIcons.settings,
              title: context.lwTranslate.menuSettings,
              onTap: () => navigatePage(context, const UserSettingsPage()),
            ),
            // _buildSettingsTile(
            //   context,
            //   // icon: Icons.contact_mail_outlined,
            //   icon: Icons.contact_mail,
            //   title: 'Contact Us',
            //   onTap: () => navigatePage(context, const ContactUs()),
            // ),
            _buildSettingsTile(
              context,
              icon: CupertinoIcons.square_arrow_right,
              title: context.lwTranslate.menuLogout,
              onTap: () {
                showActionableDialog(
                  context,
                  title: context.lwTranslate.menuLogout,
                  description: Text(
                    context.lwTranslate.areYouSureToLogout,
                    style: const TextStyle(
                      fontSize: 14,
                      color: app_theme.secondary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  confirmActionText: context.lwTranslate.menuLogout,
                  cancelActionText: context.lwTranslate.cancel,
                  onConfirm: () {
                    setState(() {
                      isMobileDialogShown = false;
                    });
                    data_transport.post('user/logout');
                    auth.logout().then((response) {
                      if (!context.mounted) {
                        return;
                      }
                      clearDemoPhoneNumbers();
                      auth.redirectIfUnauthenticated(context);
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: app_theme.primary),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: app_theme.lavenderWhite,
          ),
        ),
        trailing: const Icon(
          CupertinoIcons.chevron_forward,
          size: 16,
          color: app_theme.secondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        tileColor: app_theme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        onTap: onTap,
      ),
    );
  }
}
