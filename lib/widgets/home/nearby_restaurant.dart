

// import 'package:flutter/material.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/home/recommended_screen.dart';
// import 'package:veegify/widgets/home/discount.dart';

// class RestaurantCard extends StatefulWidget {
//   final String id;
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final dynamic price;
//   final String locationName;
//   final String status; // "active" / "inactive"
//   final dynamic discount;

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
//     required this.discount,
//   });

//   @override
//   State<RestaurantCard> createState() => _RestaurantCardState();
// }

// class _RestaurantCardState extends State<RestaurantCard> {
//   bool _isHovered = false;

//   String getFirstTwoWords(String text) {
//     final parts = text.trim().split(RegExp(r'\s+'));
//     if (parts.length >= 2) {
//       return "${parts[0]} ${parts[1]}";
//     } else if (parts.isNotEmpty) {
//       return parts[0];
//     }
//     return "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final bool isActive = widget.status.toLowerCase() == "active";
//     final bool isDesktop = Responsive.isDesktop(context);
//     final bool isMobile = Responsive.isMobile(context);
    
//     // Responsive card dimensions
//     final double cardWidth = Responsive.value(
//       context,
//       mobile: 170.0,
//       tablet: 170.0,
//       desktop: 170.0,
//     );

//     final double imageHeight = Responsive.value(
//       context,
//       mobile: 120.0,
//       tablet: 140.0,
//       desktop: 160.0,
//     );

//     final double horizontalMargin = Responsive.value(
//       context,
//       mobile: 12.0,
//       tablet: 14.0,
//       desktop: 16.0,
//     );

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
//       child: GestureDetector(
//         onTap: isActive
//             ? () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         RestaurantDetailScreen(restaurantId: widget.id),
//                   ),
//                 )
//             : null,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeInOut,
//           margin: EdgeInsets.only(right: horizontalMargin),
//           width: cardWidth,
//           transform: isDesktop && _isHovered && isActive
//               ? (Matrix4.identity()..scale(1.05))
//               : Matrix4.identity(),
//           child: Opacity(
//             opacity: isActive ? 1.0 : 0.55,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               decoration: BoxDecoration(
//                 color: isDark ? theme.cardColor : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: isDesktop && _isHovered && isActive
//                         ? theme.colorScheme.primary.withOpacity(0.3)
//                         : Colors.black.withOpacity(isDark ? 0.3 : 0.06),
//                     blurRadius: isDesktop && _isHovered && isActive ? 15 : 8,
//                     spreadRadius: isDesktop && _isHovered && isActive ? 2 : 1,
//                     offset: isDesktop && _isHovered && isActive
//                         ? const Offset(0, 6)
//                         : const Offset(0, 3),
//                   ),
//                 ],
//                 border: isDesktop && _isHovered && isActive
//                     ? Border.all(
//                         color: theme.colorScheme.primary.withOpacity(0.5),
//                         width: 2,
//                       )
//                     : null,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// IMAGE SECTION with cut corner design
//                   SizedBox(
//                     height: imageHeight,
//                     child: Stack(
//                       children: [
//                         // Image with cut corner design
//                         ClipPath(
//                           clipper: _CornerCutClipper(
//                             cutSize: isMobile ? 25.0 : 0,
//                           ),
//                           child: ClipRRect(
//                             borderRadius: const BorderRadius.vertical(
//                               top: Radius.circular(12),
//                               bottom: Radius.circular(12),
//                             ),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               curve: Curves.easeInOut,
//                               child: Image.network(
//                                 widget.imagePath,
//                                 height: imageHeight,
//                                 width: double.infinity,
//                                 fit: BoxFit.fill,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     Container(
//                                   height: imageHeight,
//                                   color: isDark
//                                       ? Colors.grey[800]
//                                       : Colors.grey[200],
//                                   child: Icon(
//                                     Icons.restaurant_menu_rounded,
//                                     size: Responsive.value(
//                                       context,
//                                       mobile: 30.0,
//                                       tablet: 36.0,
//                                       desktop: 42.0,
//                                     ),
//                                     color: theme.colorScheme.onSurface
//                                         .withOpacity(0.5),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         // Name at top left (placeholder)
//                         Positioned(
//                           top: 8,
//                           left: 8,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.black.withOpacity(0.7),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               '                  ',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),

//                         // Restaurant name at bottom left
//                         Positioned(
//                           bottom: 8,
//                           left: 8,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 10,
//                               vertical: 5,
//                             ),
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 78, 66, 66)
//                                   .withOpacity(0.7),
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               widget.name,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 13,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),

