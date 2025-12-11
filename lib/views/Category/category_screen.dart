// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:veegify/provider/CategoryProvider/category_provider.dart';
// import 'package:veegify/views/Category/category_based_screen.dart';
// import 'package:veegify/views/Category/top_restaurants_screen.dart';

// class CategoryScreen extends StatelessWidget {
//   final String userId;
//   const CategoryScreen({super.key, required this.userId});

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
//                     // Centered Title
//                     Center(
//                       child: Text(
//                         "Categories",
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                     // iOS-style Back Icon on the left
//                     Align(
//                       alignment: Alignment.centerLeft,
//                       child: IconButton(
//                         icon: Icon(
//                           Icons.arrow_back_ios,
//                           color: theme.colorScheme.onSurface,
//                         ),
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Body
//             Expanded(
//               child: Consumer<CategoryProvider>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return Center(
//                       child: CircularProgressIndicator(
//                         color: theme.colorScheme.primary,
//                       ),
//                     );
//                   } else if (provider.error != null) {
//                     return Center(
//                       child: Text(
//                         'Error: ${provider.error}',
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onSurface.withOpacity(0.7),
//                         ),
//                       ),
//                     );
//                   }

//                   return Padding(
//                     padding: const EdgeInsets.all(24),
//                     child: GridView.builder(
//                       itemCount: provider.categories.length,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 3,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 3 / 4,
//                       ),
//                       itemBuilder: (context, index) {
//                         final category = provider.categories[index];
//                         return GestureDetector(
//                           onTap: () => Navigator.push(
//                             context, 
//                             MaterialPageRoute(
//                               builder: (context) => CategoryBasedScreen(
//                                 categoryId: category.id, 
//                                 title: category.categoryName, 
//                                 userId: userId,
//                               )
//                             )
//                           ),
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 if (!isDark)
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.1),
//                                   spreadRadius: 1,
//                                   blurRadius: 4,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 CircleAvatar(
//                                   radius: 34,
//                                   backgroundImage: NetworkImage(category.imageUrl),
//                                   backgroundColor: isDark ? Colors.grey[700] : Colors.white,
//                                   onBackgroundImageError: (exception, stackTrace) {
//                                     // Handle image loading errors gracefully
//                                   },
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   category.categoryName,
//                                   textAlign: TextAlign.center,
//                                   style: theme.textTheme.bodySmall?.copyWith(
//                                     fontWeight: FontWeight.w600,
//                                     color: theme.colorScheme.onSurface,
//                                   ),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
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




















import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:veegify/provider/CategoryProvider/category_provider.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Category/category_based_screen.dart';

class CategoryScreen extends StatelessWidget {
  final String userId;
  const CategoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 🔥 Responsive values
    final bool isMobile = Responsive.isMobile(context);
    final bool isTablet = Responsive.isTablet(context);

    final int crossAxisCount = isMobile
        ? 3
        : isTablet
            ? 4
            : 6;

    final double childAspectRatio = isMobile
        ? 3 / 4
        : isTablet
            ? 3 / 3.6
            : 3 / 3.2;

    final double avatarRadius = isMobile
        ? 34
        : isTablet
            ? 40
            : 44;

    final double gridPadding = isMobile ? 16 : 24;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Categories",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Body
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    );
                  } else if (provider.error != null) {
                    return Center(
                      child: Text(
                        'Error: ${provider.error}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    );
                  }

                  if (provider.categories.isEmpty) {
                    return Center(
                      child: Text(
                        'No categories available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.all(gridPadding),
                    child: GridView.builder(
                      itemCount: provider.categories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final category = provider.categories[index];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryBasedScreen(
                                categoryId: category.id,
                                title: category.categoryName,
                                userId: userId,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.cardColor
                                  : const Color(0xFFEBF4F1),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (!isDark)
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundImage:
                                      NetworkImage(category.imageUrl),
                                  backgroundColor: isDark
                                      ? Colors.grey[700]
                                      : Colors.white,
                                  onBackgroundImageError:
                                      (exception, stackTrace) {
                                    // Handle image error gracefully
                                  },
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.categoryName,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
