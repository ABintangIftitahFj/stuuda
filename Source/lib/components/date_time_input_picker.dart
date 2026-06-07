import 'package:stundaa/components/input_field.dart';
import 'package:stundaa/services/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimeInputPicker extends StatefulWidget {
  final String? placeholder;
  final String? labelText;
  final String? helperText;
  final String initialValue;
  final String minimumDate;
  final String maximumDate;
  final IconData? suffixIcon;
  final IconData? prefixIcon;
  final void Function()? onTap;
  final void Function(String? text)? onChanged;
  final void Function(String? text)? onSaved;
  final String? Function(String? value)? validation;
  const DateTimeInputPicker({
    super.key,
    this.placeholder = '',
    this.labelText = '',
    this.helperText = '',
    this.suffixIcon,
    this.initialValue = '',
    this.minimumDate = '',
    this.maximumDate = '',
    this.prefixIcon,
    this.onSaved,
    this.onTap,
    this.onChanged,
    this.validation,
  });

  @override
  State<DateTimeInputPicker> createState() => _DateTimeInputPickerState();
}

class _DateTimeInputPickerState extends State<DateTimeInputPicker> {
  TextEditingController dateInput = TextEditingController();

  DateTime minimumAllowedDOB = DateTime.now();
  DateTime maximumAllowedDOB = DateTime.now();
  DateTime userInputDOB = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    dateInput.text = widget.initialValue; //set the initial value of text field
    super.initState();
    minimumAllowedDOB = DateTime.tryParse(widget.minimumDate.toString()) ??
        DateTime.now().subtract(
          const Duration(days: 1),
        );
    maximumAllowedDOB = DateTime.tryParse(widget.maximumDate.toString()) ??
        DateTime.now().add(const Duration(days: 1));

    userInputDOB = DateTime.tryParse(dateInput.text) ?? maximumAllowedDOB;

    if ((minimumAllowedDOB.compareTo(userInputDOB) > 0) ||
        (maximumAllowedDOB.compareTo(userInputDOB) < 0)) {
      userInputDOB = maximumAllowedDOB;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputField(
        controller: dateInput,
        readOnly: true,
        labelText: widget.labelText,
        onSaved: widget.onSaved,
        onChanged: widget.onChanged,
        onTap: () async {
          if (isIOSPlatform()) {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext builder) {
                  return SizedBox(
                    height: MediaQuery.of(context).copyWith().size.height / 3,
                    // color: Colors.white,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      onDateTimeChanged: (picked) {
                        if (_formatDate(picked) !=
                            _formatDate(dateInput.text)) {
                          setState(() {
                            dateInput.text = picked.toString();
                            dateInput.text = _formatDate(
                                picked); //set output date to TextField value.
                          });
                        }
                      },
                      initialDateTime: userInputDOB,
                      minimumDate: minimumAllowedDOB,
                      maximumDate: maximumAllowedDOB,
                    ),
                  );
                });
          } else {
            //when click we have to show the datepicker
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: userInputDOB,
              firstDate: minimumAllowedDOB,
              lastDate: maximumAllowedDOB,
            );
            if (_formatDate(pickedDate) != _formatDate(dateInput.text)) {
              setState(() {
                dateInput.text = _formatDate(
                    pickedDate); //set output date to TextField value.
              });
            }
          }

          if (widget.onChanged != null) {
            widget.onChanged!(dateInput.text);
          }
        });
  }

  _formatDate(date) {
    return DateFormat('yyyy-MM-dd')
        .format((date is DateTime ? date : DateTime.tryParse(date)) ??
            DateTime.now())
        .toString();
  }
}
