import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:stundaa/services/utils.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.phone_circle,
              size: 80,
              color: Colors.white24,
            ),
            const SizedBox(height: 16),
            Text(
              context.lwTranslate.noRecentCalls,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.lwTranslate.callHistoryWillAppear,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
