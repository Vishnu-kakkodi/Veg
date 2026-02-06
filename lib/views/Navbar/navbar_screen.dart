
// // lib/views/navbar/navbar_screen.dart
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/user_model.dart';
// import 'package:veegify/model/order.dart';

// import 'package:veegify/provider/CartProvider/cart_provider.dart';
// import 'package:veegify/provider/BookingProvider/booking_provider.dart';
// import 'package:veegify/provider/VersionProvider/version_provider.dart';

// import 'package:veegify/utils/responsive.dart';

// import 'package:veegify/views/home/home_screen.dart';
// import 'package:veegify/views/Wishlist/wishlist_screen.dart';
// import 'package:veegify/views/Cart/cart_screen.dart';
// import 'package:veegify/views/Booking/history_screen.dart';
// import 'package:veegify/views/ProfileScreen/profile_screen.dart';
// import 'package:veegify/views/Booking/accepted_order_polling_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';

// class NavbarScreen extends StatefulWidget {
//   final int initialIndex;

//   const NavbarScreen({
//     super.key,
//     this.initialIndex = 0,
//   });

//   @override
//   State<NavbarScreen> createState() => _NavbarScreenState();
// }

// class _NavbarScreenState extends State<NavbarScreen> {
//   User? user;

//   bool _showCartSummary = true;
//   bool _showBookingSummary = true;
//   bool _isUpdateDialogOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     _initialize();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context
//           .read<BottomNavbarProvider>()
//           .setIndex(widget.initialIndex.clamp(0, 4));
//     });
//   }

//   Future<void> _initialize() async {
//     final userData = UserPreferences.getUser();
//     if (userData != null) user = userData;

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CartProvider>().loadCart(user?.userId);
//       context.read<OrderProvider>().loadAllOrders(user?.userId);
//     });
//   }

//   void _handleTabChange(int index) {
//     final nav = context.read<BottomNavbarProvider>();
//     nav.setIndex(index);

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
//     final theme = Theme.of(context);

//     final pages = [
//       HomeScreen(),
//       const WishlistScreen(),
//       CartScreen(),
//       const HystoryScreen(),
//       ProfileScreen(),
//     ];

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (versionProvider.needsUpdate && !_isUpdateDialogOpen) {
//         _isUpdateDialogOpen = true;
//         _showUpdateDialog(context, versionProvider).then((_) {
//           _isUpdateDialogOpen = false;
//         });
//       }
//     });

//     return Scaffold(
// body: isDesktop
//     ? Row(
//         children: [
//           DesktopSideNavbar(
//             currentIndex: navProvider.currentIndex,
//             onTap: _handleTabChange,
//           ),
//           Expanded(
//             child: IndexedStack(
//               index: navProvider.currentIndex,
//               children: pages,
//             ),
//           ),
//         ],
//       )
//     : IndexedStack(
//         index: navProvider.currentIndex,
//         children: pages,
//       ),


//       // ✅ Mobile bottom bar stays
//       bottomNavigationBar: isDesktop
//           ? null
//           : BottomNavigationBar(
//               currentIndex: navProvider.currentIndex,
//               onTap: _handleTabChange,
//               type: BottomNavigationBarType.fixed,
//               items: const [
//                 BottomNavigationBarItem(
//                     icon: Icon(Icons.home), label: 'Home'),
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

  

//   // ---------------- UPDATE DIALOG (UNCHANGED) ----------------

//   Future<void> _showUpdateDialog(
//     BuildContext context,
//     VersionProvider versionProvider,
//   ) async {
//     const playStoreUrl =
//         'https://play.google.com/store/apps/details?id=com.veggify.veegify';
//     final url = Platform.isIOS ? playStoreUrl : playStoreUrl;

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
//               final uri = Uri.parse(url);
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
// // ====================== DESKTOP SIDE NAV ============================
// // ===================================================================

// class DesktopSideNavbar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const DesktopSideNavbar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Container(
//       width: 260,
//       height: double.infinity,
//       decoration: BoxDecoration(
//         color: colorScheme.surface,
//         border: Border(
//           right: BorderSide(
//             color: colorScheme.outline.withOpacity(0.1),
//           ),
//         ),
//       ),
//       child: Column(
//         children: [
//           const SizedBox(height: 24),

//           // ---------------- LOGO / BRAND ----------------
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20),
//             child: Row(
//               children: [
//                 Image.asset(
//                   'assets/images/logo.png',
//                   height: 36,
//                 ),
//                 const SizedBox(width: 10),
//                 Text(
//                   'Veegiffy',
//                   style: theme.textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 32),

