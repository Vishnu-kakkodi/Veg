import 'package:flutter/material.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';

class Start extends StatelessWidget {
  const Start({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/images/start.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔹 Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          /// 🔹 Bottom Content
/// 🔹 Bottom Content
Positioned(
  left: 24,
  right: 24,
  bottom: 40,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [

      /// 🌱 Title
      const Text(
        "Fresh & Delicious\nPure Veg Food\nDelivered Fast!",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),

      const SizedBox(height: 16),

      /// 🌿 Subtitle
      Text(
        "Experience healthy, tasty vegetarian meals\n"
        "made with fresh ingredients and delivered\n"
        "straight to your doorstep.",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 14,
        ),
      ),

      const SizedBox(height: 28),

      /// 🟢 Button
      SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Veg green color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => NavbarScreen(initialIndex: 0),
              ),
            );
          },
          child: const Text(
            "Get Started",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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
}
