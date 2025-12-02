import 'dart:async';
import 'package:flutter/material.dart';
import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
import 'package:veegify/views/Booking/booking_screen.dart';
import 'package:veegify/views/LocationScreen/location_detail_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? userId;
  const PaymentSuccessScreen({super.key, this.userId});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    // Navigate after 3 seconds. Store the timer so we can cancel it on dispose.
    _timer = Timer(const Duration(seconds: 3), () {
      // If BookingScreen requires a non-null userId, pass a fallback or handle accordingly.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AcceptedOrderPollingScreen(userId: widget.userId ?? ''),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // Animated Checkmark
              Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor: Colors.white,
                      // cannot be const because NetworkImage uses runtime fetching
                      backgroundImage: AssetImage(
                        'assets/images/check_mark.png',
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Payment Successful
              const Center(
                child: Text(
                  'Booking Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 23,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'Your booking is confirmed',
                  style: TextStyle(color: Colors.grey),
                ),
              ),

              const SizedBox(height: 25),

              const Center(
                child: Text(
                  'You have successfully booked your service.\n'
                  'We sent details of your booking to your\n'
                  'mobile number. You can check it under\n'
                  '"My Bookings".',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