//                         // Location at bottom right
//                         Positioned(
//                           bottom: 8,
//                           right: 8,
//                           child: AnimatedContainer(
//                             duration: const Duration(milliseconds: 200),
//                             curve: Curves.easeInOut,
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: isDesktop && _isHovered && isActive
//                                   ? theme.colorScheme.primary
//                                   : Colors.black.withOpacity(0.7),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.location_on_outlined,
//                                   size: 14,
//                                   color: isDesktop && _isHovered && isActive
//                                       ? Colors.white
//                                       : Colors.amber,
//                                 ),
//                                 const SizedBox(width: 3),
//                                 Text(
//                                   getFirstTwoWords(widget.locationName),
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: isDesktop && _isHovered && isActive
//                                         ? Colors.white
//                                         : Colors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),

//                         // Discount Badge (Top Left)
//                         if (widget.discount != null &&
//                             widget.discount.toString().isNotEmpty)
//                           Positioned(
//                             top: 8,
//                             left: 8,
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               curve: Curves.easeInOut,
//                               transform: isDesktop && _isHovered && isActive
//                                   ? (Matrix4.identity()..scale(1.1))
//                                   : Matrix4.identity(),
//                               child: discountBadge(widget.discount),
//                             ),
//                           ),

//                         // Vendor Closed overlay
//                         if (!isActive)
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.55),
//                                 borderRadius: const BorderRadius.vertical(
//                                   top: Radius.circular(12),
//                                 ),
//                               ),
//                               child: Center(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: Responsive.value(
//                                       context,
//                                       mobile: 14.0,
//                                       tablet: 16.0,
//                                       desktop: 18.0,
//                                     ),
//                                     vertical: Responsive.value(
//                                       context,
//                                       mobile: 8.0,
//                                       tablet: 9.0,
//                                       desktop: 10.0,
//                                     ),
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.red.shade600.withOpacity(0.9),
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   child: Text(
//                                     "Vendor Closed",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: Responsive.fontSize(
//                                         context,
//                                         mobile: 13.0,
//                                         tablet: 14.0,
//                                         desktop: 15.0,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                         // Rating badge (only on hover for desktop)
//                         if (isDesktop && _isHovered && isActive)
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               curve: Curves.easeInOut,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.amber,
//                                 borderRadius: BorderRadius.circular(20),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.amber.withOpacity(0.5),
//                                     blurRadius: 8,
//                                     spreadRadius: 1,
//                                   ),
//                                 ],
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.star,
//                                     size: 14,
//                                     color: Colors.white,
//                                   ),
//                                   const SizedBox(width: 3),
//                                   Text(
//                                     widget.rating.toStringAsFixed(1),
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//                   /// CONTENT - Only show for desktop/tablet on hover
//                   // if (!isMobile && _isHovered && isActive)
//                   //   Expanded(
//                   //     child: Padding(
//                   //       padding: EdgeInsets.all(
//                   //         Responsive.spacing(
//                   //           context,
//                   //           mobile: 12.0,
//                   //           tablet: 14.0,
//                   //           desktop: 16.0,
//                   //         ),
//                   //       ),
//                   //       child: Column(
//                   //         crossAxisAlignment: CrossAxisAlignment.start,
//                   //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   //         children: [
//                   //           /// Name
//                   //           Text(
//                   //             widget.name,
//                   //             style: theme.textTheme.titleMedium?.copyWith(
//                   //               fontWeight: FontWeight.bold,
//                   //               color: theme.colorScheme.onSurface,
//                   //               fontSize: Responsive.fontSize(
//                   //                 context,
//                   //                 mobile: 14.0,
//                   //                 tablet: 15.0,
//                   //                 desktop: 16.0,
//                   //               ),
//                   //             ),
//                   //             maxLines: 2,
//                   //             overflow: TextOverflow.ellipsis,
//                   //           ),

//                   //           /// Location
//                   //           Row(
//                   //             children: [
//                   //               Icon(
//                   //                 Icons.location_on_outlined,
//                   //                 color: theme.colorScheme.primary,
//                   //                 size: Responsive.value(
//                   //                   context,
//                   //                   mobile: 16.0,
//                   //                   tablet: 18.0,
//                   //                   desktop: 20.0,
//                   //                 ),
//                   //               ),
//                   //               const SizedBox(width: 4),
//                   //               Expanded(
//                   //                 child: Text(
//                   //                   getFirstTwoWords(widget.locationName),
//                   //                   style: theme.textTheme.bodySmall?.copyWith(
//                   //                     color: theme.colorScheme.onSurface
//                   //                         .withOpacity(0.9),
//                   //                     fontSize: Responsive.fontSize(
//                   //                       context,
//                   //                       mobile: 12.0,
//                   //                       tablet: 13.0,
//                   //                       desktop: 14.0,
//                   //                     ),
//                   //                   ),
//                   //                   maxLines: 1,
//                   //                   overflow: TextOverflow.ellipsis,
//                   //                 ),
//                   //               ),
//                   //             ],
//                   //           ),

//                   //           /// Price (if available)
//                   //           if (widget.price != null) ...[
//                   //             const SizedBox(height: 4),
//                   //             Text(
//                   //               "From ₹${widget.price}",
//                   //               style: theme.textTheme.bodySmall?.copyWith(
//                   //                 color: theme.colorScheme.primary,
//                   //                 fontWeight: FontWeight.w600,
//                   //                 fontSize: Responsive.fontSize(
//                   //                   context,
//                   //                   mobile: 12.0,
//                   //                   tablet: 13.0,
//                   //                   desktop: 14.0,
//                   //                 ),
//                   //               ),
//                   //             ),
//                   //           ],
//                   //         ],
//                   //       ),
//                   //     ),
//                   //   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Custom clipper for cutting corner on mobile
// class _CornerCutClipper extends CustomClipper<Path> {
//   final double cutSize;

//   _CornerCutClipper({required this.cutSize});

//   @override
//   Path getClip(Size size) {
//     final path = Path();

//     if (cutSize > 0) {
//       // Start from top-left
//       path.moveTo(0, 0);
//       // Top edge
//       path.lineTo(size.width - cutSize, 0);
//       // Diagonal cut at top-right
//       path.lineTo(size.width, cutSize);
//       // Right edge
//       path.lineTo(size.width, size.height);
//       // Bottom edge
//       path.lineTo(0, size.height);
//       // Close path
//       path.close();
//     } else {
//       // No cut - full rectangle
//       path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//     }

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }

















