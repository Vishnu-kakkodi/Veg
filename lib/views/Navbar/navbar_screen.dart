
// // lib/views/navbar/navbar_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';

// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/provider/BookingProvider/booking_provider.dart';
// import 'package:veegify/provider/VersionProvider/version_provider.dart';

// import 'package:veegify/utils/responsive.dart';

// import 'package:veegify/views/home/home_screen.dart';
// import 'package:veegify/views/Wishlist/wishlist_screen.dart';
// import 'package:veegify/views/Cart/cart_screen.dart';
// import 'package:veegify/views/Booking/history_screen.dart';
// import 'package:veegify/views/ProfileScreen/profile_screen.dart';

// import 'package:veegify/widgets/bottom_navbar.dart';

// class NavbarScreen extends StatefulWidget {
//   final int initialIndex;

//   const NavbarScreen({super.key, this.initialIndex = 0});

//   @override
//   State<NavbarScreen> createState() => _NavbarScreenState();
// }

// class _NavbarScreenState extends State<NavbarScreen> {
//   User? user;
//   bool _isUpdateDialogOpen = false;

//   @override
//   void initState() {
//     super.initState();

//     user = UserPreferences.getUser();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<BottomNavbarProvider>().setIndex(widget.initialIndex);
//       context.read<CartProvider>().loadCart(user?.userId);
//       context.read<OrderProvider>().loadAllOrders(user?.userId);
//     });
//   }

//   void _onTabChange(int index) {
//     context.read<BottomNavbarProvider>().setIndex(index);

//     if (index == 2) {
//       context.read<CartProvider>().loadCart(user?.userId);
//     }
//     if (index == 3 || index == 4) {
//       context.read<OrderProvider>().loadAllOrders(user?.userId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = Responsive.isDesktop(context);
//     final navProvider = context.watch<BottomNavbarProvider>();
//     final versionProvider = context.watch<VersionProvider>();

//     final pages = const [
//       HomeScreen(),
//       WishlistScreen(),
//       CartScreen(),
//       HystoryScreen(),
//       ProfileScreen(),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (versionProvider.needsUpdate && !_isUpdateDialogOpen) {
//         _isUpdateDialogOpen = true;
//         _showUpdateDialog(context).then((_) {
//           _isUpdateDialogOpen = false;
//         });
//       }
//     });

//     return Scaffold(
//       body: Column(
//         children: [
//           if (isDesktop)
//             DesktopTopNavbar(
//               currentIndex: navProvider.currentIndex,
//               onTap: _onTabChange,
//             ),

//           Expanded(
//             child: IndexedStack(
//               index: navProvider.currentIndex,
//               children: pages,
//             ),
//           ),
//         ],
//       ),

//       // Mobile bottom nav
//       bottomNavigationBar: isDesktop
//           ? null
//           : BottomNavigationBar(
//               currentIndex: navProvider.currentIndex,
//               onTap: _onTabChange,
//               type: BottomNavigationBarType.fixed,
//               items: const [
//                 BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.favorite), label: 'Favourites'),
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.shopping_cart), label: 'Cart'),
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.list), label: 'History'),
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.person), label: 'Account'),
//               ],
//             ),
//     );
//   }

//   Future<void> _showUpdateDialog(BuildContext context) async {
//     const playStoreUrl =
//         'https://play.google.com/store/apps/details?id=com.veggify.veegify';

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text('Update Required'),
//         content: const Text('Please update to continue using Veegify'),
//         actions: [
//           TextButton(
//             onPressed: () => SystemNavigator.pop(),
//             child: const Text('Close App'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final uri = Uri.parse(playStoreUrl);
//               if (await canLaunchUrl(uri)) {
//                 await launchUrl(uri,
//                     mode: LaunchMode.externalApplication);
//               }
//             },
//             child: const Text('Update Now'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ===================================================================
// // ====================== DESKTOP TOP NAVBAR ==========================
// // ===================================================================











// // lib/views/navbar/navbar_screen.dart
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';

// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/provider/BookingProvider/booking_provider.dart';
// import 'package:veegify/provider/VersionProvider/version_provider.dart';

// import 'package:veegify/utils/responsive.dart';

// import 'package:veegify/views/home/home_screen.dart';
// import 'package:veegify/views/Wishlist/wishlist_screen.dart';
// import 'package:veegify/views/Cart/cart_screen.dart';
// import 'package:veegify/views/Booking/history_screen.dart';
// import 'package:veegify/views/ProfileScreen/profile_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';

// class NavbarScreen extends StatefulWidget {
//   final int initialIndex;

//   const NavbarScreen({super.key, this.initialIndex = 0});

//   @override
//   State<NavbarScreen> createState() => _NavbarScreenState();
// }

