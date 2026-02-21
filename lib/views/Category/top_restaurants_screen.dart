
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/home/recommended_screen.dart';
// import '../../provider/RestaurantProvider/top_restaurants_provider.dart';

// class TopRestaurantsScreen extends StatefulWidget {
//   final String userId;
//   const TopRestaurantsScreen({super.key, required this.userId});

//   @override
//   State<TopRestaurantsScreen> createState() => _TopRestaurantsScreenState();
// }

// class _TopRestaurantsScreenState extends State<TopRestaurantsScreen> {
//   Timer? _pollingTimer;
//   bool _firstLoaded = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await _fetchTopRestaurants(initialLoad: true);
//       _startSilentPolling();
//     });
//   }

//   @override
//   void dispose() {
//     _pollingTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _fetchTopRestaurants({bool initialLoad = false}) async {
//     try {
//       await context
//           .read<TopRestaurantsProvider>()
//           .getTopRestaurants(widget.userId);

//       if (initialLoad && mounted) {
//         setState(() {
//           _firstLoaded = true;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error loading top restaurants: $e");
//     }
//   }

//   /// Auto-refresh every 5 seconds without UI disturbance
//   void _startSilentPolling() {
//     _pollingTimer?.cancel();
//     _pollingTimer =
//         Timer.periodic(const Duration(seconds: 5), (timer) async {
//       if (!mounted) {
//         _pollingTimer?.cancel();
//         return;
//       }
//       try {
//         await context
//             .read<TopRestaurantsProvider>()
//             .getTopRestaurants(widget.userId);
//       } catch (e) {
//         debugPrint("Silent Poll Error: $e");
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     // 🔥 Responsive helpers
//     final bool isMobile = Responsive.isMobile(context);
//     final bool isTablet = Responsive.isTablet(context);

//     final double imageSize = isMobile
//         ? 110
//         : isTablet
//             ? 130
//             : 140;

//     final double horizontalPadding = isMobile ? 16 : 24;
//     final double cardPadding = isMobile ? 8 : 10;

//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // AppBar
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
//                         "Top Rated Restaurants",
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

//             Expanded(
//               child: Consumer<TopRestaurantsProvider>(
//                 builder: (context, provider, child) {
//                   // First load loader
//                   if (provider.isLoading && !_firstLoaded) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                     );
//                   }

//                   if (provider.topRestaurants.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.star_border,
//                             size: 64,
//                             color: theme.colorScheme.onSurface
//                                 .withOpacity(0.5),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             "No top rated restaurants found",
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
//                     itemCount: provider.topRestaurants.length,
//                     itemBuilder: (context, index) {
//                       final restaurant = provider.topRestaurants[index];

//                       final bool isActive =
//                           (restaurant.status ?? "").toLowerCase() ==
//                               "active";

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
//                           opacity: isActive ? 1.0 : 0.50,
//                           child: Container(
//                             padding: EdgeInsets.all(cardPadding),
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
//                                       : Colors.black.withOpacity(0.55),
//                                   blurRadius: isActive ? 8 : 12,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 // IMAGE + CLOSED OVERLAY
//                                 Stack(
//                                   children: [
//                                     ClipRRect(
//                                       borderRadius:
//                                           BorderRadius.circular(12),
//                                       child: Image.network(
//                                         restaurant.imageUrl ?? "",
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

//                                 // INFO SECTION
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
//                                               "Restaurant Name",
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
//                                                 color: theme
//                                                     .colorScheme.primary,
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         20),
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
//                                               restaurant.rating
//                                                       ?.toStringAsFixed(
//                                                           1) ??
//                                                   "0.0",
//                                               style: theme
//                                                   .textTheme.bodyMedium
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
//                                               "No description available",
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
//                                                     .split(" ")
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
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow
//                                                     .ellipsis,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
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
import '../../provider/RestaurantProvider/top_restaurants_provider.dart';

class TopRestaurantsScreen extends StatefulWidget {
  final String userId;
  const TopRestaurantsScreen({super.key, required this.userId});

  @override
  State<TopRestaurantsScreen> createState() => _TopRestaurantsScreenState();
}