// import 'package:flutter/material.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/home/recommended_screen.dart';
// import 'package:veegify/widgets/home/discount.dart';

// class RestaurantCard extends StatefulWidget {
//   final String id;
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final dynamic price;
//   final String locationName;
//   final String status; // "active" / "inactive"
//   final dynamic discount;

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
//     required this.discount,
//   });

//   @override
//   State<RestaurantCard> createState() => _RestaurantCardState();
// }

// class _RestaurantCardState extends State<RestaurantCard> {
//   bool _isHovered = false;

//   String getFirstTwoWords(String text) {
//     final parts = text.trim().split(RegExp(r'\s+'));
//     if (parts.length >= 2) {
//       return "${parts[0]} ${parts[1]}";
//     } else if (parts.isNotEmpty) {
//       return parts[0];
//     }
//     return "";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     final bool isActive = widget.status.toLowerCase() == "active";
//     final bool isDesktop = Responsive.isDesktop(context);
//     final bool isMobile = Responsive.isMobile(context);
//     final bool isTablet = Responsive.isTablet(context);

//     return MouseRegion(
//       onEnter: (_) => setState(() => _isHovered = true),
//       onExit: (_) => setState(() => _isHovered = false),
//       cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
//       child: GestureDetector(
//         onTap: isActive
//             ? () => Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         RestaurantDetailScreen(restaurantId: widget.id),
//                   ),
//                 )
//             : null,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeInOut,
//           transform: isDesktop && _isHovered && isActive
//               ? (Matrix4.identity()..scale(1.02))
//               : Matrix4.identity(),
//           child: Opacity(
//             opacity: isActive ? 1.0 : 0.55,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               curve: Curves.easeInOut,
//               decoration: BoxDecoration(
//                 color: isDark ? theme.cardColor : Colors.white,
//                 borderRadius: BorderRadius.circular(isMobile ? 16 : 12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: isDesktop && _isHovered && isActive
//                         ? theme.colorScheme.primary.withOpacity(0.3)
//                         : Colors.black.withOpacity(isDark ? 0.3 : 0.08),
//                     blurRadius: isDesktop && _isHovered && isActive ? 15 : 8,
//                     offset: isDesktop && _isHovered && isActive
//                         ? const Offset(0, 6)
//                         : const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: isMobile
//                   ? _buildMobileCard(theme, isDark, isActive)
//                   : _buildTabletDesktopCard(theme, isDark, isActive, isDesktop),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// Widget _buildMobileCard(ThemeData theme, bool isDark, bool isActive) {
//   // Generate random estimated time between 30-45 minutes
//   final String estimatedTime = "30 to 45"; // This will give 30-45 min range

