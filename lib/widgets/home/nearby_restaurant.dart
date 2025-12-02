// import 'package:flutter/material.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// // --- RestaurantCard Widget ---
// class RestaurantCard extends StatelessWidget {
//   final String id;
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final dynamic price;
//   final String locationName;
//   final String status;

//   const RestaurantCard({
//     super.key,
//     required this.id,
//     required this.imagePath,
//     required this.name,
//     required this.rating,
//     required this.description,
//     required this.price,
//     required this.locationName,
//     required this.status
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
//         width: 186,
//         decoration: BoxDecoration(
//           color: isDark ? theme.cardColor : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             if (!isDark)
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Image Container with Stack
//             Container(
//               height: 186,
//               child: Stack(
//                 children: [
//                   // Image Container with Direct Shadow
//                   Container(
//                     height: 186,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       image: DecorationImage(
//                         image: NetworkImage(imagePath),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
      
//                   // Favorite Icon - Top Right (commented out but themed)
//                   // Positioned(
//                   //   top: 8,
//                   //   right: 8,
//                   //   child: Container(
//                   //     width: 40,
//                   //     height: 40,
//                   //     padding: const EdgeInsets.all(4),
//                   //     decoration: BoxDecoration(
//                   //       color: isDark ? theme.cardColor : Colors.white,
//                   //       borderRadius: BorderRadius.circular(25),
//                   //     ),
//                   //     child: Icon(
//                   //       Icons.favorite_border,
//                   //       size: 24,
//                   //       color: theme.colorScheme.onSurface,
//                   //     ),
//                   //   ),
//                   // ),
      
//                   // Price - Bottom Left
//                   // Positioned(
//                   //   bottom: 8,
//                   //   left: 8,
//                   //   child: Container(
//                   //     padding:
//                   //         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   //     child: Column(
//                   //       crossAxisAlignment: CrossAxisAlignment.start,
//                   //       mainAxisSize: MainAxisSize.min,
//                   //       children: [
//                   //         Text(
//                   //           'Starting at',
//                   //           style: TextStyle(
//                   //             color: Colors.white,
//                   //             fontSize: 12,
//                   //             fontWeight: FontWeight.w500,
//                   //           ),
//                   //         ),
//                   //         Text(
//                   //           '₹$price',
//                   //           style: const TextStyle(
//                   //             color: Colors.white,
//                   //             fontSize: 16,
//                   //             fontWeight: FontWeight.w600,
//                   //           ),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // ),
//                 ],
//               ),
//             ),
      
//             // Content Container
//             Container(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     name,
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: theme.colorScheme.onSurface,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 20,
//                         height: 20,
//                         decoration: BoxDecoration(
//                           color: theme.colorScheme.primary,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           Icons.star, 
//                           color: theme.colorScheme.onPrimary, 
//                           size: 12
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         rating.toStringAsFixed(1),
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     description,
//                     style: theme.textTheme.bodySmall?.copyWith(
//                       color: theme.colorScheme.onSurface.withOpacity(0.7),
//                     ),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         color: theme.colorScheme.primary,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           locationName.split(' ').first,
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             color: theme.colorScheme.onSurface.withOpacity(0.6),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

















import 'package:flutter/material.dart';
import 'package:veegify/views/home/recommended_screen.dart';

class RestaurantCard extends StatelessWidget {
  final String id;
  final String imagePath;
  final String name;
  final double rating;
  final String description;
  final dynamic price;
  final String locationName;
  final String status; // "active" / "inactive"

  const RestaurantCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.name,
    required this.rating,
    required this.description,
    required this.price,
    required this.locationName,
    required this.status,
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
                  builder: (context) =>
                      RestaurantDetailScreen(restaurantId: id),
                ),
              )
          : null, // Block navigation
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55, // Dim inactive restaurants
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          width: 186,
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? Colors.grey.withOpacity(0.12)
                    : Colors.black.withOpacity(0.6), // Dark shadow for inactive
                spreadRadius: isActive ? 1 : 2,
                blurRadius: isActive ? 4 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container with Stack
              SizedBox(
                height: 186,
                child: Stack(
                  children: [
                    // Image
                    Container(
                      height: 186,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: NetworkImage(imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // Vendor Closed Banner
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
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Vendor Closed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                    // Restaurant Name
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

                    // Rating
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

                    // Description
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Location
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
                            locationName.split(' ').first,
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
            ],
          ),
        ),
      ),
    );
  }
}
