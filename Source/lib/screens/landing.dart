// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../provider/contacts_provider.dart';
// import '../services/auth.dart';
// import '../services/pusher_service.dart';
// import '/screens/whatsapp/screens/whatsapp_chat.dart';
// import '/screens/myprofile.dart';
// import '/screens/settings/settings.dart';
// import '/services/utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import '/support/app_theme.dart' as app_theme;
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// import '/services/auth.dart' as auth;
// import '/screens/whatsapp/controller/chatbox_controller.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import '../services/global.dart';
//
//
// class LandingPage extends StatefulWidget {
//   const LandingPage({
//     super.key,
//     this.initialNotificationCount = 0,
//     this.initialActiveTab = 0,
//     this.skipMobileDialog = false,
//   });
//
//   final int initialNotificationCount;
//   final int initialActiveTab;
//   final bool skipMobileDialog;
//
//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }
//
// class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
//   int _currentIndex = 1;
//   int notificationCount = 0;
//   int chatCount = 5;
//   PusherChannelsFlutter pusher = PusherChannelsFlutter();
//   final ChatboxController controller = Get.put(ChatboxController());
//   String? userMobileNumber;
//   String _savedMobileNumber = '';
//   Widget? tabTitle;
//   bool _dialogShown = false;
//
//   final TextEditingController _mobileController = TextEditingController(
//     text: geUpdatedMobileNumber() != '' ? geUpdatedMobileNumber() : null,
//   );
//
//   @override
//   void initState() {
//     super.initState();
//     final contactProvider = Provider.of<ContactProvider>(context, listen: false);
//     final authToken = auth.getAuthToken();
//
//     final pusherService = PusherService();
//
//     pusherService.initPusher(auth.getAuthToken()).catchError((error) {
//       if (mounted) {
//         checkAndHandleCSRFExpiry(error, context);
//       }
//     });
//     pusherService.initPusher(authToken).then((_) {
//       if (mounted) {
//         setupContactListUpdates(pusherService, contactProvider);
//       }
//     });
//
//     // Show dialog only once after the first render
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!widget.skipMobileDialog &&
//           configItem('demoMode', fallbackValue: false) == true &&
//           !isMobileDialogShown) {
//         _showMobileNumberDialog(context, showSavedNumber: false);
//         if (mounted) {
//           setState(() {
//             _dialogShown = true;
//           });
//         }
//       }
//     });
//   }
//
//
//   @override
//   didChangeDependencies() {
//     super.didChangeDependencies();
//     _currentIndex = widget.initialActiveTab;
//     setTabTitle(_currentIndex);
//   }
//
//   Future<void> _loadSavedNumber() async {
//     final savedNumber = await getPreferences('user_mobile_number') ?? '';
//     if (mounted) {
//       setState(() {
//         _savedMobileNumber = savedNumber;
//         _mobileController.text = _savedMobileNumber;
//       });
//     }
//   }
//
//   void setupContactListUpdates(
//       PusherService pusherService, ContactProvider contactProvider) {
//     final channelName = "private-vendor-channel.${getAuthInfo('vendor_uid')}";
//     pusherService.subscribeToChannel(
//       channelName: channelName,
//       onEvent: (eventName, eventData) async {
//         pr(eventData);
//         if (eventName == 'VendorChannelBroadcast' &&
//             eventData['message_status'] == null) {
//           final contactUid = eventData['contactUid'];
//
//           // Check if this is a new contact not in our list
//           if (!contactProvider.contactExists(contactUid)) {
//             // Fetch full contact details for this new contact
//             await contactProvider.fetchSingleContact(contactUid);
//           } else {
//             // Existing contact - just update message
//             contactProvider.updateContactWithNewMessage(
//                  context,
//                 contactUid,
//                 eventData['lastMessageUid'],
//                 eventData['formatted_last_message_time']);
//           }
//           controller.getUserChatSend();
//         }else if(eventName == 'VendorChannelBroadcast' &&
//             eventData['message_status'] == "sent"){
//           controller.getUserChatSend();
//         }else if(eventName == 'VendorChannelBroadcast' &&
//             eventData['message_status'] == "read"){
//           controller.getUserChatSend();
//         }
//       },
//       onSubscriptionError: (error) {},
//     );
//   }
//
//   checkUserLoggedIn() async {
//     return isLoggedIn();
//   }
//
//   void setTabTitle(int i) {
//     if (mounted) {
//       // Check if widget is still mounted
//       setState(() {
//         switch (i) {
//           case 0:
//             tabTitle = Text(
//               context.lwTranslate.whatsAppChat,
//               style: TextStyle(color: Colors.white, fontSize: 14),
//             );
//             break;
//           case 1:
//             tabTitle = Text(
//               context.lwTranslate.whatsAppChat,
//               style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold),
//             );
//
//             break;
//           case 2:
//             tabTitle = Text(
//               context.lwTranslate.whatsAppChat,
//               style: TextStyle(color: Colors.white, fontSize: 14),
//             );
//
//             break;
//         }
//       });
//     }
//   }
//
//   void onTabTapped(int index) {
//     if (mounted) {
//       setState(() {
//         _currentIndex = index;
//         setTabTitle(index);
//       });
//     }
//   }
//
//   final List<Widget> _pages = [
//     // const Scaffold(),
//     const WhatsAppChat(),
//     // const Scaffold(),
//   ];
//
//   final List<IconData> _icons = [
//     // Icons.campaign,
//     CupertinoIcons.chat_bubble_2,
//     // Icons.info,
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<ContactProvider>(context);
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: app_theme.primary,
//         title: tabTitle,
//         iconTheme: const IconThemeData(color: Colors.white),
//         actions: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return SizedBox(
//                 width: 40,
//                 height: 40,
//                 child: PopupMenuButton<String>(
//                   offset: const Offset(0, 30),
//                   onSelected: (value) {}, // Required but can be empty
//                   itemBuilder: (BuildContext context) => [
//                     PopupMenuItem<String>(
//                       value: 'profile',
//                       onTap: () async {
//                         await Future.microtask(() {
//                           if (context.mounted) {
//                             navigatePage(context, const MyProfile());
//                           }
//                         });
//                       },
//                       child: Text(context.lwTranslate.profile),
//                     ),
//                     PopupMenuItem<String>(
//                       value: 'settings',
//                       onTap: () async {
//                         await Future.microtask(() {
//                           if (context.mounted) {
//                             navigatePage(context, const Settings());
//                           }
//                         });
//                       },
//                       child: Text(context.lwTranslate.settings),
//                     ),
//                     if (configItem('demoMode', fallbackValue: false) == true)
//                       PopupMenuItem<String>(
//                         value: 'addNumber',
//                         onTap: () async {
//                           await Future.microtask(() {
//                             if (context.mounted) {
//                               _showMobileNumberDialog(context, showSavedNumber: true);
//                             }
//                           });
//                         },
//                         child: Text(context.lwTranslate.addNumberForTest),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Scaffold(
//         body: _pages[_currentIndex],
//         bottomNavigationBar: CurvedNavigationBar(
//           index: widget.initialActiveTab,
//           backgroundColor: Colors.transparent,
//           color: app_theme.primary,
//           buttonBackgroundColor: app_theme.primary,
//           animationCurve: Curves.ease,
//           animationDuration: const Duration(milliseconds: 100),
//           height: 50,
//           items: List.generate(_icons.length, (index) {
//             return Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // if (index == 1)
//                     Stack(
//                       clipBehavior: Clip.none,
//                       children: [
//                         Icon(
//                           _icons[index],
//                           color: Colors.white,
//                           size: 30,
//                         ),
//                         if (provider.unreadMsgCount > 0)
//                           Positioned(
//                             right: -12,
//                             top: -12,
//                             child: Container(
//                               padding: const EdgeInsets.all(4),
//                               decoration: const BoxDecoration(
//                                 color: Colors.red,
//                                 shape: BoxShape.circle,
//                               ),
//                               constraints: const BoxConstraints(
//                                 minWidth: 18,
//                                 minHeight: 18,
//                               ),
//                               child: Text(
//                                 provider.unreadMsgCount.toString(),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                       ],
//                     )
//                   ],
//                 ),
//               ],
//             );
//           }),
//           onTap: (index) {
//             if (mounted) {
//               // Check if widget is still mounted
//               setState(() {
//                 _currentIndex = index;
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }
//
//   Future<void> _showMobileNumberDialog(BuildContext context,
//       {bool? showSavedNumber}) async {
//     if (isMobileDialogShown && !(showSavedNumber ?? false)) return;
//     if (!(showSavedNumber ?? false)) {
//       isMobileDialogShown = true;
//     }
//     if (showSavedNumber ?? false) {
//       await _loadSavedNumber();
//     } else {
//       if (mounted) {
//         setState(() {
//           _mobileController.clear();
//         });
//       }
//     }
//
//     final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10.0),
//           ),
//           insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
//           contentPadding: EdgeInsets.zero,
//           titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
//           actionsPadding: EdgeInsets.all(16),
//           title: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Text(
//                 context.lwTranslate.onlyForDemo,
//                 style: TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 8),
//               Text(
//                 context.lwTranslate.addYourMobileNumber,
//                 style: TextStyle(
//                     fontSize: 14,
//                     color: app_theme.primary,
//                     fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 8),
//                     Text(
//                       context.lwTranslate.youCanAddComma,
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                     ),
//                     SizedBox(height: 12),
//                     TextFormField(
//                       controller: _mobileController,
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                         labelText: context.lwTranslate.mobileNumber,
//                         labelStyle: TextStyle(color: Colors.grey),
//                         prefixIcon: Icon(Icons.phone, color: Colors.grey),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return context.lwTranslate.pleaseEnterMobile;
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 12),
//                     Text(
//                       context.lwTranslate.addYourMobileNumberTest,
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                     ),
//                     SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           actions: <Widget>[
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: app_theme.primary,
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       context.lwTranslate.update,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         await setPreferences(
//                             'user_mobile_number', _mobileController.text);
//                         Navigator.of(context).pop();
//                         showSuccessMessage(
//                           context,
//                           context.lwTranslate.mobileNumberUpdated,
//                         );
//                         if (mounted) {
//                           setState(() {
//                             Navigator.of(context).pop();
//                             _mobileController.clear();
//                           });
//                         }
//
//                         Navigator.of(context).pushAndRemoveUntil(
//                             MaterialPageRoute(
//                                 builder: (context) => const LandingPage(
//                                   skipMobileDialog: true,
//                                 )),
//                                 (route) => false);
//                         _showQRDialog(context);
//                       }
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 10,),
//                 Expanded(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey,
//                       padding: EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: Text(
//                       context.lwTranslate.notNow,
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: () async {
//                       Navigator.of(context).pop();
//
//                     },
//                   ),
//                 ),
//
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void _showQRDialog(BuildContext context) {
//     final qrData = "https://wa.me/919270075740";
//     final testNumber = "919270075740";
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.0),
//           ),
//           contentPadding: EdgeInsets.zero,
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   padding: EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(16.0),
//                       topRight: Radius.circular(16.0),
//                     ),
//                   ),
//                   child: Text(
//                     context.lwTranslate.scanQrCode,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         context.lwTranslate.youCanUseFollowing,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[700],
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 20),
//                       Container(
//                         padding: EdgeInsets.all(8.0),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey[300]!),
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: Column(
//                           children: [
//                             Text(
//                               "livelyworks",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                             SizedBox(height: 4),
//                             Text(
//                               testNumber,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).primaryColor,
//                               ),
//                             ),
//                             SizedBox(height: 12),
//                             SizedBox(
//                               width: 180,
//                               height: 180,
//                               child: QrImageView(
//                                 data: qrData,
//                                 version: QrVersions.auto,
//                                 size: 180.0,
//                                 embeddedImage: AssetImage(
//                                     'assets/images/whatsapp_logo.png'),
//                                 embeddedImageStyle: QrEmbeddedImageStyle(
//                                   size: Size(40, 40),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       elevation: 5,
//                       backgroundColor: app_theme.primary,
//                       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       minimumSize: Size(double.infinity, 0),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset(
//                           'assets/images/whatsapp_mini_logo.png',
//                           width: 22,
//                           height: 22,
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           context.lwTranslate.whatsAppNow,
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     onPressed: () async {
//                       final whatsappUrl =
//                           "https://api.whatsapp.com/send?phone=919270075740";
//                       if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
//                         await launchUrl(Uri.parse(whatsappUrl));
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(context.lwTranslate.couldNotLaunch)),
//                         );
//                       }
//                       Navigator.of(context).pop();
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../provider/contacts_provider.dart';
import '../../../services/auth.dart';
import '../../../services/global.dart';
import '../../../services/pusher_service.dart';
import '/screens/whatsapp/screens/whatsapp_chat.dart';
import '/screens/myprofile.dart';
import '/screens/settings/settings.dart';
import '/services/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/support/app_theme.dart' as app_theme;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '/services/auth.dart' as auth;
import '/screens/whatsapp/controller/chatbox_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'user/login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    super.key,
    this.initialNotificationCount = 0,
    this.initialActiveTab = 0,
    this.skipMobileDialog = false,
  });

  final int initialNotificationCount;
  final int initialActiveTab;
  final bool skipMobileDialog;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  int _currentIndex = 1;
  int notificationCount = 0;
  int chatCount = 5;
  PusherChannelsFlutter pusher = PusherChannelsFlutter();
  final ChatboxController controller = Get.put(ChatboxController());
  String? userMobileNumber;
  String _savedMobileNumber = '';
  Widget? tabTitle;
  bool _dialogShown = false;
  Future? _fetchMyData;

  final TextEditingController _mobileController = TextEditingController(
    text: geUpdatedMobileNumber() != '' ? geUpdatedMobileNumber() : null,
  );

  @override
  void initState() {
    super.initState();
    _fetchMyData = checkUserLoggedIn();
    final contactProvider = Provider.of<ContactProvider>(context, listen: false);
    final authToken = auth.getAuthToken();

    final pusherService = PusherService();

    pusherService.initPusher(auth.getAuthToken()).catchError((error) {
      if (mounted) {
        checkAndHandleCSRFExpiry(error, context);
      }
    });
    pusherService.initPusher(authToken).then((_) {
      if (mounted) {
        setupContactListUpdates(pusherService, contactProvider);
      }
    });

    // Show dialog only once after the first render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.skipMobileDialog &&
          configItem('demoMode', fallbackValue: false) == true &&
          !isMobileDialogShown) {
        _showMobileNumberDialog(context, showSavedNumber: false);
        if (mounted) {
          setState(() {
            _dialogShown = true;
          });
        }
      }
    });
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _currentIndex = widget.initialActiveTab;
    setTabTitle(_currentIndex);
  }

  Future<void> _loadSavedNumber() async {
    final savedNumber = await getPreferences('user_mobile_number') ?? '';
    if (mounted) {
      setState(() {
        _savedMobileNumber = savedNumber;
        _mobileController.text = _savedMobileNumber;
      });
    }
  }

  void setupContactListUpdates(
      PusherService pusherService, ContactProvider contactProvider) {
    final channelName = "private-vendor-channel.${getAuthInfo('vendor_uid')}";
    pusherService.subscribeToChannel(
      channelName: channelName,
      onEvent: (eventName, eventData) async {
        pr(eventData);
        if (eventName == 'VendorChannelBroadcast' &&
            eventData['message_status'] == null) {
          final contactUid = eventData['contactUid'];

          // Check if this is a new contact not in our list
          if (!contactProvider.contactExists(contactUid)) {
            // Fetch full contact details for this new contact
            await contactProvider.fetchSingleContact(contactUid);
          } else {
            // Existing contact - just update message
            contactProvider.updateContactWithNewMessage(
                context,
                contactUid,
                eventData['lastMessageUid'],
                eventData['formatted_last_message_time']);
          }
          controller.getUserChatSend();
        }else if(eventName == 'VendorChannelBroadcast' &&
            eventData['message_status'] == "sent"){
          controller.getUserChatSend();
        }else if(eventName == 'VendorChannelBroadcast' &&
            eventData['message_status'] == "read"){
          controller.getUserChatSend();
        }
      },
      onSubscriptionError: (error) {},
    );
  }

  Future<bool> checkUserLoggedIn() async {
    await auth.redirectIfUnauthenticated(context);
    return isLoggedIn();
  }

  void setTabTitle(int i) {
    if (mounted) {
      setState(() {
        switch (i) {
          case 0:
            tabTitle = Text(
              context.lwTranslate.whatsAppChat,
              style: TextStyle(color: Colors.white, fontSize: 14),
            );
            break;
          case 1:
            tabTitle = Text(
              context.lwTranslate.whatsAppChat,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            );
            break;
          case 2:
            tabTitle = Text(
              context.lwTranslate.whatsAppChat,
              style: TextStyle(color: Colors.white, fontSize: 14),
            );
            break;
        }
      });
    }
  }

  void onTabTapped(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
        setTabTitle(index);
      });
    }
  }

  final List<Widget> _pages = [
    const WhatsAppChat(),
  ];

  final List<IconData> _icons = [
    CupertinoIcons.chat_bubble_2,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContactProvider>(context);
    return FutureBuilder(
      future: _fetchMyData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        // Loading state
        if (!snapshot.hasData || snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Not authenticated state
        if (snapshot.data == false) {
          return LoginPage();
        }

        // Authenticated state - show main app
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: app_theme.primary,
              title: tabTitle,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: 40,
                      height: 40,
                      child: PopupMenuButton<String>(
                        offset: const Offset(0, 30),
                        onSelected: (value) {},
                        itemBuilder: (BuildContext context) => [
                                 PopupMenuItem<String>(
                        value: 'profile',
                        onTap: () async {
                          await Future.microtask(() {
                            if (context.mounted) {
                              navigatePage(context, const MyProfile());
                            }
                          });
                        },
                        child: Text(context.lwTranslate.profile),
                      ),

                          // PopupMenuItem<String>(
                          //   value: 'profile',
                          //   onTap: () async {
                          //     await Future.microtask(() {
                          //       if (context.mounted) {
                          //         navigatePage(context, const MyProfile());
                          //       }
                          //     });
                          //   },
                          //   child: Text(context.lwTranslate.profile),
                          // ),

                          PopupMenuItem<String>(
                            value: 'settings',
                            onTap: () async {
                              await Future.microtask(() {
                                if (context.mounted) {
                                  navigatePage(context, const Settings());
                                }
                              });
                            },
                            child: Text(context.lwTranslate.settings),
                          ),
                          if (configItem('demoMode', fallbackValue: false) == true)
                            PopupMenuItem<String>(
                              value: 'addNumber',
                              onTap: () async {
                                await Future.microtask(() {
                                  if (context.mounted) {
                                    _showMobileNumberDialog(context, showSavedNumber: true);
                                  }
                                });
                              },
                              child: Text(context.lwTranslate.addNumberForTest),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          body: Scaffold(
            body: _pages[_currentIndex],
            bottomNavigationBar: CurvedNavigationBar(
              index: widget.initialActiveTab,
              backgroundColor: Colors.transparent,
              color: app_theme.primary,
              buttonBackgroundColor: app_theme.primary,
              animationCurve: Curves.ease,
              animationDuration: const Duration(milliseconds: 100),
              height: 50,
              items: List.generate(_icons.length, (index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              _icons[index],
                              color: Colors.white,
                              size: 30,
                            ),
                            if (provider.unreadMsgCount > 0)
                              Positioned(
                                right: -12,
                                top: -12,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    provider.unreadMsgCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ],
                );
              }),
              onTap: (index) {
                if (mounted) {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showMobileNumberDialog(BuildContext context,
      {bool? showSavedNumber}) async {
    if (isMobileDialogShown && !(showSavedNumber ?? false)) return;
    if (!(showSavedNumber ?? false)) {
      isMobileDialogShown = true;
    }
    if (showSavedNumber ?? false) {
      await _loadSavedNumber();
    } else {
      if (mounted) {
        setState(() {
          _mobileController.clear();
        });
      }
    }

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          contentPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          actionsPadding: EdgeInsets.all(16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.lwTranslate.onlyForDemo,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                context.lwTranslate.addYourMobileNumber,
                style: TextStyle(
                    fontSize: 14,
                    color: app_theme.primary,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      context.lwTranslate.youCanAddComma,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: context.lwTranslate.mobileNumber,
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.phone, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.lwTranslate.pleaseEnterMobile;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    Text(
                      context.lwTranslate.addYourMobileNumberTest,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: app_theme.primary,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.lwTranslate.update,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await setPreferences(
                            'user_mobile_number', _mobileController.text);
                        Navigator.of(context).pop();
                        showSuccessMessage(
                          context,
                          context.lwTranslate.mobileNumberUpdated,
                        );
                        if (mounted) {
                          setState(() {
                            Navigator.of(context).pop();
                            _mobileController.clear();
                          });
                        }

                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LandingPage(
                                  skipMobileDialog: true,
                                )),
                                (route) => false);
                        _showQRDialog(context);
                      }
                    },
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      context.lwTranslate.notNow,
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();

                    },
                  ),
                ),

              ],
            ),
          ],
        );
      },
    );
  }

  void _showQRDialog(BuildContext context) {
    final qrData = "https://wa.me/919270075740";
    final testNumber = "919270075740";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  child: Text(
                    context.lwTranslate.scanQrCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        context.lwTranslate.youCanUseFollowing,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "livelyworks",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              testNumber,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            SizedBox(height: 12),
                            SizedBox(
                              width: 180,
                              height: 180,
                              child: QrImageView(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 180.0,
                                embeddedImage: AssetImage(
                                    'assets/images/whatsapp_logo.png'),
                                embeddedImageStyle: QrEmbeddedImageStyle(
                                  size: Size(40, 40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 5,
                      backgroundColor: app_theme.primary,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: Size(double.infinity, 0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/whatsapp_mini_logo.png',
                          width: 22,
                          height: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          context.lwTranslate.whatsAppNow,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      final whatsappUrl =
                          "https://api.whatsapp.com/send?phone=919270075740";
                      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                        await launchUrl(Uri.parse(whatsappUrl));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(context.lwTranslate.couldNotLaunch)),
                        );
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
// ... keep all your existing dialog methods (_showMobileNumberDialog, _showQRDialog) ...
}