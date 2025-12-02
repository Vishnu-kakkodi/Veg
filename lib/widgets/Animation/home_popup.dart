// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:math';

// class OfferPopupWidget extends StatefulWidget {
//   final VoidCallback? onOfferClaimed;
//   final VoidCallback? onPopupClosed;
  
//   const OfferPopupWidget({
//     super.key,
//     this.onOfferClaimed,
//     this.onPopupClosed,
//   });

//   @override
//   State<OfferPopupWidget> createState() => _OfferPopupWidgetState();
// }

// class _OfferPopupWidgetState extends State<OfferPopupWidget>
//     with TickerProviderStateMixin {
//   bool _showPopup = false;
//   Timer? _popupTimer;
  
//   // Animation controllers
//   late AnimationController _overlayController;
//   late AnimationController _ticketController;
//   late AnimationController _contentController;
//   late AnimationController _sparkleController;
//   late AnimationController _bounceController;
  
//   // Animations
//   late Animation<double> _overlayAnimation;
//   late Animation<double> _ticketScaleAnimation;
//   late Animation<Offset> _ticketSlideAnimation;
//   late Animation<double> _contentAnimation;
//   late Animation<double> _sparkleAnimation;
//   late Animation<double> _bounceAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _startPopupTimer();
//   }

//   void _initializeAnimations() {
//     // Overlay fade animation
//     _overlayController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _overlayAnimation = Tween<double>(
//       begin: 0.0,
//       end: 0.6,
//     ).animate(CurvedAnimation(
//       parent: _overlayController,
//       curve: Curves.easeInOut,
//     ));

//     // Ticket scale and slide animation
//     _ticketController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _ticketScaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _ticketController,
//       curve: Curves.elasticOut,
//     ));
//     _ticketSlideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, -0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _ticketController,
//       curve: Curves.elasticOut,
//     ));

//     // Content animation (delayed)
//     _contentController = AnimationController(
//       duration: const Duration(milliseconds: 600),
//       vsync: this,
//     );
//     _contentAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _contentController,
//       curve: Curves.easeInOut,
//     ));

//     // Sparkle animation (continuous)
//     _sparkleController = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//     _sparkleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(_sparkleController);

//     // Bounce animation for CTA button
//     _bounceController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );
//     _bounceAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.1,
//     ).animate(CurvedAnimation(
//       parent: _bounceController,
//       curve: Curves.elasticInOut,
//     ));
//   }

//   void _startPopupTimer() {
//     // Show popup initially after 2 seconds
//     _popupTimer = Timer(const Duration(seconds: 2), () {
//       _showOfferPopup();
//     });
//   }

//   void _showOfferPopup() {
//     if (mounted) {
//       setState(() {
//         _showPopup = true;
//       });
      
//       // Start animations in sequence
//       _overlayController.forward();
      
