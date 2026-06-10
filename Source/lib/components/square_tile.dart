import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagepath;
  final double height;
  final VoidCallback onPressed;
  const SquareTile({super.key, required this.imagepath, required this.height,required this.onPressed,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromRGBO(218, 217, 217, 1)),
          borderRadius: BorderRadius.circular(10),
          // color: Colors.grey[200],
        ),
        height: height,
        child: Image.asset(imagepath),
      ),
    );
  }
}
