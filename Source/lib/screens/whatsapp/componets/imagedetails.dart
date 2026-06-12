import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

// ignore: must_be_immutable
class Imagedetails extends StatefulWidget {
  /// Local file path (legacy). If imageUrl is provided, that takes precedence.
  String filepath;

  /// Network image URL. If set, filepath is ignored.
  final String? imageUrl;

  Imagedetails({super.key, this.filepath = '', this.imageUrl});

  @override
  State<Imagedetails> createState() => _ImagedetailsState();
}

class _ImagedetailsState extends State<Imagedetails> {
  bool get _isNetwork =>
      widget.imageUrl != null && widget.imageUrl!.startsWith('http');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: app_theme.backgroundColor,
        foregroundColor: app_theme.lavenderWhite,
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: app_theme.lavenderWhite),
        ),
      ),
      body: _isNetwork
          ? PhotoView(
              imageProvider: NetworkImage(widget.imageUrl!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
              backgroundDecoration:
                  const BoxDecoration(color: Colors.black),
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(color: app_theme.cyanGlow),
              ),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: app_theme.error, size: 48),
                    SizedBox(height: 8),
                    Text('Failed to load image',
                        style: TextStyle(color: app_theme.secondary)),
                  ],
                ),
              ),
            )
          : PhotoView(
              imageProvider: FileImage(File(widget.filepath)),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 4,
              backgroundDecoration:
                  const BoxDecoration(color: Colors.black),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image_outlined,
                        color: app_theme.error, size: 48),
                    SizedBox(height: 8),
                    Text('File not found',
                        style: TextStyle(color: app_theme.secondary)),
                  ],
                ),
              ),
            ),
    );
  }
}