//       Future.delayed(const Duration(milliseconds: 100), () {
//         if (mounted) _ticketController.forward();
//       });
      
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted) {
//           _contentController.forward();
//           _sparkleController.repeat();
//         }
//       });
      
//       Future.delayed(const Duration(milliseconds: 100), () {
//         if (mounted) _bounceController.repeat(reverse: true);
//       });
      
//       // Auto-hide after 8 seconds and schedule next popup
//       Future.delayed(const Duration(seconds: 16), () {
//         if (mounted && _showPopup) {
//           _hidePopup();
//         }
//       });
//     }
//   }

//   void _hidePopup() {
//     if (mounted) {
//       _bounceController.stop();
//       _sparkleController.stop();
//       _contentController.reverse();
      
//       Future.delayed(const Duration(milliseconds: 200), () {
//         if (mounted) _ticketController.reverse();
//       });
      
//       Future.delayed(const Duration(milliseconds: 400), () {
//         if (mounted) {
//           _overlayController.reverse().then((_) {
//             if (mounted) {
//               setState(() {
//                 _showPopup = false;
//               });
              
//               // Schedule next popup after 2 minutes
//               _popupTimer?.cancel();
//               _popupTimer = Timer(const Duration(minutes: 1), () {
//                 _showOfferPopup();
//               });
//             }
//           });
//         }
//       });
//     }
    
//     widget.onPopupClosed?.call();
//   }

//   void _claimOffer() {
//     widget.onOfferClaimed?.call();
//     _hidePopup();
//   }

//   @override
//   void dispose() {
//     _popupTimer?.cancel();
//     _overlayController.dispose();
//     _ticketController.dispose();
//     _contentController.dispose();
//     _sparkleController.dispose();
//     _bounceController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_showPopup) return const SizedBox.shrink();

//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _overlayAnimation,
//         _ticketScaleAnimation,
//         _ticketSlideAnimation,
//         _contentAnimation,
//         _sparkleAnimation,
//         _bounceAnimation,
//       ]),
//       builder: (context, child) {
//         return Stack(
//           children: [
//             // Overlay background
//             Positioned.fill(
//               child: GestureDetector(
//                 onTap: _hidePopup,
//                 child: Container(
//                   color: Colors.black.withOpacity(_overlayAnimation.value),
//                 ),
//               ),
//             ),
            
//             // Ticket popup
//             Center(
//               child: Transform.scale(
//                 scale: _ticketScaleAnimation.value,
//                 child: SlideTransition(
//                   position: _ticketSlideAnimation,
//                   child: _buildTicketPopup(),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildTicketPopup() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       child: Stack(
//         children: [
//           // Sparkle effects
//           _buildSparkleEffects(),
          
//           // Main ticket
//           _buildTicketDesign(),
          
//           // Close button
//           Positioned(
//             top: 5,
//             right: 5,
//             child: GestureDetector(
//               onTap: _hidePopup,
//               child: Container(
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 6,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: const Icon(
//                   Icons.close,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSparkleEffects() {
//     return Positioned.fill(
//       child: AnimatedBuilder(
//         animation: _sparkleAnimation,
//         builder: (context, child) {
//           return Stack(
//             children: [
//               _buildSparkle(-20, 20, 0.0),
//               _buildSparkle(-10, -15, 0.3),
//               _buildSparkle(300, 30, 0.6),
//               _buildSparkle(290, -10, 0.2),
//               _buildSparkle(150, -25, 0.8),
//               _buildSparkle(150, 350, 0.4),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildSparkle(double left, double top, double delay) {
//     double animationValue = (_sparkleAnimation.value + delay) % 1.0;
//     double opacity = (sin(animationValue * 2 * pi) + 1) / 2;
//     double scale = 0.5 + (sin(animationValue * 2 * pi) * 0.3);
    
//     return Positioned(
//       left: left,
//       top: top,
//       child: Transform.scale(
//         scale: scale,
//         child: Opacity(
//           opacity: opacity * 0.8,
//           child: const Icon(
//             Icons.star,
//             color: Colors.yellow,
//             size: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTicketDesign() {
//     return ClipPath(
//       clipper: TicketClipper(),
//       child: Container(
//         width: 320,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Colors.orange.shade400,
//               Colors.deepOrange.shade600,
//             ],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.3),
//               blurRadius: 20,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             // Ticket pattern background
//             _buildTicketPattern(),
            
//             // Content
//             Padding(
//               padding: const EdgeInsets.all(24),
//               child: FadeTransition(
//                 opacity: _contentAnimation,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Header
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.local_offer,
//                           color: Colors.white,
//                           size: 24,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           'SPECIAL OFFER!',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 1.2,
//                           ),
//                         ),
//                       ],
//                     ),
                    
//                     const SizedBox(height: 20),
                    
//                     // Main offer
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 20,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(25),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 8,
//                             offset: const Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Text(
//                             '🎉',
//                             style: TextStyle(fontSize: 24),
//                           ),
//                           const SizedBox(width: 12),
//                           Column(
//                             children: [
//                               Text(
//                                 'FLAT 60% OFF',
//                                 style: TextStyle(
//                                   color: Colors.deepOrange.shade600,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                               Text(
//                                 'Limited Time Only!',
//                                 style: TextStyle(
//                                   color: Colors.grey.shade600,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     const SizedBox(height: 16),
                    
//                     // Offer details
//                     Text(
//                       'Valid on first 3 orders • Min order ₹199',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
                    
//                     const SizedBox(height: 8),
                    
//                     // Promo code
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 8,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.3),
//                           style: BorderStyle.solid,
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.content_copy,
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Code: MEGA60',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 1.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     const SizedBox(height: 20),
                    
//                     // CTA Button
//                     Transform.scale(
//                       scale: _bounceAnimation.value,
//                       child: GestureDetector(
//                         onTap: _claimOffer,
//                         child: Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(30),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.3),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 5),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.shopping_cart,
//                                 color: Colors.deepOrange.shade600,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'CLAIM OFFER NOW',
//                                 style: TextStyle(
//                                   color: Colors.deepOrange.shade600,
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 0.5,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
                    
//                     const SizedBox(height: 12),
                    
//                     // Timer or urgency text
//                     Text(
//                       'Offer expires in 24 hours ⏰',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.8),
//                         fontSize: 12,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTicketPattern() {
//     return Positioned.fill(
//       child: CustomPaint(
//         painter: TicketPatternPainter(),
//       ),
//     );
//   }
// }

// // Custom clipper for ticket shape
// class TicketClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     Path path = Path();
//     double radius = 15.0;
//     double cutoutSize = 20.0;
    
//     // Top edge
//     path.moveTo(radius, 0);
//     path.lineTo(size.width - radius, 0);
//     path.arcToPoint(
//       Offset(size.width, radius),
//       radius: Radius.circular(radius),
//     );
    
//     // Right edge with cutout
//     path.lineTo(size.width, size.height * 0.4);
//     path.arcToPoint(
//       Offset(size.width - cutoutSize, size.height * 0.5),
//       radius: Radius.circular(cutoutSize),
//       clockwise: false,
//     );
//     path.arcToPoint(
//       Offset(size.width, size.height * 0.6),
//       radius: Radius.circular(cutoutSize),
//       clockwise: false,
//     );
    
//     // Bottom right
//     path.lineTo(size.width, size.height - radius);
//     path.arcToPoint(
//       Offset(size.width - radius, size.height),
//       radius: Radius.circular(radius),
//     );
    
//     // Bottom edge
//     path.lineTo(radius, size.height);
//     path.arcToPoint(
//       Offset(0, size.height - radius),
//       radius: Radius.circular(radius),
//     );
    
//     // Left edge with cutout
//     path.lineTo(0, size.height * 0.6);
//     path.arcToPoint(
//       Offset(cutoutSize, size.height * 0.5),
//       radius: Radius.circular(cutoutSize),
//       clockwise: false,
//     );
//     path.arcToPoint(
//       Offset(0, size.height * 0.4),
//       radius: Radius.circular(cutoutSize),
//       clockwise: false,
//     );
    
//     // Top left
//     path.lineTo(0, radius);
//     path.arcToPoint(
//       Offset(radius, 0),
//       radius: Radius.circular(radius),
//     );
    
//     return path;
//   }

//   @override
//   bool shouldReclip(CustomClipper<Path> oldClipper) => false;
// }

// // Custom painter for ticket pattern
// class TicketPatternPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint paint = Paint()
//       ..color = Colors.white.withOpacity(0.1)
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;

//     // Draw dashed lines
//     double dashHeight = 8;
//     double dashSpace = 6;
//     double startY = 0;

//     // Vertical dashed line in the middle
//     double centerX = size.width / 2;
//     while (startY < size.height) {
//       canvas.drawLine(
//         Offset(centerX, startY),
//         Offset(centerX, startY + dashHeight),
//         paint,
//       );
//       startY += dashHeight + dashSpace;
//     }

//     // Draw some decorative circles
//     paint.style = PaintingStyle.fill;
//     paint.color = Colors.white.withOpacity(0.05);
    
//     canvas.drawCircle(
//       Offset(size.width * 0.2, size.height * 0.3),
//       30,
//       paint,
//     );
    
//     canvas.drawCircle(
//       Offset(size.width * 0.8, size.height * 0.7),
//       20,
//       paint,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }