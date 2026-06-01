import 'package:flutter/material.dart';
import '/support/app_theme.dart' as app_theme;

class ChatNavbar extends StatefulWidget {
  final String? username;
  final String? lastseen;

  const ChatNavbar({
    super.key,
    this.username,
    this.lastseen,
  });

  @override
  State<ChatNavbar> createState() => _ChatNavbarState();
}

class _ChatNavbarState extends State<ChatNavbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: app_theme.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.username as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        widget.lastseen as String,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
