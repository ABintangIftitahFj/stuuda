import 'package:flutter/material.dart';
import 'package:whatsjet_demo/services/utils.dart';
import '../../support/app_theme.dart' as app_theme;

AppBar mainAppBarWidget(
    {String? title,
    List<Widget>? actionWidgets,
    int notificationCount = 0,
    TabBar? tabBar,
    Color? back,
    bool backbutton = true,
    required BuildContext context}) {
  return AppBar(
    backgroundColor: back,
    toolbarOpacity: 0.6,
    /*   leading: Builder(builder: (context) {
              return IconButton(
                icon: Icon(CupertinoIcons.list_dash),
                onPressed: () => Scaffold.of(context).openDrawer(),
              );
            }), */
    // backgroundColor: app_theme.topAndBottomBar,
    elevation: 0,
    title: title != null
        ? Text(title)
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
    bottom: tabBar, automaticallyImplyLeading: backbutton,
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