//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       // Image Section with modern design
//       Stack(
//         children: [
//           // Main Image
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(16),
//             ),
//             child: AspectRatio(
//               aspectRatio: 16 / 9,
//               child: Image.network(
//                 widget.imagePath,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   color: isDark ? Colors.grey[800] : Colors.grey[200],
//                   child: Icon(
//                     Icons.restaurant_menu_rounded,
//                     size: 32,
//                     color: theme.colorScheme.onSurface.withOpacity(0.3),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Modern Gradient Overlay
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withOpacity(0.3),
//                     Colors.black.withOpacity(0.7),
//                   ],
//                 ),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(16),
//                 ),
//               ),
//             ),
//           ),

//           // Discount Badge - Modern Style
//           if (widget.discount != null && widget.discount.toString().isNotEmpty)
//             Positioned(
//               top: 12,
//               left: 12,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 5,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Colors.orange.shade400,
//                       Colors.red.shade500,
//                     ],
//                   ),
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.red.shade300.withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.local_offer_rounded,
//                       size: 14,
//                       color: Colors.white,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${widget.discount}% OFF',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//           // Rating Badge - Modern Style
//           Positioned(
//             top: 12,
//             right: 12,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.star,
//                     size: 14,
//                     color: Colors.amber.shade600,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     widget.rating.toStringAsFixed(1),
//                     style: TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Estimated Time Badge
//           Positioned(
//             bottom: 12,
//             left: 12,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.95),
//                 borderRadius: BorderRadius.circular(6),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.access_time_rounded,
//                     size: 14,
//                     color: theme.colorScheme.primary,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     '$estimatedTime min',
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // Restaurant Name Overlay
//           Positioned(
//             bottom: 12,
//             right: 12,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.6),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 widget.name,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),

//           // Vendor Closed Overlay
//           if (!isActive)
//             Positioned.fill(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.6),
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(16),
//                   ),
//                 ),
//                 child: Center(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade600,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Text(
//                       "Closed",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),

//       // Bottom Info Section
//       Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             // Location and Price
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Location with icon
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.location_on_outlined,
//                         size: 14,
//                         color: theme.colorScheme.primary.withOpacity(0.7),
//                       ),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           getFirstTwoWords(widget.locationName),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: theme.colorScheme.onSurface.withOpacity(0.7),
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   // Cuisine/Description
//                   Text(
//                     widget.description,
//                     style: TextStyle(
//                       fontSize: 11,
//                       color: theme.colorScheme.onSurface.withOpacity(0.5),
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
            
//             // Price and Order Button
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 // Price
//                 if (widget.price != null)
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 3,
//                     ),
//                     decoration: BoxDecoration(
//                       color: theme.colorScheme.primary.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       '₹${widget.price}',
//                       style: TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                   ),
//                 const SizedBox(height: 6),
//                 // Order Button
//                 // if (isActive)
//                 //   Container(
//                 //     padding: const EdgeInsets.symmetric(
//                 //       horizontal: 16,
//                 //       vertical: 6,
//                 //     ),
//                 //     decoration: BoxDecoration(
//                 //       gradient: LinearGradient(
//                 //         colors: [
//                 //           theme.colorScheme.primary,
//                 //           theme.colorScheme.primary.withOpacity(0.8),
//                 //         ],
//                 //       ),
//                 //       borderRadius: BorderRadius.circular(6),
//                 //     ),
//                 //     child: const Text(
//                 //       'Order',
//                 //       style: TextStyle(
//                 //         color: Colors.white,
//                 //         fontSize: 11,
//                 //         fontWeight: FontWeight.w600,
//                 //       ),
//                 //     ),
//                 //   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ],
//   );
// }

//   Widget _buildTabletDesktopCard(ThemeData theme, bool isDark, bool isActive, bool isDesktop) {
//     final double cardWidth = Responsive.value(
//       context,
//       mobile: 170.0,
//       tablet: 170.0,
//       desktop: 170.0,
//     );

//     final double imageHeight = Responsive.value(
//       context,
//       mobile: 120.0,
//       tablet: 140.0,
//       desktop: 160.0,
//     );

//     final double horizontalMargin = Responsive.value(
//       context,
//       mobile: 12.0,
//       tablet: 14.0,
//       desktop: 16.0,
//     );

