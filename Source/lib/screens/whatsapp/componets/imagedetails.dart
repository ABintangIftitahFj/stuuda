import 'dart:io';

import 'package:flutter/material.dart';
import 'package:whatsjet_demo/services/utils.dart';

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
        backgroundColor: const Color.fromRGBO(0, 128, 105, 1),
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Hero(
          tag: context.lwTranslate.image,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(widget.filepath),
                fit: BoxFit.cover,
              )),
        ),
      ),
    );
  }
}
