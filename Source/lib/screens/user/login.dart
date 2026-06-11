import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:stundaa/screens/user/register.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/globalurls.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/common/widgets/common.dart';
import 'package:form_validator/form_validator.dart';

class LoginPage extends StatefulWidget {
  final void Function()? ontap;
  const LoginPage({super.key, this.ontap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formInputData = {};
  bool isInProcess = false;
  bool _isLoading = false;
  bool isPasswordVisible = false;

  void login() async {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await data_transport.post(
        Account.login,
        inputData: formInputData,
        context: context,
        secured: true,
        onSuccess: (responseData) {
          if (responseData != null) {
            auth.createLoginSession(responseData, context);
          }
        },
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isPasswordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: app_theme.appBackgroundDecoration(),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: app_theme.glowOrbDecoration(),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Container(
                    decoration: app_theme.glassCardDecoration(radius: 30),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AppLogo(height: 92),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(255, 255, 255, 0.05),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: app_theme.outlineSoft),
                            ),
                            child: Text(
                              'Focus workspace',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: app_theme.iceBlue,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Welcome Back',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontSize: 28,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Continue your focus journey with STUNDAA.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  color: app_theme.iceBlue,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 28),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                InputField(
                                  labelText:
                                      context.lwTranslate.emailOrUsername,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person_crop_circle,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['email'] = value;
                                  },
                                  validation:
                                      ValidationBuilder().minLength(2).build(),
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  placeholder: context.lwTranslate.password,
                                  labelText: context.lwTranslate.password,
                                  password: !isPasswordVisible,
                                  validation:
                                      ValidationBuilder().minLength(6).build(),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.lock_shield,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['password'] = value;
                                  },
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? CupertinoIcons.eye
                                          : CupertinoIcons.eye_slash,
                                      color: app_theme.iceBlue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: login,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: app_theme.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(29, 161, 255, 0.45),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: !_isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.lwTranslate.login,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: app_theme.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withValues(alpha: 0.10),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.arrow_up_right,
                                            size: 15,
                                            color: app_theme.black,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: app_theme.black,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            context.lwTranslate.dontHaveAcc,
                            style: const TextStyle(
                              color: app_theme.secondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              navigatePage(context, RegisterPage());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color:
                                    const Color.fromRGBO(255, 255, 255, 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      const Color.fromRGBO(167, 223, 255, 0.24),
                                ),
                              ),
                              child: Text(
                                context.lwTranslate.createNewAcc,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: app_theme.lavenderWhite,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
