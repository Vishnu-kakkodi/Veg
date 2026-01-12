
// import 'package:flutter/material.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// class RestaurantCard extends StatelessWidget {
//   final String id;
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final dynamic price;
//   final String locationName;
//   final String status; // "active" / "inactive"

//   const RestaurantCard({
//     super.key,
//     required this.id,
//     required this.imagePath,
//     required this.name,
//     required this.rating,
//     required this.description,
//     required this.price,
//     required this.locationName,
//     required this.status,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final bool isActive = status.toLowerCase() == "active";

//     final screenWidth = MediaQuery.of(context).size.width;

//     // 🔥 Responsive card width (for horizontal list)
//     final double cardWidth = Responsive.isMobile(context)
//         ? screenWidth * 0.38       // ~2.5 cards on screen
//         : Responsive.isTablet(context)
//             ? screenWidth * 0.28   // more spacious
//             : screenWidth * 0.22;  // desktop / large

//     return GestureDetector(
//       onTap: isActive
//           ? () => Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       RestaurantDetailScreen(restaurantId: id),
//                 ),
//               )
//           : null,
//       child: Opacity(
//         opacity: isActive ? 1.0 : 0.55,
//         child: Container(
//           margin: const EdgeInsets.only(right: 12),
//           width: cardWidth,
//           decoration: BoxDecoration(
//             color: isDark ? null : null,
//             borderRadius: BorderRadius.circular(12),
//             // boxShadow: [
//             //   if (!isDark)
//             //     BoxShadow(
//             //       color: Colors.black.withOpacity(0.06),
//             //       blurRadius: 6,
//             //       offset: const Offset(0, 3),
//             //     ),
//             // ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               /// IMAGE + RATING + CLOSED BANNER
//               SizedBox(
//                 height: 120,
//                 child: Stack(
//                   children: [
//                     // Image
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12),
//                         bottom: Radius.circular(12)
//                       ),
//                       child: Image.network(
//                         imagePath,
//                         height: 120,
//                         width: double.infinity,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Container(
//                           height: 120,
//                           color: isDark ? Colors.grey[800] : Colors.grey[200],
//                           child: Icon(
//                             Icons.restaurant_menu_rounded,
//                             size: 30,
//                             color:
//                                 theme.colorScheme.onSurface.withOpacity(0.5),
//                           ),
//                         ),
//                       ),
//                     ),

//                     /// ⭐ Rating Badge - Bottom Right
//                     Positioned(
//                       right: 0,
//                       bottom: 0,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200.withOpacity(0.95),
//                           borderRadius: const BorderRadius.only(
//                             topLeft: Radius.circular(10),
//                             bottomRight: Radius.circular(12),
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.star,
//                               size: 14,
//                               color: Color(0xFF1BA014),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               rating.toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     /// Vendor Closed overlay
//                     if (!isActive)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.55),
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(12),
//                             ),
//                           ),
//                           child: Center(
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 14,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.shade600.withOpacity(0.9),
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: const Text(
//                                 "Vendor Closed",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               /// CONTENT
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// Name
//                     Text(
//                       name,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.onSurface,
//                         fontSize: 14,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 6),

//                     /// Location
//                     Row(
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
//                               color: theme.colorScheme.onSurface
//                                   .withOpacity(0.9),
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // You can also show `price` or `description` here later
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
import 'package:veegify/utils/responsive.dart';
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

    // 🔥 Responsive card dimensions
    final double cardWidth = Responsive.value(
      context,
      mobile: 176.0,
      tablet: 220.0,
      desktop: 260.0,
    );

    final double imageHeight = Responsive.value(
      context,
      mobile: 120.0,
      tablet: 140.0,
      desktop: 160.0,
    );

    final double horizontalMargin = Responsive.value(
      context,
      mobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    return GestureDetector(
      onTap: isActive
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RestaurantDetailScreen(restaurantId: id),
                ),
              )
          : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: Container(
          margin: EdgeInsets.only(right: horizontalMargin),
          width: cardWidth,
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// IMAGE + RATING + CLOSED BANNER
              SizedBox(
                height: imageHeight,
                child: Stack(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        imagePath,
                        height: imageHeight,
                        width: double.infinity,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: imageHeight,
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: Responsive.value(
                              context,
                              mobile: 30.0,
                              tablet: 36.0,
                              desktop: 42.0,
                            ),
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                    /// ⭐ Rating Badge - Bottom Right
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.value(
                            context,
                            mobile: 8.0,
                            tablet: 10.0,
                            desktop: 12.0,
                          ),
                          vertical: Responsive.value(
                            context,
                            mobile: 4.0,
                            tablet: 5.0,
                            desktop: 6.0,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200.withOpacity(0.95),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: Responsive.value(
                                context,
                                mobile: 14.0,
                                tablet: 16.0,
                                desktop: 18.0,
                              ),
                              color: const Color(0xFF1BA014),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: Responsive.fontSize(
                                  context,
                                  mobile: 12.0,
                                  tablet: 13.0,
                                  desktop: 14.0,
                                ),
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// Vendor Closed overlay
                    if (!isActive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.value(
                                  context,
                                  mobile: 14.0,
                                  tablet: 16.0,
                                  desktop: 18.0,
                                ),
                                vertical: Responsive.value(
                                  context,
                                  mobile: 8.0,
                                  tablet: 9.0,
                                  desktop: 10.0,
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Vendor Closed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: Responsive.fontSize(
                                    context,
                                    mobile: 13.0,
                                    tablet: 14.0,
                                    desktop: 15.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(
                    Responsive.spacing(
                      context,
                      mobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Name
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                          fontSize: Responsive.fontSize(
                            context,
                            mobile: 14.0,
                            tablet: 15.0,
                            desktop: 16.0,
                          ),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      /// Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                            size: Responsive.value(
                              context,
                              mobile: 16.0,
                              tablet: 18.0,
                              desktop: 20.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              locationName.split(' ').first,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.9),
                                fontSize: Responsive.fontSize(
                                  context,
                                  mobile: 12.0,
                                  tablet: 13.0,
                                  desktop: 14.0,
                                ),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      /// Price (if available)
                      if (price != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "From ₹$price",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.fontSize(
                              context,
                              mobile: 12.0,
                              tablet: 13.0,
                              desktop: 14.0,
                            ),
                          ),
                        ),
                      ],
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