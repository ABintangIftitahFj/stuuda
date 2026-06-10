import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/services/utils.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;

AppBar mainAppBarWidget(
    {String? title,
    List<Widget>? actionWidgets,
    int notificationCount = 0,
    TabBar? tabBar,
    Color? back,
    bool backbutton = true,
    required BuildContext context}) {
  return AppBar(
    backgroundColor: Colors.transparent,
    toolbarOpacity: 1,
    /*   leading: Builder(builder: (context) {
              return IconButton(
                icon: Icon(CupertinoIcons.list_dash),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }), */
    // backgroundColor: app_theme.topAndBottomBar,
    elevation: 0,
    flexibleSpace: Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: DecoratedBox(
        decoration: app_theme.topBarDecoration(radius: 28),
      ),
    ),
    title: title != null
        ? Text(
            title,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          )
        : Padding(
            padding: const EdgeInsets.only(
              bottom: 12,
            ),
            child: SizedBox(
              height: 45,
              width: 80,
              child: app_theme.logoImage,
            ),
          ),
    /*     title: Text(
              configItem('appTitle'),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w100,
              ),
            ), */
    centerTitle: false,
    foregroundColor: app_theme.lavenderWhite,
    iconTheme: const IconThemeData(color: app_theme.lavenderWhite),
    bottom: tabBar,
    automaticallyImplyLeading: backbutton,
    leading: backbutton
        ? IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () => Navigator.of(context).pop(),
          )
        : null,
    actions: actionWidgets ??
        <Widget>[
          IconButton(
            icon: Container(
              margin: const EdgeInsets.only(right: 30),
            ),
            // tooltip: 'Show Snackbar',
            tooltip: context.lwTranslate.showSnackbar,
            onPressed: () {},
          ),
        ],
  );
}
