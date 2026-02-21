// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/cart_vendor_guard.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/wishlist_model.dart';
// import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
// import 'package:veegify/views/home/detail_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';

// // 👇 lifecycle service (update path if needed)
// import 'package:veegify/core/app_lifecycle_service.dart';

// class WishlistScreen extends StatefulWidget {
//   const WishlistScreen({Key? key}) : super(key: key);

//   @override
//   State<WishlistScreen> createState() => _WishlistScreenState();
// }

// class _WishlistScreenState extends State<WishlistScreen> {
//   String? userId;
//   bool _initialLoadTried = false; // avoid repeated fetch attempts
//   bool _firstLoaded = false; // for loader vs silent refresh

//   BottomNavbarProvider? _bottomNavbarProvider;
//   VoidCallback? _bottomNavListener;
//   static const int _wishlistTabIndex = 1; // your favourites tab index

//   Timer? _pollingTimer;

//   @override
//   void initState() {
//     super.initState();
//     debugPrint('WishlistScreen.initState called');

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       // Attach bottom nav & listener first
//       try {
//         _bottomNavbarProvider = Provider.of<BottomNavbarProvider>(
//           context,
//           listen: false,
//         );

//         _bottomNavListener = () {
//           final idx = _bottomNavbarProvider?.currentIndex;
//           debugPrint('Bottom nav index changed: $idx');
//           if (idx == _wishlistTabIndex) {
//             debugPrint('Wishlist tab became active, refreshing...');
//             if (userId == null || userId!.isEmpty) {
//               _loadUserIdAndFetch();
//             } else {
//               context.read<WishlistProvider>().fetchWishlist(userId!);
//             }
//             _startPolling();
//           } else {
//             _stopPolling();
//           }
//         };

//         _bottomNavbarProvider?.addListener(_bottomNavListener!);
//         debugPrint('Attached bottomNav listener in WishlistScreen ✅');
//       } catch (e, st) {
//         debugPrint('Could not attach BottomNavbarProvider listener: $e\n$st');
//       }

//       // Initial load
//       await _loadUserIdAndFetch();

//       // If this tab is already active, start polling
//       try {
//         if (_bottomNavbarProvider?.currentIndex == _wishlistTabIndex) {
//           _startPolling();
//         }
//       } catch (_) {}
//     });
//   }

//   @override
//   void dispose() {
//     try {
//       if (_bottomNavbarProvider != null && _bottomNavListener != null) {
//         _bottomNavbarProvider!.removeListener(_bottomNavListener!);
//       }
//     } catch (_) {}
//     _stopPolling();
//     super.dispose();
//   }

//   void _startPolling() {
//     if (_pollingTimer != null && _pollingTimer!.isActive) return;
//     debugPrint('Starting wishlist polling (every 5 seconds)');

//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (!mounted) return;

//       // ✔️ App must be foreground
//       if (!AppLifecycleService.instance.isAppInForeground) {
//         // debugPrint('⏸️ App background → skip wishlist polling');
//         return;
//       }

//       // ✔️ This tab must be active
//       if (_bottomNavbarProvider?.currentIndex != _wishlistTabIndex) {
//         // debugPrint('⏸️ Wishlist tab not active → skip polling');
//         return;
//       }

//       // ✔️ This route must be current (no DetailScreen on top)
//       final route = ModalRoute.of(context);
//       final isRouteCurrent = route?.isCurrent ?? true;
//       if (!isRouteCurrent) {
//         // debugPrint('⏸️ WishlistScreen not current route → skip polling');
//         return;
//       }

//       if (userId == null || userId!.isEmpty) {
//         await _loadUserIdAndFetch();
//         return;
//       }

//       try {
//         debugPrint(
//             '🔄 [Wishlist Poll] fetchWishlist for userId: $userId (tab active & route current)');
//         await context.read<WishlistProvider>().fetchWishlist(userId!);
//       } catch (e, st) {
//         debugPrint('Error in wishlist polling: $e\n$st');
//       }
//     });
//   }

//   void _stopPolling() {
//     if (_pollingTimer != null) {
//       debugPrint('Stopping wishlist polling');
//       _pollingTimer?.cancel();
//       _pollingTimer = null;
//     }
//   }

//   /// Make sure this returns after userId is set (async)
//   Future<String?> _loadUserId() async {
//     try {
//       debugPrint('-> _loadUserId start');
//       final user = await Future.value(UserPreferences.getUser());
//       debugPrint('UserPreferences.getUser() => $user');
//       if (user != null && mounted) {
//         setState(() {
//           userId = user.userId;
//         });
//         debugPrint('Loaded userId: $userId');
//         return userId;
//       } else {
//         debugPrint('No user found in preferences');
//         return null;
//       }
//     } catch (e, st) {
//       debugPrint('_loadUserId error: $e\n$st');
//       return null;
//     }
//   }

//   /// Single place to initialize wishlist safely
//   Future<void> _loadUserIdAndFetch() async {
//     if (!mounted) return;
//     debugPrint('>>> _loadUserIdAndFetch START');

//     try {
//       final loadedUserId = await _loadUserId();

//       if (loadedUserId == null || loadedUserId.isEmpty) {
//         debugPrint('No userId available - aborting fetchWishlist');
//         return;
//       }

//       // ensure provider exists
//       try {
//         Provider.of<WishlistProvider>(context, listen: false);
//         debugPrint('WishlistProvider found.');
//       } catch (e) {
//         debugPrint('WishlistProvider NOT found in widget tree! $e');
//         return;
//       }

//       if (_initialLoadTried) {
//         debugPrint('Initial load already tried, skipping fetchWishlist');
//         return;
//       }
//       _initialLoadTried = true;