// class _NavbarScreenState extends State<NavbarScreen> {
//   User? user;
//   bool _isUpdateDialogOpen = false;

//   @override
//   void initState() {
//     super.initState();

//     user = UserPreferences.getUser();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<BottomNavbarProvider>().setIndex(widget.initialIndex);
//       context.read<CartProvider>().loadCart(user?.userId);
//       context.read<OrderProvider>().loadAllOrders(user?.userId);
//     });
//   }

//   void _onTabChange(int index) {
//     context.read<BottomNavbarProvider>().setIndex(index);

//     if (index == 2) {
//       context.read<CartProvider>().loadCart(user?.userId);
//     }

//     if (index == 3 || index == 4) {
//       context.read<OrderProvider>().loadAllOrders(user?.userId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = Responsive.isDesktop(context);
//     final navProvider = context.watch<BottomNavbarProvider>();
//     final versionProvider = context.watch<VersionProvider>();

//     final pages = const [
//       HomeScreen(),
//       WishlistScreen(),
//       CartScreen(),
//       HystoryScreen(),
//       ProfileScreen(),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (versionProvider.needsUpdate && !_isUpdateDialogOpen) {
//         _isUpdateDialogOpen = true;
//         _showUpdateDialog(context).then((_) {
//           _isUpdateDialogOpen = false;
//         });
//       }
//     });

//     return Scaffold(
//       body: Column(
//         children: [
//           if (isDesktop)
//             DesktopTopNavbar(
//               currentIndex: navProvider.currentIndex,
//               onTap: _onTabChange,
//             ),
//           Expanded(
//             child: IndexedStack(
//               index: navProvider.currentIndex,
//               children: pages,
//             ),
//           ),
//         ],
//       ),

//       /// ✅ MOBILE CUSTOM NAVBAR
//       bottomNavigationBar: isDesktop
//           ? null
//           : CustomMobileNavbar(
//               currentIndex: navProvider.currentIndex,
//               onTap: _onTabChange,
//             ),
//     );
//   }

//   Future<void> _showUpdateDialog(BuildContext context) async {
//     const playStoreUrl =
//         'https://play.google.com/store/apps/details?id=com.veggify.veegify';

//     await showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text('Update Required'),
//         content: const Text('Please update to continue using Veegify'),
//         actions: [
//           TextButton(
//             onPressed: () => SystemNavigator.pop(),
//             child: const Text('Close App'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final uri = Uri.parse(playStoreUrl);
//               if (await canLaunchUrl(uri)) {
//                 await launchUrl(uri,
//                     mode: LaunchMode.externalApplication);
//               }
//             },
//             child: const Text('Update Now'),
//           ),
//         ],
//       ),
//     );
//   }
// }


// class CustomMobileNavbar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomMobileNavbar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const activeColor = Color(0xFFFF5A2C);

//     return Container(
//       height: 75,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade100,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [

//           _navItem(Icons.home_outlined, "Home", 0, activeColor),
//           _navItem(Icons.favorite_border, "Saved", 1, activeColor),

//           /// 🔥 CENTER ORANGE CART BUTTON
//           GestureDetector(
//             onTap: () => onTap(2),
//             child: Container(
//               height: 58,
//               width: 58,
//               decoration: const BoxDecoration(
//                 color: activeColor,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.shopping_bag_outlined,
//                 color: Colors.white,
//                 size: 26,
//               ),
//             ),
//           ),

//           _navItem(Icons.receipt_long_outlined, "Orders", 3, activeColor),
//           _navItem(Icons.person_outline, "Profile", 4, activeColor),
//         ],
//       ),
//     );
//   }

//   Widget _navItem(
//       IconData icon, String label, int index, Color activeColor) {
//     final bool isActive = currentIndex == index;

//     return GestureDetector(
//       onTap: () => onTap(index),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             icon,
//             size: 22,
//             color: isActive ? activeColor : Colors.grey,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: isActive ? activeColor : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// class DesktopTopNavbar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const DesktopTopNavbar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Container(
//       height: 70,
//       width: double.infinity,
//       color: const Color.fromARGB(255, 176, 255, 183), // 🌿 Light green
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 64),
//         child: Row(
//           children: [
//             // ---------------- LEFT: LOGO ----------------
//             Row(
//               children: [
//                 Image.asset(
//                   'assets/images/logo.png',
//                   height: 38,
//                   errorBuilder: (_, __, ___) => Icon(
//                     Icons.shopping_basket,
//                     size: 36,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Vegiffy',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: colorScheme.primary,
//                   ),
//                 ),
//               ],
//             ),

//             const Spacer(),

