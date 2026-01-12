
// import 'package:flutter/material.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/home/recommended_screen.dart';

// class TicketRestaurantCard extends StatelessWidget {
//   final String id;
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final dynamic price;
//   final String locationName;
//   final String status; // "active" / "inactive"

//   const TicketRestaurantCard({
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

//     // 🔥 Responsive sizing for left image & perforation
//     final double imageWidth = Responsive.isMobile(context)
//         ? 110
//         : Responsive.isTablet(context)
//             ? 130
//             : 150;

//     final double imageHeight = Responsive.isMobile(context)
//         ? 120
//         : Responsive.isTablet(context)
//             ? 135
//             : 150;

//     final double perforationWidth = Responsive.isMobile(context)
//         ? 18
//         : Responsive.isTablet(context)
//             ? 20
//             : 22;

//     return GestureDetector(
//       onTap: isActive
//           ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       RestaurantDetailScreen(restaurantId: id),
//                 ),
//               );
//             }
//           : null,
//       child: Opacity(
//         opacity: isActive ? 1.0 : 0.55,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
//           decoration: BoxDecoration(
//             color: isDark ? theme.cardColor : Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: isActive
//                     ? Colors.black.withOpacity(0.06)
//                     : Colors.black.withOpacity(0.35),
//                 blurRadius: isActive ? 8 : 12,
//                 spreadRadius: 1,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               // Left: Image with ticket rounded corners
//               ClipRRect(
//                 borderRadius: const BorderRadius.horizontal(
//                   left: Radius.circular(16),
//                 ),
//                 child: SizedBox(
//                   width: imageWidth,
//                   height: imageHeight,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Image.network(
//                         imagePath,
//                         fit: BoxFit.fill,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Container(
//                           color: isDark ? Colors.grey[800] : Colors.grey[300],
//                           child: Icon(
//                             Icons.restaurant_menu_rounded,
//                             size: 28,
//                             color: theme.colorScheme.onSurface
//                                 .withOpacity(0.5),
//                           ),
//                         ),
//                       ),

