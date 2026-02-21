// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/Auth/login_page.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/views/onboard/start.dart';
// import 'amoders_loading.dart';

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

//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => UserPreferences.isLoggedIn()
//             ? const Start()
//             : const LoginPage(),
//       ),
//     );
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       userId = user.userId;
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
//   // POWERED BY BRANDING (BOTTOM)
//   // ------------------------------------------------
//   Widget _poweredByBranding() {
//     return Positioned(
//       bottom: 24 + MediaQuery.of(context).padding.bottom,
//       left: 0,
//       right: 0,
//       child: Column(
//         children: [
//           Text(
//             "Powered by",
//             style: TextStyle(
//               fontSize: 11,
//               color: Colors.white.withOpacity(0.6),
//               letterSpacing: 1.5,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             "Pixelmindsolutions Pvt Ltd",
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//               shadows: [
//                 Shadow(
//                   color: Colors.white.withOpacity(0.3),
//                   blurRadius: 8,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ------------------------------------------------
//   // UI
//   // ------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           // 🔥 FULL SCREEN BACKGROUND IMAGE
// Container(
//   decoration: BoxDecoration(
//     image: DecorationImage(
//       image: AssetImage(
//         Responsive.isDesktop(context)
//             ? 'assets/images/vegsplash.png'
//             : 'assets/images/vegsplash.png',
//       ),
//       fit: BoxFit.fill,
//     ),
//   ),
// ),


//           // OPTIONAL DARK OVERLAY
//           Container(
//             color: Colors.black.withOpacity(0.25),
//           ),

//           // MAIN CONTENT
//           SafeArea(
//             left: false,
//             right: false,
//             child: Column(
//               children: [
//                 const Spacer(),
//                 const AmodersLoading(size: 45),
//                 const Spacer(),
//               ],
//             ),
//           ),

//           // ✅ BRANDING ON TOP OF EVERYTHING
//           // _poweredByBranding(),
//         ],
//       ),
//     );
//   }
// }















// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/LocationProvider/location_provider.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/Auth/login_page.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/views/onboard/start.dart';
// import 'amoders_loading.dart';

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

//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) return;

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => UserPreferences.isLoggedIn()
//             ? const Start()
//             : const LoginPage(),
//       ),
//     );
//   }

//   Future<void> _loadUserId() async {
//     final user = UserPreferences.getUser();
//     if (user != null && mounted) {
//       userId = user.userId;
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
//   // UI
//   // ------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = Responsive.isDesktop(context);
    
//     return Scaffold(
//       body: Container(
//         // color: Colors.green, // Green background for remaining area
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Center the image without stretching (for web)
//             if (isDesktop)
//               Center(
//                 child: Image.asset(
//                   'assets/images/websplash.png',
//                   fit: BoxFit.fill, // Keep original size
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       color: Colors.grey[200],
//                       child: const Center(
//                         child: Icon(
//                           Icons.broken_image,
//                           size: 100,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             else
//               // Mobile: Full screen background image
//               Container(
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     image: AssetImage('assets/images/vegsplash.png'),
//                     fit: BoxFit.fill,
//                   ),
//                 ),
//               ),

//             // OPTIONAL DARK OVERLAY (only for mobile)
//             if (!isDesktop)
//               Container(
//                 color: Colors.black.withOpacity(0.25),
//               ),

//             // MAIN CONTENT (Loading indicator) - same for both
//             SafeArea(
//               left: false,
//               right: false,
//               child: Column(
//                 children: [
//                   const Spacer(),
//                   const AmodersLoading(size: 45),
//                   const Spacer(),
//                 ],
//               ),
//             ),
//           ],
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
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';
import 'package:veegify/views/onboard/start.dart';
import 'amoders_loading.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userId;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _startFlow();
  }

  // ------------------------------------------------
  // LOGIN + LOCATION + NAVIGATION FLOW
  // ------------------------------------------------
  Future<void> _startFlow() async {
    // Initialize UserPreferences first
    await UserPreferences.init();

    // Check login status (this is fast)
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkLoginStatus();

    // Load user ID if logged in
    if (UserPreferences.isLoggedIn()) {
      await _loadUserId();
    }

    // Wait exactly 2 seconds for splash screen visibility
    await Future.delayed(const Duration(seconds: 2));

    // Navigate after 2 seconds regardless of location status
    if (!mounted || _isNavigating) return;
    
    _isNavigating = true;

    // Start location fetch in background (don't wait for it)
    if (UserPreferences.isLoggedIn() && userId != null) {
      _fetchLocationInBackground();
    }

    // Navigate to next screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => UserPreferences.isLoggedIn()
            ? const Start()
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

  // Fetch location in background without blocking navigation
  Future<void> _fetchLocationInBackground() async {
    try {
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      
      // This runs in background and won't block the UI
      locationProvider.initLocation(userId.toString()).catchError((e) {
        debugPrint("Background location error: $e");
      });
    } catch (e) {
      debugPrint("Error starting location fetch: $e");
    }
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    
    return Scaffold(
      body: Container(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Center the image without stretching (for web)
            if (isDesktop)
              Center(
                child: Image.asset(
                  'assets/images/websplash.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              // Mobile: Full screen background image
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage('assets/images/vegsplash.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),

            // OPTIONAL DARK OVERLAY (only for mobile)
            if (!isDesktop)
              Container(
                color: Colors.black.withOpacity(0.25),
              ),

            // MAIN CONTENT (Loading indicator) - same for both
            SafeArea(
              left: false,
              right: false,
              child: Column(
                children: [
                  const Spacer(),
                  const AmodersLoading(size: 45),
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