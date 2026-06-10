import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:stundaa/common/widgets/common.dart';
import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/components/email_validator.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/services/auth.dart' as auth;

import 'package:stundaa/repositories/common_repository.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final CommonRepository _commonRepository = CommonRepository();

  @override
  void initState() {
    super.initState();
    // Auto-fill from auth info
    _nameController = TextEditingController(
      text: auth.getAuthInfo('profile.full_name', ''),
    );
    _emailController = TextEditingController(
      text: auth.getAuthInfo('profile.email', ''),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isLoading = true;
      });

      try {
        await _commonRepository.submitContactForm(
          fullName: _nameController.text,
          email: _emailController.text,
          subject: _subjectController.text,
          message: _messageController.text,
        );
        if (mounted) {
          showSuccessMessage(context, context.lwTranslate.submittedSuccessfully);
          _subjectController.clear();
          _messageController.clear();
        }
      } catch (e) {
        if (mounted) {
          showErrorMessage(context, e.toString());
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: app_theme.backgroundColor,
      appBar: innerAppBar(
        title: context.lwTranslate.contactUs,
        context: context,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: app_theme.appBackgroundDecoration(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 540),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: app_theme.cardGradient,
                      color: app_theme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color.fromRGBO(167, 223, 255, 0.16),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
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
                              CupertinoIcons.chat_bubble_2,
                              color: app_theme.iceBlue,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.lwTranslate.contactUs,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: app_theme.lavenderWhite,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Tell us what you need. We will answer in the same STUNDAA tone.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: app_theme.secondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                InputField(
                                  controller: _nameController,
                                  labelText: context.lwTranslate.fullName,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person,
                                    color: app_theme.iceBlue,
                                  ),
                                  validation:
                                      ValidationBuilder().minLength(3).build(),
                                ),
                                InputField(
                                  controller: _emailController,
                                  labelText: context.lwTranslate.email,
                                  validation: (value) => isValidEmail(value)
                                      ? null
                                      : context.lwTranslate.enterValidAddress,
                                  prefixIcon: const Icon(
                                    CupertinoIcons.mail,
                                    color: app_theme.iceBlue,
                                  ),
                                  onChanged: (text) {},
                                ),
                                InputField(
                                  controller: _subjectController,
                                  labelText: context.lwTranslate.subject,
                                  validation:
                                      ValidationBuilder().minLength(3).build(),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.doc_text,
                                    color: app_theme.iceBlue,
                                  ),
                                ),
                                InputField(
                                  controller: _messageController,
                                  maxLines: null,
                                  minLines: 5,
                                  labelText: context.lwTranslate.message,
                                  placeholder: context.lwTranslate.messagee,
                                  validation:
                                      ValidationBuilder().minLength(6).build(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: _submitForm,
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: app_theme.primaryGradient,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(14)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(29, 161, 255, 0.35),
                                    blurRadius: 22,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: !isLoading
                                    ? Text(
                                        context.lwTranslate.submit,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: app_theme.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : const CircularProgressIndicator(
                                        color: app_theme.black,
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
