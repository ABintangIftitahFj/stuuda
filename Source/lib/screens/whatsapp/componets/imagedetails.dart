import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

// ignore: must_be_immutable
class Imagedetails extends StatefulWidget {
  String filepath;

  Imagedetails({super.key, required this.filepath});

  @override
  State<Imagedetails> createState() => _ImagedetailsState();
}

class _ImagedetailsState extends State<Imagedetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: app_theme.backgroundColor,
        foregroundColor: app_theme.lavenderWhite,
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: app_theme.lavenderWhite,
          ),
        ),
      ),
      body: Container(
        decoration: app_theme.appBackgroundDecoration(),
        child: Center(
          child: Hero(
            tag: context.lwTranslate.image,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(167, 223, 255, 0.16),
                    ),
                  ),
                  child: Image.file(
                    File(widget.filepath),
                    fit: BoxFit.cover,
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