//     return SizedBox(
//       width: cardWidth,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// IMAGE SECTION with cut corner design
//           SizedBox(
//             height: imageHeight,
//             child: Stack(
//               children: [
//                 // Image with cut corner design
//                 ClipPath(
//                   clipper: _CornerCutClipper(
//                     cutSize: Responsive.isMobile(context) ? 25.0 : 0,
//                   ),
//                   child: ClipRRect(
//                     borderRadius: const BorderRadius.vertical(
//                       top: Radius.circular(12),
//                       bottom: Radius.circular(12),
//                     ),
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       curve: Curves.easeInOut,
//                       child: Image.network(
//                         widget.imagePath,
//                         height: imageHeight,
//                         width: double.infinity,
//                         fit: BoxFit.fill,
//                         errorBuilder: (context, error, stackTrace) =>
//                             Container(
//                           height: imageHeight,
//                           color: isDark
//                               ? Colors.grey[800]
//                               : Colors.grey[200],
//                           child: Icon(
//                             Icons.restaurant_menu_rounded,
//                             size: Responsive.value(
//                               context,
//                               mobile: 30.0,
//                               tablet: 36.0,
//                               desktop: 42.0,
//                             ),
//                             color: theme.colorScheme.onSurface
//                                 .withOpacity(0.5),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Restaurant name at bottom left
//                 Positioned(
//                   bottom: 8,
//                   left: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 78, 66, 66)
//                           .withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Text(
//                       widget.name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 13,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ),

//                 // Location at bottom right
//                 Positioned(
//                   bottom: 8,
//                   right: 8,
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 200),
//                     curve: Curves.easeInOut,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isDesktop && _isHovered && isActive
//                           ? theme.colorScheme.primary
//                           : Colors.black.withOpacity(0.7),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.location_on_outlined,
//                           size: 14,
//                           color: isDesktop && _isHovered && isActive
//                               ? Colors.white
//                               : Colors.amber,
//                         ),
//                         const SizedBox(width: 3),
//                         Text(
//                           getFirstTwoWords(widget.locationName),
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w600,
//                             color: isDesktop && _isHovered && isActive
//                                 ? Colors.white
//                                 : Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Discount Badge (Top Left)
//                 if (widget.discount != null &&
//                     widget.discount.toString().isNotEmpty)
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       curve: Curves.easeInOut,
//                       transform: isDesktop && _isHovered && isActive
//                           ? (Matrix4.identity()..scale(1.1))
//                           : Matrix4.identity(),
//                       child: discountBadge(widget.discount),
//                     ),
//                   ),

