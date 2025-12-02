
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/LocationProvider/location_provider.dart';
import 'package:veegify/views/Auth/login_page.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';

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

    // Keep splash for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (UserPreferences.isLoggedIn()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => NavbarScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  Future<void> _loadUserId() async {
    final user = UserPreferences.getUser();
    if (user != null && mounted) {
      setState(() {
        userId = user.userId;
      });
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
  // UI EXACTLY LIKE THE IMAGE YOU SENT
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF083F1A), // top dark green
              Color(0xFF000000), // bottom blackish
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO (Your full splash logo)
                Image.asset(
                  'assets/images/logo.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 180),

                // POWERED BY TEXT
                const Text(
                  "Powered by Nemishhrree",
                  style: TextStyle(
                    color: Color(0xFFEDEDED),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                // OPERATED BY TEXT
                const Text(
                  "Operated by JEIPLX",
                  style: TextStyle(
                    color: Color(0xFFEDEDED),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                                const SizedBox(height: 8),

                // OPERATED BY TEXT
                const Text(
                  "Join Indis's First Pure Vegetarian Food Delivery Revokution!",
                  style: TextStyle(
                    color: Color(0xFFEDEDED),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