class _TopRestaurantsScreenState extends State<TopRestaurantsScreen> {
  Timer? _pollingTimer;
  bool _firstLoaded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchTopRestaurants(initialLoad: true);
      _startSilentPolling();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTopRestaurants({bool initialLoad = false}) async {
    try {
      await context
          .read<TopRestaurantsProvider>()
          .getTopRestaurants(widget.userId);

      if (initialLoad && mounted) {
        setState(() {
          _firstLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading top restaurants: $e");
    }
  }

  void _startSilentPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) {
        _pollingTimer?.cancel();
        return;
      }
      try {
        await context
            .read<TopRestaurantsProvider>()
            .getTopRestaurants(widget.userId);
      } catch (e) {
        debugPrint("Silent Poll Error: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

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
                      child: Consumer<TopRestaurantsProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading && !_firstLoaded) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                            );
                          }

                          if (provider.topRestaurants.isEmpty) {
                            return _buildEmptyState(theme, isDesktop);
                          }

                          // MOBILE LAYOUT
                          if (isMobile) {
                            return ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: verticalPadding,
                              ),
                              itemCount: provider.topRestaurants.length,
                              itemBuilder: (context, index) {
                                final restaurant = provider.topRestaurants[index];
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
                            onRefresh: () => _fetchTopRestaurants(),
                            color: theme.colorScheme.primary,
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
                                      child: _buildWebHeader(
                                        theme, 
                                        colorScheme,
                                        provider.topRestaurants.length,
                                      ),
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
                                        final restaurant = provider.topRestaurants[index];
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
                                      childCount: provider.topRestaurants.length,
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

  Widget _buildAppBar(ThemeData theme, ColorScheme colorScheme, bool isDesktop, double horizontalPadding) {
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
                "Top Rated Restaurants",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: isDesktop ? 28 : 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

            // Sort button (web only)
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
                    Icons.sort_rounded,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => _showSortDialog(context),
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
              Icons.star,
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
                  'Popular Restaurants',
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
            onPressed: () => _fetchTopRestaurants(),
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

  Widget _buildEmptyState(ThemeData theme, bool isDesktop) {
    final colorScheme = theme.colorScheme;
    
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
              Icons.star_border,
              size: isDesktop ? 80 : 64,
              color: colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "No top rated restaurants found",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop ? 24 : 20,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Check back later for popular restaurants in your area",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _fetchTopRestaurants(),
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

  void _showSortDialog(BuildContext context) {
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
              'Sort By',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildSortOption('Rating: High to Low', Icons.star, colorScheme, context),
            _buildSortOption('Rating: Low to High', Icons.star_border, colorScheme, context),
            _buildSortOption('Most Popular', Icons.trending_up, colorScheme, context),
            _buildSortOption('Name: A to Z', Icons.sort_by_alpha, colorScheme, context),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, IconData icon, ColorScheme colorScheme, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(label),
      onTap: () => Navigator.pop(context),
    );
  }
}

// Mobile Restaurant Card
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
    final bool isActive = (restaurant.status ?? "").toLowerCase() == "active";
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
        opacity: isActive ? 1.0 : 0.50,
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
            restaurant.imageUrl ?? "",
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
                      fontSize: 10,
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
      restaurant.restaurantName ?? "Restaurant Name",
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
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
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
      restaurant.description ?? "No description available",
      style: theme.textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.7),
        fontSize: 11,
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
          size: 12,
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            restaurant.locationName?.split(" ").first ?? "Location",
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
    final bool isActive = (restaurant.status ?? "").toLowerCase() == "active";

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
                      restaurant.imageUrl ?? "",
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

                  // Rating badge - SMALLER
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            (restaurant.rating ?? 0.0).toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Closed badge
                  if (!isActive)
                    Positioned(
                      top: 8,
                      right: 8,
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
                      restaurant.restaurantName ?? "Restaurant Name",
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

                    // Description - 2 LINES
                    Text(
                      restaurant.description ?? "No description available",
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
                          size: 11,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            restaurant.locationName ?? "Location",
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
                      child: ElevatedButton(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? colorScheme.primary : Colors.grey,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(double.infinity, 28),
                        ),
                        child: Text(
                          isActive ? 'View' : 'Closed',
                          style: const TextStyle(
                            fontSize: 11,
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