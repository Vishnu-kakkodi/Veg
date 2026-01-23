
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// import '../../provider/RestaurantProvider/nearby_restaurants_provider.dart';

// class NearbyScreen extends StatefulWidget {
//   final String userId; // Add userId parameter
//   const NearbyScreen({super.key, required this.userId});

//   @override
//   State<NearbyScreen> createState() => _NearbyScreenState();
// }

// class _NearbyScreenState extends State<NearbyScreen> {
//   Timer? _pollingTimer;
//   bool _hasLoadedOnce = false;

//   @override
//   void initState() {
//     super.initState();

//     // Fetch nearby restaurants when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _fetchNearby(initial: true);
//       _startPolling();
//     });
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchNearby({bool initial = false}) async {
//     try {
//       await context
//           .read<RestaurantProvider>()
//           .getNearbyRestaurants(widget.userId);

//       if (initial && mounted) {
//         setState(() {
//           _hasLoadedOnce = true;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching nearby restaurants: $e');
//     }
//   }

//   void _startPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (!mounted) {
//         _pollingTimer?.cancel();
//         return;
//       }
//       try {
//         await context
//             .read<RestaurantProvider>()
//             .getNearbyRestaurants(widget.userId);
//         // No loader here – silent refresh.
//       } catch (e) {
//         debugPrint('Error polling nearby restaurants: $e');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom AppBar
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               child: SizedBox(
//                 height: 48,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.arrow_back_ios,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                     Center(
//                       child: Text(
//                         "Near By Restaurants",
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // List of Restaurants using Consumer
//             Expanded(
//               child: Consumer<RestaurantProvider>(
//                 builder: (context, restaurantProvider, child) {
//                   // Show loader ONLY before first data comes
//                   if (restaurantProvider.isLoading && !_hasLoadedOnce) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                     );
//                   }

//                   if (restaurantProvider.nearbyRestaurants.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.restaurant,
//                             size: 64,
//                             color: theme.colorScheme.onSurface
//                                 .withOpacity(0.5),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             "No nearby restaurants found",
//                             style:
//                                 theme.textTheme.bodyLarge?.copyWith(
//                               color: theme.colorScheme.onSurface
//                                   .withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: restaurantProvider.nearbyRestaurants.length,
//                     itemBuilder: (context, index) {
//                       final restaurant =
//                           restaurantProvider.nearbyRestaurants[index];

//                       // ⚠️ Change `restaurant.status` to your actual field if named differently.
//                       final bool isActive =
//                           (restaurant.status ?? '').toLowerCase() == 'active';

//                       return GestureDetector(
//                         onTap: isActive
//                             ? () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         RestaurantDetailScreen(
//                                       restaurantId: restaurant.id,
//                                     ),
//                                   ),
//                                 )
//                             : null, // Block navigation when inactive
//                         child: Opacity(
//                           opacity: isActive ? 1.0 : 0.55, // Dim inactive vendors
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             margin: const EdgeInsets.only(bottom: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: isDark
//                                     ? Colors.grey[700]!
//                                     : const Color.fromARGB(
//                                         255, 196, 196, 196),
//                               ),
//                               color: isDark
//                                   ? theme.cardColor
//                                   : Colors.white,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: isActive
//                                       ? Colors.grey.withOpacity(0.15)
//                                       : Colors.black.withOpacity(
//                                           0.6), // darker when closed
//                                   blurRadius: isActive ? 8 : 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 // Restaurant Image with Heart Icon + Closed overlay
//                                 Stack(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius:
//                                           BorderRadius.circular(12),
//                                       child: Image.network(
//                                         restaurant.imageUrl ?? '',
//                                         height: 122,
//                                         width: 122,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error,
//                                             stackTrace) {
//                                           return Container(
//                                             height: 122,
//                                             width: 122,
//                                             decoration: BoxDecoration(
//                                               color: isDark
//                                                   ? Colors.grey[700]
//                                                   : Colors.grey[200],
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: Icon(
//                                               Icons.restaurant,
//                                               size: 40,
//                                               color: theme
//                                                   .colorScheme.onSurface
//                                                   .withOpacity(0.5),
//                                             ),
//                                           );
//                                         },
//                                         loadingBuilder: (context, child,
//                                             loadingProgress) {
//                                           if (loadingProgress == null) {
//                                             return child;
//                                           }
//                                           return Container(
//                                             height: 122,
//                                             width: 122,
//                                             decoration: BoxDecoration(
//                                               color: isDark
//                                                   ? Colors.grey[700]
//                                                   : Colors.grey[200],
//                                               borderRadius:
//                                                   BorderRadius.circular(12),
//                                             ),
//                                             child: Center(
//                                               child:
//                                                   CircularProgressIndicator(
//                                                 color: theme
//                                                     .colorScheme.primary,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),

//                                     // Favorite icon (still just UI)
//                                     Positioned(
//                                       top: 8,
//                                       right: 8,
//                                       child: CircleAvatar(
//                                         radius: 14,
//                                         backgroundColor: isDark
//                                             ? theme.cardColor
//                                             : Colors.white,
//                                         child: Icon(
//                                           Icons.favorite_border,
//                                           size: 16,
//                                           color: theme
//                                               .colorScheme.onSurface,
//                                         ),
//                                       ),
//                                     ),

//                                     // Vendor Closed overlay
//                                     if (!isActive)
//                                       Positioned.fill(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.black
//                                                 .withOpacity(0.55),
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           child: Center(
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                 horizontal: 14,
//                                                 vertical: 6,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.red.shade600
//                                                     .withOpacity(0.9),
//                                                 borderRadius:
//                                                     BorderRadius.circular(10),
//                                               ),
//                                               child: const Text(
//                                                 "Vendor Closed",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight: FontWeight.bold,
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),

//                                 // Restaurant Info
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 12,
//                                       horizontal: 12,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           restaurant.restaurantName ??
//                                               'Restaurant Name',
//                                           style: theme
//                                               .textTheme.titleMedium
//                                               ?.copyWith(
//                                             fontWeight: FontWeight.w700,
//                                             color: theme
//                                                 .colorScheme.onSurface,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.all(4),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(20),
//                                                 color: theme
//                                                     .colorScheme.primary,
//                                               ),
//                                               child: Icon(
//                                                 Icons.star,
//                                                 size: 16,
//                                                 color: theme.colorScheme
//                                                     .onPrimary,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               (restaurant.rating ??
//                                                       0.0)
//                                                   .toStringAsFixed(1),
//                                               style: theme
//                                                   .textTheme.bodyMedium
//                                                   ?.copyWith(
//                                                 fontWeight: FontWeight.w600,
//                                                 color: theme.colorScheme
//                                                     .onSurface,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           restaurant.description ??
//                                               'No description available',
//                                           style: theme
//                                               .textTheme.bodySmall
//                                               ?.copyWith(
//                                             color: theme
//                                                 .colorScheme.onSurface
//                                                 .withOpacity(0.7),
//                                           ),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Row(
//                                           children: [
//                                             Icon(
//                                               Icons.location_on,
//                                               color: theme
//                                                   .colorScheme.primary,
//                                               size: 16,
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Expanded(
//                                               child: Text(
//                                                 restaurant.locationName
//                                                     .split(' ')
//                                                     .first,
//                                                 style: theme.textTheme
//                                                     .bodySmall
//                                                     ?.copyWith(
//                                                   color: theme
//                                                       .colorScheme.onSurface
//                                                       .withOpacity(0.6),
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow:
//                                                     TextOverflow.ellipsis,
//                                               ),
//                                             )
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






















// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// import '../../provider/RestaurantProvider/nearby_restaurants_provider.dart';

// class NearbyScreen extends StatefulWidget {
//   final String userId;
//   const NearbyScreen({super.key, required this.userId});

//   @override
//   State<NearbyScreen> createState() => _NearbyScreenState();
// }

// class _NearbyScreenState extends State<NearbyScreen> {
//   Timer? _pollingTimer;
//   bool _hasLoadedOnce = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _fetchNearby(initial: true);
//       _startPolling();
//     });
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchNearby({bool initial = false}) async {
//     try {
//       await context
//           .read<RestaurantProvider>()
//           .getNearbyRestaurants(widget.userId);

//       if (initial && mounted) {
//         setState(() {
//           _hasLoadedOnce = true;
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching nearby restaurants: $e');
//     }
//   }

//   void _startPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
//       if (!mounted) {
//         _pollingTimer?.cancel();
//         return;
//       }
//       try {
//         await context
//             .read<RestaurantProvider>()
//             .getNearbyRestaurants(widget.userId);
//         // Silent refresh
//       } catch (e) {
//         debugPrint('Error polling nearby restaurants: $e');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     // 🔥 Responsive sizes
//     final bool isMobile = Responsive.isMobile(context);
//     final bool isTablet = Responsive.isTablet(context);

//     final double imageSize = isMobile
//         ? 110
//         : isTablet
//             ? 130
//             : 140;

//     final double horizontalPadding = isMobile ? 16 : 24;
//     final double cardVerticalPadding = isMobile ? 8 : 10;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Custom AppBar
//             Padding(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//               child: SizedBox(
//                 height: 48,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.arrow_back_ios,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                     Center(
//                       child: Text(
//                         "Nearby Restaurants",
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // List of Restaurants
//             Expanded(
//               child: Consumer<RestaurantProvider>(
//                 builder: (context, restaurantProvider, child) {
//                   // Loader only before first data
//                   if (restaurantProvider.isLoading && !_hasLoadedOnce) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                     );
//                   }

//                   if (restaurantProvider.nearbyRestaurants.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.restaurant,
//                             size: 64,
//                             color: theme.colorScheme.onSurface
//                                 .withOpacity(0.5),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             "No nearby restaurants found",
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: theme.colorScheme.onSurface
//                                   .withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: horizontalPadding,
//                       vertical: 4,
//                     ),
//                     itemCount:
//                         restaurantProvider.nearbyRestaurants.length,
//                     itemBuilder: (context, index) {
//                       final restaurant =
//                           restaurantProvider.nearbyRestaurants[index];

//                       final bool isActive =
//                           (restaurant.status ?? '').toLowerCase() ==
//                               'active';

//                       return GestureDetector(
//                         onTap: isActive
//                             ? () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                         RestaurantDetailScreen(
//                                       restaurantId: restaurant.id,
//                                     ),
//                                   ),
//                                 )
//                             : null,
//                         child: Opacity(
//                           opacity: isActive ? 1.0 : 0.55,
//                           child: Container(
//                             padding: EdgeInsets.all(cardVerticalPadding),
//                             margin: const EdgeInsets.only(bottom: 16),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: isDark
//                                     ? Colors.grey[700]!
//                                     : const Color.fromARGB(
//                                         255, 196, 196, 196),
//                               ),
//                               color: isDark
//                                   ? theme.cardColor
//                                   : Colors.white,
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: isActive
//                                       ? Colors.grey.withOpacity(0.15)
//                                       : Colors.black.withOpacity(0.6),
//                                   blurRadius: isActive ? 8 : 10,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 // Image + heart + CLOSED overlay
//                                 Stack(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius:
//                                           BorderRadius.circular(12),
//                                       child: Image.network(
//                                         restaurant.imageUrl ?? '',
//                                         height: imageSize,
//                                         width: imageSize,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error,
//                                             stackTrace) {
//                                           return Container(
//                                             height: imageSize,
//                                             width: imageSize,
//                                             decoration: BoxDecoration(
//                                               color: isDark
//                                                   ? Colors.grey[700]
//                                                   : Colors.grey[200],
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       12),
//                                             ),
//                                             child: Icon(
//                                               Icons.restaurant,
//                                               size: 40,
//                                               color: theme
//                                                   .colorScheme.onSurface
//                                                   .withOpacity(0.5),
//                                             ),
//                                           );
//                                         },
//                                         loadingBuilder: (context, child,
//                                             loadingProgress) {
//                                           if (loadingProgress == null) {
//                                             return child;
//                                           }
//                                           return Container(
//                                             height: imageSize,
//                                             width: imageSize,
//                                             decoration: BoxDecoration(
//                                               color: isDark
//                                                   ? Colors.grey[700]
//                                                   : Colors.grey[200],
//                                               borderRadius:
//                                                   BorderRadius.circular(
//                                                       12),
//                                             ),
//                                             child: Center(
//                                               child:
//                                                   CircularProgressIndicator(
//                                                 color: theme
//                                                     .colorScheme.primary,
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ),

//                                     Positioned(
//                                       top: 8,
//                                       right: 8,
//                                       child: CircleAvatar(
//                                         radius: 14,
//                                         backgroundColor: isDark
//                                             ? theme.cardColor
//                                             : Colors.white,
//                                         child: Icon(
//                                           Icons.favorite_border,
//                                           size: 16,
//                                           color: theme
//                                               .colorScheme.onSurface,
//                                         ),
//                                       ),
//                                     ),

//                                     if (!isActive)
//                                       Positioned.fill(
//                                         child: Container(
//                                           decoration: BoxDecoration(
//                                             color: Colors.black
//                                                 .withOpacity(0.55),
//                                             borderRadius:
//                                                 BorderRadius.circular(12),
//                                           ),
//                                           child: Center(
//                                             child: Container(
//                                               padding:
//                                                   const EdgeInsets
//                                                       .symmetric(
//                                                 horizontal: 14,
//                                                 vertical: 6,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 color: Colors.red.shade600
//                                                     .withOpacity(0.9),
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         10),
//                                               ),
//                                               child: const Text(
//                                                 "Vendor Closed",
//                                                 style: TextStyle(
//                                                   color: Colors.white,
//                                                   fontWeight:
//                                                       FontWeight.bold,
//                                                   fontSize: 13,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),

//                                 // Info
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 12,
//                                       horizontal: 12,
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           restaurant.restaurantName ??
//                                               'Restaurant Name',
//                                           style: theme.textTheme
//                                               .titleMedium
//                                               ?.copyWith(
//                                             fontWeight:
//                                                 FontWeight.w700,
//                                             color: theme
//                                                 .colorScheme.onSurface,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Container(
//                                               padding:
//                                                   const EdgeInsets.all(
//                                                       4),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         20),
//                                                 color: theme
//                                                     .colorScheme.primary,
//                                               ),
//                                               child: Icon(
//                                                 Icons.star,
//                                                 size: 16,
//                                                 color: theme.colorScheme
//                                                     .onPrimary,
//                                               ),
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Text(
//                                               (restaurant.rating ?? 0.0)
//                                                   .toStringAsFixed(1),
//                                               style: theme.textTheme
//                                                   .bodyMedium
//                                                   ?.copyWith(
//                                                 fontWeight:
//                                                     FontWeight.w600,
//                                                 color: theme.colorScheme
//                                                     .onSurface,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           restaurant.description ??
//                                               'No description available',
//                                           style: theme
//                                               .textTheme.bodySmall
//                                               ?.copyWith(
//                                             color: theme
//                                                 .colorScheme.onSurface
//                                                 .withOpacity(0.7),
//                                           ),
//                                           maxLines: 2,
//                                           overflow:
//                                               TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 6),
//                                         Row(
//                                           children: [
//                                             Icon(
//                                               Icons.location_on,
//                                               color: theme
//                                                   .colorScheme.primary,
//                                               size: 16,
//                                             ),
//                                             const SizedBox(width: 4),
//                                             Expanded(
//                                               child: Text(
//                                                 restaurant.locationName
//                                                     .split(' ')
//                                                     .first,
//                                                 style: theme
//                                                     .textTheme.bodySmall
//                                                     ?.copyWith(
//                                                   color: theme
//                                                       .colorScheme
//                                                       .onSurface
//                                                       .withOpacity(
//                                                           0.6),
//                                                 ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow
//                                                     .ellipsis,
//                                               ),
//                                             )
//                                           ],
//                                         )
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

















import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/home/recommended_screen.dart';

import '../../provider/RestaurantProvider/nearby_restaurants_provider.dart';

class NearbyScreen extends StatefulWidget {
  final String userId;
  const NearbyScreen({super.key, required this.userId});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  Timer? _pollingTimer;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchNearby(initial: true);
      _startPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNearby({bool initial = false}) async {
    try {
      await context
          .read<RestaurantProvider>()
          .getNearbyRestaurants(widget.userId);

      if (initial && mounted) {
        setState(() {
          _hasLoadedOnce = true;
        });
      }
    } catch (e) {
      debugPrint('Error fetching nearby restaurants: $e');
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) {
        _pollingTimer?.cancel();
        return;
      }
      try {
        await context
            .read<RestaurantProvider>()
            .getNearbyRestaurants(widget.userId);
      } catch (e) {
        debugPrint('Error polling nearby restaurants: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isMobile = width < 700;
            final bool isTablet = width >= 700 && width < 1100;
            final bool isDesktop = width >= 1100;

            // ✅ Prevent full width stretching on web
            final double maxWidth = isDesktop
                ? 1200
                : isTablet
                    ? 950
                    : double.infinity;

            final double horizontalPadding = isDesktop
                ? 30
                : isTablet
                    ? 20
                    : 16;

            // ✅ Image sizes
            final double imageSize = isMobile
                ? 110
                : isTablet
                    ? 120
                    : 130;

            // ✅ Grid columns for web
            final int gridCount = isDesktop ? 2 : (isTablet ? 2 : 1);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // Custom AppBar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 12,
                      ),
                      child: SizedBox(
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: colorScheme.onSurface,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Center(
                              child: Text(
                                "Nearby Restaurants",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Consumer<RestaurantProvider>(
                        builder: (context, restaurantProvider, child) {
                          // Loader only before first data
                          if (restaurantProvider.isLoading && !_hasLoadedOnce) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            );
                          }

                          if (restaurantProvider.nearbyRestaurants.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 64,
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No nearby restaurants found",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          // ✅ MOBILE = LIST
                          if (isMobile) {
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: 4,
                              ),
                              itemCount: restaurantProvider.nearbyRestaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant =
                                    restaurantProvider.nearbyRestaurants[index];

                                return _RestaurantCard(
                                  restaurant: restaurant,
                                  theme: theme,
                                  colorScheme: colorScheme,
                                  isDark: isDark,
                                  imageSize: imageSize,
                                );
                              },
                            );
                          }

                          // ✅ WEB/TABLET = GRID
                          return GridView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 6,
                            ),
                            itemCount: restaurantProvider.nearbyRestaurants.length,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: gridCount,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isDesktop ? 2.4 : 2.1,
                            ),
                            itemBuilder: (context, index) {
                              final restaurant =
                                  restaurantProvider.nearbyRestaurants[index];

                              return _RestaurantCard(
                                restaurant: restaurant,
                                theme: theme,
                                colorScheme: colorScheme,
                                isDark: isDark,
                                imageSize: imageSize,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ✅ Restaurant Card Widget (Reusable for List & Grid)
class _RestaurantCard extends StatelessWidget {
  final dynamic restaurant;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isDark;
  final double imageSize;

  const _RestaurantCard({
    required this.restaurant,
    required this.theme,
    required this.colorScheme,
    required this.isDark,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive =
        (restaurant.status ?? '').toLowerCase() == 'active';

    return GestureDetector(
      onTap: isActive
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(
                    restaurantId: restaurant.id,
                  ),
                ),
              )
          : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.grey[700]!
                  : const Color.fromARGB(255, 210, 210, 210),
            ),
            color: isDark ? theme.cardColor : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Image + heart + CLOSED overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      restaurant.imageUrl ?? '',
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: imageSize,
                          width: imageSize,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: imageSize,
                          width: imageSize,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[700] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: isDark ? theme.cardColor : Colors.white,
                      child: Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  if (!isActive)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade600.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "Vendor Closed",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.restaurantName ?? 'Restaurant Name',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: colorScheme.primary,
                            ),
                            child: Icon(
                              Icons.star,
                              size: 16,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (restaurant.rating ?? 0.0).toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        restaurant.description ?? 'No description available',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              (restaurant.locationName ?? '')
                                  .split(' ')
                                  .first,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
