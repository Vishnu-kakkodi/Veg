// // views/ProfileScreen/profile_screen.dart
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:veegify/provider/AuthProvider/auth_provider.dart';
// import 'package:veegify/provider/ProfileProvider.dart/profile_provider.dart';
// import 'package:veegify/views/ProfileScreen/edit_profile_screen.dart';
// import 'package:veegify/views/ProfileScreen/help_screen.dart';
// import 'package:veegify/views/Booking/booking_screen.dart';
// import 'package:veegify/views/ProfileScreen/settings.dart';
// import 'package:veegify/views/ProfileScreen/wallet.dart';
// import 'package:veegify/views/Tracker/tracking_screen_osm.dart';
// import 'package:veegify/views/address/address_list.dart';
// import 'package:veegify/views/home/invoice_screen.dart';
// import 'package:veegify/views/Navbar/navbar_screen.dart';
// import 'package:veegify/views/ProfileScreen/refer_earn_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class ProfileScreenWithController extends StatelessWidget {
//   final ScrollController scrollController;

//   const ProfileScreenWithController({
//     super.key,
//     required this.scrollController,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ProfileScreen(scrollController: scrollController);
//   }
// }

// class ProfileScreen extends StatefulWidget {
//   final ScrollController? scrollController;

//   const ProfileScreen({super.key, this.scrollController});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   @override
//   void initState() {
//     super.initState();
//     final profileProvider = Provider.of<ProfileProvider>(
//       context,
//       listen: false,
//     );
//     profileProvider.loadLocalUser().then(
//       (_) => profileProvider.fetchUserProfile(),
//     );
//   }

//   void _handleBackButton() {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => const NavbarScreen()),
//       (route) => false,
//     );

//     Provider.of<BottomNavbarProvider>(context, listen: false).setIndex(0);
//   }

//   void _launchAboutUsUrl() async {
//     final Uri url = Uri.parse('https://vegiffyy.com/');
//     try {
//       if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//         debugPrint('Could not launch $url');
//       }
//     } catch (e) {
//       debugPrint('Launch error: $e');
//     }
//   }

//   void _launchPrivacyUsUrl() async {
//     final Uri url = Uri.parse(
//       'https://vegiffy-policy.onrender.com/privacy-and-policy',
//     );

//     try {
//       if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
//         debugPrint('Could not launch $url');
//       }
//     } catch (e) {
//       debugPrint('Launch error: $e');
//     }
//   }