//                 // Vendor Closed overlay
//                 if (!isActive)
//                   Positioned.fill(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.55),
//                         borderRadius: const BorderRadius.vertical(
//                           top: Radius.circular(12),
//                         ),
//                       ),
//                       child: Center(
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: Responsive.value(
//                               context,
//                               mobile: 14.0,
//                               tablet: 16.0,
//                               desktop: 18.0,
//                             ),
//                             vertical: Responsive.value(
//                               context,
//                               mobile: 8.0,
//                               tablet: 9.0,
//                               desktop: 10.0,
//                             ),
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade600.withOpacity(0.9),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             "Vendor Closed",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: Responsive.fontSize(
//                                 context,
//                                 mobile: 13.0,
//                                 tablet: 14.0,
//                                 desktop: 15.0,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                 // Rating badge (only on hover for desktop)
//                 if (isDesktop && _isHovered && isActive)
//                   Positioned(
//                     top: 8,
//                     right: 8,
//                     child: AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       curve: Curves.easeInOut,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.amber,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.amber.withOpacity(0.5),
//                             blurRadius: 8,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.star,
//                             size: 14,
//                             color: Colors.white,
//                           ),
//                           const SizedBox(width: 3),
//                           Text(
//                             widget.rating.toStringAsFixed(1),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Custom clipper for cutting corner on mobile
// class _CornerCutClipper extends CustomClipper<Path> {
//   final double cutSize;

//   _CornerCutClipper({required this.cutSize});

//   @override
//   Path getClip(Size size) {
//     final path = Path();

//     if (cutSize > 0) {
//       // Start from top-left
//       path.moveTo(0, 0);
//       // Top edge
//       path.lineTo(size.width - cutSize, 0);
//       // Diagonal cut at top-right
//       path.lineTo(size.width, cutSize);
//       // Right edge
//       path.lineTo(size.width, size.height);
//       // Bottom edge
//       path.lineTo(0, size.height);
//       // Close path
//       path.close();
//     } else {
//       // No cut - full rectangle
//       path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//     }

//     return path;
//   }

//   @override
//   bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
//     return true;
//   }
// }




















import 'package:flutter/material.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/home/recommended_screen.dart';
import 'package:veegify/widgets/home/discount.dart';

class RestaurantCard extends StatefulWidget {
  final String id;
  final String imagePath;
  final String name;
  final double rating;
  final String description;
  final dynamic price;
  final String locationName;
  final String status; // "active" / "inactive"
  final dynamic discount;
  String? distance;

   RestaurantCard({
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
    this.distance
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isHovered = false;

  String getFirstTwoWords(String text) {
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return "${parts[0]} ${parts[1]}";
    } else if (parts.isNotEmpty) {
      return parts[0];
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bool isActive = widget.status.toLowerCase() == "active";
    final bool isDesktop = Responsive.isDesktop(context);
    final bool isMobile = Responsive.isMobile(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isActive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: isActive
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RestaurantDetailScreen(restaurantId: widget.id),
                  ),
                )
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: isDesktop && _isHovered && isActive
              ? (Matrix4.identity()..scale(1.02))
              : Matrix4.identity(),
          child: Opacity(
            opacity: isActive ? 1.0 : 0.55,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(isMobile ? 12 : 10),
                boxShadow: [
                  BoxShadow(
                    color: isDesktop && _isHovered && isActive
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                    blurRadius: isDesktop && _isHovered && isActive ? 12 : 6,
                    offset: isDesktop && _isHovered && isActive
                        ? const Offset(0, 5)
                        : const Offset(0, 2),
                  ),
                ],
              ),
              child: isMobile
                  ? _buildMobileCard(theme, isDark, isActive)
                  : _buildTabletDesktopCard(theme, isDark, isActive, isDesktop),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCard(ThemeData theme, bool isDark, bool isActive) {
    const String estimatedTime = "20-40";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── IMAGE SECTION ──────────────────────────────────────────
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(
                      Icons.restaurant_menu_rounded,
                      size: 28,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ),

            // Subtle gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),
            ),

            // Discount Badge – top left
            if (widget.discount != null &&
                widget.discount.toString().isNotEmpty)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.red.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_rounded,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.discount}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                         if (widget.distance != null &&
                widget.distance.toString().isNotEmpty)
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.red.shade500,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade300.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.social_distance,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.distance}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Rating Badge – top right
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 11, color: Colors.amber.shade600),
                    const SizedBox(width: 3),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
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
                      top: Radius.circular(12),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Closed",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // ── INFO SECTION (outside image) ──────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Restaurant Name
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Location + Time row
              Row(
                children: [
                  // Location
                  Icon(
                    Icons.location_on_outlined,
                    size: 11,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      getFirstTwoWords(widget.locationName),
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Time badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 10,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$estimatedTime min',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Description + Price row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.price != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '₹${widget.price}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletDesktopCard(
      ThemeData theme, bool isDark, bool isActive, bool isDesktop) {
    final double cardWidth = Responsive.value(
      context,
      mobile: 140.0,
      tablet: 150.0,
      desktop: 155.0,
    );

    final double imageHeight = Responsive.value(
      context,
      mobile: 95.0,
      tablet: 110.0,
      desktop: 120.0,
    );

    return SizedBox(
      width: cardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE ────────────────────────────────────────────────
          SizedBox(
            height: imageHeight,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.imagePath,
                    height: imageHeight,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: imageHeight,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 26,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),

                // Discount Badge – top left
                if (widget.discount != null &&
                    widget.discount.toString().isNotEmpty)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      transform: isDesktop && _isHovered && isActive
                          ? (Matrix4.identity()..scale(1.1))
                          : Matrix4.identity(),
                      child: discountBadge(widget.discount),
                    ),
                  ),

                // Rating badge – shown on hover (desktop) or always (tablet)
                if (!isDesktop || (isDesktop && _isHovered && isActive))
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 11, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(
                            widget.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 10,
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
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Closed",
                            style: TextStyle(
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
          ),

          // ── INFO (outside image) ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Restaurant Name
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 3),

                // Location row
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: theme.colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        getFirstTwoWords(widget.locationName),
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Time + Price row
                Row(
                  children: [
                    // Time badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 10,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '30-45 min',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Price
                    if (widget.price != null)
                      Text(
                        '₹${widget.price}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}