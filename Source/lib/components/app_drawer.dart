import 'package:stundaa/services/utils.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/screens/myprofile.dart';
import 'package:stundaa/screens/my_plan.dart';
import 'package:stundaa/screens/user/change_password.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/screens/contact/contact_us.dart';
import 'package:stundaa/screens/user/change_email.dart';
import 'package:stundaa/screens/user/user_settings.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/data_transport.dart' as data_transport;

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: app_theme.deepNavy,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
            decoration: app_theme.glassCardDecoration(radius: 24),
            child: Column(
              children: [
                const AppLogo(height: 68),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${auth.getAuthInfo('full_name')} (${auth.getAuthInfo('username')})',
                      style: const TextStyle(
                        color: app_theme.lavenderWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      auth.getAuthInfo('email'),
                      style: const TextStyle(color: app_theme.secondary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      navigatePage(
                        context,
                        const MyProfile(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Color.fromRGBO(167, 223, 255, 0.18)),
          ),
          _drawerItem(
            context,
            icon: Icons.person_2_outlined,
            label: context.lwTranslate.myProfile,
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const MyProfile(),
              );
            },
          ),
          _drawerItem(
            context,
            icon: Icons.password,
            label: context.lwTranslate.menuChangePassword,
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const ChangePasswordPage(),
              );
            },
          ),
          _drawerItem(
            context,
            icon: Icons.email_outlined,
            label: context.lwTranslate.menuChangeEmail,
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const ChangeEmailPage(),
              );
            },
          ),
          _drawerItem(
            context,
            icon: Icons.settings_outlined,
            label: context.lwTranslate.menuSettings,
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const UserSettingsPage(),
              );
            },
          ),
          _drawerItem(
            context,
            icon: Icons.workspace_premium_outlined,
            label: 'My Plan',
            onTap: () {
              Navigator.pop(context);
              navigatePage(context, const MyPlanScreen());
            },
          ),
          _drawerItem(
            context,
            icon: Icons.contact_mail_outlined,
            label: context.lwTranslate.contactUs,
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const ContactUs(),
              );
            },
          ),
          _drawerItem(
            context,
            icon: Icons.logout,
            label: context.lwTranslate.menuLogout,
            onTap: () {
              Navigator.pop(context);
              data_transport.post(
                'user/logout',
              );
              auth.logout().then((response) {
                if (context.mounted) {
                  auth.redirectIfUnauthenticated(context);
                }
              });
            },
            iconColor: app_theme.error,
            textColor: app_theme.error,
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = app_theme.iceBlue,
    Color textColor = app_theme.lavenderWhite,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
