// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class ReferEarnScreen extends StatelessWidget {
//   const ReferEarnScreen({super.key});

//   final String inviteCode = "HGT9LL8MEE";


//   bool _isDesktop(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 1024;

//   bool _isTablet(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     return w >= 600 && w < 1024;
//   }
   

//     double _maxWidth(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     if (w >= 1400) return 1200;
//     if (w >= 1100) return 1050;
//     return double.infinity;
//   }

//   double _pagePadding(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     if (w >= 1200) return 32;
//     if (w >= 900) return 24;
//     return 16;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;

//     final desktop = _isDesktop(context);
//     final tablet = _isTablet(context);


// final padding = _pagePadding(context);
    
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Text(
//           "Invite Friends",
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: isDarkMode ? theme.cardColor : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new,
//               size: 18,
//               color: isDarkMode ? Colors.white : Colors.black87,
//             ),
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
          
//           child: ConstrainedBox(
//             constraints: BoxConstraints(maxWidth: _maxWidth(context)),
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 children: [
//                   // Hero Section with Gradient Card
//                   Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           Color(0xFF4CAF50),
//                           Color(0xFF2E7D32),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(24),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.green.withOpacity(0.3),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(24.0),
//                       child: Column(
//                         children: [
//                           // Illustration placeholder
//                           Container(
//                             height: 160,
//                             width: 160,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.2),
//                               borderRadius: BorderRadius.circular(80),
//                             ),
//                             child: const Icon(
//                               Icons.card_giftcard_rounded,
//                               size: 80,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 24),
//                           const Text(
//                             "🎉 Earn Rewards!",
//                             style: TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Text(
//                             "Refer 10 friends this month and earn up to ₹3,000!\nThat's equal to a month's subscription.",
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.white.withOpacity(0.9),
//                               height: 1.5,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
            
//                   const SizedBox(height: 32),
            
//                   // Invite Code Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: theme.cardColor,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 16,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(12),
//                               decoration: BoxDecoration(
//                                 color: theme.colorScheme.primary.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: Icon(
//                                 Icons.confirmation_number_rounded,
//                                 color: theme.colorScheme.primary,
//                                 size: 24,
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     "Your Invite Code",
//                                     style: theme.textTheme.titleMedium?.copyWith(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                   Text(
//                                     "Share this code with friends",
//                                     style: theme.textTheme.bodyMedium?.copyWith(
//                                       color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Container(
//                           width: double.infinity,
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               colors: [
//                                 theme.colorScheme.primary.withOpacity(0.1),
//                                 theme.colorScheme.primary.withOpacity(0.2),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: theme.colorScheme.primary.withOpacity(0.3),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Text(
//                             inviteCode,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 24,
//                               color: theme.colorScheme.primary,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 3,
//                               fontFamily: 'monospace',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
            
//                   const SizedBox(height: 24),
            
//                   // Action Buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 56,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: theme.colorScheme.primary.withOpacity(0.5),
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(16),
//                               onTap: () {
//                                 Clipboard.setData(ClipboardData(text: inviteCode));
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Row(
//                                       children: [
//                                         Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
//                                         const SizedBox(width: 12),
//                                         Text("Invite code copied!"),
//                                       ],
//                                     ),
//                                     backgroundColor: theme.colorScheme.primary,
//                                     behavior: SnackBarBehavior.floating,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 );
//                               },
//                               child: Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.copy_rounded,
//                                       color: theme.colorScheme.primary,
//                                       size: 20,
//                                     ),
//                                     const SizedBox(width: 8),
//                                     Text(
//                                       "Copy Code",
//                                       style: TextStyle(
//                                         color: theme.colorScheme.primary,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Container(
//                           height: 56,
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.green.withOpacity(0.3),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               borderRadius: BorderRadius.circular(16),
//                               onTap: () {
//                                 Share.share(
//                                   "🎉 Join me on this amazing app and earn rewards! Use my invite code: $inviteCode to get started!\n\nDownload the app and enter this code during registration to get your bonus!",
//                                 );
//                               },
//                               child: const Center(
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Icon(
//                                       Icons.share_rounded,
//                                       color: Colors.white,
//                                       size: 20,
//                                     ),
//                                     SizedBox(width: 8),
//                                     Text(
//                                       "Share Code",
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
            
//                   const SizedBox(height: 32),
            
//                   // How it Works Section
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(24),
//                     decoration: BoxDecoration(
//                       color: theme.cardColor,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 16,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "How it works",
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                         _buildHowItWorksStep(
//                           icon: Icons.share_rounded,
//                           title: "Share your code",
//                           subtitle: "Send your unique invite code to friends",
//                           color: theme.colorScheme.primary,
//                           theme: theme,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildHowItWorksStep(
//                           icon: Icons.person_add_rounded,
//                           title: "Friend signs up",
//                           subtitle: "They use your code during registration",
//                           color: Colors.orange,
//                           theme: theme,
//                         ),
//                         const SizedBox(height: 16),
//                         _buildHowItWorksStep(
//                           icon: Icons.card_giftcard_rounded,
//                           title: "Both earn rewards",
//                           subtitle: "Get ₹300 for each successful referral",
//                           color: Colors.green,
//                           theme: theme,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHowItWorksStep({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required ThemeData theme,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 24,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class QRScanResultScreen extends StatelessWidget {
//   final String qrData;

//   const QRScanResultScreen({super.key, required this.qrData});

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDarkMode = theme.brightness == Brightness.dark;
//     final inviteData = _parseQRData(qrData);
    
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         title: Text(
//           "Invite Received",
//           style: theme.textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: isDarkMode ? theme.cardColor : Colors.white,
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Icon(
//               Icons.arrow_back_ios_new,
//               size: 18,
//               color: isDarkMode ? Colors.white : Colors.black87,
//             ),
//           ),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             children: [
//               // Success Animation Container
//               Container(
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFF4CAF50),
//                       Color(0xFF2E7D32),
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.green.withOpacity(0.3),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10),
//                     ),
//                   ],
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(32.0),
//                   child: Column(
//                     children: [
//                       // Success Icon with Animation
//                       TweenAnimationBuilder<double>(
//                         tween: Tween<double>(begin: 0.0, end: 1.0),
//                         duration: const Duration(milliseconds: 800),
//                         curve: Curves.elasticOut,
//                         builder: (context, value, child) {
//                           return Transform.scale(
//                             scale: value,
//                             child: Container(
//                               height: 120,
//                               width: 120,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.2),
//                                 borderRadius: BorderRadius.circular(60),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.3),
//                                   width: 3,
//                                 ),
//                               ),
//                               child: const Icon(
//                                 Icons.check_circle_rounded,
//                                 size: 60,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 24),
//                       const Text(
//                         "🎉 Invitation Found!",
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Text(
//                         inviteData['message'] ?? "You've been invited to join our amazing app!",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white.withOpacity(0.9),
//                           height: 1.5,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 32),

//               // Invite Code Display
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(28),
//                 decoration: BoxDecoration(
//                   color: theme.cardColor,
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 20,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [
//                             theme.colorScheme.primary.withOpacity(0.1),
//                             theme.colorScheme.primary.withOpacity(0.2),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Icon(
//                         Icons.card_giftcard_rounded,
//                         size: 48,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     Text(
//                       "Your Invite Code",
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "Use this code when signing up",
//                       style: theme.textTheme.bodyMedium?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.6),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             theme.colorScheme.primary.withOpacity(0.2),
//                             theme.colorScheme.primary.withOpacity(0.3),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: theme.colorScheme.primary.withOpacity(0.4),
//                           width: 2,
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           Text(
//                             inviteData['code'] ?? 'INVALID',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               fontSize: 32,
//                               color: theme.colorScheme.primary,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 4,
//                               fontFamily: 'monospace',
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: theme.colorScheme.primary,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               "INVITE CODE",
//                               style: TextStyle(
//                                 color: theme.colorScheme.onPrimary,
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 1,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // Action Buttons
//               Column(
//                 children: [
//                   // Copy Code Button
//                   Container(
//                     width: double.infinity,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(18),
//                       border: Border.all(
//                         color: theme.colorScheme.primary.withOpacity(0.5),
//                         width: 2,
//                       ),
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(18),
//                         onTap: () {
//                           Clipboard.setData(ClipboardData(text: inviteData['code'] ?? ''));
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Row(
//                                 children: [
//                                   Icon(Icons.check_circle, color: theme.colorScheme.onPrimary),
//                                   const SizedBox(width: 12),
//                                   const Text("Invite code copied to clipboard!"),
//                                 ],
//                               ),
//                               backgroundColor: theme.colorScheme.primary,
//                               behavior: SnackBarBehavior.floating,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               margin: const EdgeInsets.all(16),
//                             ),
//                           );
//                         },
//                         child: Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.copy_rounded,
//                                 color: theme.colorScheme.primary,
//                                 size: 24,
//                               ),
//                               const SizedBox(width: 12),
//                               Text(
//                                 "Copy Invite Code",
//                                 style: TextStyle(
//                                   color: theme.colorScheme.primary,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
                  
//                   const SizedBox(height: 16),

//                   // Sign Up Button
//                   Container(
//                     width: double.infinity,
//                     height: 60,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
//                       ),
//                       borderRadius: BorderRadius.circular(18),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.green.withOpacity(0.4),
//                           blurRadius: 16,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(18),
//                         onTap: () {
//                           // Navigate to sign up screen with the invite code
//                           _navigateToSignUp(context, inviteData['code'] ?? '');
//                         },
//                         child: const Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.app_registration_rounded,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 "Sign Up Now",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 32),

//               // Benefits Section
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: theme.cardColor,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 16,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "🎁 What you'll get",
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     _buildBenefitItem(
//                       icon: Icons.stars_rounded,
//                       title: "Welcome Bonus",
//                       subtitle: "Get ₹300 bonus when you sign up",
//                       color: Colors.orange,
//                       theme: theme,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildBenefitItem(
//                       icon: Icons.people_rounded,
//                       title: "Referral Rewards",
//                       subtitle: "Earn more by inviting your friends",
//                       color: Colors.blue,
//                       theme: theme,
//                     ),
//                     const SizedBox(height: 16),
//                     _buildBenefitItem(
//                       icon: Icons.workspace_premium_rounded,
//                       title: "Premium Features",
//                       subtitle: "Access to exclusive app features",
//                       color: Colors.purple,
//                       theme: theme,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Map<String, String> _parseQRData(String qrData) {
//     try {
//       final Map<String, dynamic> data = json.decode(qrData);
//       return {
//         'code': data['code'] ?? '',
//         'message': data['message'] ?? '',
//         'app_name': data['app_name'] ?? '',
//         'type': data['type'] ?? '',
//       };
//     } catch (e) {
//       // If parsing fails, treat the entire QR data as the invite code
//       return {
//         'code': qrData,
//         'message': '🎉 You\'ve been invited! Use this code to join and earn rewards!',
//         'app_name': 'Your App Name',
//         'type': 'invite_code',
//       };
//     }
//   }

//   void _navigateToSignUp(BuildContext context, String inviteCode) {
//     // This would navigate to your sign up screen with the invite code pre-filled
//     // Example navigation:
//     // Navigator.pushNamed(context, '/signup', arguments: inviteCode);
    
//     // For demonstration, show a dialog
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.app_registration_rounded, color: Theme.of(context).colorScheme.primary),
//               const SizedBox(width: 12),
//               const Text("Ready to Sign Up!"),
//             ],
//           ),
//           content: Text(
//             "Navigate to sign up screen with invite code: $inviteCode\n\nThis code will be automatically filled in the registration form.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text("Got it!"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBenefitItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required ThemeData theme,
//   }) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Icon(
//             icon,
//             color: color,
//             size: 24,
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: theme.textTheme.titleMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               Text(
//                 subtitle,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: theme.colorScheme.onSurface.withOpacity(0.6),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }









import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  final String inviteCode = "HGT9LL8MEE";

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  bool _isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= 600 && w < 1024;
  }

  double _maxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 1200;
    if (w >= 1100) return 1050;
    return double.infinity;
  }

  double _pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 32;
    if (w >= 900) return 24;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final desktop = _isDesktop(context);
    final tablet = _isTablet(context);

    final padding = _pagePadding(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Invite Friends",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: 20,
              ),
              child: Column(
                children: [
                  /// Desktop: Hero + Invite Card side-by-side
                  /// Mobile/Tablet: stacked
                  if (desktop) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _heroCard(theme)),
                        const SizedBox(width: 24),
                        Expanded(child: _inviteCard(theme)),
                      ],
                    ),
                  ] else ...[
                    _heroCard(theme),
                    const SizedBox(height: 24),
                    _inviteCard(theme),
                  ],

                  const SizedBox(height: 24),

                  /// Action Buttons responsive
                  desktop || tablet
                      ? Row(
                          children: [
                            Expanded(child: _copyButton(context, theme)),
                            const SizedBox(width: 16),
                            Expanded(child: _shareButton(theme)),
                          ],
                        )
                      : Column(
                          children: [
                            _copyButton(context, theme),
                            const SizedBox(height: 14),
                            _shareButton(theme),
                          ],
                        ),

                  const SizedBox(height: 28),

                  _howItWorksSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ----------------- UI Widgets -----------------

  Widget _heroCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(80),
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "🎉 Earn Rewards!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Refer 10 friends this month and earn up to ₹3,000!\nThat's equal to a month's subscription.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inviteCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.confirmation_number_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Invite Code",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Share this code with friends",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              inviteCode,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 3,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _copyButton(BuildContext context, ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Clipboard.setData(ClipboardData(text: inviteCode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 12),
                    const Text("Invite code copied!"),
                  ],
                ),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copy_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Copy Code",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shareButton(ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Share.share(
              "🎉 Join me on this amazing app and earn rewards! Use my invite code: $inviteCode to get started!\n\nDownload the app and enter this code during registration to get your bonus!",
            );
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Share Code",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _howItWorksSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How it works",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildHowItWorksStep(
            icon: Icons.share_rounded,
            title: "Share your code",
            subtitle: "Send your unique invite code to friends",
            color: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildHowItWorksStep(
            icon: Icons.person_add_rounded,
            title: "Friend signs up",
            subtitle: "They use your code during registration",
            color: Colors.orange,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildHowItWorksStep(
            icon: Icons.card_giftcard_rounded,
            title: "Both earn rewards",
            subtitle: "Get ₹300 for each successful referral",
            color: Colors.green,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// ----------------------------------------------------------------------
/// QR RESULT SCREEN RESPONSIVE
/// ----------------------------------------------------------------------

class QRScanResultScreen extends StatelessWidget {
  final String qrData;

  const QRScanResultScreen({super.key, required this.qrData});

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  double _maxWidth(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1400) return 1200;
    if (w >= 1100) return 1050;
    return double.infinity;
  }

  double _pagePadding(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 1200) return 32;
    if (w >= 900) return 24;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final inviteData = _parseQRData(qrData);

    final desktop = _isDesktop(context);
    final padding = _pagePadding(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Invite Received",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDarkMode ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth(context)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 20),
              child: Column(
                children: [
                  if (desktop) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _successHero(theme, inviteData),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _inviteCodeCard(theme, inviteData),
                        ),
                      ],
                    ),
                  ] else ...[
                    _successHero(theme, inviteData),
                    const SizedBox(height: 24),
                    _inviteCodeCard(theme, inviteData),
                  ],

                  const SizedBox(height: 20),

                  _actionButtons(context, theme, inviteData),

                  const SizedBox(height: 28),

                  _benefitsSection(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _successHero(ThemeData theme, Map<String, String> inviteData) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4CAF50),
            Color(0xFF2E7D32),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "🎉 Invitation Found!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              inviteData['message'] ??
                  "You've been invited to join our amazing app!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inviteCodeCard(ThemeData theme, Map<String, String> inviteData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.1),
                  theme.colorScheme.primary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.card_giftcard_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Your Invite Code",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Use this code when signing up",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.2),
                  theme.colorScheme.primary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  inviteData['code'] ?? 'INVALID',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "INVITE CODE",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
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

  Widget _actionButtons(
      BuildContext context, ThemeData theme, Map<String, String> inviteData) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 700;

    final code = inviteData['code'] ?? '';

    if (isWide) {
      return Row(
        children: [
          Expanded(child: _copyInviteButton(context, theme, code)),
          const SizedBox(width: 16),
          Expanded(child: _signUpButton(context, theme, code)),
        ],
      );
    }

    return Column(
      children: [
        _copyInviteButton(context, theme, code),
        const SizedBox(height: 16),
        _signUpButton(context, theme, code),
      ],
    );
  }

  Widget _copyInviteButton(
      BuildContext context, ThemeData theme, String code) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 12),
                    const Text("Invite code copied to clipboard!"),
                  ],
                ),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.copy_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  "Copy Invite Code",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signUpButton(BuildContext context, ThemeData theme, String code) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _navigateToSignUp(context, code);
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.app_registration_rounded,
                    color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  "Sign Up Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefitsSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "🎁 What you'll get",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildBenefitItem(
            icon: Icons.stars_rounded,
            title: "Welcome Bonus",
            subtitle: "Get ₹300 bonus when you sign up",
            color: Colors.orange,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.people_rounded,
            title: "Referral Rewards",
            subtitle: "Earn more by inviting your friends",
            color: Colors.blue,
            theme: theme,
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.workspace_premium_rounded,
            title: "Premium Features",
            subtitle: "Access to exclusive app features",
            color: Colors.purple,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, String> _parseQRData(String qrData) {
    try {
      final Map<String, dynamic> data = json.decode(qrData);
      return {
        'code': data['code'] ?? '',
        'message': data['message'] ?? '',
        'app_name': data['app_name'] ?? '',
        'type': data['type'] ?? '',
      };
    } catch (e) {
      return {
        'code': qrData,
        'message': '🎉 You\'ve been invited! Use this code to join and earn rewards!',
        'app_name': 'Your App Name',
        'type': 'invite_code',
      };
    }
  }

  void _navigateToSignUp(BuildContext context, String inviteCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.app_registration_rounded,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              const Text("Ready to Sign Up!"),
            ],
          ),
          content: Text(
            "Navigate to sign up screen with invite code: $inviteCode\n\nThis code will be automatically filled in the registration form.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Got it!"),
            ),
          ],
        );
      },
    );
  }
}
