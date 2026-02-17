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
  // POWERED BY BRANDING (BOTTOM)
  // ------------------------------------------------
  Widget _poweredByBranding() {
    return Positioned(
      bottom: 24 + MediaQuery.of(context).padding.bottom,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            "Powered by",
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Pixelmindsolutions Pvt Ltd",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // UI
  // ------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔥 FULL SCREEN BACKGROUND IMAGE
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage(
        Responsive.isDesktop(context)
            ? 'assets/images/vegsplash.png'
            : 'assets/images/vegsplash.png',
      ),
      fit: BoxFit.fill,
    ),
  ),
),


          // OPTIONAL DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.25),
          ),

          // MAIN CONTENT
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

          // ✅ BRANDING ON TOP OF EVERYTHING
          // _poweredByBranding(),
        ],
      ),
    );
  }
}





