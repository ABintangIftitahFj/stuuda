import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:stundaa/services/utils.dart';

class PdfPickerPage extends StatefulWidget {
  final String pickedFilePath;
  final String filename;

  const PdfPickerPage(
      {super.key, required this.pickedFilePath, required this.filename});
  @override
  State<PdfPickerPage> createState() => PdfPickerPageState();
}

class PdfPickerPageState extends State<PdfPickerPage> {
  void openPdfFile() {
    OpenFilex.open(widget.pickedFilePath);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Text(widget.filename),
          TextButton(
            onPressed: openPdfFile,
            child:  Text(context.lwTranslate.open),
          ),
        ],
      ),
    );
  }
}
