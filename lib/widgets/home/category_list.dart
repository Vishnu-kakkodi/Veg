
import 'package:flutter/material.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Category/category_based_screen.dart';

class CategoryList extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final String userId;
  final int? productCount; // Optional product count

  const CategoryList({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.userId,
    this.productCount,
  });

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);

    // Use web design for desktop/tablet, mobile design for mobile
    if (isMobile) {
      return _buildMobileCard(theme, isDark);
    } else {
      return _buildWebCard(theme, isDark, isDesktop);
    }
  }

  /// Original Mobile Card - Unchanged
  Widget _buildMobileCard(ThemeData theme, bool isDark) {
    final double iconRadius = 26.0;
    final double cardWidth = 84.0;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () => _navigateToCategory(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : const Color(0xFFEBF4F1),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: iconRadius,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(widget.imagePath),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Improved Web Card - Matches reference design
Widget _buildWebCard(ThemeData theme, bool isDark, bool isDesktop) {
  final double cardWidth = isDesktop ? 180 : 160;
  final double imageSize = isDesktop ? 120 : 80;

  return MouseRegion(
    onEnter: (_) => setState(() => _isHovered = true),
    onExit: (_) => setState(() => _isHovered = false),
    child: GestureDetector(
      onTap: () => _navigateToCategory(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cardWidth,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary
                : Colors.grey.withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? theme.colorScheme.primary.withOpacity(0.18)
                  : Colors.black.withOpacity(0.06),
              blurRadius: _isHovered ? 18 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Container(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800] : Colors.grey[100],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.category_rounded,
                    size: imageSize * 0.6,
                    color: theme.colorScheme.primary.withOpacity(0.6),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Title
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isDesktop ? 15 : 14,
                color: _isHovered
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),

            if (widget.productCount != null) ...[
              const SizedBox(height: 6),
              Text(
                '${widget.productCount} products',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}


  void _navigateToCategory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryBasedScreen(
          categoryId: widget.id,
          title: widget.title,
          userId: widget.userId,
        ),
      ),
    );
  }
}