import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

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
      decoration: app_theme.topBarDecoration(radius: 0),
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
                CupertinoIcons.back,
                color: app_theme.lavenderWhite,
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: app_theme.surfaceMuted,
                    child: Icon(
                      CupertinoIcons.person,
                      color: app_theme.iceBlue,
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
                        style: const TextStyle(
                          color: app_theme.lavenderWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.lastseen as String,
                        style: const TextStyle(
                          color: app_theme.secondary,
                        ),
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
