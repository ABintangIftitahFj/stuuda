import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/utils.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool activationRequired = false;
  bool isPasswordVisibleOld = false;
  bool isPasswordVisibleNew = false;
  bool isPasswordVisibleConfirm = false;

  final Map<String, dynamic> formInputData = {};
  // final String encryptionKey = EncryptionHelper.generateRandomKey();

  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmNewPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isPasswordVisibleOld = false;
    isPasswordVisibleNew = false;
    isPasswordVisibleConfirm = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        title: context.lwTranslate.changePassword,
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 22, right: 22, bottom: 0),
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
                              CupertinoIcons.lock_rotation,
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
                                labelText: context.lwTranslate.currentPassword,
                                password: !isPasswordVisibleOld,
                                controller: _currentPassController,
                                prefixIcon: const Icon(
                                  CupertinoIcons.lock,
                                  color: app_theme.iceBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisibleOld
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisibleOld =
                                          !isPasswordVisibleOld;
                                    });
                                  },
                                ),
                                onSaved: (String? value) {
                                  formInputData['old_password'] = value;
                                },
                                validation:
                                    ValidationBuilder().minLength(3).build(),
                              ),
                              InputField(
                                labelText: context.lwTranslate.newPassword,
                                password: !isPasswordVisibleNew,
                                controller: _newPassController,
                                prefixIcon: const Icon(
                                  CupertinoIcons.lock_shield,
                                  color: app_theme.iceBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisibleNew
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisibleNew =
                                          !isPasswordVisibleNew;
                                    });
                                  },
                                ),
                                validation:
                                    ValidationBuilder().minLength(6).build(),
                                onSaved: (String? value) {
                                  formInputData['password'] = value;
                                },
                              ),
                              InputField(
                                labelText:
                                    context.lwTranslate.confirmNewPassword,
                                password: !isPasswordVisibleConfirm,
                                controller: _confirmNewPassController,
                                prefixIcon: const Icon(
                                  CupertinoIcons.check_mark_circled,
                                  color: app_theme.iceBlue,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisibleConfirm
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisibleConfirm =
                                          !isPasswordVisibleConfirm;
                                    });
                                  },
                                ),
                                validation:
                                    ValidationBuilder().minLength(6).build(),
                                onSaved: (String? value) {
                                  formInputData['password_confirmation'] =
                                      value;
                                },
                              ),
                              LoadingButton(
                                defaultWidget: Text(
                                    context.lwTranslate.changePassword,
                                    style: const TextStyle(
                                        color: app_theme.black)),
                                width: MediaQuery.of(context).size.width,
                                color: app_theme.cyanGlow,
                                onPressed: () async {
                                  _formKey.currentState?.save();
                                  if (_formKey.currentState!.validate()) {
                                    await data_transport.post(
                                      'update-password',
                                      inputData: formInputData,
                                      context: context,
                                      secured: true,
                                      onSuccess: (responseData) {
                                        Navigator.pop(context);
                                      },
                                      onFailed: (responseData) {},
                                    );
                                  }
                                },
                              )
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
