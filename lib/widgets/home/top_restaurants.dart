// import 'package:flutter/material.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// // --- TopRestaurantCard Widget ---
// class TopRestaurantCard extends StatelessWidget {
//   final String id;
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final dynamic price;
//   final String locationName;

//   const TopRestaurantCard({
//     super.key,
//     required this.id,
//     required this.imagePath,
//     required this.name,
//     required this.rating,
//     required this.description,
//     required this.price,
//     required this.locationName
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
    
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context, 
//         MaterialPageRoute(
//           builder: (context) => RestaurantDetailScreen(restaurantId: id)
//         )
//       ),
//       child: Container(
//         margin: const EdgeInsets.only(right: 12),
//         padding: const EdgeInsets.all(8),
//         decoration: BoxDecoration(
//           color: isDark ? theme.cardColor : const Color.fromARGB(255, 255, 255, 255),
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(
//             color: isDark ? Colors.grey[700]! : const Color.fromARGB(255, 163, 163, 163),
//           ),
//         ),
//         child: Container(
//           width: 186,
//           decoration: BoxDecoration(
//             color: isDark ? theme.cardColor : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               if (!isDark)
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Image Container
//               Container(
//                 height: 120,
//                 child: Stack(
//                   children: [
//                     Container(
//                       height: 120,
//                       decoration: BoxDecoration(
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(12),
//                         ),
//                         image: DecorationImage(
//                           image: NetworkImage(imagePath),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     // Positioned(
//                     //   top: 8,
//                     //   right: 8,
//                     //   child: Container(
//                     //     width: 40,
//                     //     height: 40,
//                     //     padding: const EdgeInsets.all(4),
//                     //     decoration: BoxDecoration(
//                     //       color: isDark ? theme.cardColor : Colors.white,
//                     //       borderRadius: BorderRadius.circular(25),
//                     //     ),
//                     //     child: Icon(
//                     //       Icons.favorite_border,
//                     //       size: 24,
//                     //       color: theme.colorScheme.onSurface,
//                     //     ),
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
      
//               // Content Container
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.onSurface,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 20,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             color: theme.colorScheme.primary,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Icon(
//                             Icons.star,
//                             color: theme.colorScheme.onPrimary,
//                             size: 12,
//                           ),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           rating.toStringAsFixed(1),
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: theme.colorScheme.onSurface,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       description,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         Icon(
//                           Icons.location_on_outlined,
//                           color: theme.colorScheme.primary,
//                           size: 16,
//                         ),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             locationName.split(' ').first,
//                             style: theme.textTheme.bodySmall?.copyWith(
//                               color: theme.colorScheme.onSurface.withOpacity(0.6),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




















import 'package:flutter/material.dart';
import 'package:veegify/views/home/recommended_screen.dart';

// --- TopRestaurantCard Widget ---
class TopRestaurantCard extends StatelessWidget {
  final String id;
  final String imagePath;
  final String name;
  final double rating;
  final String description;
  final dynamic price;
  final String locationName;
  final String status; // <--- NEW

  const TopRestaurantCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.name,
    required this.rating,
    required this.description,
    required this.price,
    required this.locationName,
    required this.status, // <--- NEW
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bool isActive = status.toLowerCase() == "active";

    return GestureDetector(
      onTap: isActive
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailScreen(restaurantId: id),
                ),
              )
          : null, // Disable navigation when inactive
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55, // Dim inactive card
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : const Color.fromARGB(255, 163, 163, 163),
            ),
          ),
          child: Container(
            width: 186,
            decoration: BoxDecoration(
              color: isDark ? theme.cardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? Colors.grey.withOpacity(0.1)
                      : Colors.black.withOpacity(0.6), // Dark shadow when closed
                  spreadRadius: isActive ? 1 : 2,
                  blurRadius: isActive ? 4 : 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container
                Container(
                  height: 120,
                  child: Stack(
                    children: [
                      // Background Image
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: NetworkImage(imagePath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Vendor Closed Overlay
                      if (!isActive)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius:
                                  const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade600.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Vendor Closed",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Content Container
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.star,
                              color: theme.colorScheme.onPrimary,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationName.split(" ").first,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
