

// import 'package:flutter/material.dart';
// import 'package:veegify/utils/responsive.dart';
// import 'package:veegify/views/Category/category_based_screen.dart';

// class CategoryCard extends StatelessWidget {
//   final String id;
//   final String imagePath;
//   final String title;
//   final String userId;

//   const CategoryCard({
//     super.key,
//     required this.id,
//     required this.imagePath,
//     required this.title,
//     required this.userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;

//     // 🔥 Responsive width based on screen size
//     final screenWidth = MediaQuery.of(context).size.width;
//     double cardWidth;

//     if (Responsive.isMobile(context)) {
//       cardWidth = screenWidth * 0.24;   // ~4 cards on screen
//     } else if (Responsive.isTablet(context)) {
//       cardWidth = screenWidth * 0.18;   // ~5–6 cards
//     } else {
//       cardWidth = screenWidth * 0.12;   // desktop, more compact
//     }

//     return SizedBox(
//       width: cardWidth,
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => CategoryBasedScreen(
//                 categoryId: id,
//                 title: title,
//                 userId: userId,
//               ),
//             ),
//           );
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           decoration: BoxDecoration(
//             color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               if (!isDark)
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.1),
//                   spreadRadius: 1,
//                   blurRadius: 4,
//                   offset: const Offset(0, 2),
//                 ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 26,
//                 backgroundColor: isDark ? Colors.grey[700] : Colors.white,
//                 backgroundImage: NetworkImage(imagePath),
//                 onBackgroundImageError: (exception, stackTrace) {
//                   // TODO: handle image error if needed
//                 },
//               ),
//               const SizedBox(height: 8),
//               Flexible(
//                 child: Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: theme.colorScheme.onSurface,
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
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
import 'package:veegify/views/Category/category_based_screen.dart';

class CategoryCard extends StatelessWidget {
  final String id;
  final String imagePath;
  final String title;
  final String userId;

  const CategoryCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    /// ✅ FIX: Use fixed responsive widths
    final double cardWidth = Responsive.value(
      context,
      mobile: 84,   // 4–5 cards visible
      tablet: 100,  // balanced
      desktop: 110, // compact & clean
    );

    final double avatarRadius = Responsive.value(
      context,
      mobile: 24,
      tablet: 26,
      desktop: 28,
    );

    final double verticalPadding = Responsive.value(
      context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CategoryBasedScreen(
                categoryId: id,
                title: title,
                userId: userId,
              ),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: isDark ? Colors.grey[700] : Colors.white,
                backgroundImage: NetworkImage(imagePath),
                onBackgroundImageError: (_, __) {},
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
