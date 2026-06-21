import 'package:stundaa/screens/user/login.dart';
import 'package:stundaa/screens/landing.dart';
import 'package:stundaa/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:stundaa/support/app_theme.dart' as app_theme;
import 'package:stundaa/common/widgets/common.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<bool> _fetchMyData;

  @override
  void initState() {
    super.initState();
    _fetchMyData = checkUserLoggedIn();
  }

  Future<bool> checkUserLoggedIn() async {
    return isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchMyData,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: app_theme.backgroundColor,
            body: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: app_theme.glowOrbDecoration(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(height: 100, useLoadingLogo: true),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 180,
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: const LinearProgressIndicator(
                            backgroundColor: Color.fromRGBO(255, 255, 255, 0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(app_theme.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const LandingPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

// import 'package:stundaa/services/global.dart';
// import 'package:stundaa/components/toggle_page_login_register.dart';
// import 'package:stundaa/screens/landing.dart';
// import 'package:stundaa/services/auth.dart';
// import 'package:flutter/material.dart';
// import 'package:stundaa/support/app_theme.dart' as app_theme;
// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
// class _HomePageState extends State<HomePage> {
//   Future<bool>? _fetchMyData;
//   bool _dialogShown = false;
//   bool _dialogCompleted = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchMyData = checkUserLoggedIn();
//     if (!isMobileDialogShown && !_dialogShown) {
//       _showWelcomeDialog();
//     } else {
//       _dialogCompleted = true;
//     }
//   }
//
//   Future<bool> checkUserLoggedIn() async {
//     return isLoggedIn();
//   }
//
//   // void _showWelcomeDialog() {
//   //   _dialogShown = true;
//   //   isMobileDialogShown = true;
//   //
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     showDialog(
//   //       context: context,
//   //       barrierDismissible: false,
//   //       builder: (BuildContext context) {
//   //         return AlertDialog(
//   //           title: const Text('Welcome!'),
//   //           content: const Text('Welcome to our app! We\'re glad to have you here.'),
//   //           actions: <Widget>[
//   //             TextButton(
//   //               child: const Text("Let's Go"),
//   //               onPressed: () {
//   //                 Navigator.of(context).pop(); // Close the dialog
//   //                 setState(() {
//   //                   _dialogCompleted = true;
//   //                 });
//   //               },
//   //             ),
//   //           ],
//   //         );
//   //       },
//   //     );
//   //   });
//   // }
//
//   void _showWelcomeDialog() {
//     _dialogShown = true;
//     isMobileDialogShown = true;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (BuildContext context) {
//           return Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(24.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20.0),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // WhatsApp icon
//                   Column(
//                     children: [
//                       Image.asset(
//                         'assets/images/icon.png',
//                         width: 150,
//                         height: 80,
//                       ),
//                       Image.asset(
//                         'assets/images/logo.png',
//                         width: 150,
//                         height: 40,
//                       ),
//                     ],
//                   ),
//                   // Container(
//                   //   width: 80,
//                   //   height: 80,
//                   //   decoration: BoxDecoration(
//                   //     color: const Color(0xFF25D366),
//                   //     shape: BoxShape.circle,
//                   //   ),
//                   //   child: Image.asset(
//                   //     'assets/images/logo.png',
//                   //     width: 40,
//                   //     height: 40,
//                   //
//                   //   ),
//                   // ),
//                   const SizedBox(height: 20),
//
//                   // Title
//                   const Text(
//                     'Engage Your Customers on WhatsApp Like Never Before',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 17,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Subtitle
//                   Column(
//                     children: [
//                       const Text(
//                         'WhatsJetSaas',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: app_theme.primary,
//                         ),
//                       ),
//                       Container(
//                         height: 5, // Thickness of the line
//                         width: 100, // Width of the line
//                         color: Colors.yellow, // Yellow color
//                         margin: const EdgeInsets.only(top: 1), // Space between text and line
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//
//                   // Description
//                    Text(
//                     'Unlock the full potential of customer engagement with WhatsJetSaas your comprehensive WhatsApp Marketing Platform.',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade500,
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//
//                   // Buttons
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // Get Started button
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                           setState(() {
//                             _dialogCompleted = true;
//                             _fetchMyData = checkUserLoggedIn();
//                           });
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor:app_theme.primary,
//                           // padding: const EdgeInsets.symmetric(
//                           //     horizontal: 10, vertical: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30.0),
//                           ),
//                         ),
//                         child: const Text(
//                           'Get Started',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ),
//
//                       // Signup Now button
//                       // OutlinedButton(
//                       //   onPressed: () {
//                       //     Navigator.of(context).pop();
//                       //     setState(() {
//                       //       _dialogCompleted = true;
//                       //     });
//                       //     // Add your signup navigation here
//                       //   },
//                       //   style: OutlinedButton.styleFrom(
//                       //     padding: const EdgeInsets.symmetric(
//                       //         horizontal: 20, vertical: 12),
//                       //     shape: RoundedRectangleBorder(
//                       //       borderRadius: BorderRadius.circular(30.0),
//                       //     ),
//                       //     side: const BorderSide(
//                       //       color: Color(0xFF25D366),
//                       //       width: 2,
//                       //     ),
//                       //   ),
//                       //   child: const Text(
//                       //     'Signup Now',
//                       //     style: TextStyle(
//                       //       fontSize: 16,
//                       //       fontWeight: FontWeight.bold,
//                       //       color: Color(0xFF25D366),
//                       //     ),
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Show loading until dialog is completed
//     if (!_dialogCompleted) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return FutureBuilder(
//       future: _fetchMyData,
//       builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('An error occurred: ${snapshot.error}'));
//         } else if (snapshot.hasData && snapshot.data == true) {
//           return const LandingPage();
//         } else {
//           return const LoginPage();
//         }
//       },
//     );
//   }
// }
