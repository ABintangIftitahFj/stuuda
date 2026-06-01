import 'package:flutter/material.dart';

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
      style: const TextStyle(
        height: 1.5,
        fontSize: 16.0,
      ),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontSize: 16.0,
          color: Colors.grey,
        ),
        helperText: helperText,
        hintText: placeholder,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          color: Colors.red,
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
          borderSide: BorderSide(color: borderColor ?? Colors.green, width: 2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      ),
      maxLength: maxlength,
    );
  }
}
