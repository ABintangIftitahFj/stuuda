import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class InputField extends StatelessWidget {
  final String? placeholder;
  final String? labelText;
  final String? helperText;
  final String? initialValue;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final void Function()? onTap;
  final void Function(String? text)? onChanged;
  final TextEditingController? controller;
  final bool autofocus;
  final bool password;
  final bool readOnly;
  final void Function(String? text)? onSaved;
  final String? Function(String? value)? validation;
  final Color? borderColor;
  final TextInputType? inputType;
  final int? maxLines;
  final int? minLines;
  final int? maxlength;
  final InputBorder? focusborder;
  final InputBorder? unfocusborder;
  final InputBorder? errorborder;

  const InputField({
    super.key,
    this.placeholder = '',
    this.labelText = '',
    this.helperText = '',
    this.suffixIcon,
    this.initialValue,
    this.prefixIcon,
    this.onSaved,
    this.onTap,
    this.inputType = TextInputType.text,
    this.onChanged,
    this.validation,
    this.maxLines,
    this.autofocus = false,
    this.password = false,
    this.readOnly = false,
    this.borderColor,
    this.controller,
    this.maxlength,
    this.focusborder,
    this.unfocusborder,
    this.errorborder,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      initialValue: controller == null ? initialValue : null,
      validator: validation,
      keyboardType: inputType,
      maxLines: password ? 1 : maxLines,
      minLines: minLines,
      obscureText: password,
      onSaved: onSaved,
      onTap: onTap,
      onChanged: onChanged,
      controller: controller,
      autofocus: autofocus,
      style: GoogleFonts.plusJakartaSans(
        height: 1.5,
        fontSize: 16.0,
        color: app_theme.lavenderWhite,
      ),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 16.0,
          color: app_theme.iceBlue,
          fontWeight: FontWeight.w500,
        ),
        helperText: helperText,
        hintText: placeholder,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: app_theme.secondary,
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: app_theme.error,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(3.0),
                child: suffixIcon,
              )
            : null,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.all(3.0),
                child: prefixIcon,
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: borderColor ?? app_theme.cyanGlow, width: 1.6),
          borderRadius: BorderRadius.circular(18.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromRGBO(167, 223, 255, 0.22),
          ),
          borderRadius: BorderRadius.circular(18.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: app_theme.error, width: 1.5),
          borderRadius: BorderRadius.circular(18.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: app_theme.error, width: 1.5),
          borderRadius: BorderRadius.circular(18.0),
        ),
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.055),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      ),
      maxLength: maxlength,
    );
  }
}
