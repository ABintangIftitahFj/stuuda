import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

class AppBackgroundImage extends StatelessWidget {
  const AppBackgroundImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: app_theme.primaryGradient,
        image: DecorationImage(
          opacity: 0.4,
          image: app_theme.backgroundImage,
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 3,
          sigmaY: 3,
        ),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0)),
        ),
      ),
    );
  }
}
