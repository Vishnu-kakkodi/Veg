
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
//       } catch (e) {
//         debugPrint('Error polling nearby restaurants: $e');
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     final isDark = theme.brightness == Brightness.dark;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final width = constraints.maxWidth;

//             final bool isMobile = width < 700;
//             final bool isTablet = width >= 700 && width < 1100;
//             final bool isDesktop = width >= 1100;

//             // ✅ Prevent full width stretching on web
//             final double maxWidth = isDesktop
//                 ? 1200
//                 : isTablet
//                     ? 950
//                     : double.infinity;

//             final double horizontalPadding = isDesktop
//                 ? 30
//                 : isTablet
//                     ? 20
//                     : 16;

//             // ✅ Image sizes
//             final double imageSize = isMobile
//                 ? 110
//                 : isTablet
//                     ? 120
//                     : 130;

//             // ✅ Grid columns for web
//             final int gridCount = isDesktop ? 2 : (isTablet ? 2 : 1);

//             return Center(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(maxWidth: maxWidth),
//                 child: Column(
//                   children: [
//                     // Custom AppBar
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: horizontalPadding,
//                         vertical: 12,
//                       ),
//                       child: SizedBox(
//                         height: 52,
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             Align(
//                               alignment: Alignment.centerLeft,
//                               child: IconButton(
//                                 icon: Icon(
//                                   Icons.arrow_back_ios_new_rounded,
//                                   color: colorScheme.onSurface,
//                                 ),
//                                 onPressed: () => Navigator.pop(context),
//                               ),
//                             ),
//                             Center(
//                               child: Text(
//                                 "Nearby Restaurants",
//                                 style: theme.textTheme.titleLarge?.copyWith(
//                                   fontWeight: FontWeight.w700,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 8),

//                     Expanded(
//                       child: Consumer<RestaurantProvider>(
//                         builder: (context, restaurantProvider, child) {
//                           // Loader only before first data
//                           if (restaurantProvider.isLoading && !_hasLoadedOnce) {
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 color: colorScheme.primary,
//                               ),
//                             );
//                           }

//                           if (restaurantProvider.nearbyRestaurants.isEmpty) {
//                             return Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.restaurant,
//                                     size: 64,
//                                     color: colorScheme.onSurface.withOpacity(0.5),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     "No nearby restaurants found",
//                                     style: theme.textTheme.bodyLarge?.copyWith(
//                                       color: colorScheme.onSurface.withOpacity(0.7),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           }

//                           // ✅ MOBILE = LIST
//                           if (isMobile) {
//                             return ListView.builder(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: horizontalPadding,
//                                 vertical: 4,
//                               ),
//                               itemCount: restaurantProvider.nearbyRestaurants.length,
//                               itemBuilder: (context, index) {
//                                 final restaurant =
//                                     restaurantProvider.nearbyRestaurants[index];

//                                 return _RestaurantCard(
//                                   restaurant: restaurant,
//                                   theme: theme,
//                                   colorScheme: colorScheme,
//                                   isDark: isDark,
//                                   imageSize: imageSize,
//                                 );
//                               },
//                             );
//                           }

//                           // ✅ WEB/TABLET = GRID
//                           return GridView.builder(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: horizontalPadding,
//                               vertical: 6,
//                             ),
//                             itemCount: restaurantProvider.nearbyRestaurants.length,
//                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: gridCount,
//                               crossAxisSpacing: 16,
//                               mainAxisSpacing: 16,
//                               childAspectRatio: isDesktop ? 2.4 : 2.1,
//                             ),
//                             itemBuilder: (context, index) {
//                               final restaurant =
//                                   restaurantProvider.nearbyRestaurants[index];

//                               return _RestaurantCard(
//                                 restaurant: restaurant,
//                                 theme: theme,
//                                 colorScheme: colorScheme,
//                                 isDark: isDark,
//                                 imageSize: imageSize,
//                               );
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ✅ Restaurant Card Widget (Reusable for List & Grid)
// class _RestaurantCard extends StatelessWidget {
//   final dynamic restaurant;
//   final ThemeData theme;
//   final ColorScheme colorScheme;
//   final bool isDark;
//   final double imageSize;

//   const _RestaurantCard({
//     required this.restaurant,
//     required this.theme,
//     required this.colorScheme,
//     required this.isDark,
//     required this.imageSize,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isActive =
//         (restaurant.status ?? '').toLowerCase() == 'active';

//     return GestureDetector(
//       onTap: isActive
//           ? () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => RestaurantDetailScreen(
//                     restaurantId: restaurant.id,
//                   ),
//                 ),
//               )
//           : null,
//       child: Opacity(
//         opacity: isActive ? 1.0 : 0.55,
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           margin: const EdgeInsets.only(bottom: 6),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: isDark
//                   ? Colors.grey[700]!
//                   : const Color.fromARGB(255, 210, 210, 210),
//             ),
//             color: isDark ? theme.cardColor : Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.06),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // Image + heart + CLOSED overlay
//               Stack(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(14),
//                     child: Image.network(
//                       restaurant.imageUrl ?? '',
//                       height: imageSize,
//                       width: imageSize,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           height: imageSize,
//                           width: imageSize,
//                           decoration: BoxDecoration(
//                             color: isDark ? Colors.grey[700] : Colors.grey[200],
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: Icon(
//                             Icons.restaurant,
//                             size: 40,
//                             color: colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                         );
//                       },
//                       loadingBuilder: (context, child, loadingProgress) {
//                         if (loadingProgress == null) return child;
//                         return Container(
//                           height: imageSize,
//                           width: imageSize,
//                           decoration: BoxDecoration(
//                             color: isDark ? Colors.grey[700] : Colors.grey[200],
//                             borderRadius: BorderRadius.circular(14),
//                           ),
//                           child: Center(
//                             child: CircularProgressIndicator(
//                               color: colorScheme.primary,
//                               strokeWidth: 2,
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: CircleAvatar(
//                       radius: 14,
//                       backgroundColor: isDark ? theme.cardColor : Colors.white,
//                       child: Icon(
//                         Icons.favorite_border,
//                         size: 16,
//                         color: colorScheme.onSurface,
//                       ),
//                     ),
//                   ),

//                   if (!isActive)
//                     Positioned.fill(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.55),
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: Center(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 14,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade600.withOpacity(0.9),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: const Text(
//                               "Vendor Closed",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 13,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               // Info
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 12,
//                     horizontal: 12,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         restaurant.restaurantName ?? 'Restaurant Name',
//                         style: theme.textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: colorScheme.onSurface,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 6),

//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(20),
//                               color: colorScheme.primary,
//                             ),
//                             child: Icon(
//                               Icons.star,
//                               size: 16,
//                               color: colorScheme.onPrimary,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Text(
//                             (restaurant.rating ?? 0.0).toStringAsFixed(1),
//                             style: theme.textTheme.bodyMedium?.copyWith(
//                               fontWeight: FontWeight.w600,
//                               color: colorScheme.onSurface,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 6),

//                       Text(
//                         restaurant.description ?? 'No description available',
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color: colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       const SizedBox(height: 8),

//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on,
//                             color: colorScheme.primary,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               (restaurant.locationName ?? '')
//                                   .split(' ')
//                                   .first,
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: colorScheme.onSurface.withOpacity(0.6),
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
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

            final double maxWidth = isDesktop
                ? 1600
                : isTablet
                    ? 1000
                    : double.infinity;

            final double horizontalPadding = isDesktop
                ? 48
                : isTablet
                    ? 24
                    : 16;

            final double verticalPadding = isDesktop ? 24 : 16;

            // Grid configuration
            final int crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 1);
            final double maxCardWidth = isDesktop ? 350 : (isTablet ? 300 : double.infinity);
            final double cardAspectRatio = isDesktop ? 1.0 : (isTablet ? 1.1 : 1.2);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    // Custom AppBar
                    _buildAppBar(theme, colorScheme, isDesktop, horizontalPadding),

                    const SizedBox(height: 8),

                    Expanded(
                      child: Consumer<RestaurantProvider>(
                        builder: (context, restaurantProvider, child) {
                          if (restaurantProvider.isLoading && !_hasLoadedOnce) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: colorScheme.primary,
                              ),
                            );
                          }

                          if (restaurantProvider.nearbyRestaurants.isEmpty) {
                            return _buildEmptyState(theme, colorScheme, isDesktop);
                          }

                          // MOBILE LAYOUT
                          if (isMobile) {
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalPadding,
                              ),
                              itemCount: restaurantProvider.nearbyRestaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant =
                                    restaurantProvider.nearbyRestaurants[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _RestaurantCardMobile(
                                    restaurant: restaurant,
                                    theme: theme,
                                    colorScheme: colorScheme,
                                    isDark: isDark,
                                  ),
                                );
                              },
                            );
                          }

                          // TABLET/DESKTOP LAYOUT
                          return RefreshIndicator(
                            onRefresh: () => _fetchNearby(),
                            color: colorScheme.primary,
                            child: CustomScrollView(
                              slivers: [
                                // Header for web
                                if (isDesktop)
                                  SliverPadding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                      vertical: 16,
                                    ),
                                    sliver: SliverToBoxAdapter(
                                      child: _buildWebHeader(theme, colorScheme, 
                                          restaurantProvider.nearbyRestaurants.length),
                                    ),
                                  ),

                                // Grid of restaurants
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                    vertical: verticalPadding,
                                  ),
                                  sliver: SliverGrid(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: isDesktop ? 20 : 16,
                                      mainAxisSpacing: isDesktop ? 20 : 16,
                                      childAspectRatio: cardAspectRatio,
                                    ),
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final restaurant =
                                            restaurantProvider.nearbyRestaurants[index];

                                        return SizedBox(
                                          width: maxCardWidth,
                                          child: _RestaurantCardWeb(
                                            restaurant: restaurant,
                                            theme: theme,
                                            colorScheme: colorScheme,
                                            isDark: isDark,
                                          ),
                                        );
                                      },
                                      childCount: restaurantProvider.nearbyRestaurants.length,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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

  Widget _buildAppBar(ThemeData theme, ColorScheme colorScheme, 
      bool isDesktop, double horizontalPadding) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isDesktop ? 16 : 12,
      ),
      child: SizedBox(
        height: isDesktop ? 70 : 52,
        child: Row(
          children: [
            // Back button
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDesktop ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: isDesktop ? 20 : 18,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(width: 16),

            // Title
            Expanded(
              child: Text(
                "Nearby Restaurants",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isDesktop ? 28 : 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Filter button (web only)
            if (isDesktop)
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: () {
                    _showFilterDialog(context);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(ThemeData theme, ColorScheme colorScheme, int count) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.restaurant,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurants Near You',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count ${count == 1 ? 'restaurant' : 'restaurants'} found',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _fetchNearby(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Refresh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              size: isDesktop ? 80 : 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No nearby restaurants found",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 24 : 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Try changing your location or check back later",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _fetchNearby(),
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 32 : 24,
                vertical: isDesktop ? 16 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Restaurants',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Rating: High to Low', Icons.star, colorScheme, context),
            _buildFilterOption('Distance: Near to Far', Icons.location_on, colorScheme, context),
            _buildFilterOption('Price: Low to High', Icons.arrow_upward, colorScheme, context),
            _buildFilterOption('Price: High to Low', Icons.arrow_downward, colorScheme, context),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, IconData icon, ColorScheme colorScheme, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}

// Mobile Restaurant Card - WITH DESCRIPTION
class _RestaurantCardMobile extends StatelessWidget {
  final dynamic restaurant;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isDark;

  const _RestaurantCardMobile({
    required this.restaurant,
    required this.theme,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = (restaurant.status ?? '').toLowerCase() == 'active';
    final imageSize = 90.0;

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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
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
              // Image section
              _buildImageSection(isActive, imageSize),

              const SizedBox(width: 12),

              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRestaurantName(),
                    const SizedBox(height: 4),
                    _buildRating(),
                    const SizedBox(height: 4),
                    _buildDescription(),
                    const SizedBox(height: 4),
                    _buildLocation(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isActive, double imageSize) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 30,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              );
            },
          ),
        ),

        // Favorite button
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(
              Icons.favorite_border,
              size: 12,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        if (!isActive)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Closed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRestaurantName() {
    return Text(
      restaurant.restaurantName ?? 'Restaurant Name',
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.primary,
          ),
          child: Icon(
            Icons.star,
            size: 10,
            color: colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          (restaurant.rating ?? 0.0).toStringAsFixed(1),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      restaurant.description ?? 'No description available',
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontSize: 11,
        height: 1.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: colorScheme.primary,
          size: 11,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            restaurant.locationName ?? 'Location',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// Web Restaurant Card - COMPACT WITH DESCRIPTION
class _RestaurantCardWeb extends StatelessWidget {
  final dynamic restaurant;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isDark;

  const _RestaurantCardWeb({
    required this.restaurant,
    required this.theme,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = (restaurant.status ?? '').toLowerCase() == 'active';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image section - COMPACT
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      restaurant.imageUrl ?? '',
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 110,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Center(
                            child: Icon(
                              Icons.restaurant,
                              size: 35,
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Status badge
                  if (!isActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Closed",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ),

                  // // Favorite button
                  // Positioned(
                  //   top: 8,
                  //   right: 8,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(4),
                  //     decoration: BoxDecoration(
                  //       color: isDark ? theme.cardColor : Colors.white,
                  //       shape: BoxShape.circle,
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.black.withOpacity(0.1),
                  //           blurRadius: 4,
                  //         ),
                  //       ],
                  //     ),
                  //     child: Icon(
                  //       Icons.favorite_border,
                  //       size: 12,
                  //       color: colorScheme.onSurface,
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              // Content - COMPACT PADDING
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Restaurant Name - ALLOWS 2 LINES
                    Text(
                      restaurant.restaurantName ?? 'Restaurant Name',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Rating Row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 9,
                                color: colorScheme.onPrimary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                (restaurant.rating ?? 0.0).toStringAsFixed(1),
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description - 2 LINES
                    Text(
                      restaurant.description ?? 'No description available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: colorScheme.primary,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            restaurant.locationName ?? 'Location',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // View button - COMPACT
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: OutlinedButton(
                        onPressed: isActive
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RestaurantDetailScreen(
                                      restaurantId: restaurant.id,
                                    ),
                                  ),
                                )
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: BorderSide(
                            color: isActive ? colorScheme.primary : Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isActive ? 'View' : 'Closed',
                          style: TextStyle(
                            color: isActive ? colorScheme.primary : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}