//           // ---------------- NAV ITEMS ----------------
//           _SideNavItem(
//             icon: Icons.home_rounded,
//             label: 'Home',
//             index: 0,
//             currentIndex: currentIndex,
//             onTap: onTap,
//           ),
//           _SideNavItem(
//             icon: Icons.favorite_rounded,
//             label: 'Favourites',
//             index: 1,
//             currentIndex: currentIndex,
//             onTap: onTap,
//           ),
//           _SideNavItem(
//             icon: Icons.shopping_cart_rounded,
//             label: 'Cart',
//             index: 2,
//             currentIndex: currentIndex,
//             onTap: onTap,
//           ),
//           _SideNavItem(
//             icon: Icons.receipt_long_rounded,
//             label: 'History',
//             index: 3,
//             currentIndex: currentIndex,
//             onTap: onTap,
//           ),
//           _SideNavItem(
//             icon: Icons.person_rounded,
//             label: 'Account',
//             index: 4,
//             currentIndex: currentIndex,
//             onTap: onTap,
//           ),

//           const Spacer(),

//           // ---------------- FOOTER ----------------
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Text(
//               '© 2026 Veegiffy',
//               style: theme.textTheme.bodySmall?.copyWith(
//                 color: colorScheme.onSurface.withOpacity(0.5),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }





// class _SideNavItem extends StatefulWidget {
//   final IconData icon;
//   final String label;
//   final int index;
//   final int currentIndex;
//   final Function(int) onTap;

//   const _SideNavItem({
//     required this.icon,
//     required this.label,
//     required this.index,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   State<_SideNavItem> createState() => _SideNavItemState();
// }

// class _SideNavItemState extends State<_SideNavItem> {
//   bool _hovered = false;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     final isActive = widget.index == widget.currentIndex;

//     return MouseRegion(
//       onEnter: (_) => setState(() => _hovered = true),
//       onExit: (_) => setState(() => _hovered = false),
//       child: InkWell(
//         onTap: () => widget.onTap(widget.index),
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? colorScheme.primary.withOpacity(0.12)
//                 : _hovered
//                     ? colorScheme.primary.withOpacity(0.06)
//                     : Colors.transparent,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Row(
//             children: [
//               // Active indicator bar
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 width: 4,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: isActive
//                       ? colorScheme.primary
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               ),
//               const SizedBox(width: 12),

//               Icon(
//                 widget.icon,
//                 size: 22,
//                 color: isActive
//                     ? colorScheme.primary
//                     : colorScheme.onSurface.withOpacity(0.7),
//               ),
//               const SizedBox(width: 14),

//               Text(
//                 widget.label,
//                 style: theme.textTheme.bodyLarge?.copyWith(
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

  @override
  void initState() {
    super.initState();

    user = UserPreferences.getUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            ),

          Expanded(
            child: IndexedStack(
              index: navProvider.currentIndex,
              children: pages,
            ),
          ),
        ],
      ),

      // Mobile bottom nav
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: navProvider.currentIndex,
              onTap: _onTabChange,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.favorite), label: 'Favourites'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart), label: 'Cart'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list), label: 'History'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: 'Account'),
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
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// ====================== DESKTOP TOP NAVBAR ==========================
// ===================================================================

class DesktopTopNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const DesktopTopNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 70,
      width: double.infinity,
      color: const Color.fromARGB(255, 64, 255, 80), // 🌿 Light green
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
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Vegiffy',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
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
            _NavItem(
              label: 'Cart',
              icon: Icons.shopping_cart_rounded,
              index: 2,
              currentIndex: currentIndex,
              onTap: onTap,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
                ? colorScheme.primary.withOpacity(0.15)
                : hovered
                    ? colorScheme.primary.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 18,
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