//       debugPrint('Calling fetchWishlist for userId: $loadedUserId');
//       await context.read<WishlistProvider>().fetchWishlist(loadedUserId);
//       if (mounted) {
//         setState(() {
//           _firstLoaded = true;
//         });
//       }
//       debugPrint(
//         'fetchWishlist completed, list length: ${context.read<WishlistProvider>().wishlist.length}',
//       );
//     } catch (e, st) {
//       debugPrint('Exception in _loadUserIdAndFetch: $e\n$st');
//     } finally {
//       debugPrint('<<< _loadUserIdAndFetch END');
//     }
//   }

//   Future<void> _refreshWishlist() async {
//     if (userId != null) {
//       try {
//         await context.read<WishlistProvider>().fetchWishlist(userId!);
//       } catch (e, st) {
//         debugPrint('Error refreshing wishlist: $e\n$st');
//       }
//     } else {
//       await _loadUserIdAndFetch();
//     }
//   }

//   void _showRemoveDialog(
//     BuildContext context,
//     WishlistProduct product,
//     WishlistProvider provider,
//   ) {
//     final theme = Theme.of(context);

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: theme.dialogBackgroundColor,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Text('Remove from Wishlist', style: theme.textTheme.titleMedium),
//         content: Text(
//           'Are you sure you want to remove "${product.name}" from your wishlist?',
//           style: theme.textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text(
//               'Cancel',
//               style: TextStyle(
//                 color: theme.colorScheme.onSurface.withOpacity(0.7),
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (userId != null) {
//                 provider.toggleWishlist(userId!, product.id);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: const Text('Unable to remove: user not found'),
//                     backgroundColor: theme.colorScheme.error,
//                   ),
//                 );
//               }
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${product.name} removed from wishlist'),
//                   backgroundColor: theme.colorScheme.error,
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: theme.colorScheme.error,
//               foregroundColor: theme.colorScheme.onError,
//             ),
//             child: const Text('Remove'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
//         foregroundColor: theme.colorScheme.onSurface,
//         title: Row(
//           children: [
//             Icon(Icons.favorite, color: Colors.red[400]),
//             const SizedBox(width: 8),
//             Text(
//               'My Wishlist',
//               style: theme.textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//                 color: theme.colorScheme.onSurface,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           Consumer<WishlistProvider>(
//             builder: (context, wishlistProvider, child) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '${wishlistProvider.wishlist.length} items',
//                       style: theme.textTheme.labelMedium?.copyWith(
//                         color: Colors.red[600],
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: userId == null
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircularProgressIndicator(
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       theme.colorScheme.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Loading user data...',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           : Consumer<WishlistProvider>(
//               builder: (context, wishlistProvider, child) {
//                 if (wishlistProvider.error.isNotEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.favorite, size: 64, color: Colors.red[300]),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No Favourites',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // Show loader ONLY before first successful data
//                 if (wishlistProvider.isLoading && !_firstLoaded) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             theme.colorScheme.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Loading your wishlist...',
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: theme.colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 if (wishlistProvider.wishlist.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.all(24),
//                           decoration: BoxDecoration(
//                             color: isDark ? theme.cardColor : Colors.grey[100],
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.favorite_border,
//                             size: 64,
//                             color: theme.colorScheme.onSurface.withOpacity(0.4),
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           'Your wishlist is empty',
//                           style: theme.textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Save your favorite items to see them here',
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: theme.colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }



// return RefreshIndicator(
//   onRefresh: _refreshWishlist,
//   color: theme.colorScheme.primary,
//   child: LayoutBuilder(
//     builder: (context, constraints) {
//       final width = constraints.maxWidth;

//       // Max content width for web
//       final maxWidth = width >= 1200 ? 1100.0 : double.infinity;

//       // Switch to grid in web
//       final isWebWide = width >= 900;
//       final crossAxisCount = width >= 1400
//           ? 3
//           : width >= 900
//               ? 2
//               : 1;

//       return Center(
//         child: ConstrainedBox(
//           constraints: BoxConstraints(maxWidth: maxWidth),
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: isWebWide ? 16 : 8,
//               vertical: 12,
//             ),
//             child: isWebWide
//                 ? GridView.builder(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: wishlistProvider.wishlist.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: crossAxisCount,
//                       crossAxisSpacing: 14,
//                       mainAxisSpacing: 14,
//                       childAspectRatio: width >= 1200 ? 2.2 : 2.0,
//                     ),
//                     itemBuilder: (context, index) {
//                       final product = wishlistProvider.wishlist[index];
//                       return WishlistListItem(
//                         product: product,
//                         userId: userId!,
//                         onRemove: () => _showRemoveDialog(
//                           context,
//                           product,
//                           wishlistProvider,
//                         ),
//                         restaurantId: product.restaurantId,
//                       );
//                     },
//                   )
//                 : ListView.separated(
//                     physics: const AlwaysScrollableScrollPhysics(),
//                     itemCount: wishlistProvider.wishlist.length,
//                     separatorBuilder: (context, index) =>
//                         const SizedBox(height: 10),
//                     itemBuilder: (context, index) {
//                       final product = wishlistProvider.wishlist[index];
//                       return WishlistListItem(
//                         product: product,
//                         userId: userId!,
//                         onRemove: () => _showRemoveDialog(
//                           context,
//                           product,
//                           wishlistProvider,
//                         ),
//                         restaurantId: product.restaurantId,
//                       );
//                     },
//                   ),
//           ),
//         ),
//       );
//     },
//   ),
// );

//                 // Normal List
//                 // return RefreshIndicator(
//                 //   onRefresh: _refreshWishlist,
//                 //   color: theme.colorScheme.primary,
//                 //   child: Padding(
//                 //     padding: const EdgeInsets.symmetric(
//                 //       horizontal: 8.0,
//                 //       vertical: 12,
//                 //     ),
//                 //     child: ListView.separated(
//                 //       physics: const AlwaysScrollableScrollPhysics(),
//                 //       itemCount: wishlistProvider.wishlist.length,
//                 //       separatorBuilder: (context, index) =>
//                 //           const Divider(height: 8, color: Colors.transparent),
//                 //       itemBuilder: (context, index) {
//                 //         final product = wishlistProvider.wishlist[index];
//                 //         return WishlistListItem(
//                 //           product: product,
//                 //           userId: userId!, // pass userId down
//                 //           onRemove: () => _showRemoveDialog(
//                 //             context,
//                 //             product,
//                 //             wishlistProvider,
//                 //           ),
//                 //           restaurantId: product.restaurantId,
//                 //         );
//                 //       },
//                 //     ),
//                 //   ),
//                 // );
//               },
//             ),
//     );
//   }
// }

// class WishlistListItem extends StatefulWidget {
//   final WishlistProduct product;
//   final String userId;
//   final VoidCallback onRemove;
//   final String restaurantId;

//   const WishlistListItem({
//     Key? key,
//     required this.product,
//     required this.userId,
//     required this.onRemove,
//     required this.restaurantId,
//   }) : super(key: key);

//   @override
//   State<WishlistListItem> createState() => _WishlistListItemState();
// }

// class _WishlistListItemState extends State<WishlistListItem> {
//   bool _expanded = false;

//   String safeString(String? s, [String fallback = '']) {
//     if (s == null) return fallback;
//     return s;
//   }

//   void _openAddBottomSheet() {
//     final isRestaurantActive =
//         (widget.product.restaurantStatus.toLowerCase() == 'active');
//     final isProductActive = (widget.product.status.toLowerCase() == 'active');
//     final isAvailable = isRestaurantActive && isProductActive;

//     if (!isAvailable) return;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       builder: (context) => WishlistProductBottomSheet(
//         product: widget.product,
//         userId: widget.userId,
//         restaurantId: widget.restaurantId,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const imageSize = 100.0;
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     final isRestaurantActive =
//         (widget.product.restaurantStatus.toLowerCase() == 'active');
//     final isProductActive = (widget.product.status.toLowerCase() == 'active');
//     final isAvailable = isRestaurantActive && isProductActive;
//     final num priceNum = widget.product.price ?? 0;
//     final num discountNum = widget.product.discount ?? 0;

//     final int originalPrice = priceNum is int ? priceNum : priceNum.toInt();
//     final int discount = discountNum is int ? discountNum : discountNum.toInt();

//     final bool hasDiscount = discount > 0;

//     final double discountedPrice = hasDiscount
//         ? originalPrice * (100 - discount) / 100
//         : originalPrice.toDouble();

//     return Opacity(
//       opacity: isAvailable ? 1.0 : 0.55,
//       child: GestureDetector(
//         onTap: isAvailable
//             ? () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DetailScreen(
//                       productId: widget.product.id,
//                       currentUserId: widget.userId.toString(),
//                       restaurantId: widget.restaurantId,
//                     ),
//                   ),
//                 );
//               }
//             : null,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color.fromARGB(255, 148, 231, 100)),
//             borderRadius: BorderRadius.circular(12),
//             color: isDark ? theme.cardColor : Colors.white,
//           ),
//           child: Row(
//             children: [
//               // LEFT: Text info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           width: 12,
//                           height: 12,
//                           margin: const EdgeInsets.only(right: 8, top: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.green,
//                             borderRadius: BorderRadius.circular(2),
//                             border: Border.all(color: Colors.white, width: 1),
//                           ),
//                         ),
//                         Expanded(
//                           child: Text(
//                             safeString(widget.product.name, 'Unnamed product'),
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontWeight: FontWeight.w700,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     hasDiscount
//                         ? Row(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 '₹${discountedPrice.toStringAsFixed(1)}',
//                                 style: theme.textTheme.bodyLarge?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: theme.colorScheme.onSurface,
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 '₹$originalPrice',
//                                 style: theme.textTheme.bodyMedium?.copyWith(
//                                   decoration: TextDecoration.lineThrough,
//                                   color: theme.colorScheme.onSurface
//                                       .withOpacity(0.6),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Text(
//                             '₹$originalPrice',
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               fontWeight: FontWeight.bold,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                     const SizedBox(height: 6),
//                     GestureDetector(
//                       onTap: () => setState(() => _expanded = !_expanded),
//                       child: RichText(
//                         maxLines: _expanded ? 10 : 2,
//                         overflow: TextOverflow.ellipsis,
//                         text: TextSpan(
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             fontSize: 13,
//                             color: theme.colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                           children: <TextSpan>[
//                             TextSpan(
//                               text: safeString(
//                                 widget.product.description,
//                                 'Deliciously decadent flavored food',
//                               ),
//                             ),
//                             if (!_expanded)
//                               TextSpan(
//                                 text: ' more',
//                                 style: theme.textTheme.bodySmall?.copyWith(
//                                   color: theme.colorScheme.onSurface,
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // RIGHT: Image + remove & status overlay + ADD
//               Stack(
//                 clipBehavior: Clip.none,
//                 children: [
//                   // Image container with overlay
//                   Stack(
//                     children: [
//                       Container(
//                         width: imageSize,
//                         height: imageSize,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: isDark ? Colors.grey[800] : Colors.grey[100],
//                           image: widget.product.image.isNotEmpty
//                               ? DecorationImage(
//                                   image: NetworkImage(widget.product.image),
//                                   fit: BoxFit.cover,
//                                 )
//                               : null,
//                         ),
//                         child: widget.product.image.isEmpty
//                             ? Icon(
//                                 Icons.image_outlined,
//                                 size: 40,
//                                 color: theme.colorScheme.onSurface.withOpacity(
//                                   0.4,
//                                 ),
//                               )
//                             : null,
//                       ),

//                       // Overlay for closed/unavailable
//                       if (!isAvailable)
//                         Positioned.fill(
//                           child: Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color:
//                                   (!isRestaurantActive
//                                           ? Colors.black
//                                           : Colors.grey.shade700)
//                                       .withOpacity(0.55),
//                             ),
//                             child: Center(
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 4,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color:
//                                       (!isRestaurantActive
//                                               ? Colors.red.shade600
//                                               : Colors.black87)
//                                           .withOpacity(0.9),
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Text(
//                                   !isRestaurantActive
//                                       ? 'Vendor Closed'
//                                       : 'Unavailable',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 11,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),

//                   // Remove from wishlist (always allowed)
//                   Positioned(
//                     top: -8,
//                     right: -8,
//                     child: Material(
//                       color: isDark ? theme.cardColor : Colors.white,
//                       elevation: 2,
//                       shape: const CircleBorder(),
//                       child: InkWell(
//                         customBorder: const CircleBorder(),
//                         onTap: widget.onRemove,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Icon(
//                             Icons.favorite,
//                             color: Colors.red[400],
//                             size: 18,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // ADD button
//                   Positioned(
//                     bottom: -12,
//                     left: (imageSize / 2) - 28,
//                     child: GestureDetector(
//                       onTap: isAvailable ? _openAddBottomSheet : null,
//                       child: Opacity(
//                         opacity: isAvailable ? 1.0 : 0.4,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 18,
//                             vertical: 8,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isDark ? theme.cardColor : Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               if (!isDark)
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.06),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 ),
//                             ],
//                           ),
//                           child: Text(
//                             'ADD',
//                             style: TextStyle(
//                               color: Colors.green.shade700,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Bottom sheet for selecting variation + quantity (Wishlist version)
// class WishlistProductBottomSheet extends StatefulWidget {
//   final WishlistProduct product;
//   final String userId;
//   final String restaurantId;

//   const WishlistProductBottomSheet({
//     super.key,
//     required this.product,
//     required this.userId,
//     required this.restaurantId,
//   });

//   @override
//   State<WishlistProductBottomSheet> createState() =>
//       _WishlistProductBottomSheetState();
// }

// class _WishlistProductBottomSheetState
//     extends State<WishlistProductBottomSheet> {
//   late String selectedVariation;
//   int quantity = 1;

//   List<String> get availableVariations {
//     final variations = <String>[];
//     if (widget.product.halfPlatePrice > 0) {
//       variations.add('Half');
//     }
//     if (widget.product.fullPlatePrice > 0) {
//       variations.add('Full');
//     }
//     if (variations.isEmpty) {
//       variations.add('Regular');
//     }
//     return variations;
//   }

//   @override
//   void initState() {
//     super.initState();
//     final vars = availableVariations;
//     selectedVariation = vars.first;
//   }

//   num _unitBasePrice() {
//     switch (selectedVariation) {
//       case 'Half':
//         if (widget.product.halfPlatePrice > 0) {
//           return widget.product.halfPlatePrice;
//         }
//         return widget.product.price;
//       case 'Full':
//         if (widget.product.fullPlatePrice > 0) {
//           return widget.product.fullPlatePrice;
//         }
//         return widget.product.price;
//       default:
//         return widget.product.price;
//     }
//   }

//   num _unitPriceWithDiscount() {
//     final base = _unitBasePrice();
//     if (widget.product.discount > 0) {
//       return (base - (base * widget.product.discount / 100)).round();
//     }
//     return base;
//   }

//   num getPrice() {
//     return _unitPriceWithDiscount() * quantity;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, child) {
//         return SafeArea(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: SizedBox(
//                   height: 40,
//                   width: 40,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       widget.product.image,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           color: isDark ? Colors.grey[700] : Colors.grey[200],
//                           child: Icon(
//                             Icons.image_not_supported,
//                             color: theme.colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 title: Text(
//                   widget.product.name,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 trailing: IconButton(
//                   icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
//                 ),
//                 child: Column(
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Portion',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Select any 1',
//                         style: TextStyle(
//                           color: theme.colorScheme.onSurface.withOpacity(0.6),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: isDark ? theme.cardColor : Colors.white,
//                       ),
//                       child: Column(
//                         children: availableVariations.map((variation) {
//                           num basePrice;
//                           if (variation == 'Half') {
//                             basePrice = widget.product.halfPlatePrice > 0
//                                 ? widget.product.halfPlatePrice
//                                 : widget.product.price;
//                           } else if (variation == 'Full') {
//                             basePrice = widget.product.fullPlatePrice > 0
//                                 ? widget.product.fullPlatePrice
//                                 : widget.product.price;
//                           } else {
//                             basePrice = widget.product.price;
//                           }

//                           final discounted = widget.product.discount > 0
//                               ? (basePrice -
//                                       (basePrice *
//                                           widget.product.discount /
//                                           100))
//                                   .round()
//                               : basePrice;

//                           return ListTile(
//                             title: Text(
//                               variation,
//                               style: TextStyle(
//                                 color: theme.colorScheme.onSurface,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 if (widget.product.discount > 0) ...[
//                                   Text(
//                                     '₹$discounted',
//                                     style: TextStyle(
//                                       color: theme.colorScheme.onSurface,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     '₹$basePrice',
//                                     style: TextStyle(
//                                       decoration: TextDecoration.lineThrough,
//                                       fontSize: 12,
//                                       color: theme.colorScheme.onSurface
//                                           .withOpacity(0.6),
//                                     ),
//                                   ),
//                                 ] else
//                                   Text(
//                                     '₹$basePrice',
//                                     style: TextStyle(
//                                       color: theme.colorScheme.onSurface,
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             leading: Radio<String>(
//                               value: variation,
//                               groupValue: selectedVariation,
//                               onChanged: (val) =>
//                                   setState(() => selectedVariation = val!),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Quantity selector
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: theme.colorScheme.onSurface.withOpacity(0.4),
//                         ),
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: quantity > 1
//                                 ? () => setState(() => quantity--)
//                                 : null,
//                             icon: Icon(
//                               Icons.remove,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                           Text(
//                             '$quantity',
//                             style: TextStyle(
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () => setState(() => quantity++),
//                             icon: Icon(
//                               Icons.add,
//                               color: theme.colorScheme.onSurface,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: theme.colorScheme.primary,
//                         foregroundColor: theme.colorScheme.onPrimary,
//                         shape: const StadiumBorder(),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                       ),
//                       onPressed: cartProvider.isLoading
//                           ? null
//                           : () async {
//                               final success = await addToCartWithVendorGuard(
//                                 context: context,
//                                 cartProvider: cartProvider,
//                                 restaurantIdOfProduct:
//                                     widget.restaurantId, // vendor id
//                                 restaurantProductId:
//                                     widget.product.restaurantProductId,
//                                 recommendedId: widget.product.id,
//                                 quantity: quantity,
//                                 variation:
//                                     selectedVariation, // "Half" / "Full" / "Regular"
//                                 plateItems: 0,
//                                 userId: widget.userId.toString(),
//                               );

//                               if (success) {
//                                 Navigator.pop(context);
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       '${widget.product.name} added to cart!',
//                                     ),
//                                     behavior: SnackBarBehavior.floating,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 );
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       cartProvider.error ??
//                                           'Failed to add item to cart',
//                                     ),
//                                     behavior: SnackBarBehavior.floating,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                       child: cartProvider.isLoading
//                           ? SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   theme.colorScheme.onPrimary,
//                                 ),
//                               ),
//                             )
//                           : Text(
//                               'Add Item | ₹${getPrice()}',
//                               style: TextStyle(
//                                 color: theme.colorScheme.onPrimary,
//                               ),
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }























import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/helper/cart_vendor_guard.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/wishlist_model.dart';
import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
import 'package:veegify/views/home/detail_screen.dart';
import 'package:veegify/widgets/bottom_navbar.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';

// 👇 lifecycle service (update path if needed)
import 'package:veegify/core/app_lifecycle_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String? userId;
  bool _initialLoadTried = false; // avoid repeated fetch attempts
  bool _firstLoaded = false; // for loader vs silent refresh

  BottomNavbarProvider? _bottomNavbarProvider;
  VoidCallback? _bottomNavListener;
  static const int _wishlistTabIndex = 1; // your favourites tab index

  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('WishlistScreen.initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Attach bottom nav & listener first
      try {
        _bottomNavbarProvider = Provider.of<BottomNavbarProvider>(
          context,
          listen: false,
        );

        _bottomNavListener = () {
          final idx = _bottomNavbarProvider?.currentIndex;
          debugPrint('Bottom nav index changed: $idx');
          if (idx == _wishlistTabIndex) {
            debugPrint('Wishlist tab became active, refreshing...');
            if (userId == null || userId!.isEmpty) {
              _loadUserIdAndFetch();
            } else {
              context.read<WishlistProvider>().fetchWishlist(userId!);
            }
            _startPolling();
          } else {
            _stopPolling();
          }
        };

        _bottomNavbarProvider?.addListener(_bottomNavListener!);
        debugPrint('Attached bottomNav listener in WishlistScreen ✅');
      } catch (e, st) {
        debugPrint('Could not attach BottomNavbarProvider listener: $e\n$st');
      }

      // Initial load
      await _loadUserIdAndFetch();

      // If this tab is already active, start polling
      try {
        if (_bottomNavbarProvider?.currentIndex == _wishlistTabIndex) {
          _startPolling();
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      if (_bottomNavbarProvider != null && _bottomNavListener != null) {
        _bottomNavbarProvider!.removeListener(_bottomNavListener!);
      }
    } catch (_) {}
    _stopPolling();
    super.dispose();
  }

  void _startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;
    debugPrint('Starting wishlist polling (every 5 seconds)');

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;

      // ✔️ App must be foreground
      if (!AppLifecycleService.instance.isAppInForeground) {
        // debugPrint('⏸️ App background → skip wishlist polling');
        return;
      }

      // ✔️ This tab must be active
      if (_bottomNavbarProvider?.currentIndex != _wishlistTabIndex) {
        // debugPrint('⏸️ Wishlist tab not active → skip polling');
        return;
      }

      // ✔️ This route must be current (no DetailScreen on top)
      final route = ModalRoute.of(context);
      final isRouteCurrent = route?.isCurrent ?? true;
      if (!isRouteCurrent) {
        // debugPrint('⏸️ WishlistScreen not current route → skip polling');
        return;
      }

      if (userId == null || userId!.isEmpty) {
        await _loadUserIdAndFetch();
        return;
      }

      try {
        debugPrint(
            '🔄 [Wishlist Poll] fetchWishlist for userId: $userId (tab active & route current)');
        await context.read<WishlistProvider>().fetchWishlist(userId!);
      } catch (e, st) {
        debugPrint('Error in wishlist polling: $e\n$st');
      }
    });
  }

  void _stopPolling() {
    if (_pollingTimer != null) {
      debugPrint('Stopping wishlist polling');
      _pollingTimer?.cancel();
      _pollingTimer = null;
    }
  }

  /// Make sure this returns after userId is set (async)
  Future<String?> _loadUserId() async {
    try {
      debugPrint('-> _loadUserId start');
      final user = await Future.value(UserPreferences.getUser());
      debugPrint('UserPreferences.getUser() => $user');
      if (user != null && mounted) {
        setState(() {
          userId = user.userId;
        });
        debugPrint('Loaded userId: $userId');
        return userId;
      } else {
        debugPrint('No user found in preferences');
        return null;
      }
    } catch (e, st) {
      debugPrint('_loadUserId error: $e\n$st');
      return null;
    }
  }

  /// Single place to initialize wishlist safely
  Future<void> _loadUserIdAndFetch() async {
    if (!mounted) return;
    debugPrint('>>> _loadUserIdAndFetch START');

    try {
      final loadedUserId = await _loadUserId();

      if (loadedUserId == null || loadedUserId.isEmpty) {
        debugPrint('No userId available - aborting fetchWishlist');
        return;
      }

      // ensure provider exists
      try {
        Provider.of<WishlistProvider>(context, listen: false);
        debugPrint('WishlistProvider found.');
      } catch (e) {
        debugPrint('WishlistProvider NOT found in widget tree! $e');
        return;
      }

      if (_initialLoadTried) {
        debugPrint('Initial load already tried, skipping fetchWishlist');
        return;
      }
      _initialLoadTried = true;

      debugPrint('Calling fetchWishlist for userId: $loadedUserId');
      await context.read<WishlistProvider>().fetchWishlist(loadedUserId);
      if (mounted) {
        setState(() {
          _firstLoaded = true;
        });
      }
      debugPrint(
        'fetchWishlist completed, list length: ${context.read<WishlistProvider>().wishlist.length}',
      );
    } catch (e, st) {
      debugPrint('Exception in _loadUserIdAndFetch: $e\n$st');
    } finally {
      debugPrint('<<< _loadUserIdAndFetch END');
    }
  }

  Future<void> _refreshWishlist() async {
    if (userId != null) {
      try {
        await context.read<WishlistProvider>().fetchWishlist(userId!);
      } catch (e, st) {
        debugPrint('Error refreshing wishlist: $e\n$st');
      }
    } else {
      await _loadUserIdAndFetch();
    }
  }

  void _showRemoveDialog(
    BuildContext context,
    WishlistProduct product,
    WishlistProvider provider,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Remove from Wishlist', style: theme.textTheme.titleMedium),
        content: Text(
          'Are you sure you want to remove "${product.name}" from your wishlist?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (userId != null) {
                provider.toggleWishlist(userId!, product.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Unable to remove: user not found'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} removed from wishlist'),
                  backgroundColor: theme.colorScheme.error,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 900;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: isWeb ? 1 : 0,
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: isWeb,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.red[400], size: isWeb ? 28 : 24),
            const SizedBox(width: 8),
            Text(
              'My Wishlist',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: isWeb ? 24 : 20,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${wishlistProvider.wishlist.length} ${isWeb ? (wishlistProvider.wishlist.length == 1 ? 'item' : 'items') : 'items'}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
                        fontSize: isWeb ? 14 : 12,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: userId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading user data...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            )
          : Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, child) {
                if (wishlistProvider.error.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'No Favourites',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Show loader ONLY before first successful data
                if (wishlistProvider.isLoading && !_firstLoaded) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Loading your wishlist...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (wishlistProvider.wishlist.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.favorite_border,
                            size: isWeb ? 80 : 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your wishlist is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                            fontSize: isWeb ? 22 : 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save your favorite items to see them here',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: isWeb ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refreshWishlist,
                  color: theme.colorScheme.primary,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final isWebWide = width >= 900;

                      // Max content width for web
                      final maxWidth = width >= 1200 ? 1200.0 : double.infinity;

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: isWebWide ? 24 : 8,
                              vertical: isWebWide ? 24 : 12,
                            ),
                            child: isWebWide
                                ? _buildWebLayout(wishlistProvider, theme)
                                : _buildMobileLayout(wishlistProvider, theme),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMobileLayout(WishlistProvider wishlistProvider, ThemeData theme) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: wishlistProvider.wishlist.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final product = wishlistProvider.wishlist[index];
        return WishlistListItem(
          product: product,
          userId: userId!,
          onRemove: () => _showRemoveDialog(
            context,
            product,
            wishlistProvider,
          ),
          restaurantId: product.restaurantId,
        );
      },
    );
  }

  Widget _buildWebLayout(WishlistProvider wishlistProvider, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with stats
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: Colors.red[400],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Wishlist',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${wishlistProvider.wishlist.length} ${wishlistProvider.wishlist.length == 1 ? 'item' : 'items'} saved',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _refreshWishlist,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid view for web
        Expanded(
          child: GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: wishlistProvider.wishlist.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9, // Adjusted for better card proportions
            ),
            itemBuilder: (context, index) {
              final product = wishlistProvider.wishlist[index];
              return WishlistWebCard(
                product: product,
                userId: userId!,
                onRemove: () => _showRemoveDialog(
                  context,
                  product,
                  wishlistProvider,
                ),
                restaurantId: product.restaurantId,
              );
            },
          ),
        ),
      ],
    );
  }
}

