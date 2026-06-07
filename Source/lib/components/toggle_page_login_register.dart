import 'package:flutter/material.dart';

import 'package:stundaa/screens/user/login.dart';
import 'package:stundaa/screens/user/register.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        ontap: togglePages,
      );
    } else {
      return RegisterPage(
        ontap: togglePages,
      );
    }
  }
}
