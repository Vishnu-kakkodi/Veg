
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/views/Auth/login_page.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   String? userId;

//   @override
//   void initState() {
//     super.initState();
//     _startFlow();
//   }

//   // ------------------------------------------------
//   // LOGIN + LOCATION + NAVIGATION FLOW
//   // ------------------------------------------------
//   Future<void> _startFlow() async {
//     await UserPreferences.init();

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     await authProvider.checkLoginStatus();

//     if (UserPreferences.isLoggedIn()) {
//       await _loadUserId();
//       await _handleCurrentLocation();
//     }

//     // Keep splash for 2 seconds
//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) return;

//     if (UserPreferences.isLoggedIn()) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => NavbarScreen(initialIndex: 0,)),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     }
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       setState(() {
//         userId = user.userId;
//       });
//     }
//   }

//   Future<void> _handleCurrentLocation() async {
//     try {
//       final locationProvider =
//           Provider.of<LocationProvider>(context, listen: false);
//       await locationProvider.initLocation(userId.toString());
//     } catch (e) {
//       debugPrint("Location error: $e");
//     }
//   }

//   // ------------------------------------------------
//   // UI EXACTLY LIKE THE IMAGE YOU SENT
//   // ------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF083F1A), // top dark green
//               Color(0xFF000000), // bottom blackish
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // LOGO (Your full splash logo)
//                 Image.asset(
//                   'assets/images/logo.png',
//                   width: 300,
//                   fit: BoxFit.contain,
//                 ),

//                 const SizedBox(height: 100),
//                     // Text(
//                     //   'Pure Vegiterian',
//                     //   style: const TextStyle(
//                     //     fontFamily: 'Cursive',
//                     //     fontWeight: FontWeight.w900,
//                     //     fontSize: 50,
//                     //     letterSpacing: 1.5,
//                     //     color: Colors.white,
//                     //     shadows: [
//                     //       Shadow(
//                     //         color: Colors.black26,
//                     //         offset: Offset(2, 2),
//                     //         blurRadius: 4,
//                     //       ),
//                     //     ],
//                     //   ),
//                     //   overflow: TextOverflow.ellipsis,
//                     // ),

//                                 const SizedBox(height: 100),


//                 // POWERED BY TEXT
//                 const Text(
//                   "Powered by Nemishhrree",
//                   style: TextStyle(
//                     color: Color(0xFFEDEDED),
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // OPERATED BY TEXT
//                 const Text(
//                   "Operated by JEIPLX",
//                   style: TextStyle(
//                     color: Color(0xFFEDEDED),
//                     fontSize: 18,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),

//                                                 const SizedBox(height: 8),

//                 // OPERATED BY TEXT
//                 const Text(
//                   "Join Indis's First Pure Vegetarian Food Delivery",
//                   style: TextStyle(
//                     color: Color(0xFFEDEDED),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                                                                 const SizedBox(height: 4),

//                 // OPERATED BY TEXT
//                 const Text(
//                   "Revolution!",
//                   style: TextStyle(
//                     color: Color(0xFFEDEDED),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



















import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';
import 'amoders_loading.dart'; // 👈 import your loader

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  // ------------------------------------------------
  // LOGIN + LOCATION + NAVIGATION FLOW
  // ------------------------------------------------
  Future<void> _startFlow() async {
    await UserPreferences.init();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    if (UserPreferences.isLoggedIn()) {
      await _loadUserId();
      await _handleCurrentLocation();
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UserPreferences.isLoggedIn()
            ? const NavbarScreen(initialIndex: 0)
            : const LoginPage(),
      ),
    );
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      userId = user.userId;
    }
  }

  Future<void> _handleCurrentLocation() async {
    try {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.initLocation(userId.toString());
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF083F1A),
              Color(0xFF000000),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // LOGO
              Image.asset(
                'assets/images/logo.png',
                width: 300,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              // 🔥 LOADING ANIMATION
              const AmodersLoading(size: 45),

              const Spacer(),

              // BOTTOM TEXTS
              const Text(
                "Powered by Nemishhrree",
                style: TextStyle(
                  color: Color(0xFFEDEDED),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Operated by JEIPLX",
                style: TextStyle(
                  color: Color(0xFFEDEDED),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Join India's First Pure Vegetarian Food Delivery",
                style: TextStyle(
                  color: Color(0xFFEDEDED),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                "Revolution!",
                style: TextStyle(
                  color: Color(0xFFEDEDED),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
