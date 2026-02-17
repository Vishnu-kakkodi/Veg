import 'package:flutter/material.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/home/recommended_screen.dart';
import 'package:veegify/widgets/home/discount.dart';

class RestaurantCard extends StatelessWidget {
  final String id;
  final String imagePath;
  final String name;
  final double rating;
  final String description;
  final dynamic price;
  final String locationName;
  final String status; // "active" / "inactive"
  final dynamic discount;

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
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {

    String getFirstTwoWords(String text) {
  final parts = text.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return "${parts[0]} ${parts[1]}";
  } else if (parts.isNotEmpty) {
    return parts[0];
  }
  return "";
}

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isActive = status.toLowerCase() == "active";
    final isMobile = Responsive.isMobile(context);
    
    // 🔥 Responsive card dimensions
    final double cardWidth = Responsive.value(
      context,
      mobile: 170.0,
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
              /// IMAGE SECTION with cut corner design
              SizedBox(
                height: imageHeight,
                child: Stack(
                  children: [
                    // Image with cut corner design
                    ClipPath(
                      clipper: _CornerCutClipper(
                        cutSize: isMobile ? 25.0 : 0, // Cut only on mobile
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                                                    bottom: Radius.circular(12),

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
                    ),

                    /// For Mobile: Name and Rating inside image
                    if (isMobile) ...[
                      // Name at top left
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '                  ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                                           Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 78, 66, 66).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      
                      // Rating at bottom left (inside image)
                      // Positioned(
                      //   top: 8,
                      //   right: 12,
                      //   child: Container(
                      //     padding: const EdgeInsets.symmetric(
                      //       horizontal: 8,
                      //       vertical: 4,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: Colors.black.withOpacity(0.7),
                      //       borderRadius: BorderRadius.circular(20),
                      //     ),
                      //     child: Row(
                      //       mainAxisSize: MainAxisSize.min,
                      //       children: [
                      //         const Icon(
                      //           Icons.star,
                      //           size: 14,
                      //           color: Colors.amber,
                      //         ),
                      //         const SizedBox(width: 3),
                      //         Text(
                      //           rating.toStringAsFixed(1),
                      //           style: const TextStyle(
                      //             fontSize: 12,
                      //             fontWeight: FontWeight.w600,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                                            Positioned(
                        bottom: 8,
                        right: 8,
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
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                locationName,
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
                    ],

                    /// For Desktop/Tablet: Rating badge at top right
                    if (!isMobile)
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

                    /// Discount Badge (Top Left)
                    if (discount != null && discount.toString().isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: discountBadge(discount),
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

              /// CONTENT - Only show for desktop/tablet, mobile already has name/rating in image
              if (!isMobile)
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
                                 getFirstTwoWords(locationName),

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

/// Custom clipper for cutting corner on mobile
class _CornerCutClipper extends CustomClipper<Path> {
  final double cutSize;

  _CornerCutClipper({required this.cutSize});

  @override
  Path getClip(Size size) {
    final path = Path();
    
    if (cutSize > 0) {
      // Start from top-left
      path.moveTo(0, 0);
      // Top edge
      path.lineTo(size.width - cutSize, 0);
      // Diagonal cut at top-right
      path.lineTo(size.width, cutSize);
      // Right edge
      path.lineTo(size.width, size.height);
      // Bottom edge
      path.lineTo(0, size.height);
      // Close path
      path.close();
    } else {
      // No cut - full rectangle
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    }
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}