//                       // Rating badge on image
//                       Positioned(
//                         right: 6,
//                         top: 6,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.black.withOpacity(0.7),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Icon(
//                                 Icons.star,
//                                 size: 14,
//                                 color: Colors.amber,
//                               ),
//                               const SizedBox(width: 3),
//                               Text(
//                                 rating.toStringAsFixed(1),
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // Vendor Closed overlay
//                       if (!isActive)
//                         Container(
//                           color: Colors.black.withOpacity(0.55),
//                           child: Center(
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 10,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.red.shade600.withOpacity(0.95),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Text(
//                                 "Vendor Closed",
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Perforated separator (ticket cut)
//               SizedBox(
//                 width: perforationWidth,
//                 height: imageHeight,
//                 child: Stack(
//                   children: [
//                     // Dotted line
//                     Center(
//                       child: LayoutBuilder(
//                         builder: (context, constraints) {
//                           final dotCount =
//                               (constraints.maxHeight / 6).floor();
//                           return Column(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: List.generate(dotCount, (index) {
//                               return Container(
//                                 width: 2,
//                                 height: 2,
//                                 decoration: BoxDecoration(
//                                   color: isDark
//                                       ? Colors.grey[600]
//                                       : Colors.grey[400],
//                                   shape: BoxShape.circle,
//                                 ),
//                               );
//                             }),
//                           );
//                         },
//                       ),
//                     ),
//                     // Top circle cut
//                     Align(
//                       alignment: Alignment.topCenter,
//                       child: Container(
//                         width: perforationWidth,
//                         height: 18,
//                         decoration: BoxDecoration(
//                           color: theme.scaffoldBackgroundColor,
//                           borderRadius: const BorderRadius.vertical(
//                             bottom: Radius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Bottom circle cut
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child: Container(
//                         width: perforationWidth,
//                         height: 18,
//                         decoration: BoxDecoration(
//                           color: theme.scaffoldBackgroundColor,
//                           borderRadius: const BorderRadius.vertical(
//                             top: Radius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Right: Content
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 10,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Name + status
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               name,
//                               style: theme.textTheme.titleMedium?.copyWith(
//                                 fontWeight: FontWeight.bold,
//                                 color: theme.colorScheme.onSurface,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 6,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: isActive
//                                   ? Colors.green.withOpacity(0.15)
//                                   : Colors.red.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               isActive ? "Open" : "Closed",
//                               style: TextStyle(
//                                 color: isActive ? Colors.green : Colors.red,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 10,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 6),

//                       // Description
//                       Text(
//                         description,
//                         style: theme.textTheme.bodySmall?.copyWith(
//                           color:
//                               theme.colorScheme.onSurface.withOpacity(0.7),
//                           height: 1.3,
//                         ),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),

//                       const SizedBox(height: 8),

//                       // Location
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on_outlined,
//                             size: 16,
//                             color: theme.colorScheme.primary,
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               locationName.split(' ').first,
//                               style: theme.textTheme.bodySmall?.copyWith(
//                                 color: theme.colorScheme.onSurface
//                                     .withOpacity(0.6),
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),

//                       const SizedBox(height: 6),

//                       // Starting price
//                       if (price != null)
//                         Text(
//                           "Starts from ₹$price",
//                           style: theme.textTheme.bodySmall?.copyWith(
//                             fontWeight: FontWeight.w600,
//                             color: theme.colorScheme.primary,
//                           ),
//                         ),
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























import 'package:flutter/material.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/home/recommended_screen.dart';

class TicketRestaurantCard extends StatelessWidget {
  final String id;
  final String imagePath;
  final String name;
  final double rating;
  final String description;
  final dynamic price;
  final String locationName;
  final String status; // "active" / "inactive"

  const TicketRestaurantCard({
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

    // 🔥 Responsive dimensions
    final double imageWidth = Responsive.value(
      context,
      mobile: 110.0,
      tablet: 140.0,
      desktop: 170.0,
    );

    final double imageHeight = Responsive.value(
      context,
      mobile: 120.0,
      tablet: 145.0,
      desktop: 170.0,
    );

    final double perforationWidth = Responsive.value(
      context,
      mobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    final double contentPadding = Responsive.spacing(
      context,
      mobile: 10.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    // For desktop/tablet grid view, use card layout instead of horizontal ticket
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    if (isDesktop || isTablet) {
      return _buildGridCard(
        context,
        theme,
        isDark,
        isActive,
        imageHeight,
      );
    }

    // Mobile: Horizontal ticket layout
    return _buildTicketCard(
      context,
      theme,
      isDark,
      isActive,
      imageWidth,
      imageHeight,
      perforationWidth,
      contentPadding,
    );
  }

  /// Desktop/Tablet: Vertical Grid Card Layout
  Widget _buildGridCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isActive,
    double imageHeight,
  ) {
    return GestureDetector(
      onTap: isActive
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RestaurantDetailScreen(restaurantId: id),
                ),
              );
            }
          : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with overlay
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        imagePath,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: 48,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),

                    // Rating badge
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Vendor Closed overlay
                    if (!isActive)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                "Vendor Closed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Status badge
                    if (isActive)
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Open",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),

                          // Description
                          Text(
                            description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.7),
                              height: 1.3,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Bottom info
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  locationName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Price
                          if (price != null)
                            Text(
                              "Starts from ₹$price",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                                fontSize: 13,
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

  /// Mobile: Horizontal Ticket Card Layout
  Widget _buildTicketCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isActive,
    double imageWidth,
    double imageHeight,
    double perforationWidth,
    double contentPadding,
  ) {
    return GestureDetector(
      onTap: isActive
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RestaurantDetailScreen(restaurantId: id),
                ),
              );
            }
          : null,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? Colors.black.withOpacity(0.06)
                    : Colors.black.withOpacity(0.35),
                blurRadius: isActive ? 8 : 12,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: Image
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
                child: SizedBox(
                  width: imageWidth,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: 28,
                            color: theme.colorScheme.onSurface
                                .withOpacity(0.5),
                          ),
                        ),
                      ),

                      // Rating badge
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Vendor Closed overlay
                      if (!isActive)
                        Container(
                          color: Colors.black.withOpacity(0.55),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Vendor Closed",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Perforated separator
              SizedBox(
                width: perforationWidth,
                height: imageHeight,
                child: Stack(
                  children: [
                    // Dotted line
                    Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final dotCount =
                              (constraints.maxHeight / 6).floor();
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(dotCount, (index) {
                              return Container(
                                width: 2,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          );
                        },
                      ),
                    ),
                    // Top circle cut
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: perforationWidth,
                        height: 18,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    // Bottom circle cut
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: perforationWidth,
                        height: 18,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(contentPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name + status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? "Open" : "Closed",
                              style: TextStyle(
                                color: isActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
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
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
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

                      const SizedBox(height: 6),

                      // Price
                      if (price != null)
                        Text(
                          "Starts from ₹$price",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
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