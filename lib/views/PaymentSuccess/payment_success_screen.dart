// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
// // import 'package:veegify/views/Booking/booking_screen.dart';
// // import 'package:veegify/views/LocationScreen/location_detail_screen.dart';

// // class PaymentSuccessScreen extends StatefulWidget {
// //   final String? userId;
// //   const PaymentSuccessScreen({super.key, this.userId});

// //   @override
// //   State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
// // }

// // class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
// //     with SingleTickerProviderStateMixin {
// //   late final AnimationController _controller;
// //   late final Animation<double> _scaleAnimation;
// //   late final Animation<double> _fadeAnimation;
// //   Timer? _timer;

// //   @override
// //   void initState() {
// //     super.initState();

// //     _controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 800),
// //     );

// //     _scaleAnimation =
// //         CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

// //     _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

// //     _controller.forward();

// //     // Navigate after 3 seconds. Store the timer so we can cancel it on dispose.
// //     _timer = Timer(const Duration(seconds: 3), () {
// //       // If BookingScreen requires a non-null userId, pass a fallback or handle accordingly.
// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(
// //           builder: (context) => AcceptedOrderPollingScreen(userId: widget.userId ?? ''),
// //         ),
// //       );
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     _controller.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 80),

// //               // Animated Checkmark
// //               Center(
// //                 child: ScaleTransition(
// //                   scale: _scaleAnimation,
// //                   child: FadeTransition(
// //                     opacity: _fadeAnimation,
// //                     child: CircleAvatar(
// //                       radius: 90,
// //                       backgroundColor: Colors.white,
// //                       // cannot be const because NetworkImage uses runtime fetching
// //                       backgroundImage: AssetImage(
// //                         'assets/images/check_mark.png',
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),

// //               const SizedBox(height: 30),

// //               // Payment Successful
// //               const Center(
// //                 child: Text(
// //                   'Booking Successful',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 23,
// //                   ),
// //                 ),
// //               ),

// //               const SizedBox(height: 15),

// //               const Center(
// //                 child: Text(
// //                   'Your booking is confirmed',
// //                   style: TextStyle(color: Colors.grey),
// //                 ),
// //               ),

// //               const SizedBox(height: 25),

// //               const Center(
// //                 child: Text(
// //                   'You have successfully booked your service.\n'
// //                   'We sent details of your booking to your\n'
// //                   'mobile number. You can check it under\n'
// //                   '"My Bookings".',
// //                   style: TextStyle(color: Colors.grey),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }






















// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
// import 'package:veegify/views/Booking/booking_screen.dart';
// import 'package:veegify/views/LocationScreen/location_detail_screen.dart';

// class PaymentSuccessScreen extends StatefulWidget {
//   final String? userId;
//     final String? orderId;

//   const PaymentSuccessScreen({super.key, this.userId, this.orderId});

//   @override
//   State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
// }

// class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnimation;
//   late final Animation<double> _fadeAnimation;

//   static const int _totalSeconds = 60; // buffer time 1 minute
//   int _remainingSeconds = _totalSeconds;
//   Timer? _countdownTimer;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     );

//     _scaleAnimation =
//         CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

//     _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

//     _controller.forward();

//     _startCountdown();
//   }

//   void _startCountdown() {
//     _remainingSeconds = _totalSeconds;

//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         if (_remainingSeconds > 1) {
//           _remainingSeconds--;
//         } else {
//           // last tick finished
//           _remainingSeconds = 0;
//           timer.cancel();
//           _navigateToNext();
//         }
//       });
//     });
//   }

//   void _navigateToNext() {
//     // Navigate after buffer time is over
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             AcceptedOrderPollingScreen(userId: widget.userId ?? ''),
//       ),
//     );
//   }

//   Future<void> _cancelBooking() async {
//     // Stop the countdown
//     _countdownTimer?.cancel();

//     // TODO: call your API to cancel booking here if needed

//     // For now just go back (or to any screen you want)
//     Navigator.pop(context);
//     // Or:
//     // Navigator.pushReplacement(
//     //   context,
//     //   MaterialPageRoute(builder: (_) => const BookingScreen()),
//     // );
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
// @override
// Widget build(BuildContext context) {
//   final double progress =
//       _remainingSeconds / _totalSeconds; // 1.0 -> 0.0 over time

//   return WillPopScope(
//     onWillPop: () async => false, // ❌ Block back navigation
//     child: Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const SizedBox(height: 80),

