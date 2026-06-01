import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:whatsjet_demo/screens/user/register.dart';
import '../../components/input_field.dart';
import '../../services/globalurls.dart';
import '../../services/utils.dart';
import '../../services/data_transport.dart' as data_transport;
import '../../services/auth.dart' as auth;
import '../../support/app_theme.dart' as app_theme;
import '../../common/widgets/common.dart';
import 'package:form_validator/form_validator.dart';

/// The scopes required by this application.
const List<String> scopes = <String>[
  'email',
  // 'https://www.googleapis.com/auth/contacts.readonly',
];

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
  bool _isLoadingForDemo = false;
  bool isPasswordVisible = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Optional clientId
    clientId:
        isIOSPlatform() ? configItem('social_logins.google.client_id') : null,
    scopes: scopes,
  );

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

  void demoLogin() async {
    formInputData['email'] = 'testcompany';
    formInputData['password'] = 'demopass12';

    setState(() {
      _isLoadingForDemo = true;
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
      _isLoadingForDemo = false;
    });
  }

  @override
  void initState() {
    super.initState();
    isPasswordVisible = false;
  }

  @override
  Widget build(BuildContext context) {
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Centers vertically
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
                              context.lwTranslate.login,
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
                                            context.lwTranslate.emailOrUsername,
                                        prefixIcon: const Icon(Icons.person),
                                        onSaved: (String? value) {
                                          formInputData['email'] = value;
                                        },
                                        validation: ValidationBuilder()
                                            .minLength(3)
                                            .build(),
                                      ),
                                      InputField(
                                        placeholder:
                                            context.lwTranslate.password,
                                        labelText: context.lwTranslate.password,
                                        password: !isPasswordVisible,
                                        validation: ValidationBuilder()
                                            .minLength(6)
                                            .build(),
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
                                    ],
                                  )),
                              const SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: login,
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
                                    child: !_isLoading
                                        ? Text(
                                            context.lwTranslate.login,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (configItem('demoMode',
                                      fallbackValue: false) ==
                                  true)
                                Column(
                                  children: [
                                    Text(
                                      context.lwTranslate.or,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      onTap: demoLogin,
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
                                          child: !_isLoadingForDemo
                                              ? Text(
                                                  context.lwTranslate
                                                      .demoCompanyLogin,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              : const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                  context.lwTranslate.dontHaveAcc,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                  textAlign: TextAlign.center),
                              const SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  navigatePage(
                                    context,
                                    RegisterPage(
                                      // skipMobileDialog: true,
                                    ),
                                  );
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
                                      context.lwTranslate.createNewAcc,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ),
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
