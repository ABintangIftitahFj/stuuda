import 'package:flutter/material.dart';

final Widget logoImage = Image.asset(
  'assets/images/logo_stundaa.png',
  fit: BoxFit.contain,
);

const AssetImage backgroundImage = AssetImage(
  'assets/images/ic_background.png',
);

const AssetImage chatBackgroundImage = AssetImage(
  'assets/images/stundaa_bg.jpeg',
);

const Color black = Color(0xFF02040A);
const Color white = Color(0xFFEEF0FF);
const Color green = Colors.green;
const Color primary = Color(0xFF1DA1FF);
const Color cyanGlow = Color(0xFF49C8FF);
const Color iceBlue = Color(0xFFA7DFFF);
const Color deepNavy = Color(0xFF06111F);
const Color lavenderWhite = Color(0xFFEEF0FF);
const Color sidebarBgColor = deepNavy;
const Color backgroundColor = black;
const Color surface = Color(0xFF0B1627);
const Color surfaceElevated = Color(0xFF102034);
const Color surfaceMuted = Color(0xFF15263B);
const Color secondary = Color(0xFF8FB7D9);
const Color error = Color(0xFFF87171);
const Color success = Color(0xFF36D399);
const Color warning = Color(0xFFFBBF24);
const Color info = Color(0xFF38BDF8);
const Color outlineSoft = Color.fromRGBO(167, 223, 255, 0.16);
const Color outlineStrong = Color.fromRGBO(167, 223, 255, 0.24);

const LinearGradient primaryGradient = LinearGradient(
  colors: [
    Color(0xFF1DA1FF),
    Color(0xFF49C8FF),
    Color(0xFFBDEEFF),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient pageBackgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF02040A),
    Color(0xFF06111F),
    Color(0xFF09192C),
  ],
);

const LinearGradient cardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromRGBO(29, 161, 255, 0.16),
    Color.fromRGBO(255, 255, 255, 0.05),
  ],
);

BoxDecoration appBackgroundDecoration() {
  return const BoxDecoration(
    gradient: pageBackgroundGradient,
  );
}

BoxDecoration appScaffoldDecoration() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF02040A),
        Color(0xFF07111E),
        Color(0xFF0B1D30),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
  );
}

BoxDecoration glowOrbDecoration({
  Alignment alignment = Alignment.topCenter,
  double radius = 0.55,
}) {
  return BoxDecoration(
    gradient: RadialGradient(
      center: alignment,
      radius: radius,
      colors: const [
        Color.fromRGBO(29, 161, 255, 0.24),
        Color.fromRGBO(73, 200, 255, 0.10),
        Colors.transparent,
      ],
    ),
  );
}

BoxDecoration secondaryOrbDecoration({
  Alignment alignment = const Alignment(0.88, -0.92),
  double radius = 0.6,
}) {
  return BoxDecoration(
    gradient: RadialGradient(
      center: alignment,
      radius: radius,
      colors: const [
        Color.fromRGBO(130, 195, 255, 0.16),
        Color.fromRGBO(73, 200, 255, 0.08),
        Colors.transparent,
      ],
    ),
  );
}

BoxDecoration glassCardDecoration({double radius = 28}) {
  return BoxDecoration(
    gradient: cardGradient,
    color: const Color.fromRGBO(255, 255, 255, 0.08),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: const Color.fromRGBO(167, 223, 255, 0.22),
    ),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.35),
        blurRadius: 40,
        offset: Offset(0, 20),
      ),
      BoxShadow(
        color: Color.fromRGBO(29, 161, 255, 0.12),
        blurRadius: 30,
        offset: Offset(0, 0),
      ),
    ],
  );
}

BoxDecoration doubleBezelShellDecoration({double radius = 30}) {
  return BoxDecoration(
    color: const Color.fromRGBO(255, 255, 255, 0.03),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: outlineSoft),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.24),
        blurRadius: 30,
        offset: Offset(0, 18),
      ),
    ],
  );
}

BoxDecoration topBarDecoration({double radius = 30}) {
  return BoxDecoration(
    gradient: const LinearGradient(
      colors: [
        Color(0xD90B1627),
        Color(0xC9102034),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: outlineSoft),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.28),
        blurRadius: 22,
        offset: Offset(0, 14),
      ),
    ],
  );
}

BoxDecoration insetPanelDecoration({double radius = 24}) {
  return BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: outlineStrong),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(255, 255, 255, 0.04),
        blurRadius: 0,
        spreadRadius: 0.5,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.28),
        blurRadius: 18,
        offset: Offset(0, 12),
      ),
    ],
  );
}
