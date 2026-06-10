import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

///
/// App Logo Widget
class AppLogo extends StatelessWidget {
  final double height;
  const AppLogo({super.key, this.height = 250});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, child: app_theme.logoImage);
  }
}

class PageTitle extends StatelessWidget {
  final String title;
  const PageTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 25),
      child: Text(
        title,
        style: const TextStyle(fontSize: 30, color: app_theme.white),
      ),
    );
  }
}

class AppItemProgressIndicator extends StatelessWidget {
  final double? size;
  const AppItemProgressIndicator({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (size != null)
            ? Center(
                child: SizedBox(
                  height: size,
                  width: size,
                  child: const CircularProgressIndicator.adaptive(
                    strokeWidth: 1.5,
                  ),
                ),
              )
            : const CircularProgressIndicator.adaptive()
      ],
    );
  }
}

PreferredSizeWidget innerAppBar(
    {required String title,
    required BuildContext context,
    List<Widget>? actions,  TabBar? bottom}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    automaticallyImplyLeading: false,
    centerTitle: false,
    flexibleSpace: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: DecoratedBox(
        decoration: app_theme.topBarDecoration(radius: 28),
      ),
    ),
    leading: IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        CupertinoIcons.back,
        color: Colors.white,
      ),
    ),
    title: Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    ),
    actions: actions,
  );
}

/// confirmation dialog
///
void showActionableDialog(
  BuildContext context, {
  String? title,
  Widget? description,
  String? confirmActionText,
  String? cancelActionText,
  dynamic Function()? onConfirm,
  VoidCallback? onCancel,
}) {
  title ??= context.lwTranslate.areYouSure;
  // show the dialog
  if (isIOSPlatform()) {
    CupertinoAlertDialog iosDialog = CupertinoAlertDialog(
      title: Text(title),
      content: description, //(description != null) ? Text(description) : null,
      actions: <Widget>[
        if (confirmActionText != null)
          CupertinoDialogAction(
            child: Text(
              confirmActionText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
            onPressed: () {
              if (onConfirm != null) {
                if (onConfirm() != false) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        if (cancelActionText != null)
          CupertinoDialogAction(
            child: Text(cancelActionText,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).secondaryHeaderColor)),
            onPressed: () {
              Navigator.of(context).pop();
              if (onCancel != null) onCancel();
            },
          ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return iosDialog;
      },
    );
  }
  else
  {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: description, //(description != null) ? Text(description) : null,
      actions: [
        if (cancelActionText != null)
          TextButton(
            child: Text(cancelActionText,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(); // dismiss dialog
              if (onCancel != null) onCancel();
            },
          ),
        if (confirmActionText != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // dismiss dialog
              if (onConfirm != null) onConfirm();
            },
            child: Text(
              confirmActionText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor),
            ),
          ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class AppCachedNetworkImage extends StatelessWidget {
  const AppCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.height = 300,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const AppItemProgressIndicator(
        size: 20,
      ),
      errorWidget: (context, url, error) => const Icon(Icons.error),
      height: height,
      width: width,
      // alignment: Alignment.center,
      fit: fit,
    );
  }
}

CachedNetworkImageProvider appCachedNetworkImageProvider({required String imageUrl}) {
  return CachedNetworkImageProvider(imageUrl);
}