//             // ---------------- RIGHT: NAV ITEMS ----------------
//             _NavItem(
//               label: 'Home',
//               icon: Icons.home_rounded,
//               index: 0,
//               currentIndex: currentIndex,
//               onTap: onTap,
//             ),
//             _NavItem(
//               label: 'Favourites',
//               icon: Icons.favorite_rounded,
//               index: 1,
//               currentIndex: currentIndex,
//               onTap: onTap,
//             ),
//             _NavItem(
//               label: 'Cart',
//               icon: Icons.shopping_cart_rounded,
//               index: 2,
//               currentIndex: currentIndex,
//               onTap: onTap,
//             ),
//             _NavItem(
//               label: 'History',
//               icon: Icons.receipt_long_rounded,
//               index: 3,
//               currentIndex: currentIndex,
//               onTap: onTap,
//             ),
//             _NavItem(
//               label: 'Account',
//               icon: Icons.person_rounded,
//               index: 4,
//               currentIndex: currentIndex,
//               onTap: onTap,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _NavItem extends StatefulWidget {
//   final String label;
//   final IconData icon;
//   final int index;
//   final int currentIndex;
//   final Function(int) onTap;

//   const _NavItem({
//     required this.label,
//     required this.icon,
//     required this.index,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   State<_NavItem> createState() => _NavItemState();
// }

// class _NavItemState extends State<_NavItem> {
//   bool hovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isActive = widget.index == widget.currentIndex;

//     return MouseRegion(
//       onEnter: (_) => setState(() => hovered = true),
//       onExit: (_) => setState(() => hovered = false),
//       child: GestureDetector(
//         onTap: () => widget.onTap(widget.index),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 6),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? colorScheme.primary.withOpacity(0.15)
//                 : hovered
//                     ? colorScheme.primary.withOpacity(0.08)
//                     : Colors.transparent,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 widget.icon,
//                 size: 18,
//                 color: isActive
//                     ? colorScheme.primary
//                     : colorScheme.onSurface.withOpacity(0.7),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 widget.label,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight:
//                       isActive ? FontWeight.w600 : FontWeight.w500,
//                   color: isActive
//                       ? colorScheme.primary
//                       : colorScheme.onSurface.withOpacity(0.8),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }









// lib/views/navbar/navbar_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/user_model.dart';

import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/provider/BookingProvider/booking_provider.dart';
import 'package:veegify/provider/VersionProvider/version_provider.dart';

import 'package:veegify/utils/responsive.dart';

import 'package:veegify/views/home/home_screen.dart';
import 'package:veegify/views/Wishlist/wishlist_screen.dart';
import 'package:veegify/views/Cart/cart_screen.dart';
import 'package:veegify/views/Booking/history_screen.dart';
import 'package:veegify/views/ProfileScreen/profile_screen.dart';
import 'package:veegify/widgets/bottom_navbar.dart';

class NavbarScreen extends StatefulWidget {
  final int initialIndex;

  const NavbarScreen({super.key, this.initialIndex = 0});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  User? user;
  bool _isUpdateDialogOpen = false;

  // Orange color constants
  static const Color orangePrimary = Color(0xFFFF5A2C);
  static const Color orangeLight = Color(0xFFFF8A5C);
  static const Color orangeVeryLight = Color(0xFFFFE9E0);