class WishlistListItem extends StatefulWidget {
  final WishlistProduct product;
  final String userId;
  final VoidCallback onRemove;
  final String restaurantId;

  const WishlistListItem({
    Key? key,
    required this.product,
    required this.userId,
    required this.onRemove,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<WishlistListItem> createState() => _WishlistListItemState();
}

class _WishlistListItemState extends State<WishlistListItem> {
  bool _expanded = false;

  String safeString(String? s, [String fallback = '']) {
    if (s == null) return fallback;
    return s;
  }

  void _openAddBottomSheet() {
    final isRestaurantActive =
        (widget.product.restaurantStatus.toLowerCase() == 'active');
    final isProductActive = (widget.product.status.toLowerCase() == 'active');
    final isAvailable = isRestaurantActive && isProductActive;

    if (!isAvailable) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => WishlistProductBottomSheet(
        product: widget.product,
        userId: widget.userId,
        restaurantId: widget.restaurantId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const imageSize = 100.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isRestaurantActive =
        (widget.product.restaurantStatus.toLowerCase() == 'active');
    final isProductActive = (widget.product.status.toLowerCase() == 'active');
    final isAvailable = isRestaurantActive && isProductActive;
    final num priceNum = widget.product.price ?? 0;
    final num discountNum = widget.product.discount ?? 0;

    final int originalPrice = priceNum is int ? priceNum : priceNum.toInt();
    final int discount = discountNum is int ? discountNum : discountNum.toInt();

    final bool hasDiscount = discount > 0;

    final double discountedPrice = hasDiscount
        ? originalPrice * (100 - discount) / 100
        : originalPrice.toDouble();

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.55,
      child: GestureDetector(
        onTap: isAvailable
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      productId: widget.product.id,
                      currentUserId: widget.userId.toString(),
                      restaurantId: widget.restaurantId,
                    ),
                  ),
                );
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 148, 231, 100)),
            borderRadius: BorderRadius.circular(12),
            color: isDark ? theme.cardColor : Colors.white,
          ),
          child: Row(
            children: [
              // LEFT: Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            safeString(widget.product.name, 'Unnamed product'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    hasDiscount
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₹${discountedPrice.toStringAsFixed(1)}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '₹$originalPrice',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '₹$originalPrice',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: RichText(
                        maxLines: _expanded ? 10 : 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 13,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: safeString(
                                widget.product.description,
                                'Deliciously decadent flavored food',
                              ),
                            ),
                            if (!_expanded)
                              TextSpan(
                                text: ' more',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // RIGHT: Image + remove & status overlay + ADD
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Image container with overlay
                  Stack(
                    children: [
                      Container(
                        width: imageSize,
                        height: imageSize,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          image: widget.product.image.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.product.image),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.product.image.isEmpty
                            ? Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.4,
                                ),
                              )
                            : null,
                      ),

                      // Overlay for closed/unavailable
                      if (!isAvailable)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  (!isRestaurantActive
                                          ? Colors.black
                                          : Colors.grey.shade700)
                                      .withOpacity(0.55),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (!isRestaurantActive
                                              ? Colors.red.shade600
                                              : Colors.black87)
                                          .withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  !isRestaurantActive
                                      ? 'Vendor Closed'
                                      : 'Unavailable',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Remove from wishlist (always allowed)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Material(
                      color: isDark ? theme.cardColor : Colors.white,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onRemove,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red[400],
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ADD button
                  Positioned(
                    bottom: -12,
                    left: (imageSize / 2) - 28,
                    child: GestureDetector(
                      onTap: isAvailable ? _openAddBottomSheet : null,
                      child: Opacity(
                        opacity: isAvailable ? 1.0 : 0.4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: Text(
                            'ADD',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class WishlistWebCard extends StatefulWidget {
  final WishlistProduct product;
  final String userId;
  final VoidCallback onRemove;
  final String restaurantId;

  const WishlistWebCard({
    Key? key,
    required this.product,
    required this.userId,
    required this.onRemove,
    required this.restaurantId,
  }) : super(key: key);

  @override
  State<WishlistWebCard> createState() => _WishlistWebCardState();
}

class _WishlistWebCardState extends State<WishlistWebCard> {
  bool _isHovered = false;
  bool _expanded = false;

  String safeString(String? s, [String fallback = '']) {
    if (s == null) return fallback;
    return s;
  }

  void _openAddBottomSheet() {
    final isRestaurantActive =
        (widget.product.restaurantStatus.toLowerCase() == 'active');
    final isProductActive = (widget.product.status.toLowerCase() == 'active');
    final isAvailable = isRestaurantActive && isProductActive;

    if (!isAvailable) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => WishlistProductBottomSheet(
        product: widget.product,
        userId: widget.userId,
        restaurantId: widget.restaurantId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isRestaurantActive =
        (widget.product.restaurantStatus.toLowerCase() == 'active');
    final isProductActive = (widget.product.status.toLowerCase() == 'active');
    final isAvailable = isRestaurantActive && isProductActive;
    final num priceNum = widget.product.price ?? 0;
    final num discountNum = widget.product.discount ?? 0;

    final int originalPrice = priceNum is int ? priceNum : priceNum.toInt();
    final int discount = discountNum is int ? discountNum : discountNum.toInt();
    final bool hasDiscount = discount > 0;
    final double discountedPrice = hasDiscount
        ? originalPrice * (100 - discount) / 100
        : originalPrice.toDouble();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isAvailable
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image section with overlay
                Stack(
                  children: [
                    Container(
                      height: 110, // Reduced from 140
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        image: widget.product.image.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.product.image),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.product.image.isEmpty
                          ? Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 40,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            )
                          : null,
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Availability badge
                    if (!isAvailable)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: !isRestaurantActive
                                ? Colors.red
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            !isRestaurantActive ? 'Closed' : 'NA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),

                    // Remove button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white,
                        elevation: 2,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.onRemove,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.favorite,
                              color: Colors.red[400],
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Restaurant name badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              widget.product.restaurantName ?? 'Restaurant',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Content section
                Padding(
                  padding: const EdgeInsets.all(10), // Reduced from 12
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Product name and status dot
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              safeString(widget.product.name, 'Unnamed product'),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Price section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '₹${discountedPrice.toStringAsFixed(0)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                              fontSize: 15,
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 4),
                            Text(
                              '₹$originalPrice',
                              style: theme.textTheme.bodySmall?.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$discount%',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 6),

                      // Description with toggle
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Text(
                          safeString(
                            widget.product.description,
                            'Delicious food',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                            height: 1.2,
                          ),
                          maxLines: _expanded ? 10 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Add to cart button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isAvailable ? _openAddBottomSheet : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAvailable
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: _isHovered && isAvailable ? 2 : 0,
                            minimumSize: const Size(double.infinity, 28),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isAvailable ? 'Add' : 'NA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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

/// Bottom sheet for selecting variation + quantity (Wishlist version)
class WishlistProductBottomSheet extends StatefulWidget {
  final WishlistProduct product;
  final String userId;
  final String restaurantId;

  const WishlistProductBottomSheet({
    super.key,
    required this.product,
    required this.userId,
    required this.restaurantId,
  });

  @override
  State<WishlistProductBottomSheet> createState() =>
      _WishlistProductBottomSheetState();
}

class _WishlistProductBottomSheetState
    extends State<WishlistProductBottomSheet> {
  late String selectedVariation;
  int quantity = 1;

  List<String> get availableVariations {
    final variations = <String>[];
    if (widget.product.halfPlatePrice > 0) {
      variations.add('Half');
    }
    if (widget.product.fullPlatePrice > 0) {
      variations.add('Full');
    }
    if (variations.isEmpty) {
      variations.add('Regular');
    }
    return variations;
  }

  @override
  void initState() {
    super.initState();
    final vars = availableVariations;
    selectedVariation = vars.first;
  }

  num _unitBasePrice() {
    switch (selectedVariation) {
      case 'Half':
        if (widget.product.halfPlatePrice > 0) {
          return widget.product.halfPlatePrice;
        }
        return widget.product.price;
      case 'Full':
        if (widget.product.fullPlatePrice > 0) {
          return widget.product.fullPlatePrice;
        }
        return widget.product.price;
      default:
        return widget.product.price;
    }
  }

  num _unitPriceWithDiscount() {
    final base = _unitBasePrice();
    if (widget.product.discount > 0) {
      return (base - (base * widget.product.discount / 100)).round();
    }
    return base;
  }

  num getPrice() {
    return _unitPriceWithDiscount() * quantity;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth >= 900;

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar for web/mobile
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),

                // Header with product info
                Padding(
                  padding: EdgeInsets.all(isWeb ? 20 : 16),
                  child: Row(
                    children: [
                      // Product image
                      Container(
                        width: isWeb ? 70 : 50,
                        height: isWeb ? 70 : 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: widget.product.image.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.product.image),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                        ),
                        child: widget.product.image.isEmpty
                            ? Icon(
                                Icons.image_outlined,
                                size: isWeb ? 35 : 25,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // Product name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isWeb ? 18 : 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select portion and quantity',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: theme.colorScheme.onSurface,
                          size: isWeb ? 28 : 24,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Variations section
                Container(
                  padding: EdgeInsets.all(isWeb ? 20 : 16),
                  color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Portion',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isWeb ? 20 : 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose your preferred size',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Variation options in a grid for web
                      isWeb
                          ? GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3,
                              children: availableVariations.map((variation) {
                                return _buildVariationTile(variation, theme);
                              }).toList(),
                            )
                          : Column(
                              children: availableVariations.map((variation) {
                                return _buildVariationTile(variation, theme);
                              }).toList(),
                            ),
                    ],
                  ),
                ),

                // Bottom section with quantity and add button
                Padding(
                  padding: EdgeInsets.all(isWeb ? 20 : 16),
                  child: Row(
                    children: [
                      // Quantity selector
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                color: theme.colorScheme.onSurface,
                                size: isWeb ? 22 : 20,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                '$quantity',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isWeb ? 18 : 16,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => quantity++),
                              icon: Icon(
                                Icons.add,
                                color: theme.colorScheme.onSurface,
                                size: isWeb ? 22 : 20,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 40,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Add to cart button
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: isWeb ? 16 : 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: cartProvider.isLoading
                              ? null
                              : () async {
                                  final success = await addToCartWithVendorGuard(
                                    context: context,
                                    cartProvider: cartProvider,
                                    restaurantIdOfProduct: widget.restaurantId,
                                    restaurantProductId: widget.product.restaurantProductId,
                                    recommendedId: widget.product.id,
                                    quantity: quantity,
                                    variation: selectedVariation,
                                    plateItems: 0,
                                    userId: widget.userId.toString(),
                                  );

                                  if (success) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${widget.product.name} added to cart!',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          cartProvider.error ??
                                              'Failed to add item to cart',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                },
                          child: cartProvider.isLoading
                              ? SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Add to Cart • ₹${getPrice()}',
                                  style: TextStyle(
                                    fontSize: isWeb ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVariationTile(String variation, ThemeData theme) {
    num basePrice;
    if (variation == 'Half') {
      basePrice = widget.product.halfPlatePrice > 0
          ? widget.product.halfPlatePrice
          : widget.product.price;
    } else if (variation == 'Full') {
      basePrice = widget.product.fullPlatePrice > 0
          ? widget.product.fullPlatePrice
          : widget.product.price;
    } else {
      basePrice = widget.product.price;
    }

    final discounted = widget.product.discount > 0
        ? (basePrice - (basePrice * widget.product.discount / 100)).round()
        : basePrice;

    return InkWell(
      onTap: () => setState(() => selectedVariation = variation),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selectedVariation == variation
              ? theme.colorScheme.primary.withOpacity(0.1)
              : (theme.brightness == Brightness.dark
                  ? theme.cardColor
                  : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedVariation == variation
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.1),
            width: selectedVariation == variation ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variation,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: selectedVariation == variation
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: selectedVariation == variation
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '₹$discounted',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selectedVariation == variation
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (widget.product.discount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '₹$basePrice',
                          style: theme.textTheme.bodySmall?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: variation,
              groupValue: selectedVariation,
              onChanged: (val) => setState(() => selectedVariation = val!),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}