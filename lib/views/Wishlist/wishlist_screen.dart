// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/wishlist_model.dart';
// import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';

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
//         _bottomNavbarProvider =
//             Provider.of<BottomNavbarProvider>(context, listen: false);

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
//       if (userId == null || userId!.isEmpty) {
//         await _loadUserIdAndFetch();
//         return;
//       }
//       try {
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

//       final providerAvailable =
//           Provider.of<WishlistProvider>(context, listen: false);
//       if (providerAvailable == null) {
//         debugPrint('WishlistProvider NOT found in widget tree!');
//         return;
//       } else {
//         debugPrint('WishlistProvider found.');
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
//           'fetchWishlist completed, list length: ${context.read<WishlistProvider>().wishlist.length}');
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
//       BuildContext context, WishlistProduct product, WishlistProvider provider) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Remove from Wishlist'),
//         content: Text(
//             'Are you sure you want to remove "${product.name}" from your wishlist?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (userId != null) {
//                 provider.toggleWishlist(userId!, product.id);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Unable to remove: user not found'),
//                     backgroundColor: Colors.redAccent,
//                   ),
//                 );
//               }
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${product.name} removed from wishlist'),
//                   backgroundColor: Colors.red[400],
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red[400],
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Remove'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         title: Row(
//           children: [
//             Icon(Icons.favorite, color: Colors.red[400]),
//             const SizedBox(width: 8),
//             const Text(
//               'My Wishlist',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20,
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
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '${wishlistProvider.wishlist.length} items',
//                       style: TextStyle(
//                         color: Colors.red[600],
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
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
//                     valueColor:
//                         AlwaysStoppedAnimation<Color>(Colors.red[400]!),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Loading user data...',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                       fontSize: 16,
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
//                         Icon(Icons.favorite,
//                             size: 64, color: Colors.red[300]),
//                         const SizedBox(height: 16),
//                         Text(
//                           'No Favourates',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[800],
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
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(Colors.red[400]!),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Loading your wishlist...',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
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
//                             color: Colors.grey[100],
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(Icons.favorite_border,
//                               size: 64, color: Colors.grey[400]),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           'Your wishlist is empty',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Save your favorite items to see them here',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // Normal List
//                 return RefreshIndicator(
//                   onRefresh: _refreshWishlist,
//                   color: Colors.red[400],
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 8.0, vertical: 8),
//                     child: ListView.separated(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: wishlistProvider.wishlist.length,
//                       separatorBuilder: (context, index) =>
//                           const Divider(height: 1, color: Colors.transparent),
//                       itemBuilder: (context, index) {
//                         final product = wishlistProvider.wishlist[index];
//                         return WishlistListItem(
//                           product: product,
//                           onRemove: () =>
//                               _showRemoveDialog(context, product, wishlistProvider),
//                           onAdd: () {
//                             // You can plug cart here and also check status before adding
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content:
//                                     Text('Added ${product.name} to cart'),
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class WishlistListItem extends StatefulWidget {
//   final WishlistProduct product;
//   final VoidCallback onRemove;
//   final VoidCallback onAdd;

//   const WishlistListItem({
//     Key? key,
//     required this.product,
//     required this.onRemove,
//     required this.onAdd,
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

//   @override
//   Widget build(BuildContext context) {
//     const imageSize = 100.0;

//     final isRestaurantActive =
//         (widget.product.restaurantStatus.toLowerCase() == 'active');
//     final isProductActive =
//         (widget.product.status.toLowerCase() == 'active');
//     final isAvailable = isRestaurantActive && isProductActive;

//     return Opacity(
//       opacity: isAvailable ? 1.0 : 0.55,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         color: Colors.transparent,
//         child: Row(
//           children: [
//             // LEFT: Text info
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: 12,
//                         height: 12,
//                         margin: const EdgeInsets.only(right: 8, top: 2),
//                         decoration: BoxDecoration(
//                           color: Colors.green,
//                           borderRadius: BorderRadius.circular(2),
//                           border: Border.all(color: Colors.white, width: 1),
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           safeString(widget.product.name, 'Unnamed product'),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.black87,
//                           ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     '₹${widget.product.price}',
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   GestureDetector(
//                     onTap: () => setState(() => _expanded = !_expanded),
//                     child: RichText(
//                       maxLines: _expanded ? 10 : 2,
//                       overflow: TextOverflow.ellipsis,
//                       text: TextSpan(
//                         style: TextStyle(
//                             fontSize: 13, color: Colors.grey[700]),
//                         children: <TextSpan>[
//                           TextSpan(
//                             text: safeString(
//                               widget.product.description,
//                               'Deliciously decadent flavored food',
//                             ),
//                           ),
//                           if (!_expanded)
//                             TextSpan(
//                               text: ' more',
//                               style: TextStyle(
//                                   color: Colors.grey[800],
//                                   fontWeight: FontWeight.w700),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),

//             // RIGHT: Image + remove & status overlay
//             Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 // Image container with overlay
//                 Stack(
//                   children: [
//                     Container(
//                       width: imageSize,
//                       height: imageSize,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[100],
//                         image: widget.product.image.isNotEmpty
//                             ? DecorationImage(
//                                 image: NetworkImage(widget.product.image),
//                                 fit: BoxFit.cover,
//                               )
//                             : null,
//                       ),
//                       child: widget.product.image.isEmpty
//                           ? Icon(Icons.image_outlined,
//                               size: 40, color: Colors.grey[400])
//                           : null,
//                     ),

//                     // Overlay for closed/unavailable
//                     if (!isAvailable)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             color: (!isRestaurantActive
//                                     ? Colors.black
//                                     : Colors.grey.shade700)
//                                 .withOpacity(0.55),
//                           ),
//                           child: Center(
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 4),
//                               decoration: BoxDecoration(
//                                 color: (!isRestaurantActive
//                                         ? Colors.red.shade600
//                                         : Colors.black87)
//                                     .withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Text(
//                                 !isRestaurantActive
//                                     ? 'Vendor Closed'
//                                     : 'Unavailable',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 11,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),

//                 // Remove from wishlist (always allowed)
//                 Positioned(
//                   top: -8,
//                   right: -8,
//                   child: Material(
//                     color: Colors.white,
//                     elevation: 2,
//                     shape: const CircleBorder(),
//                     child: InkWell(
//                       customBorder: const CircleBorder(),
//                       onTap: widget.onRemove,
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Icon(Icons.favorite,
//                             color: Colors.red[400], size: 18),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // If in future you re-enable ADD button, you can do:
//                 GestureDetector(
//                   onTap: (){
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   shape:
//                       const RoundedRectangleBorder(
//                     borderRadius:
//                         BorderRadius.vertical(
//                       top: Radius.circular(25),
//                     ),
//                   ),
//                   builder: (context) =>
//                       VegPannerBottomSheet(
//                     item: widget.product.,
//                     product: product,
//                     productId: productId,
//                     restaurantId: restaurantId,
//                     userId: userId.toString(),
//                   ),
//                 );
//                   },
//                   child: Positioned(
//                     bottom: -12,
//                     left: (imageSize / 2) - 28,
//                     child: GestureDetector(
//                       onTap: isAvailable ? widget.onAdd : null,
//                       child: Opacity(
//                         opacity: isAvailable ? 1.0 : 0.4,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 18, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.06),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'ADD',
//                             style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Bottom sheet for selecting variation + quantity
// class VegPannerBottomSheet extends StatefulWidget {
//   final RecommendedItem item;
//   final RecommendedProduct product;
//   final String productId;
//   final String restaurantId;
//   final String userId;

//   const VegPannerBottomSheet({
//     super.key,
//     required this.item,
//     required this.product,
//     required this.productId,
//     required this.restaurantId,
//     required this.userId,
//   });

//   @override
//   _VegPannerBottomSheetState createState() =>
//       _VegPannerBottomSheetState();
// }

// class _VegPannerBottomSheetState
//     extends State<VegPannerBottomSheet> {
//   late String selectedVariation;
//   int quantity = 1;

//   List<String> get availableVariations {
//     final variations = <String>[];
//     if (widget.item.halfPlatePrice > 0) {
//       variations.add('Half');
//     }
//     if (widget.item.fullPlatePrice > 0) {
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
//         if (widget.item.halfPlatePrice > 0) {
//           return widget.item.halfPlatePrice;
//         }
//         return widget.item.price;
//       case 'Full':
//         if (widget.item.fullPlatePrice > 0) {
//           return widget.item.fullPlatePrice;
//         }
//         return widget.item.price;
//       default:
//         return widget.item.price;
//     }
//   }

//   num _unitPriceWithDiscount() {
//     final base = _unitBasePrice();
//     if (widget.item.discount > 0) {
//       return (base -
//               (base * widget.item.discount / 100))
//           .round();
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
//                     borderRadius:
//                         BorderRadius.circular(8),
//                     child: Image.network(
//                       widget.item.image,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error,
//                           stackTrace) {
//                         return Container(
//                           color: isDark
//                               ? Colors.grey[700]
//                               : Colors.grey[200],
//                           child: Icon(
//                             Icons
//                                 .image_not_supported,
//                             color: theme
//                                 .colorScheme.onSurface
//                                 .withOpacity(0.5),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 title: Text(
//                   widget.item.name,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color:
//                         theme.colorScheme.onSurface,
//                   ),
//                 ),
//                 trailing: IconButton(
//                   icon: Icon(
//                     Icons.close,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   onPressed: () =>
//                       Navigator.pop(context),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isDark
//                       ? theme.cardColor
//                       : const Color(0xFFEBF4F1),
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
//                           color: theme
//                               .colorScheme.onSurface,
//                         ),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         'Select any 1',
//                         style: TextStyle(
//                           color: theme
//                               .colorScheme.onSurface
//                               .withOpacity(0.6),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.circular(12),
//                         color: isDark
//                             ? theme.cardColor
//                             : Colors.white,
//                       ),
//                       child: Column(
//                         children:
//                             availableVariations.map((variation) {
//                           num basePrice;
//                           if (variation == 'Half') {
//                             basePrice =
//                                 widget.item.halfPlatePrice >
//                                         0
//                                     ? widget.item
//                                         .halfPlatePrice
//                                     : widget.item.price;
//                           } else if (variation ==
//                               'Full') {
//                             basePrice =
//                                 widget.item.fullPlatePrice >
//                                         0
//                                     ? widget.item
//                                         .fullPlatePrice
//                                     : widget.item.price;
//                           } else {
//                             basePrice =
//                                 widget.item.price;
//                           }

//                           final discounted =
//                               widget.item.discount >
//                                       0
//                                   ? (basePrice -
//                                           (basePrice *
//                                                   widget
//                                                       .item
//                                                       .discount /
//                                                   100))
//                                       .round()
//                                   : basePrice;

//                           return ListTile(
//                             title: Text(
//                               variation,
//                               style: TextStyle(
//                                 color: theme
//                                     .colorScheme
//                                     .onSurface,
//                               ),
//                             ),
//                             trailing: Row(
//                               mainAxisSize:
//                                   MainAxisSize.min,
//                               children: [
//                                 if (widget.item
//                                         .discount >
//                                     0) ...[
//                                   Text(
//                                     '₹$discounted',
//                                     style: TextStyle(
//                                       color: theme
//                                           .colorScheme
//                                           .onSurface,
//                                       fontWeight:
//                                           FontWeight
//                                               .bold,
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                       width: 6),
//                                   Text(
//                                     '₹$basePrice',
//                                     style:
//                                         TextStyle(
//                                       decoration:
//                                           TextDecoration
//                                               .lineThrough,
//                                       fontSize: 12,
//                                       color: theme
//                                           .colorScheme
//                                           .onSurface
//                                           .withOpacity(
//                                               0.6),
//                                     ),
//                                   ),
//                                 ] else
//                                   Text(
//                                     '₹$basePrice',
//                                     style: TextStyle(
//                                       color: theme
//                                           .colorScheme
//                                           .onSurface,
//                                     ),
//                                   ),
//                               ],
//                             ),
//                             leading: Radio<String>(
//                               value: variation,
//                               groupValue:
//                                   selectedVariation,
//                               onChanged: (val) =>
//                                   setState(() =>
//                                       selectedVariation =
//                                           val!),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                   children: [
//                     // Quantity selector
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: theme
//                               .colorScheme.onSurface
//                               .withOpacity(0.4),
//                         ),
//                         borderRadius:
//                             BorderRadius.circular(25),
//                       ),
//                       child: Row(
//                         children: [
//                           IconButton(
//                             onPressed: quantity > 1
//                                 ? () => setState(
//                                     () => quantity--)
//                                 : null,
//                             icon: Icon(
//                               Icons.remove,
//                               color: theme
//                                   .colorScheme
//                                   .onSurface,
//                             ),
//                           ),
//                           Text(
//                             '$quantity',
//                             style: TextStyle(
//                               color: theme
//                                   .colorScheme.onSurface,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: () =>
//                                 setState(() =>
//                                     quantity++),
//                             icon: Icon(
//                               Icons.add,
//                               color: theme
//                                   .colorScheme
//                                   .onSurface,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton
//                           .styleFrom(
//                         backgroundColor: theme
//                             .colorScheme.primary,
//                         foregroundColor: theme
//                             .colorScheme.onPrimary,
//                         shape:
//                             const StadiumBorder(),
//                         padding:
//                             const EdgeInsets
//                                 .symmetric(
//                           horizontal: 24,
//                           vertical: 12,
//                         ),
//                       ),
//                       onPressed: cartProvider
//                               .isLoading
//                           ? null
//                           : () async {
//                               final success =
//                                   await cartProvider
//                                       .addItemToCart(
//                                 restaurantProductId:
//                                     widget
//                                         .productId,
//                                 recommendedId: widget
//                                     .item.itemId,
//                                 quantity: quantity,
//                                 variation:
//                                     selectedVariation,
//                                 plateItems:
//                                     0, // no extra plate add-ons
//                                 userId: widget.userId
//                                     .toString(),
//                               );

//                               if (success) {
//                                 Navigator.pop(
//                                     context);
//                                 ScaffoldMessenger
//                                         .of(context)
//                                     .showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                         '${widget.item.name} added to cart!'),
//                                     behavior:
//                                         SnackBarBehavior
//                                             .floating,
//                                     shape:
//                                         RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                                   12),
//                                     ),
//                                   ),
//                                 );
//                               } else {
//                                 ScaffoldMessenger
//                                         .of(context)
//                                     .showSnackBar(
//                                   SnackBar(
//                                     content: Text(
//                                       cartProvider.error ??
//                                           'Failed to add item to cart',
//                                     ),
//                                     behavior:
//                                         SnackBarBehavior
//                                             .floating,
//                                     shape:
//                                         RoundedRectangleBorder(
//                                       borderRadius:
//                                           BorderRadius
//                                               .circular(
//                                                   12),
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                       child: cartProvider.isLoading
//                           ? SizedBox(
//                               width: 20,
//                               height: 20,
//                               child:
//                                   CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                     AlwaysStoppedAnimation<
//                                         Color>(
//                                   theme.colorScheme
//                                       .onPrimary,
//                                 ),
//                               ),
//                             )
//                           : Text(
//                               'Add Item | ₹${getPrice()}',
//                               style: TextStyle(
//                                 color: theme
//                                     .colorScheme
//                                     .onPrimary,
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

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/helper/storage_helper.dart';
// import 'package:veegify/model/wishlist_model.dart';
// import 'package:veegify/provider/WishListProvider/wishlist_provider.dart';
// import 'package:veegify/views/home/detail_screen.dart';
// import 'package:veegify/widgets/bottom_navbar.dart';
// import 'package:veegify/provider/CartProvider/cart_provider.dart';

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
//       if (userId == null || userId!.isEmpty) {
//         await _loadUserIdAndFetch();
//         return;
//       }
//       try {
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

//       final providerAvailable = Provider.of<WishlistProvider>(
//         context,
//         listen: false,
//       );
//       if (providerAvailable == null) {
//         debugPrint('WishlistProvider NOT found in widget tree!');
//         return;
//       } else {
//         debugPrint('WishlistProvider found.');
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
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: const Text('Remove from Wishlist'),
//         content: Text(
//           'Are you sure you want to remove "${product.name}" from your wishlist?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (userId != null) {
//                 provider.toggleWishlist(userId!, product.id);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Unable to remove: user not found'),
//                     backgroundColor: Colors.redAccent,
//                   ),
//                 );
//               }
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text('${product.name} removed from wishlist'),
//                   backgroundColor: Colors.red[400],
//                   duration: const Duration(seconds: 2),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red[400],
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Remove'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         title: Row(
//           children: [
//             Icon(Icons.favorite, color: Colors.red[400]),
//             const SizedBox(width: 8),
//             const Text(
//               'My Wishlist',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '${wishlistProvider.wishlist.length} items',
//                       style: TextStyle(
//                         color: Colors.red[600],
//                         fontWeight: FontWeight.w600,
//                         fontSize: 12,
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
//                     valueColor: AlwaysStoppedAnimation<Color>(Colors.red[400]!),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Loading user data...',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
//                           'No Favourates',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[800],
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
//                             Colors.red[400]!,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           'Loading your wishlist...',
//                           style: TextStyle(
//                             color: Colors.grey[600],
//                             fontSize: 16,
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
//                             color: Colors.grey[100],
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.favorite_border,
//                             size: 64,
//                             color: Colors.grey[400],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                         Text(
//                           'Your wishlist is empty',
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Save your favorite items to see them here',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 // Normal List
//                 return RefreshIndicator(
//                   onRefresh: _refreshWishlist,
//                   color: Colors.red[400],
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8.0,
//                       vertical: 8,
//                     ),
//                     child: ListView.separated(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: wishlistProvider.wishlist.length,
//                       separatorBuilder: (context, index) =>
//                           const Divider(height: 1, color: Colors.transparent),
//                       itemBuilder: (context, index) {
//                         final product = wishlistProvider.wishlist[index];
//                         return WishlistListItem(
//                           product: product,
//                           userId: userId!, // 👈 pass userId down
//                           onRemove: () => _showRemoveDialog(
//                             context,
//                             product,
//                             wishlistProvider,
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class WishlistListItem extends StatefulWidget {
//   final WishlistProduct product;
//   final String userId;
//   final VoidCallback onRemove;

//   const WishlistListItem({
//     Key? key,
//     required this.product,
//     required this.userId,
//     required this.onRemove,
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
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const imageSize = 100.0;

//     final isRestaurantActive =
//         (widget.product.restaurantStatus.toLowerCase() == 'active');
//     final isProductActive = (widget.product.status.toLowerCase() == 'active');
//     final isAvailable = isRestaurantActive && isProductActive;

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
//                     ),
//                   ),
//                 );
//               }
//             : null,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           // color: Colors.transparent,
//           decoration: BoxDecoration(
//             border: Border.all(color: const Color.fromARGB(255, 148, 231, 100)),
//             borderRadius: BorderRadius.circular(12),
//             color: Colors.transparent
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
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w700,
//                               color: Colors.black87,
//                             ),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       '₹${widget.product.price}',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     GestureDetector(
//                       onTap: () => setState(() => _expanded = !_expanded),
//                       child: RichText(
//                         maxLines: _expanded ? 10 : 2,
//                         overflow: TextOverflow.ellipsis,
//                         text: TextSpan(
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[700],
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
//                                 style: TextStyle(
//                                   color: Colors.grey[800],
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
//               const SizedBox(width: 12),

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
//                           color: Colors.grey[100],
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
//                                 color: Colors.grey[400],
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
//                       color: Colors.white,
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
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.06),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'ADD',
//                             style: TextStyle(
//                               color: Colors.green,
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

//   const WishlistProductBottomSheet({
//     super.key,
//     required this.product,
//     required this.userId,
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
//                                         (basePrice *
//                                             widget.product.discount /
//                                             100))
//                                     .round()
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
//                               // NOTE:
//                               // If you have a separate restaurantProductId in WishlistProduct,
//                               // use that instead of product.id for restaurantProductId.
//                               final success = await cartProvider.addItemToCart(
//                                 restaurantProductId:
//                                     widget.product.restaurantId,
//                                 recommendedId: widget.product.id,
//                                 quantity: quantity,
//                                 variation: selectedVariation,
//                                 plateItems: 0,
//                                 userId: widget.userId,
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
//       if (userId == null || userId!.isEmpty) {
//         await _loadUserIdAndFetch();
//         return;
//       }
//       try {
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

//       final providerAvailable = Provider.of<WishlistProvider>(
//         context,
//         listen: false,
//       );
//       if (providerAvailable == null) {
//         debugPrint('WishlistProvider NOT found in widget tree!');
//         return;
//       } else {
//         debugPrint('WishlistProvider found.');
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

//                 // Normal List
//                 return RefreshIndicator(
//                   onRefresh: _refreshWishlist,
//                   color: theme.colorScheme.primary,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8.0,
//                       vertical: 12,
//                     ),
//                     child: ListView.separated(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: wishlistProvider.wishlist.length,
//                       separatorBuilder: (context, index) =>
//                           const Divider(height: 8, color: Colors.transparent),
//                       itemBuilder: (context, index) {
//                         final product = wishlistProvider.wishlist[index];
//                         return WishlistListItem(
//                           product: product,
//                           userId: userId!, // pass userId down
//                           onRemove: () => _showRemoveDialog(
//                             context,
//                             product,
//                             wishlistProvider,
//                           ),
//                           restaurantId: product.restaurantId,
//                         );
//                       },
//                     ),
//                   ),
//                 );
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
//               const SizedBox(width: 12),

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
//                                         (basePrice *
//                                             widget.product.discount /
//                                             100))
//                                     .round()
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
//                               // Using restaurantId as restaurantProductId
//                               // and wishlist product id as recommendedId
//                               // final success =
//                               //     await cartProvider.addItemToCart(
//                               //   restaurantProductId:
//                               //       widget.product.restaurantProductId,
//                               //   recommendedId: widget.product.id,
//                               //   quantity: quantity,
//                               //   variation: selectedVariation,
//                               //   plateItems: 0,
//                               //   userId: widget.userId,
//                               // );

//                               final success = await addToCartWithVendorGuard(
//                                 context: context,
//                                 cartProvider: cartProvider,
//                                 restaurantIdOfProduct: widget
//                                     .restaurantId, // 🔑 vendor id of this product
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

//       // 🔒 Extra safety:
//       // Only poll when:
//       // 1. THIS route is visible (no DetailScreen / Checkout on top)
//       // 2. Wishlist tab is the active bottom tab
//       final route = ModalRoute.of(context);
//       final isRouteCurrent = route?.isCurrent ?? true;
//       final isTabActive =
//           (_bottomNavbarProvider?.currentIndex == _wishlistTabIndex);

//       if (!isRouteCurrent || !isTabActive) {
//         // Screen is not visible or tab not active → skip API call
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

//       // This will throw if provider not found, then we catch
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

//                 // Normal List
//                 return RefreshIndicator(
//                   onRefresh: _refreshWishlist,
//                   color: theme.colorScheme.primary,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8.0,
//                       vertical: 12,
//                     ),
//                     child: ListView.separated(
//                       physics: const AlwaysScrollableScrollPhysics(),
//                       itemCount: wishlistProvider.wishlist.length,
//                       separatorBuilder: (context, index) =>
//                           const Divider(height: 8, color: Colors.transparent),
//                       itemBuilder: (context, index) {
//                         final product = wishlistProvider.wishlist[index];
//                         return WishlistListItem(
//                           product: product,
//                           userId: userId!, // pass userId down
//                           onRemove: () => _showRemoveDialog(
//                             context,
//                             product,
//                             wishlistProvider,
//                           ),
//                           restaurantId: product.restaurantId,
//                         );
//                       },
//                     ),
//                   ),
//                 );
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
//               const SizedBox(width: 12),

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
//                                 restaurantIdOfProduct: widget.restaurantId,
//                                 restaurantProductId:
//                                     widget.product.restaurantProductId,
//                                 recommendedId: widget.product.id,
//                                 quantity: quantity,
//                                 variation: selectedVariation,
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? theme.scaffoldBackgroundColor : Colors.white,
        foregroundColor: theme.colorScheme.onSurface,
        title: Row(
          children: [
            Icon(Icons.favorite, color: Colors.red[400]),
            const SizedBox(width: 8),
            Text(
              'My Wishlist',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
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
                      '${wishlistProvider.wishlist.length} items',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600,
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
                            size: 64,
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your wishlist is empty',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save your favorite items to see them here',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Normal List
                return RefreshIndicator(
                  onRefresh: _refreshWishlist,
                  color: theme.colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 12,
                    ),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: wishlistProvider.wishlist.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 8, color: Colors.transparent),
                      itemBuilder: (context, index) {
                        final product = wishlistProvider.wishlist[index];
                        return WishlistListItem(
                          product: product,
                          userId: userId!, // pass userId down
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
                );
              },
            ),
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

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SizedBox(
                  height: 40,
                  width: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: isDark ? Colors.grey[700] : Colors.grey[200],
                          child: Icon(
                            Icons.image_not_supported,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                title: Text(
                  widget.product.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
                ),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Portion',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select any 1',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isDark ? theme.cardColor : Colors.white,
                      ),
                      child: Column(
                        children: availableVariations.map((variation) {
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
                              ? (basePrice -
                                      (basePrice *
                                          widget.product.discount /
                                          100))
                                  .round()
                              : basePrice;

                          return ListTile(
                            title: Text(
                              variation,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.product.discount > 0) ...[
                                  Text(
                                    '₹$discounted',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '₹$basePrice',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                                  ),
                                ] else
                                  Text(
                                    '₹$basePrice',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                              ],
                            ),
                            leading: Radio<String>(
                              value: variation,
                              groupValue: selectedVariation,
                              onChanged: (val) =>
                                  setState(() => selectedVariation = val!),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Quantity selector
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        borderRadius: BorderRadius.circular(25),
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
                            ),
                          ),
                          Text(
                            '$quantity',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => quantity++),
                            icon: Icon(
                              Icons.add,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: cartProvider.isLoading
                          ? null
                          : () async {
                              final success = await addToCartWithVendorGuard(
                                context: context,
                                cartProvider: cartProvider,
                                restaurantIdOfProduct:
                                    widget.restaurantId, // vendor id
                                restaurantProductId:
                                    widget.product.restaurantProductId,
                                recommendedId: widget.product.id,
                                quantity: quantity,
                                variation:
                                    selectedVariation, // "Half" / "Full" / "Regular"
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
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(
                              'Add Item | ₹${getPrice()}',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
