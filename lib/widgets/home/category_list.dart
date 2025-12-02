import 'package:flutter/material.dart';
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
    required this.userId
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => CategoryBasedScreen(
              categoryId: id, 
              title: title, 
              userId: userId
            )
          )
        );
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: isDark ? Colors.grey[700] : Colors.white,
              backgroundImage: NetworkImage(imagePath),
              onBackgroundImageError: (exception, stackTrace) {
                // Handle image loading errors
              },
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}