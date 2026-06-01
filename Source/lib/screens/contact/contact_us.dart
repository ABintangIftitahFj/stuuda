import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import '../../common/widgets/common.dart';
import '../../components/input_field.dart';
import '../../components/Email_validator.dart';
import '../../services/utils.dart';
import '../../support/app_theme.dart' as app_theme;

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: innerAppBar(
        title: context.lwTranslate.contactUs,
        context: context,
      ),
      body: Stack(children: [
        SizedBox.expand(
          child: Image.asset(
            'assets/images/ic_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(2, 2),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 30, bottom: 40, right: 15, left: 15),
                      child: Column(
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    context.lwTranslate.contactUs,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                InputField(
                                  labelText: context.lwTranslate.fullName,
                                  prefixIcon: const Icon(Icons.person),
                                  validation:
                                      ValidationBuilder().minLength(3).build(),
                                ),
                                InputField(
                                  labelText: context.lwTranslate.email,
                                  validation: (value) => isValidEmail(value)
                                      ? null
                                      : context.lwTranslate.enterValidAddress,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  onChanged: (text) {},
                                ),
                                InputField(
                                  labelText: context.lwTranslate.subject,
                                  validation:
                                      ValidationBuilder().minLength(6).build(),
                                  prefixIcon:
                                      const Icon(Icons.menu_book_outlined),
                                ),
                                InputField(
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    _formKey.currentState?.save();
                    if (_formKey.currentState!.validate()) {}
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: app_theme.primary,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: !isLoading
                          ? Text(
                              context.lwTranslate.submit,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const CircularProgressIndicator(
                              color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
