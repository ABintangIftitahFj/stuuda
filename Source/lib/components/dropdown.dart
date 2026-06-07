import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class CustomDropdown extends StatefulWidget {
  final String labelText;
  final void Function(String? text)? onChanged;
  final void Function(String? text)? onSaved;
  final dynamic listItems;
  final bool autofocus;
  final bool showOptionKeyInBracket;
  final String optionKeyName;
  final String optionLabelName;
  final String? value;
  final String? Function(String? value)? validation;
  final EdgeInsetsGeometry padding;
  const CustomDropdown(
      {super.key,
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
      this.padding = const EdgeInsets.only(top: 8, bottom: 8)});

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();
  List<dynamic> filteredItems = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedValue = widget.value;
    });

    filteredItems = widget.listItems;
  }

  @override
  Widget build(BuildContext context) {
    if ((selectedValue == '') || (selectedValue == 'null')) {
      selectedValue = null;
    }

    return Padding(
      padding: widget.padding,
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Text(
            widget.labelText,
            style: const TextStyle(
              fontSize: 14,
              color: app_theme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          value: selectedValue,
          buttonStyleData: const ButtonStyleData(
            padding: EdgeInsets.symmetric(horizontal: 12),
            height: 56,
            width: 500,
            decoration: BoxDecoration(
              color: Color.fromRGBO(255, 255, 255, 0.055),
              borderRadius: BorderRadius.all(Radius.circular(18)),
              border: Border.fromBorderSide(
                BorderSide(color: Color.fromRGBO(167, 223, 255, 0.16)),
              ),
            ),
          ),
          dropdownStyleData: const DropdownStyleData(
            decoration: BoxDecoration(
              color: app_theme.surface,
              borderRadius: BorderRadius.all(Radius.circular(18)),
              border: Border.fromBorderSide(
                BorderSide(color: Color.fromRGBO(167, 223, 255, 0.16)),
              ),
            ),
            maxHeight: 200,
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 50,
          ),
          onChanged: (newValue) {
            setState(() {
              selectedValue = newValue;
            });
            if (widget.onChanged != null) {
              widget.onChanged!(newValue);
            }
          },
          items: _buildSelectOptions(
            filteredItems,
            keyName: widget.optionKeyName,
            valueName: widget.optionLabelName,
            showKeyInBracket: widget.showOptionKeyInBracket,
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              textEditingController.clear();
              setState(() {
                filteredItems = widget.listItems;
              });
            }
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildSelectOptions(
    selectOptions, {
    keyName = 'id',
    valueName = 'value',
    showKeyInBracket = false,
  }) {
    if (selectOptions.isEmpty) {
      return [
        DropdownMenuItem<String>(
          value: null,
          child: Text(
            context.lwTranslate.noResultFound,
            style: TextStyle(
              fontSize: 14,
              color: app_theme.secondary,
            ),
          ),
        ),
      ];
    }
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
    List<DropdownMenuItem<String>>? newItems = [];
    processedOptions.forEach((index, value) {
      newItems.add(DropdownMenuItem(
        value: index.toString(),
        child: Text(
          value.toString(),
          style: TextStyle(
            fontSize: 14,
            color: app_theme.lavenderWhite,
          ),
        ),
      ));
    });
    return newItems;
  }
}

class MultiDropdownCustom extends StatefulWidget {
  final String labelText;
  final void Function(List<String> selectedValues)? onChanged;
  final List<dynamic> listItems;
  final String optionKeyName;
  final String optionLabelName;
  final List<String> values;
  final EdgeInsetsGeometry padding;

  const MultiDropdownCustom({
    super.key,
    this.labelText = '',
    this.onChanged,
    this.listItems = const [],
    this.optionKeyName = 'id',
    this.optionLabelName = 'value',
    this.values = const [],
    this.padding = const EdgeInsets.only(top: 8, bottom: 8),
  });

  @override
  State<MultiDropdownCustom> createState() => _MultiDropdownCustomState();
}

class _MultiDropdownCustomState extends State<MultiDropdownCustom> {
  List<String> selectedValues = [];

  @override
  void initState() {
    super.initState();
    selectedValues = widget.values;
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.listItems.map<DropdownItem<String>>((item) {
      return DropdownItem<String>(
        label: item[widget.optionLabelName].toString(),
        value: item[widget.optionKeyName].toString(),
      );
    }).toList();

    return Padding(
      padding: widget.padding,
      child: MultiDropdown<String>(
        items: items,
        onSelectionChange: (selectedItems) {
          setState(() {
            selectedValues = selectedItems.map((item) => item).toList();
          });
          if (widget.onChanged != null) {
            widget.onChanged!(selectedValues);
          }
        },
        itemBuilder: (DropdownItem<String> item, index, select) {
          return ListTile(
            title: Text(
              item.label,
              style: const TextStyle(
                fontSize: 14,
                color: app_theme.lavenderWhite,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: select,
          );
        },
        dropdownDecoration: DropdownDecoration(
          marginTop: 8.0,
          backgroundColor: app_theme.surface,
          elevation: 4.0,
          borderRadius: BorderRadius.circular(12),
          maxHeight: 400,
        ),
        searchEnabled: true,
        maxSelections: 100,
      ),
    );
  }
}

class CustomMultiDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<String> selectedValues;
  final void Function(List<String>) onSelectionChanged;

  const CustomMultiDropdown({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelectionChanged,
  });

  @override
  State<CustomMultiDropdown> createState() => _CustomMultiDropdownState();
}

class _CustomMultiDropdownState extends State<CustomMultiDropdown> {
  List<String> selectedIds = [];

  @override
  void initState() {
    super.initState();
    selectedIds = widget.selectedValues;
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        widget.items.where((item) => selectedIds.contains(item['id'])).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final newSelections = await _showMultiSelectDialog(context);
            if (newSelections != null) {
              setState(() {
                selectedIds = newSelections;
              });
              widget.onSelectionChanged(selectedIds);
            }
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color.fromRGBO(167, 223, 255, 0.16),
              ),
              color: const Color.fromRGBO(255, 255, 255, 0.055),
            ),
            child: Wrap(
              spacing: 5.0,
              runSpacing: 6.0,
              children: selectedItems.isNotEmpty
                  ? selectedItems.map((item) {
                      final Color textColor =
                          HexColorCustom.fromHex(item['textColor']);
                      final Color bgColor =
                          HexColorCustom.fromHex(item['bgColor']);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: bgColor,
                          border: Border.all(
                            color: const Color.fromRGBO(167, 223, 255, 0.16),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 5),
                          child: Text(
                            item['value'].toString(),
                            style: TextStyle(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList()
                  : [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          context.lwTranslate.selectLable,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: app_theme.secondary,
                          ),
                        ),
                      )
                    ],
            ),
          ),
        ),
      ],
    );
  }

  Future<List<String>?> _showMultiSelectDialog(BuildContext context) async {
    final items = widget.items;
    List<String> tempSelectedIds = List.from(selectedIds);
    return await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: app_theme.surface,
          insetPadding: EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            context.lwTranslate.selectLable,
            style: const TextStyle(color: app_theme.lavenderWhite),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: items.map((item) {
                    final String id = item['id'].toString();
                    final String label = item['value'].toString();
                    final Color textColor =
                        HexColorCustom.fromHex(item['textColor'].toString());
                    final Color bgColor =
                        HexColorCustom.fromHex(item['bgColor']);
                    final bool isSelected = tempSelectedIds.contains(id);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            tempSelectedIds.remove(id);
                          } else {
                            tempSelectedIds.add(id);
                          }
                        });
                      },
                      child: Chip(
                        side: BorderSide(
                          color: const Color.fromRGBO(167, 223, 255, 0.16),
                          width: 1.0,
                        ),
                        backgroundColor: bgColor,
                        label: Text(
                          label,
                          style: TextStyle(color: textColor),
                        ),
                        avatar: isSelected
                            ? const CircleAvatar(
                                backgroundColor: Colors.transparent,
                                child: Icon(
                                  Icons.check_circle,
                                  color: app_theme.primary,
                                  size: 20,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.lwTranslate.cancel,
                style: const TextStyle(color: app_theme.secondary),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(
                  app_theme.cyanGlow,
                ),
              ),
              onPressed: () => Navigator.pop(context, tempSelectedIds),
              child: Text(
                context.lwTranslate.ok,
                style: const TextStyle(color: app_theme.black),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HexColorCustom extends Color {
  HexColorCustom(final String hexColor) : super(_getColorFromHex(hexColor));
  static int _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return 0xFF000000;
    }
    final cleanedHexColor = hexColor.replaceAll('#', '');
    if (cleanedHexColor.length == 6) {
      return int.parse('FF$cleanedHexColor', radix: 16);
    } else {
      return 0xFF000000;
    }
  }

  static Color fromHex(String? hexColor) {
    return HexColorCustom(hexColor ?? '#000000');
  }
}