  @override
  void initState() {
    super.initState();

    user = UserPreferences.getUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set user ID in cart provider
      if (user?.userId != null) {
        context.read<CartProvider>().setUserId(user!.userId);
      }
      
      context.read<BottomNavbarProvider>().setIndex(widget.initialIndex);
      context.read<CartProvider>().loadCart(user?.userId);
      context.read<OrderProvider>().loadAllOrders(user?.userId);
    });
  }

  void _onTabChange(int index) {
    context.read<BottomNavbarProvider>().setIndex(index);

    if (index == 2) {
      context.read<CartProvider>().loadCart(user?.userId);
    }

    if (index == 3 || index == 4) {
      context.read<OrderProvider>().loadAllOrders(user?.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final navProvider = context.watch<BottomNavbarProvider>();
    final versionProvider = context.watch<VersionProvider>();
    final cartProvider = context.watch<CartProvider>();

    final pages = const [
      HomeScreen(),
      WishlistScreen(),
      CartScreen(),
      HystoryScreen(),
      ProfileScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (versionProvider.needsUpdate && !_isUpdateDialogOpen) {
        _isUpdateDialogOpen = true;
        _showUpdateDialog(context).then((_) {
          _isUpdateDialogOpen = false;
        });
      }
    });

    return Scaffold(
      body: Column(
        children: [
          if (isDesktop)
            DesktopTopNavbar(
              currentIndex: navProvider.currentIndex,
              onTap: _onTabChange,
              cartItemCount: cartProvider.totalItems,
            ),
          Expanded(
            child: IndexedStack(
              index: navProvider.currentIndex,
              children: pages,
            ),
          ),
        ],
      ),

      /// ✅ MOBILE CUSTOM NAVBAR WITH FLOATING CART
      bottomNavigationBar: isDesktop
          ? null
          : Stack(
              clipBehavior: Clip.none,
              children: [
                // Bottom navigation bar
                CustomMobileNavbar(
                  currentIndex: navProvider.currentIndex,
                  onTap: _onTabChange,
                ),
                
                // Floating cart button
                Positioned(
                  top: -20, // Adjust this value to control how high it floats
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () => _onTabChange(2),
                      child: Container(
                        height: 65,
                        width: 65,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [orangePrimary, orangeLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: orangePrimary.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Center(
                              child: Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            
                            // Cart badge - using cartProvider.totalItems
                            if (cartProvider.totalItems > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${cartProvider.totalItems}',
                                    style: const TextStyle(
                                      color: orangePrimary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              
                            // Show "!" if vendor is inactive
                            if (cartProvider.hasItems && !cartProvider.isVendorActive)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    const playStoreUrl =
        'https://play.google.com/store/apps/details?id=com.veggify.veegify';

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Update Required'),
        content: const Text('Please update to continue using Veegify'),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Close App'),
          ),
          ElevatedButton(
            onPressed: () async {
              final uri = Uri.parse(playStoreUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri,
                    mode: LaunchMode.externalApplication);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: orangePrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}

class CustomMobileNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomMobileNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Orange color constants
  static const Color orangePrimary = Color(0xFFFF5A2C);
  static const Color orangeLight = Color(0xFFFF8A5C);

  @override
  Widget build(BuildContext context) {
    // Watch cart provider for badge updates
    final cartProvider = context.watch<CartProvider>();
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home - left side
          Expanded(
            child: _navItem(
              Icons.home_outlined, 
              "Home", 
              0, 
              orangePrimary,
              showBadge: false,
            ),
          ),
          
          // Saved - left side
          Expanded(
            child: _navItem(
              Icons.favorite_border, 
              "Saved", 
              1, 
              orangePrimary,
              showBadge: false,
            ),
          ),

          /// Empty space in the middle for floating cart button
          const SizedBox(width: 70),

          // Orders - right side
          Expanded(
            child: _navItem(
              Icons.receipt_long_outlined, 
              "Orders", 
              3, 
              orangePrimary,
              showBadge: false,
            ),
          ),
          
          // Profile - right side
          Expanded(
            child: _navItem(
              Icons.person_outline, 
              "Profile", 
              4, 
              orangePrimary,
              showBadge: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    IconData icon, 
    String label, 
    int index, 
    Color activeColor, {
    required bool showBadge,
    int badgeCount = 0,
  }) {
    final bool isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? activeColor : Colors.grey,
              ),
              
              // Optional badge (currently not used for any nav items)
              if (showBadge && badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isActive ? activeColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopTopNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final int cartItemCount;

  const DesktopTopNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.cartItemCount,
  });

  // Orange color constants
  static const Color orangePrimary = Color(0xFFFF5A2C);
  static const Color orangeLight = Color(0xFFFF8A5C);
  static const Color orangeVeryLight = Color(0xFFFFE9E0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 70,
      width: double.infinity,
      color: orangeVeryLight, // Light orange background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Row(
          children: [
            // ---------------- LEFT: LOGO ----------------
            Row(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 38,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.shopping_basket,
                    size: 36,
                    color: orangePrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Veegify',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: orangePrimary,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // ---------------- RIGHT: NAV ITEMS ----------------
            _NavItem(
              label: 'Home',
              icon: Icons.home_rounded,
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              label: 'Favourites',
              icon: Icons.favorite_rounded,
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            
            // Cart item with badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                _NavItem(
                  label: 'Cart',
                  icon: Icons.shopping_cart_rounded,
                  index: 2,
                  currentIndex: currentIndex,
                  onTap: onTap,
                ),
                
                // Cart badge
                if (cartItemCount > 0)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: orangePrimary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        cartItemCount > 9 ? '9+' : cartItemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            
            _NavItem(
              label: 'History',
              icon: Icons.receipt_long_rounded,
              index: 3,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              label: 'Account',
              icon: Icons.person_rounded,
              index: 4,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool hovered = false;

  // Orange color constants
  static const Color orangePrimary = Color(0xFFFF5A2C);
  static const Color orangeLight = Color(0xFFFF8A5C);
  static const Color orangeVeryLight = Color(0xFFFFE9E0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.index == widget.currentIndex;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? orangePrimary.withOpacity(0.15)
                : hovered
                    ? orangePrimary.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: isActive
                    ? orangePrimary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? orangePrimary
                      : theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}