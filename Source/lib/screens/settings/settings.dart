import '../../common/widgets/common.dart';
import '../../screens/myprofile.dart';
import '../../services/utils.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart' as auth;
import '../../services/data_transport.dart' as data_transport;
import '../user/user_settings.dart';
import '/support/app_theme.dart' as app_theme;
import '../../services/global.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: innerAppBar(
        context: context,
        title:    context.lwTranslate.settings,
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: app_theme.primary,
                      radius: 25,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      '${auth.getAuthInfo('username') ?? ""}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(auth.getAuthInfo('email') ?? "",
                        style: const TextStyle(fontSize: 10)),
                    trailing: const Icon(Icons.edit),
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
              icon: Icons.person,
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
              icon: Icons.settings,
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
              icon: Icons.logout,
              title: context.lwTranslate.menuLogout,
              onTap: () {
                showActionableDialog(
                  context,
                  title: context.lwTranslate.menuLogout,
                  description: Text(context.lwTranslate.areYouSureToLogout,
                    style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w400
                  ),),
                  confirmActionText: context.lwTranslate.menuLogout,
                  cancelActionText: context.lwTranslate.cancel,
                  onConfirm:  () {
                    setState(() {
                      isMobileDialogShown = false;
                    });
                    data_transport.post('user/logout');
                    auth.logout().then((response) {
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        onTap: onTap,
      ),
    );
  }
}
