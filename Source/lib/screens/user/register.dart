import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:form_validator/form_validator.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/services/data_transport.dart' as data_transport;
import 'package:stundaa/services/globalurls.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'login.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? ontap;

  const RegisterPage({super.key, this.ontap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
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
                  (route) => false,
                );
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

  void _openPolicyPage(String title, Uri url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(url),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    auth.redirectIfAuthenticated(context);
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
                decoration: app_theme.glowOrbDecoration(
                  alignment: const Alignment(0, -0.85),
                  radius: 0.65,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    decoration: app_theme.glassCardDecoration(radius: 30),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
                      child: Column(
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
                              'Premium onboarding',
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
                            'Create Account',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontSize: 28,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start managing your time better today.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 14,
                                  color: app_theme.iceBlue,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                InputField(
                                  labelText: context.lwTranslate.vendorCompName,
                                  helperText: context.lwTranslate.mustBe2Character,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.building_2_fill,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['vendor_title'] = value;
                                  },
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    if (value.length < 2) {
                                      return context
                                          .lwTranslate.mustBe2Character;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  context.lwTranslate.adminUserDeta,
                                  style: const TextStyle(
                                    color: app_theme.iceBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  labelText: context.lwTranslate.username,
                                  helperText: context.lwTranslate.mustBe2Character,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person_crop_circle_badge_plus,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['username'] = value;
                                  },
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    if (value.length < 2) {
                                      return context
                                          .lwTranslate.mustBe2Character;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  labelText: context.lwTranslate.firstName,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['first_name'] = value;
                                  },
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  labelText: context.lwTranslate.lastName,
                                  prefixIcon: const Icon(
                                    Icons.badge_outlined,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['last_name'] = value;
                                  },
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  labelText: context.lwTranslate.mobileNumber,
                                  inputType: TextInputType.phone,
                                  prefixIcon: const Icon(
                                    Icons.phone_android_outlined,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['mobile_number'] = value;
                                  },
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    if (value.length < 9) {
                                      return context
                                          .lwTranslate.mustBe9Character;
                                    }
                                    return null;
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 12),
                                  child: Text(
                                    context.lwTranslate.mobileNumbCountry,
                                    style: const TextStyle(
                                      color: app_theme.secondary,
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                InputField(
                                  labelText: context.lwTranslate.email,
                                  inputType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(
                                    Icons.alternate_email,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['email'] = value;
                                  },
                                  validation: ValidationBuilder(
                                    requiredMessage:
                                        context.lwTranslate.fieldRequired,
                                  )
                                      .email(
                                          context.lwTranslate.pleaseEntValEmail)
                                      .build(),
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  placeholder: context.lwTranslate.password,
                                  labelText: context.lwTranslate.password,
                                  password: !isPasswordVisible,
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    if (value.length < 8) {
                                      return context
                                          .lwTranslate.mustBe8Character;
                                    }
                                    return null;
                                  },
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['password'] = value;
                                  },
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: app_theme.iceBlue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                InputField(
                                  placeholder:
                                      context.lwTranslate.confirmPassword,
                                  labelText:
                                      context.lwTranslate.confirmPassword,
                                  password: !isPasswordVisibleCom,
                                  validation: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return context.lwTranslate.fieldRequired;
                                    }
                                    if (value.length < 8) {
                                      return context
                                          .lwTranslate.mustBe8Character;
                                    }
                                    if (value != formInputData['password']) {
                                      return context
                                          .lwTranslate.passwordConfirMatch;
                                    }
                                    return null;
                                  },
                                  prefixIcon: const Icon(
                                    Icons.verified_user_outlined,
                                    color: app_theme.iceBlue,
                                  ),
                                  onSaved: (String? value) {
                                    formInputData['password_confirmation'] =
                                        value;
                                  },
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisibleCom
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: app_theme.iceBlue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisibleCom =
                                            !isPasswordVisibleCom;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Checkbox(
                                      value: isChecked,
                                      activeColor: app_theme.primary,
                                      checkColor: app_theme.black,
                                      side: const BorderSide(
                                        color:
                                            Color.fromRGBO(167, 223, 255, 0.32),
                                      ),
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
                                    const SizedBox(width: 10),
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
                                            text: context.lwTranslate.agreeWith,
                                            style: const TextStyle(
                                              color: app_theme.secondary,
                                              height: 1.5,
                                            ),
                                            children: <InlineSpan>[
                                              TextSpan(
                                                text: context
                                                    .lwTranslate.userTermsCond,
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _openPolicyPage(
                                                          context.lwTranslate
                                                              .termsAndCond,
                                                          apiUrl(
                                                            'terms-and-policies/user_terms',
                                                            useApiUrl: false,
                                                          ),
                                                        );
                                                      },
                                                style: const TextStyle(
                                                  color: app_theme.cyanGlow,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationThickness: 1.6,
                                                  decorationColor:
                                                      app_theme.cyanGlow,
                                                ),
                                              ),
                                              const TextSpan(text: ' , '),
                                              TextSpan(
                                                text: context
                                                    .lwTranslate.privacyCPolicy,
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        _openPolicyPage(
                                                          context.lwTranslate
                                                              .privacyCPolicy,
                                                          apiUrl(
                                                            'terms-and-policies/privacy_policy',
                                                            useApiUrl: false,
                                                          ),
                                                        );
                                                      },
                                                style: const TextStyle(
                                                  color: app_theme.cyanGlow,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationThickness: 1.6,
                                                  decorationColor:
                                                      app_theme.cyanGlow,
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
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _termsError!,
                                      style: const TextStyle(
                                        color: app_theme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26),
                          GestureDetector(
                            onTap: register,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: app_theme.primaryGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(29, 161, 255, 0.45),
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: app_theme.black,
                                      ),
                                    )
                                  : Text(
                                      context.lwTranslate.createAcc,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: app_theme.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            context.lwTranslate.alreadyHaveAnAccount,
                            style: const TextStyle(
                              color: app_theme.secondary,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                                (route) => false,
                              );
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
                                context.lwTranslate.clickLogin,
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
