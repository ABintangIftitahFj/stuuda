import 'package:flutter/material.dart';

class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;

  SlideLeftRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const beginForward = Offset(1.0, 0.0); // From right to left
            const beginReverse = Offset(1.0, 0.0); // From left to right
            const end = Offset(0.0, 0.0); // Finish at the center
            const curve = Curves.easeInOut; // Smoother curve

            var tween = Tween(
              begin: animation.status == AnimationStatus.reverse
                  ? beginReverse // Back animation
                  : beginForward, // Forward animation
              end: end,
            ).chain(CurveTween(curve: curve));

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
          transitionDuration:
              const Duration(milliseconds: 200), // Adjust duration
        );
}
