// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// import '../../provider/RestaurantProvider/top_restaurants_provider.dart';

// class TopRestaurantsScreen extends StatefulWidget {
//   final String userId; // Add userId parameter
//   const TopRestaurantsScreen({super.key, required this.userId});

//   @override
//   State<TopRestaurantsScreen> createState() => _TopRestaurantsScreenState();
// }

// class _TopRestaurantsScreenState extends State<TopRestaurantsScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Fetch top restaurants when screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<TopRestaurantsProvider>().getTopRestaurants(widget.userId);
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
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

//             // List of Restaurants using Consumer
//             Expanded(
//               child: Consumer<TopRestaurantsProvider>(
//                 builder: (context, topRestaurantsProvider, child) {
//                   if (topRestaurantsProvider.isLoading) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                     );
//                   }

//                   if (topRestaurantsProvider.topRestaurants.isEmpty) {
//                     return Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             Icons.star_border,
//                             size: 64,
//                             color: theme.colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             "No top rated restaurants found",
//                             style: theme.textTheme.bodyLarge?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(0.7),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     itemCount: topRestaurantsProvider.topRestaurants.length,
//                     itemBuilder: (context, index) {
//                       final restaurant = topRestaurantsProvider.topRestaurants[index];
//                       return GestureDetector(
//                         onTap: () => Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => RestaurantDetailScreen(restaurantId: restaurant.id,),
//                           ),
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.all(8),
//                           margin: const EdgeInsets.only(bottom: 16),
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: isDark ? Colors.grey[700]! : const Color.fromARGB(255, 196, 196, 196),
//                             ),
//                             color: isDark ? theme.cardColor : Colors.white,
//                             boxShadow: [
//                               if (!isDark)
//                               BoxShadow(
//                                 color: Colors.grey.withOpacity(0.15),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 4),
//                               )
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               // Restaurant Image with Heart Icon
//                               Stack(
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(12),
//                                     child: Image.network(
//                                       restaurant.imageUrl ?? '', // Handle null image
//                                       height: 122,
//                                       width: 122,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) {
//                                         return Container(
//                                           height: 122,
//                                           width: 122,
//                                           decoration: BoxDecoration(
//                                             color: isDark ? Colors.grey[700] : Colors.grey[200],
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Icon(
//                                             Icons.restaurant,
//                                             size: 40,
//                                             color: theme.colorScheme.onSurface.withOpacity(0.5),
//                                           ),
//                                         );
//                                       },
//                                       loadingBuilder: (context, child, loadingProgress) {
//                                         if (loadingProgress == null) return child;
//                                         return Container(
//                                           height: 122,
//                                           width: 122,
//                                           decoration: BoxDecoration(
//                                             color: isDark ? Colors.grey[700] : Colors.grey[200],
//                                             borderRadius: BorderRadius.circular(12),
//                                           ),
//                                           child: Center(
//                                             child: CircularProgressIndicator(
//                                               color: theme.colorScheme.primary,
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                   Positioned(
//                                     top: 8,
//                                     right: 8,
//                                     child: CircleAvatar(
//                                       radius: 14,
//                                       backgroundColor: isDark ? theme.cardColor : Colors.white,
//                                       child: Icon(
//                                         Icons.favorite_border,
//                                         size: 16,
//                                         color: theme.colorScheme.onSurface,
//                                       ),
//                                     ),
//                                   )
//                                 ],
//                               ),

//                               // Restaurant Info
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 12,
//                                     horizontal: 12,
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         restaurant.restaurantName ?? 'Restaurant Name',
//                                         style: theme.textTheme.titleMedium?.copyWith(
//                                           fontWeight: FontWeight.w700,
//                                           color: theme.colorScheme.onSurface,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           Container(
//                                             padding: const EdgeInsets.all(4),
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.circular(20),
//                                               color: theme.colorScheme.primary,
//                                             ),
//                                             child: Icon(
//                                               Icons.star,
//                                               size: 16,
//                                               color: theme.colorScheme.onPrimary,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             restaurant.rating?.toString() ?? '0.0',
//                                             style: theme.textTheme.bodyMedium?.copyWith(
//                                               fontWeight: FontWeight.w600,
//                                               color: theme.colorScheme.onSurface,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         restaurant.description ?? 'No description available',
//                                         style: theme.textTheme.bodySmall?.copyWith(
//                                           color: theme.colorScheme.onSurface.withOpacity(0.7),
//                                         ),
//                                         maxLines: 2,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                       const SizedBox(height: 6),
//                                       Row(
//                                         children: [
//                                           Icon(
//                                             Icons.location_on,
//                                             color: theme.colorScheme.primary,
//                                             size: 16,
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Expanded(
//                                             child: Text(
//                                               restaurant.locationName.split(' ').first,
//                                               style: theme.textTheme.bodySmall?.copyWith(
//                                                 color: theme.colorScheme.onSurface.withOpacity(0.6),
//                                               ),
//                                               maxLines: 2,
//                                               overflow: TextOverflow.ellipsis,
//                                             ),
//                                           )
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
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
      await context.read<TopRestaurantsProvider>().getTopRestaurants(widget.userId);

      if (initialLoad && mounted) {
        setState(() {
          _firstLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error loading top restaurants: $e");
    }
  }

  /// Auto-refresh every 5 seconds without UI disturbance
  void _startSilentPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!mounted) return;
      try {
        await context.read<TopRestaurantsProvider>().getTopRestaurants(widget.userId);
      } catch (e) {
        debugPrint("Silent Poll Error: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Text(
                        "Top Rated Restaurants",
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Consumer<TopRestaurantsProvider>(
                builder: (context, provider, child) {
                  // First load loader
                  if (provider.isLoading && !_firstLoaded) {
                    return Center(
                      child: CircularProgressIndicator(color: theme.colorScheme.primary),
                    );
                  }

                  if (provider.topRestaurants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_border,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            "No top rated restaurants found",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.topRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = provider.topRestaurants[index];

                      /// Status check (active/inactive)
                      final bool isActive =
                          (restaurant.status ?? "").toLowerCase() == "active";

                      return GestureDetector(
                        onTap: isActive
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RestaurantDetailScreen(restaurantId: restaurant.id),
                                  ),
                                )
                            : null,
                        child: Opacity(
                          opacity: isActive ? 1.0 : 0.50,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.grey[700]!
                                    : const Color.fromARGB(255, 196, 196, 196),
                              ),
                              color: isDark ? theme.cardColor : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: isActive
                                      ? Colors.grey.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.55),
                                  blurRadius: isActive ? 8 : 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // IMAGE + CLOSED OVERLAY
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        restaurant.imageUrl ?? "",
                                        height: 122,
                                        width: 122,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            height: 122,
                                            width: 122,
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.grey[700] : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Icon(Icons.restaurant,
                                                size: 40,
                                                color: theme.colorScheme.onSurface.withOpacity(0.5)),
                                          );
                                        },
                                      ),
                                    ),

                                    // Vendor Closed overlay
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
                                                  horizontal: 14, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade600.withOpacity(0.9),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                "Vendor Closed",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // INFO SECTION
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          restaurant.restaurantName ?? "Restaurant Name",
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primary,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Icon(Icons.star,
                                                  size: 16,
                                                  color: theme.colorScheme.onPrimary),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              restaurant.rating?.toStringAsFixed(1) ?? "0.0",
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: theme.colorScheme.onSurface,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          restaurant.description ?? "No description available",
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                color: theme.colorScheme.primary, size: 16),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                restaurant.locationName.split(" ").first,
                                                style: theme.textTheme.bodySmall?.copyWith(
                                                  color: theme.colorScheme.onSurface
                                                      .withOpacity(0.6),
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
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
