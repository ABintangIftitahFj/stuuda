import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import 'package:stundaa/components/app_bar.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/support/app_theme.dart' as app_theme;

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _requestOtpFormKey = GlobalKey<FormState>();
  final _resetPasswordFormKey = GlobalKey<FormState>();

  bool emailOtpSent = false;
  bool emailOtpVerified = false;
  String alertMessage = '';

  final Map<String, dynamic> formInputData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBarWidget(
          context: context,
          title: context.lwTranslate.forgotPassword,
          actionWidgets: []),
      backgroundColor: app_theme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: app_theme.insetPanelDecoration(radius: 24).copyWith(
              gradient: app_theme.cardGradient,
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: app_theme.surfaceMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.lock_rotation,
                    color: app_theme.iceBlue,
                  ),
                ),
                const SizedBox(height: 16),
                if (alertMessage != '')
                  Text(
                    alertMessage,
                    style: const TextStyle(
                      color: app_theme.warning,
                    ),
                  ),
                // Request email OTP
                if (!emailOtpSent && !emailOtpVerified)
                  Form(
                    key: _requestOtpFormKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            InputField(
                              labelText: context.lwTranslate.yourEmailAddress,
                              inputType: TextInputType.emailAddress,
                              onSaved: (String? value) {
                                formInputData['email'] = value;
                              },
                              prefixIcon: const Icon(
                                CupertinoIcons.mail,
                                color: app_theme.iceBlue,
                              ),
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            LoadingButton(
                              defaultWidget: Text(
                                context.lwTranslate.sendEmailOtp,
                                style: const TextStyle(
                                  color: app_theme.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              color: app_theme.cyanGlow,
                              onPressed: () async {
                                _requestOtpFormKey.currentState?.save();
                                if (_requestOtpFormKey.currentState!
                                    .validate()) {
                                  await data_transport.post(
                                    'user/request-new-password',
                                    inputData: formInputData,
                                    context: context,
                                    secured: true,
                                    onSuccess: (responseData) {
                                      if (getItemValue(
                                              responseData, 'data.mail_sent') ==
                                          true) {
                                        setState(() {
                                          emailOtpSent = true;
                                          alertMessage = getItemValue(
                                            responseData,
                                            'data.message',
                                          );
                                        });
                                      }
                                    },
                                    onFailed: (responseData) {},
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                if (emailOtpSent)
                  Form(
                    key: _resetPasswordFormKey,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            InputField(
                              readOnly: true,
                              initialValue: formInputData['email'],
                              labelText:  context.lwTranslate.email,
                              prefixIcon: const Icon(
                                CupertinoIcons.mail_solid,
                                color: app_theme.iceBlue,
                              ),
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              labelText: context.lwTranslate.emailOtp,
                              inputType: TextInputType.emailAddress,
                              onSaved: (String? value) {
                                formInputData['otp'] = value;
                              },
                              prefixIcon: const Icon(
                                CupertinoIcons.number_circle,
                                color: app_theme.iceBlue,
                              ),
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              labelText: context.lwTranslate.newPassword,
                              password: true,
                              prefixIcon: const Icon(
                                CupertinoIcons.lock,
                                color: app_theme.iceBlue,
                              ),
                              onSaved: (String? value) {
                                formInputData['password'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            InputField(
                              labelText: context.lwTranslate.confirmNewPassword,
                              password: true,
                              prefixIcon: const Icon(
                                CupertinoIcons.lock_shield,
                                color: app_theme.iceBlue,
                              ),
                              onSaved: (String? value) {
                                formInputData['password_confirmation'] = value;
                              },
                              validation:
                                  ValidationBuilder().minLength(3).build(),
                            ),
                            LoadingButton(
                              defaultWidget: Text(
                                context.lwTranslate.submit,
                                style: const TextStyle(
                                  color: app_theme.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              color: app_theme.cyanGlow,
                              onPressed: () async {
                                _resetPasswordFormKey.currentState?.save();
                                if (_resetPasswordFormKey.currentState!
                                    .validate()) {
                                  await data_transport.post(
                                    'user/process-reset-password',
                                    inputData: formInputData,
                                    context: context,
                                    onSuccess: (responseData) {
                                      if (getItemValue(responseData,
                                              'data.password_changed') ==
                                          true) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    onFailed: (responseData) {},
                                  );
                                }
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: app_theme.surfaceMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        foregroundColor: app_theme.lavenderWhite,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.lwTranslate.cancel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
