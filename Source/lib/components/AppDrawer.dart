import './../services/utils.dart';
import './../common/widgets/common.dart';
import './../screens/myprofile.dart';
import './../screens/user/change_password.dart';
import 'package:flutter/material.dart';
import '../screens/contact/contact_us.dart';
import '../screens/user/change_email.dart';
import '../screens/user/user_settings.dart';
import '../../support/app_theme.dart' as app_theme;
import './../services/auth.dart' as auth;
import './../services/data_transport.dart' as data_transport;

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: app_theme.backgroundColor,
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              const AppLogo(
                height: 75,
              ),
              ListTile(
                title: Text(
                    '${auth.getAuthInfo('full_name')} (${auth.getAuthInfo('username')})',
                    style: const TextStyle(color: Colors.black)),
                subtitle: Text(
                  auth.getAuthInfo('email'),
                  style: const TextStyle(color: Colors.black),
                ),
                onTap: () {
                  // Then close the drawer
                  Navigator.pop(context);
                  navigatePage(
                    context,
                    const MyProfile(),
                  );
                },
              ),
            ],
          ),
          const Divider(color: Color.fromARGB(255, 209, 206, 206)),
          ListTile(
            leading: const Icon(Icons.person_2_outlined),
            title: Text(context.lwTranslate.myProfile),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const MyProfile(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.password),
            title: Text(context.lwTranslate.menuChangePassword),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const ChangePasswordPage(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(context.lwTranslate.menuChangeEmail),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const ChangeEmailPage(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(context.lwTranslate.menuSettings),
            onTap: () {
              // Then close the drawer
              Navigator.pop(context);
              navigatePage(
                context,
                const UserSettingsPage(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_mail_outlined),
            title: Text(context.lwTranslate.contactUs),
            onTap: () {
              Navigator.pop(context);
              navigatePage(
                context,
                const ContactUs(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.lwTranslate.menuLogout),
            onTap: () {
              Navigator.pop(context);
              data_transport.post(
                'user/logout',
              );
              auth.logout().then((response) {
                auth.redirectIfUnauthenticated(context);
              });
            },
          ),
        ],
      ),
    );
  }
}