//               // Animated Checkmark
//               Center(
//                 child: ScaleTransition(
//                   scale: _scaleAnimation,
//                   child: FadeTransition(
//                     opacity: _fadeAnimation,
//                     child: CircleAvatar(
//                       radius: 90,
//                       backgroundColor: Colors.white,
//                       backgroundImage: const AssetImage(
//                         'assets/images/check_mark.png',
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               const Center(
//                 child: Text(
//                   'Booking Successful',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 23,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 15),

//               const Center(
//                 child: Text(
//                   'Your booking is confirmed',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),

//               const SizedBox(height: 25),

//               const Center(
//                 child: Text(
//                   'You have successfully booked your service.\n'
//                   'We sent details of your booking to your\n'
//                   'mobile number. You can check it under\n'
//                   '"My Bookings".',
//                   style: TextStyle(color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // Countdown timer + cancel button
//               Center(
//                 child: Column(
//                   children: [
//                     SizedBox(
//                       width: 90,
//                       height: 90,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           CircularProgressIndicator(
//                             value: progress,
//                             strokeWidth: 6,
//                           ),
//                           Text(
//                             '${_remainingSeconds}s',
//                             style: const TextStyle(
//                               fontWeight: FontWeight.w600,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'You can cancel this booking within 1 minute.\n'
//                       'After that, your booking will be processed.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),
//                     OutlinedButton.icon(
//                       onPressed:
//                           _remainingSeconds == 0 ? null : _cancelBooking,
//                       icon: const Icon(
//                         Icons.cancel_outlined,
//                         color: Colors.red,
//                       ),
//                       label: const Text(
//                         'Cancel Booking',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                       style: OutlinedButton.styleFrom(
//                         side: const BorderSide(color: Colors.red),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 10,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }

// }




















import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
import 'package:veegify/views/Booking/booking_screen.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String? userId;
  final String? orderId;

  const PaymentSuccessScreen({
    super.key,
    this.userId,
    this.orderId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  static const int _totalSeconds = 30; // buffer time 1 minute
  int _remainingSeconds = _totalSeconds;
  Timer? _countdownTimer;
  bool _isCancelling = false;

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

    _startCountdown();
  }

  void _startCountdown() {
    _remainingSeconds = _totalSeconds;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 1) {
          _remainingSeconds--;
        } else {
          // last tick finished
          _remainingSeconds = 0;
          timer.cancel();
          _navigateToNext();
        }
      });
    });
  }

  void _navigateToNext() {
    // Don't navigate if the widget was disposed or if cancelling is in progress
    if (!mounted || _isCancelling) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AcceptedOrderPollingScreen(userId: widget.userId ?? ''),
      ),
    );
  }

  Future<void> _cancelBooking() async {
    // Stop the countdown so it won't auto-navigate
    _countdownTimer?.cancel();

    if (widget.userId == null || widget.orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to cancel: missing IDs')),
      );
      return;
    }

    if (_isCancelling) return; // avoid duplicate taps

    setState(() {
      _isCancelling = true;
    });

    try {
      print("sijffjdfklfjd;ffsk;fsaf${widget.userId}");
            print("sijffjdfklfjd;ffsk;fsaf${widget.orderId}");

      final url = Uri.parse(
        'https://api.vegiffyy.com/api/cancel-order/${widget.userId}/${widget.orderId}',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Cancel Response Status: ${response.statusCode}');
      debugPrint('Cancel Response Body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final success = body['success'] == true;
        final message =
            body['message']?.toString() ?? 'Booking cancelled successfully';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        if (success) {
          // Navigate to home (BookingScreen) and clear stack
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const NavbarScreen()),
            (route) => false,
          );
        }
      } else {
        // Non-200 response
        String errorMessage = 'Failed to cancel booking';
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['message'] != null) {
            errorMessage = errorBody['message'].toString();
          }
        } catch (_) {}

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

        // If you want, you can restart countdown here. For now we keep it stopped.
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling booking: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress =
        _remainingSeconds / _totalSeconds; // 1.0 -> 0.0 over time

    return WillPopScope(
      onWillPop: () async => false, // ❌ Block back navigation
      child: Scaffold(
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
                      child: const CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage(
                          'assets/images/check_mark.png',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

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

                const SizedBox(height: 30),

                // Countdown timer + cancel button
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                            ),
                            Text(
                              '${_remainingSeconds}s',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'You can cancel this booking within 30 seconds.\n'
                        'After that, your booking will be processed.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: (_remainingSeconds == 0 || _isCancelling)
                            ? null
                            : _cancelBooking,
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                        label: Text(
                          _isCancelling ? 'Cancelling...' : 'Cancel Booking',
                          style: const TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
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
