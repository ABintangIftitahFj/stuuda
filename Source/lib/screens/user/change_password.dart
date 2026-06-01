import 'package:flutter/material.dart';
import 'package:progress_loading_button/progress_loading_button.dart';
import 'package:form_validator/form_validator.dart';
import '../../common/widgets/common.dart';
import '../../components/input_field.dart';
import '../../services/data_transport.dart' as data_transport;
import '../../support/app_theme.dart' as app_theme;
import '../../services/utils.dart';

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
      appBar: innerAppBar(
        title: context.lwTranslate.changePassword,
        context: context,
      ),

      body: Padding(
        padding: const EdgeInsets.only(top: 0, left: 32, right: 32, bottom: 0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (activationRequired)
                        Column(
                          children: [
                            Text(
                              context.lwTranslate.activateYourNewEmailAddress,
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              context.lwTranslate
                                  .almostFinishedYouNeedToConfirmYourEmailAddressTo,
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisibleOld
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisibleNew
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                              labelText: context.lwTranslate.confirmNewPassword,
                              password: !isPasswordVisibleConfirm,
                              controller: _confirmNewPassController,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisibleConfirm
                                      ? Icons.visibility
                                      : Icons.visibility_off,
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
                                formInputData['password_confirmation'] = value;
                              },
                            ),
                            LoadingButton(
                              defaultWidget:
                                  Text(context.lwTranslate.changePassword,
                                      style: TextStyle(color: Colors.white)),
                              width: MediaQuery.of(context).size.width,
                              // height: 60,
                              color: app_theme.primary,
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              foregroundColor: app_theme.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              context.lwTranslate.goBack,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
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
          ],
        ),
      ),
    );
  }
}
