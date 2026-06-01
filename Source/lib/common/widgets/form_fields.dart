// ignore_for_file: must_be_immutable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/support/app_theme.dart' as app_theme;

class SelectField extends StatelessWidget {
  final String labelText;
  final void Function(String? text)? onChanged;
  final void Function(String? text)? onSaved;
  final dynamic listItems;
  final bool autofocus;
  final bool showOptionKeyInBracket;
  final String optionKeyName;
  final String optionLabelName;
  String? value;
  final String? Function(String? value)? validation;

  SelectField({
    super.key,
    this.labelText = '',
    this.onChanged,
    this.onSaved,
    this.listItems,
    this.validation,
    this.autofocus = false,
    this.value,
    this.optionKeyName = 'id',
    this.optionLabelName = 'value',
    this.showOptionKeyInBracket = false,
  });

  @override
  Widget build(BuildContext context) {
    if ((value == '') || (value == 'null')) {
      value = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: app_theme.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: app_theme.primary),
          ),
        ),
        isExpanded: true,
        value: value,
        icon: const Icon(
          CupertinoIcons.chevron_down,
          size: 18,
        ),
        dropdownColor: Colors.white,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
        onChanged: (selectedValue) {
          value = selectedValue;
          if (onChanged != null) {
            onChanged!(selectedValue);
          }
        },
        onSaved: (selectedValue) {
          value = selectedValue;
          if (onSaved != null) {
            onSaved!(selectedValue);
          }
        },
        items: _buildSelectOptions(
          listItems,
          title: labelText,
          keyName: optionKeyName,
          valueName: optionLabelName,
          showKeyInBracket: showOptionKeyInBracket,
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSelectOptions(
    selectOptions, {
    title = '',
    keyName = 'id',
    valueName = 'value',
    showKeyInBracket = false,
  }) {
    Map processedOptions = {};
    if (selectOptions is List) {
      processedOptions = {
        for (var selectOption in selectOptions)
          if (selectOption is Map)
            selectOption[keyName].toString():
                selectOption[valueName].toString() +
                    ((showKeyInBracket == true &&
                            selectOption[keyName].toString() != '')
                        ? " (${selectOption[keyName].toString()})"
                        : '')
          else
            selectOption.toString(): selectOption.toString()
      };
    } else {
      processedOptions = selectOptions;
    }

    List<DropdownMenuItem<String>>? newItems = [
      DropdownMenuItem(
        enabled: false,
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
      ),
      const DropdownMenuItem(
        enabled: false,
        child: Divider(
          thickness: 1,
          color: Colors.grey,
        ),
      )
    ];

    processedOptions.forEach((index, value) {
      newItems.add(DropdownMenuItem(
        value: index.toString(),
        child: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ));
    });

    return newItems;
  }
}
