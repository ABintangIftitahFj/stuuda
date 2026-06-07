import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/support/app_theme.dart' as app_theme;

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final _formKey = GlobalKey<FormState>();

  bool activationRequired = false;

  final Map<String, dynamic> formInputData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        title: context.lwTranslate.changeEmail,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: app_theme.insetPanelDecoration(radius: 24)
                        .copyWith(gradient: app_theme.cardGradient),
                    child: Column(
                      children: [
                        if (!activationRequired) ...[
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: app_theme.surfaceMuted,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              CupertinoIcons.mail,
                              color: app_theme.iceBlue,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (activationRequired)
                          Column(
                            children: [
                              Text(
                                context.lwTranslate.activateYourNewEmailAddress,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: app_theme.lavenderWhite,
                                ),
                              ),
                              Text(
                                context.lwTranslate
                                    .almostFinishedYouNeedToConfirmYourEmailAddressTo,
                                style:
                                    const TextStyle(color: app_theme.secondary),
                              )
                            ],
                          ),
                        if (!activationRequired)
                          Column(
                            children: [
                              InputField(
                                readOnly: true,
                                initialValue: auth.getAuthInfo('email'),
                                labelText: context.lwTranslate.currentEmail,
                                prefixIcon: const Icon(
                                  CupertinoIcons.mail_solid,
                                  color: app_theme.iceBlue,
                                ),
                                onSaved: (String? value) {
                                  formInputData['current_email'] = value;
                                },
                                validation: ValidationBuilder()
                                    .minLength(3)
                                    .email()
                                    .build(),
                              ),
                              InputField(
                                labelText: context.lwTranslate.newEmail,
                                prefixIcon: const Icon(
                                  CupertinoIcons.at,
                                  color: app_theme.iceBlue,
                                ),
                                onSaved: (String? value) {
                                  formInputData['new_email'] = value;
                                },
                                validation: ValidationBuilder()
                                    .minLength(3)
                                    .email()
                                    .build(),
                              ),
                              InputField(
                                labelText: context.lwTranslate.password,
                                password: true,
                                prefixIcon: const Icon(
                                  CupertinoIcons.lock,
                                  color: app_theme.iceBlue,
                                ),
                                validation:
                                    ValidationBuilder().minLength(6).build(),
                                onSaved: (String? value) {
                                  formInputData['current_password'] = value;
                                },
                              ),
                              LoadingButton(
                                defaultWidget: Text(
                                  context.lwTranslate.changeEmail,
                                  style:
                                      const TextStyle(color: app_theme.black),
                                ),
                                width: MediaQuery.of(context).size.width,
                                color: app_theme.cyanGlow,
                                onPressed: () async {
                                  _formKey.currentState?.save();
                                  if (_formKey.currentState!.validate()) {
                                    await data_transport.post(
                                      'profile/update-email-process',
                                      inputData: formInputData,
                                      context: context,
                                      onSuccess: (responseData) {
                                        setState(() {
                                          activationRequired = getItemValue(
                                            responseData,
                                            'data.activationRequired',
                                          );
                                        });
                                        if (!activationRequired) {
                                          auth.refreshUserInfo();
                                          Navigator.pop(context);
                                        }
                                      },
                                      onFailed: (responseData) {},
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: app_theme.surfaceElevated,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                context.lwTranslate.goBack,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: app_theme.lavenderWhite,
                                ),
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
          ],
        ),
      ),
    );
  }
}