//   Widget _buildProfileOption({
//     required IconData icon,
//     required String title,
//     required Color backgroundColor,
//     VoidCallback? onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 20),
//         child: Row(
//           children: [
//             Container(
//               width: 30,
//               height: 30,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 color: backgroundColor,
//               ),
//               child: Icon(icon, color: Colors.white),
//             ),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> _onAvatarTap(BuildContext context) async {
//     // pick and upload via provider helper
//     final provider = Provider.of<ProfileProvider>(context, listen: false);
//     await provider.pickAndUploadImage();
//     // provider will update listeners and refresh UI
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Consumer<ProfileProvider>(
//           builder: (context, provider, child) {
//             final user = provider.user;
//             final imageUrl = provider.imageUrl;

//             return SingleChildScrollView(
//               controller: widget.scrollController,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     // Header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Align(
//                           alignment: Alignment.center,
//                           child: const Text(
//                             'My Account',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 30),

//                     // Enhanced Profile Card UI
//                     Container(
//                       margin: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                           colors: [
//                             Theme.of(context).colorScheme.primary,
//                             Theme.of(
//                               context,
//                             ).colorScheme.primary.withOpacity(0.8),
//                           ],
//                         ),
//                         borderRadius: BorderRadius.circular(24),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.primary.withOpacity(0.3),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Stack(
//                         children: [
//                           // Decorative circles in background
//                           Positioned(
//                             top: -50,
//                             right: -50,
//                             child: Container(
//                               width: 150,
//                               height: 150,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.1),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: -30,
//                             left: -30,
//                             child: Container(
//                               width: 100,
//                               height: 100,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white.withOpacity(0.1),
//                               ),
//                             ),
//                           ),

//                           // Main content
//                           Padding(
//                             padding: const EdgeInsets.all(24),
//                             child: Column(
//                               children: [
//                                 // Avatar with edit button
//                                 Stack(
//                                   children: [
//                                     GestureDetector(
//                                       onTap: () => _onAvatarTap(context),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           border: Border.all(
//                                             color: Colors.white,
//                                             width: 4,
//                                           ),
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black.withOpacity(
//                                                 0.2,
//                                               ),
//                                               blurRadius: 15,
//                                               offset: const Offset(0, 5),
//                                             ),
//                                           ],
//                                         ),
//                                         child: CircleAvatar(
//                                           radius: 55,
//                                           backgroundColor: Colors.white,
//                                           backgroundImage:
//                                               (imageUrl != null &&
//                                                   imageUrl.isNotEmpty)
//                                               ? NetworkImage(imageUrl)
//                                               : const AssetImage(
//                                                       'assets/images/default_avatar.png',
//                                                     )
//                                                     as ImageProvider,
//                                         ),
//                                       ),
//                                     ),
//                                     if (provider.loading)
//                                       Positioned.fill(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: Colors.black.withOpacity(
//                                               0.5,
//                                             ),
//                                           ),
//                                           child: const Center(
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 3,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                     Positioned(
//                                       bottom: 0,
//                                       right: 0,
//                                       child: Container(
//                                         padding: const EdgeInsets.all(8),
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           shape: BoxShape.circle,
//                                           boxShadow: [
//                                             BoxShadow(
//                                               color: Colors.black.withOpacity(
//                                                 0.2,
//                                               ),
//                                               blurRadius: 8,
//                                               offset: const Offset(0, 2),
//                                             ),
//                                           ],
//                                         ),
//                                         child: Icon(
//                                           Icons.camera_alt,
//                                           color: Theme.of(
//                                             context,
//                                           ).colorScheme.primary,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),

//                                 const SizedBox(height: 20),

//                                 if (user != null) ...[
//                                   // Name with edit button
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           user.fullName,
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 24,
//                                             color: Colors.white,
//                                             letterSpacing: 0.5,
//                                           ),
//                                           textAlign: TextAlign.center,
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 2,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.white.withOpacity(0.2),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: IconButton(
//                                           onPressed: () {
//                                             Navigator.push(
//                                               context,
//                                               MaterialPageRoute(
//                                                 builder: (_) =>
//                                                     EditProfileScreen(),
//                                               ),
//                                             );
//                                           },
//                                           icon: const Icon(
//                                             Icons.edit,
//                                             size: 18,
//                                             color: Colors.white,
//                                           ),
//                                           padding: const EdgeInsets.all(8),
//                                           constraints: const BoxConstraints(),
//                                         ),
//                                       ),
//                                     ],
//                                   ),

//                                   const SizedBox(height: 20),

//                                   // Info cards
//                                   Container(
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.15),
//                                       borderRadius: BorderRadius.circular(16),
//                                       border: Border.all(
//                                         color: Colors.white.withOpacity(0.2),
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         _buildInfoRow(
//                                           icon: Icons.email_outlined,
//                                           text: user.email,
//                                         ),
//                                         const SizedBox(height: 12),
//                                         Container(
//                                           height: 1,
//                                           color: Colors.white.withOpacity(0.2),
//                                         ),
//                                         const SizedBox(height: 12),
//                                         _buildInfoRow(
//                                           icon: Icons.phone_outlined,
//                                           text: user.phoneNumber,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],

//                                 const SizedBox(height: 8),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const Divider(),
//                     const SizedBox(height: 20),

//                     _buildProfileOption(
//                       icon: Icons.shopping_bag,
//                       title: 'Orders',
//                       backgroundColor: Colors.blue,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 BookingScreen(userId: user?.userId),
//                           ),
//                         );
//                       },
//                     ),

//                     _buildProfileOption(
//                       icon: Icons.location_on,
//                       title: 'Addresses',
//                       backgroundColor: Colors.green,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => AddressList(),
//                           ),
//                         );
//                       },
//                     ),

//                     _buildProfileOption(
//                       icon: Icons.card_giftcard,
//                       title: 'Refer & Earn',
//                       backgroundColor: Colors.black,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ReferEarnScreen(),
//                           ),
//                         );
//                       },
//                     ),

//                     _buildProfileOption(
//                       icon: Icons.wallet,
//                       title: 'Wallet',
//                       backgroundColor: Colors.black,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => WalletScreen(),
//                           ),
//                         );
//                       },
//                     ),

//                     const SizedBox(height: 15),
//                     const Divider(),

//                     const Row(
//                       children: [
//                         Text(
//                           'Support & Settings',
//                           style: TextStyle(
//                             color: Color.fromARGB(255, 104, 102, 102),
//                             fontSize: 15,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     _buildProfileOption(
//                       icon: Icons.settings,
//                       title: 'Settings',
//                       backgroundColor: const Color.fromARGB(255, 164, 164, 164),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LocationSettingsScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                     _buildProfileOption(
//                       icon: Icons.privacy_tip,
//                       title: 'Privacy Policy',
//                       backgroundColor: Colors.orange,
//                       onTap: _launchPrivacyUsUrl,
//                     ),

//                     _buildProfileOption(
//                       icon: Icons.info,
//                       title: 'About Us',
//                       backgroundColor: const Color.fromARGB(255, 140, 203, 255),
//                       onTap: _launchAboutUsUrl,
//                     ),

//                     _buildProfileOption(
//                       icon: Icons.help,
//                       title: 'Help',
//                       backgroundColor: Colors.blue,
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => HelpScreen()),
//                         );
//                       },
//                     ),

//                     _buildProfileOption(
//                       icon: Icons.logout,
//                       title: 'Logout',
//                       backgroundColor: const Color.fromARGB(255, 189, 90, 207),
//                       onTap: () {
//                         Provider.of<AuthProvider>(
//                           context,
//                           listen: false,
//                         ).logout(context);
//                       },
//                     ),

//                     //                                         _buildProfileOption(
//                     //                       icon: Icons.logout,
//                     //                       title: 'Tracker',
//                     //                       backgroundColor: const Color.fromARGB(255, 189, 90, 207),
//                     //                       onTap: () {
//                     //                         // Navigator.push(context, MaterialPageRoute(builder: (context)=>TrackingScreenGoogle()));
//                     //                         // Provider.of<AuthProvider>(context, listen: false)
//                     //                         //     .logout(context);
//                     //                         Navigator.push(
//                     //   context,
//                     //   MaterialPageRoute(
//                     //     builder: (_) => TrackingScreenGoogle(
//                     //       deliveryBoyId: '691b281934db761b6349ab49',
//                     //       userId: '68ef35a7447e0771c2b4aac4',
//                     //       // optional custom center and destination:
//                     //       initialCenter: LatLng(17.486681, 78.3914777),
//                     //     ),
//                     //   ),
//                     // );

//                     //                       },
//                     //                     ),
//                     const SizedBox(height: 20),
//                     if (provider.error != null)
//                       Text(
//                         provider.error!,
//                         style: const TextStyle(color: Colors.red),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // Helper method to add to your widget
//   Widget _buildInfoRow({required IconData icon, required String text}) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, color: Colors.white, size: 18),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             text,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//       ],
//     );
//   }
// }



















// views/ProfileScreen/profile_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veegify/provider/AuthProvider/auth_provider.dart';
import 'package:veegify/provider/ProfileProvider.dart/profile_provider.dart';
import 'package:veegify/views/ProfileScreen/edit_profile_screen.dart';
import 'package:veegify/views/ProfileScreen/help_screen.dart';
import 'package:veegify/views/Booking/booking_screen.dart';
import 'package:veegify/views/ProfileScreen/settings.dart';
import 'package:veegify/views/ProfileScreen/wallet.dart';
import 'package:veegify/views/Tracker/tracking_screen_osm.dart';
import 'package:veegify/views/address/address_list.dart';
import 'package:veegify/views/home/invoice_screen.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart';
import 'package:veegify/views/ProfileScreen/refer_earn_screen.dart';
import 'package:veegify/widgets/bottom_navbar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProfileScreenWithController extends StatelessWidget {
  final ScrollController scrollController;

  const ProfileScreenWithController({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileScreen(scrollController: scrollController);
  }
}

class ProfileScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ProfileScreen({super.key, this.scrollController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    profileProvider.loadLocalUser().then(
      (_) => profileProvider.fetchUserProfile(),
    );
  }

  void _handleBackButton() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const NavbarScreen()),
      (route) => false,
    );

    Provider.of<BottomNavbarProvider>(context, listen: false).setIndex(0);
  }

  void _launchAboutUsUrl() async {
    final Uri url = Uri.parse('https://vegiffyy.com/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }

  void _launchPrivacyUsUrl() async {
    final Uri url = Uri.parse(
      'https://vegiffy-policy.onrender.com/privacy-and-policy',
    );

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Launch error: $e');
    }
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color backgroundColor,
    VoidCallback? onTap,
    bool isWeb = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isWeb ? 16 : 20),
        padding: isWeb ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12) : null,
        decoration: isWeb
            ? BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: isWeb ? 40 : 30,
              height: isWeb ? 40 : 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: backgroundColor,
              ),
              child: Icon(icon, color: Colors.white, size: isWeb ? 20 : 18),
            ),
            SizedBox(width: isWeb ? 20 : 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: isWeb ? 15 : 14,
              ),
            ),
            if (isWeb) const Spacer(),
            if (isWeb)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onAvatarTap(BuildContext context) async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await provider.pickAndUploadImage();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebLayout = screenWidth > 600;
    final maxWidth = isWebLayout ? 1200.0 : double.infinity;
    final contentPadding = isWebLayout ? 40.0 : 16.0;

    return Scaffold(
      backgroundColor: isWebLayout ? Colors.grey.shade50 : Colors.white,
      body: SafeArea(
        child: Consumer<ProfileProvider>(
          builder: (context, provider, child) {
            final user = provider.user;
            final imageUrl = provider.imageUrl;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: Padding(
                    padding: EdgeInsets.all(contentPadding),
                    child: isWebLayout
                        ? _buildWebLayout(context, provider, user, imageUrl)
                        : _buildMobileLayout(context, provider, user, imageUrl),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWebLayout(
    BuildContext context,
    ProfileProvider provider,
    dynamic user,
    String? imageUrl,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column - Profile Card
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                _buildProfileCard(context, provider, user, imageUrl, isWeb: true),
                const SizedBox(height: 20),
                if (provider.error != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Right Column - Menu Options
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileOption(
                  icon: Icons.shopping_bag,
                  title: 'Orders',
                  backgroundColor: Colors.blue,
                  isWeb: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingScreen(userId: user?.userId),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.location_on,
                  title: 'Addresses',
                  backgroundColor: Colors.green,
                  isWeb: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressList()),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.card_giftcard,
                  title: 'Refer & Earn',
                  backgroundColor: Colors.black,
                  isWeb: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReferEarnScreen()),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.wallet,
                  title: 'Wallet',
                  backgroundColor: Colors.black,
                  isWeb: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalletScreen()),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Support & Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 104, 102, 102),
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: 'Settings',
                  backgroundColor: const Color.fromARGB(255, 164, 164, 164),
                  isWeb: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  backgroundColor: Colors.orange,
                  isWeb: true,
                  onTap: _launchPrivacyUsUrl,
                ),
                _buildProfileOption(
                  icon: Icons.info,
                  title: 'About Us',
                  backgroundColor: const Color.fromARGB(255, 140, 203, 255),
                  isWeb: true,
                  onTap: _launchAboutUsUrl,
                ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: 'Help',
                  backgroundColor: Colors.blue,
                  isWeb: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpScreen()),
                    );
                  },
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: 'Logout',
                  backgroundColor: const Color.fromARGB(255, 189, 90, 207),
                  isWeb: true,
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false).logout(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ProfileProvider provider,
    dynamic user,
    String? imageUrl,
  ) {
    return Column(
      children: [
        // Header
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Account',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        _buildProfileCard(context, provider, user, imageUrl, isWeb: false),

        const Divider(),
        const SizedBox(height: 20),

        _buildProfileOption(
          icon: Icons.shopping_bag,
          title: 'Orders',
          backgroundColor: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(userId: user?.userId),
              ),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.location_on,
          title: 'Addresses',
          backgroundColor: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddressList()),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.card_giftcard,
          title: 'Refer & Earn',
          backgroundColor: Colors.black,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReferEarnScreen()),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.wallet,
          title: 'Wallet',
          backgroundColor: Colors.black,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WalletScreen()),
            );
          },
        ),
        const SizedBox(height: 15),
        const Divider(),
        const Row(
          children: [
            Text(
              'Support & Settings',
              style: TextStyle(
                color: Color.fromARGB(255, 104, 102, 102),
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProfileOption(
          icon: Icons.settings,
          title: 'Settings',
          backgroundColor: const Color.fromARGB(255, 164, 164, 164),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationSettingsScreen(),
              ),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          backgroundColor: Colors.orange,
          onTap: _launchPrivacyUsUrl,
        ),
        _buildProfileOption(
          icon: Icons.info,
          title: 'About Us',
          backgroundColor: const Color.fromARGB(255, 140, 203, 255),
          onTap: _launchAboutUsUrl,
        ),
        _buildProfileOption(
          icon: Icons.help,
          title: 'Help',
          backgroundColor: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HelpScreen()),
            );
          },
        ),
        _buildProfileOption(
          icon: Icons.logout,
          title: 'Logout',
          backgroundColor: const Color.fromARGB(255, 189, 90, 207),
          onTap: () {
            Provider.of<AuthProvider>(context, listen: false).logout(context);
          },
        ),
        const SizedBox(height: 20),
        if (provider.error != null)
          Text(
            provider.error!,
            style: const TextStyle(color: Colors.red),
          ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ProfileProvider provider,
    dynamic user,
    String? imageUrl, {
    required bool isWeb,
  }) {
    return Container(
      margin: EdgeInsets.all(isWeb ? 0 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(isWeb ? 32 : 24),
            child: Column(
              children: [
                // Avatar with edit button
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _onAvatarTap(context),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: isWeb ? 65 : 55,
                          backgroundColor: Colors.white,
                          backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                              ? NetworkImage(imageUrl)
                              : const AssetImage('assets/images/default_avatar.png')
                                  as ImageProvider,
                        ),
                      ),
                    ),
                    if (provider.loading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(isWeb ? 10 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.primary,
                          size: isWeb ? 20 : 18,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isWeb ? 24 : 20),

                if (user != null) ...[
                  // Name with edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          user.fullName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isWeb ? 28 : 24,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.edit,
                            size: isWeb ? 20 : 18,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.all(isWeb ? 10 : 8),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isWeb ? 24 : 20),

                  // Info cards
                  Container(
                    padding: EdgeInsets.all(isWeb ? 20 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          text: user.email,
                          isWeb: isWeb,
                        ),
                        SizedBox(height: isWeb ? 16 : 12),
                        Container(
                          height: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        SizedBox(height: isWeb ? 16 : 12),
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          text: user.phoneNumber,
                          isWeb: isWeb,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    bool isWeb = false,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isWeb ? 10 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: isWeb ? 20 : 18),
        ),
        SizedBox(width: isWeb ? 16 : 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isWeb ? 16 : 15,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
