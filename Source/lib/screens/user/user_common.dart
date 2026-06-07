import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'package:stundaa/common/widgets/common.dart';

class ProfileImageView extends StatelessWidget {
  const ProfileImageView(
      {super.key, required this.imageUrl, this.actions, this.title});
  final String imageUrl;
  final Text? title;
  final List<Widget>? actions;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title,
        actions: actions,
        automaticallyImplyLeading: false,
        leading: InkWell(
          onTap: () async {
            Navigator.pop(context);
          },
          child: const Icon(
            CupertinoIcons.back,
            size: 24,
          ),
        ),
      ),
      body: PhotoView(
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.contained * 3,
        imageProvider: appCachedNetworkImageProvider(
          imageUrl: imageUrl,
        ),
      ),
    );
  }
}
