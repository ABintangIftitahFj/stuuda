// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:stundaa/provider/contacts_provider.dart';
// import 'package:stundaa/services/auth.dart';
// import 'package:stundaa/services/pusher_service.dart';
// import 'package:stundaa/screens/whatsapp/screens/whatsapp_chat.dart';
// import 'package:stundaa/screens/myprofile.dart';
// import 'package:stundaa/screens/settings/settings.dart';
// import 'package:stundaa/services/utils.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:stundaa/support/app_theme.dart' as app_theme;
// import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
// import 'package:stundaa/services/auth.dart' as auth;
// import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:stundaa/services/global.dart';
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
//                               "STUNDAA",
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
import 'package:provider/provider.dart';


import 'package:stundaa/provider/contacts_provider.dart';
import 'package:stundaa/services/auth.dart';
import 'package:stundaa/services/global.dart';
import 'package:stundaa/services/pusher_service.dart';
import 'package:stundaa/components/app_drawer.dart';
import 'package:stundaa/components/demo_dialogs.dart';
import 'package:stundaa/screens/whatsapp/screens/whatsapp_chat.dart';
import 'package:stundaa/screens/myprofile.dart';
import 'package:stundaa/screens/settings/settings.dart';
import 'package:stundaa/services/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:stundaa/services/auth.dart' as auth;
import 'package:stundaa/screens/whatsapp/controller/chatbox_controller.dart';

import 'package:stundaa/services/call_service.dart';
import 'package:stundaa/services/webrtc_manager.dart';
import 'package:stundaa/screens/whatsapp/screens/calling_screen.dart';

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
  int _currentIndex = 0;
  int notificationCount = 0;
  int chatCount = 5;
  PusherChannelsFlutter pusher = PusherChannelsFlutter();
  final ChatboxController controller = Get.put(ChatboxController());
  String? userMobileNumber;
  Widget? tabTitle;
  Future? _fetchMyData;

  @override
  void initState() {
    super.initState();
    _fetchMyData = checkUserLoggedIn();
    final contactProvider =
        Provider.of<ContactProvider>(context, listen: false);
    final authToken = auth.getAuthToken();

    final pusherService = PusherService();

    pusherService.initPusher(auth.getAuthToken()).catchError((error) {
      if (mounted) {
        auth.checkAndHandleCSRFExpiry(error, context);
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
        DemoDialogs.showMobileNumberDialog(context, showSavedNumber: false);
      }
    });
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    _currentIndex = widget.initialActiveTab;
    setTabTitle(_currentIndex);
  }

  void setupContactListUpdates(
      PusherService pusherService, ContactProvider contactProvider) {
    final channelName = "private-vendor-channel.${getAuthInfo('vendor_uid')}";
    final callService = CallService();
    final webRTCManager = WebRTCManager();

    pusherService.subscribeToChannel(
      channelName: channelName,
      onEvent: (eventName, eventData) async {
        pr("Pusher Event: $eventName");
        pr(eventData);

        // 1. WhatsApp Calling Events
        if (eventName == 'WhatsAppCallingEvent') {
          final type = eventData['type'];

          if (type == 'offer') {
            // Incoming Call
            await callService.showIncomingCall(
              callerName: eventData['contactName'] ?? 'WhatsApp Contact',
              avatar: '',
              handle: eventData['contactPhoneNumber'],
              userId: eventData['contactUid'],
            );
            // Store remote SDP to be answered later
            await setPreferences('remote_sdp', eventData['sdp']);

            // If app is in foreground, navigate to calling screen
            Get.to(() => CallingScreen(
              contactName: eventData['contactName'] ?? 'WhatsApp Contact',
              contactPhoneNumber: eventData['contactPhoneNumber'],
              isIncoming: true,
            ));
          } else if (type == 'answer') {
            // Call Answered by customer
            await webRTCManager.setRemoteDescription(eventData['sdp'], 'answer');
          } else if (type == 'ice-candidate') {
            // Received ICE Candidate
            await webRTCManager.addIceCandidate(eventData['candidate']);
          } else if (type == 'end') {
            // Call Ended
            await webRTCManager.dispose();
          }
        }

        // 2. Messaging Events
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
        } else if (eventName == 'VendorChannelBroadcast' &&
            eventData['message_status'] == "sent") {
          controller.getUserChatSend();
        } else if (eventName == 'VendorChannelBroadcast' &&
            eventData['message_status'] == "read") {
          controller.getUserChatSend();
        }
      },
      onSubscriptionError: (error) {},
    );
  }

  Future<bool> checkUserLoggedIn() async {
    if (!mounted) return false;
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
        if (!snapshot.hasData ||
            snapshot.connectionState != ConnectionState.done) {
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
          drawer: const AppDrawer(),
          backgroundColor: app_theme.backgroundColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(68),
            child: AppBar(
              backgroundColor: app_theme.deepNavy,
              elevation: 0,
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'STUNDAA',
                    style: TextStyle(
                      color: app_theme.iceBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  tabTitle ??
                      const Text(
                        'Inbox',
                        style: TextStyle(
                          color: app_theme.lavenderWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                ],
              ),
              iconTheme: const IconThemeData(color: app_theme.lavenderWhite),
              actions: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: 48,
                      height: 48,
                      child: PopupMenuButton<String>(
                        offset: const Offset(0, 30),
                        color: app_theme.surface,
                        icon: const Icon(
                          Icons.more_vert,
                          color: app_theme.lavenderWhite,
                        ),
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
                          if (configItem('demoMode', fallbackValue: false) ==
                              true)
                            PopupMenuItem<String>(
                              value: 'addNumber',
                              onTap: () async {
                                await Future.microtask(() {
                                  if (context.mounted) {
                                    DemoDialogs.showMobileNumberDialog(context,
                                        showSavedNumber: true);
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
          body: _pages[_currentIndex],
          bottomNavigationBar: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color.fromRGBO(167, 223, 255, 0.18),
              ),
              gradient: app_theme.cardGradient,
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.35),
                  blurRadius: 24,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: CurvedNavigationBar(
              index: widget.initialActiveTab,
              backgroundColor: Colors.transparent,
              color: app_theme.surface,
              buttonBackgroundColor: app_theme.primary,
              animationCurve: Curves.easeOutCubic,
              animationDuration: const Duration(milliseconds: 180),
              height: 58,
              items: List.generate(_icons.length, (index) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      _icons[index],
                      color: index == _currentIndex
                          ? app_theme.black
                          : app_theme.lavenderWhite,
                      size: 28,
                    ),
                    if (provider.unreadMsgCount > 0)
                      Positioned(
                        right: -12,
                        top: -10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: app_theme.error,
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
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }),
              onTap: (index) {
                if (mounted) {
                  setState(() {
                    _currentIndex = index;
                    setTabTitle(index);
                  });
                }
              },
            ),
          ),
        );
      },
    );
  }
}
