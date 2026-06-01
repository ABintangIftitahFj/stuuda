import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../components/input_field.dart';
import '../../services/globalurls.dart';
import '../../services/utils.dart';
import '../../services/data_transport.dart' as data_transport;
import '../../services/auth.dart' as auth;
import '../../support/app_theme.dart' as app_theme;
import '../../common/widgets/common.dart';
import 'package:form_validator/form_validator.dart';
import 'login.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? ontap;

  const RegisterPage({super.key, this.ontap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool isChecked = false;
  bool isPasswordVisibleCom = false;
  String? _termsError;
  final Map<String, dynamic> formInputData = {};
  bool isLoading = false;

  void register() async {
    try {
      _formKey.currentState?.save();
      if (_formKey.currentState?.validate() ?? false) {
        if (!isChecked) {
          setState(() {
            _termsError = context.lwTranslate.termsCondAccept;
          });
          return;
        }
        setState(() {
          isLoading = true;
          _termsError = '';
        });
        try {
          await data_transport.post(
            Account.registerVendor,
            inputData: formInputData,
            context: context,
            secured: true,
            onSuccess: (responseData) {
              if (responseData != null) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false);
              }
            },
            onFailed: (responseData) {},
          );
        } catch (e) {
          pr("Error during registration: $e");
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isPasswordVisible = false;
    isPasswordVisibleCom = false;
  }

  @override
  Widget build(BuildContext context) {
    auth.redirectIfAuthenticated(context);
    return Scaffold(
      body: Stack(children: [
        SizedBox.expand(
          child: Image.asset(
            'assets/images/ic_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 30, bottom: 40, right: 15, left: 15),
                      child: Column(
                        children: [
                          const AppLogo(
                            height: 75,
                          ),
                          Center(
                            child: Text(
                              context.lwTranslate.registerVendorComp,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(height: 50),
                          const SizedBox(
                            height: 20,
                          ),
                          Column(
                            children: [
                              Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      InputField(
                                        labelText:
                                            context.lwTranslate.vendorCompName,
                                        prefixIcon: const Icon(Icons.person),
                                        onSaved: (String? value) {
                                          formInputData['vendor_title'] = value;
                                        },
                                        validation: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .lwTranslate.fieldRequired;
                                          }
                                          if (value.length < 2) {
                                            return context
                                                .lwTranslate.mustBe2Character;
                                          }
                                          return null;
                                        },

                                        // validation: ValidationBuilder()
                                        //     .minLength(2)
                                        //     .build(),
                                      ),
                                      Text(context.lwTranslate.adminUserDeta,
                                          // "Admin User Details",
                                          style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 14),
                                          textAlign: TextAlign.center),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      InputField(
                                        labelText: context.lwTranslate.username,
                                        prefixIcon:
                                            const Icon(Icons.account_box),
                                        onSaved: (String? value) {
                                          formInputData['username'] = value;
                                        },
                                        validation: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .lwTranslate.fieldRequired;
                                          }
                                          if (value.length < 2) {
                                            return context
                                                .lwTranslate.mustBe2Character;
                                          }

                                          return null;
                                        },
                                      ),
                                      InputField(
                                        labelText:
                                            context.lwTranslate.firstName,
                                        prefixIcon: const Icon(Icons.person),
                                        onSaved: (String? value) {
                                          formInputData['first_name'] = value;
                                        },
                                        validation: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return context
                                              .lwTranslate.fieldRequired;
                                        }

                                        return null;
                                      },

                                        // validation: ValidationBuilder()
                                        //     .minLength(1)
                                        //     .build(),
                                      ),
                                      InputField(
                                        labelText: context.lwTranslate.lastName,
                                        prefixIcon: const Icon(Icons.person),
                                        onSaved: (String? value) {
                                          formInputData['last_name'] = value;
                                        },
                                        validation: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .lwTranslate.fieldRequired;
                                          }
                                          return null;
                                        },
                                        // validation: ValidationBuilder()
                                        //     .minLength(1)
                                        //     .build(),
                                      ),
                                      InputField(
                                        labelText:
                                            context.lwTranslate.mobileNumber,
                                        inputType: TextInputType.phone,
                                        prefixIcon:
                                            const Icon(Icons.phone_android),
                                        onSaved: (String? value) {
                                          formInputData['mobile_number'] =
                                              value;
                                        },
                                        validation: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .lwTranslate.fieldRequired;
                                          }
                                          if (value.length < 9) {
                                            return context
                                                .lwTranslate.mustBe9Character;
                                          }
                                          return null;
                                        },
                                        // validation: ValidationBuilder()
                                        //     .minLength(9)
                                        //     .build(),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Text(
                                            context
                                                .lwTranslate.mobileNumbCountry,
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11),
                                            textAlign: TextAlign.center),
                                      ),
                                      InputField(
                                        labelText:
                                            // "Email",
                                            context.lwTranslate.email,
                                        inputType: TextInputType.emailAddress,
                                        prefixIcon:
                                            const Icon(Icons.alternate_email),
                                        onSaved: (String? value) {
                                          formInputData['email'] = value;
                                        },
                                        validation: ValidationBuilder(
                                          requiredMessage: context
                                              .lwTranslate.fieldRequired,
                                        )
                                            .email(context
                                                .lwTranslate.pleaseEntValEmail)
                                            .build(),
                                      ),
                                      InputField(
                                        placeholder:
                                            context.lwTranslate.password,
                                        labelText: context.lwTranslate.password,
                                        password: !isPasswordVisible,
                                        validation: (String? value) {
                                        if (value == null || value.isEmpty) {
                                          return context
                                              .lwTranslate.fieldRequired;
                                        }
                                        if (value.length < 8) {
                                          return context
                                              .lwTranslate.mustBe8Character;
                                        }

                                        return null;
                                      },

                                        // validation: ValidationBuilder()
                                        //     .minLength(8)
                                        //     .build(),
                                        prefixIcon: const Icon(Icons.key),
                                        onSaved: (String? value) {
                                          formInputData['password'] = value;
                                        },
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      InputField(
                                        placeholder:
                                            context.lwTranslate.confirmPassword,
                                        labelText:
                                            context.lwTranslate.confirmPassword,
                                        password: !isPasswordVisibleCom,
                                        validation: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .lwTranslate.fieldRequired;
                                          }
                                          if (value.length < 8) {
                                            return context
                                                .lwTranslate.mustBe8Character;
                                          }
                                          if (value !=
                                              formInputData['password']) {
                                            return context.lwTranslate
                                                .passwordConfirMatch;
                                          }
                                          return null;
                                        },
                                        prefixIcon: const Icon(Icons.key),
                                        onSaved: (String? value) {
                                          formInputData[
                                              'password_confirmation'] = value;
                                        },
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isPasswordVisibleCom
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordVisibleCom =
                                                  !isPasswordVisibleCom;
                                            });
                                          },
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isChecked,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                isChecked = value ?? false;
                                                formInputData[
                                                        'terms_and_conditions'] =
                                                    isChecked ? 'on' : '';
                                                _termsError = null;
                                              });
                                            },
                                          ),
                                          SizedBox(width: 15),
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  isChecked = !isChecked;
                                                  formInputData[
                                                          'terms_and_conditions'] =
                                                      isChecked ? 'on' : '';
                                                  _termsError = null;
                                                });
                                              },
                                              child: Text.rich(
                                                TextSpan(
                                                  text: context
                                                      .lwTranslate.agreeWith,
                                                  children: <InlineSpan>[
                                                    TextSpan(
                                                      text: context.lwTranslate
                                                          .userTermsCond,
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Scaffold(
                                                                    appBar: AppBar(
                                                                        title: Text(
                                                                      context
                                                                          .lwTranslate
                                                                          .termsAndCond,
                                                                    )),
                                                                    body: WebViewWidget(
                                                                        controller: WebViewController()
                                                                          ..setJavaScriptMode(
                                                                              JavaScriptMode.unrestricted)
                                                                          ..loadRequest(apiUrl(
                                                                            'terms-and-policies/user_terms',
                                                                            useApiUrl:
                                                                                false,
                                                                          ))),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationThickness: 2,
                                                        decorationColor:
                                                            app_theme.primary,
                                                      ),
                                                    ),
                                                    TextSpan(text: " , "),
                                                    TextSpan(
                                                      text: context.lwTranslate
                                                          .privacyCPolicy,
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          Scaffold(
                                                                    appBar: AppBar(
                                                                        title: Text(context
                                                                            .lwTranslate
                                                                            .privacyCPolicy)),
                                                                    body: WebViewWidget(
                                                                        controller: WebViewController()
                                                                          ..setJavaScriptMode(
                                                                              JavaScriptMode.unrestricted)
                                                                          ..loadRequest(apiUrl(
                                                                            'terms-and-policies/privacy_policy',
                                                                            useApiUrl:
                                                                                false,
                                                                          ))),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationThickness: 2,
                                                        decorationColor:
                                                            app_theme.primary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_termsError != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            _termsError!,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  )),
                              const SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: register,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    color: app_theme.primary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: Center(
                                      child: Text(
                                    // "Create Account",
                                    context.lwTranslate.createAcc,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(context.lwTranslate.alreadyHaveAnAccount,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  textAlign: TextAlign.center),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginPage()),
                                      (route) => false);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 15.0),
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade800,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                  child: Center(
                                      child: Text(
                                    context.lwTranslate.clickLogin,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
