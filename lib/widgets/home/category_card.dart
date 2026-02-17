import 'package:flutter/material.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Category/category_based_screen.dart';

class CategoryCard extends StatefulWidget {
  final String id;
  final String imagePath;
  final String title;
  final String userId;
  final int? productCount; // Optional product count

  const CategoryCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.title,
    required this.userId,
    this.productCount,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
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

  /// Mobile Card - Clean design with proper spacing
  Widget _buildMobileCard(ThemeData theme, bool isDark) {
    final double iconRadius = 30.0;
    final double cardWidth = 90.0;

    return SizedBox(
      width: cardWidth,
      child: GestureDetector(
        onTap: () => _navigateToCategory(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image container with clean background
            Container(
              width: iconRadius * 2,
              height: iconRadius * 2,
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.grey.shade50,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  widget.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.restaurant_menu_rounded,
                    size: iconRadius,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Title with proper styling
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Web/Tablet Card - Modern design matching reference
  Widget _buildWebCard(ThemeData theme, bool isDark, bool isDesktop) {
    final double cardWidth = isDesktop ? 160 : 140;
    final double imageSize = isDesktop ? 100 : 80;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => _navigateToCategory(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: cardWidth,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with circular background
              Container(
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isHovered 
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : isDark 
                          ? Colors.grey.shade800 
                          : Colors.grey.shade100,
                  boxShadow: [
                    if (_isHovered)
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.category_rounded,
                      size: imageSize * 0.5,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                widget.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                  fontSize: isDesktop ? 15 : 14,
                  color: _isHovered
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.9),
                ),
              ),

              // Optional product count
              if (widget.productCount != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${widget.productCount} items',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
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