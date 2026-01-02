
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:veegify/helper/cart_vendor_guard.dart';
import 'package:veegify/provider/CartProvider/cart_provider.dart';
import 'package:veegify/utils/responsive.dart';
import 'package:veegify/views/Navbar/navbar_screen.dart'; // ✅ use your util

class DetailScreen extends StatefulWidget {
  final String productId;
  final String currentUserId; // <-- current user id
  final String restaurantId;

  const DetailScreen({
    super.key,
    required this.productId,
    required this.currentUserId,
    required this.restaurantId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? _productData;
  dynamic _userViews;
  dynamic _resLocation;

  String? _recId;

  bool _isLoading = true;
  String _error = '';
  bool _isReviewActionLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://31.97.206.144:5051/api/getsingleproduct/${widget.productId}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _productData = data['recommended'];
          _userViews = data['userRating'];
          _resLocation = data['restaurant']['locationName'];
          _recId = data['restaurantProductId'];

          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load product details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _editReviewOnServer({
    required String reviewId,
    required int stars,
    required String comment,
  }) async {
    setState(() {
      _isReviewActionLoading = true;
    });
    try {
      final response = await http.put(
        Uri.parse('http://31.97.206.144:5051/api/editprodutreview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "productId": widget.productId,
          "userId": widget.currentUserId,
          "stars": stars,
          "comment": comment,
          "reviewId": reviewId,
        }),
      );

      if (response.statusCode == 200) {
        // Update only this review locally
        final product = Map<String, dynamic>.from(_productData ?? {});
        final List<dynamic> reviews = List<dynamic>.from(
          product['reviews'] ?? [],
        );

        final index = reviews.indexWhere((r) {
          final id = r['_id'] ?? r['id'] ?? r['reviewId'];
          return id == reviewId;
        });

        if (index != -1) {
          final updatedReview = Map<String, dynamic>.from(reviews[index]);
          updatedReview['stars'] = stars;
          updatedReview['comment'] = comment;
          reviews[index] = updatedReview;

          setState(() {
            _productData = {...product, 'reviews': reviews};
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Review updated')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update review (${response.statusCode})'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating review: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviewActionLoading = false;
        });
      }
    }
  }

  Future<void> _deleteReviewOnServer({required String reviewId}) async {
    setState(() {
      _isReviewActionLoading = true;
    });
    try {
      final response = await http.delete(
        Uri.parse('http://31.97.206.144:5051/api/deleteproductreview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "productId": widget.productId,
          "userId": widget.currentUserId,
          "reviewId": reviewId,
        }),
      );

      if (response.statusCode == 200) {
        // Remove only this review locally
        final product = Map<String, dynamic>.from(_productData ?? {});
        final List<dynamic> reviews = List<dynamic>.from(
          product['reviews'] ?? [],
        );

        reviews.removeWhere((r) {
          final id = r['_id'] ?? r['id'] ?? r['reviewId'];
          return id == reviewId;
        });

        setState(() {
          _productData = {...product, 'reviews': reviews};
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Review deleted')));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete review (${response.statusCode})'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting review: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReviewActionLoading = false;
        });
      }
    }
  }

Future<void> _showEditReviewDialog(
  Map<String, dynamic> review,
  String reviewId,
) async {
  final TextEditingController commentController = TextEditingController(
    text: review['comment'] ?? '',
  );
  int selectedStars = review['stars'] ?? 0;

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final isMobile = MediaQuery.of(dialogContext).size.width < 600;
      final isTablet = MediaQuery.of(dialogContext).size.width >= 600 &&
          MediaQuery.of(dialogContext).size.width < 1024;
      final bool isDesktop = MediaQuery.of(dialogContext).size.width >= 1024;

      final double maxWidth = isDesktop
          ? 480
          : (isTablet ? 440 : 360); // 🔹 dialog width cap for big screens

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: isMobile ? 24 : 32,
            ),
            titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
            contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Edit Review',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close),
                  splashRadius: 20,
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ⭐ Rating row
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your rating',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final isFilled = starIndex <= selectedStars;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              selectedStars = starIndex;
                            });
                          },
                          icon: Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 26,
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    // 📝 Comment field
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Your comment',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop({
                    'stars': selectedStars,
                    'comment': commentController.text.trim(),
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );

  if (result != null) {
    final stars = result['stars'] as int;
    final comment = result['comment'] as String;
    await _editReviewOnServer(
      reviewId: reviewId,
      stars: stars,
      comment: comment,
    );
  }
}


  Future<void> _confirmDeleteReview(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Review'),
          content: const Text('Are you sure you want to delete this review?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteReviewOnServer(reviewId: reviewId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: _isLoading
            ? _buildLoadingState(theme)
            : _error.isNotEmpty
                ? _buildErrorState(theme)
                : Stack(
                    children: [
                      _buildContent(theme),
                      if (_isReviewActionLoading)
                        Container(
                          color: Colors.black.withOpacity(0.2),
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading product details...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchProductDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final product = _productData!;
    final recomentID = _recId!;
    final views = _userViews;
    final reslocation = _resLocation;

    final reviews = List<dynamic>.from(product['reviews'] ?? []);

    // Responsive flags
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    final double imageHeight = isMobile ? 300 : 380;
    final double horizontalPadding = isMobile ? 16 : 24;
    final double maxWidth =
        isDesktop ? 1100 : (isTablet ? 900 : double.infinity);

    // ----- PRICE + DISCOUNT LOGIC -----
    final num priceNum = product['price'] ?? 0;
    final int originalPrice = priceNum is int ? priceNum : priceNum.toInt();

    final num discountNum = product['discount'] ?? 0;
    final int discount = discountNum is int ? discountNum : discountNum.toInt();

    final bool hasDiscount = discount > 0;
    final double discountedPrice = hasDiscount
        ? originalPrice * (100 - discount) / 100
        : originalPrice.toDouble();
    // -----------------------------------

    // MAIN INFO SECTION (name, price, description, etc.)
    final Widget infoSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product['name'] ?? 'Product Name',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                reslocation ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        /// PRICE ROW WITH DISCOUNT
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "₹${discountedPrice.toStringAsFixed(1)}",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            if (hasDiscount) ...[
              const SizedBox(width: 8),
              Text(
                "₹$originalPrice",
                style: theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$discount% OFF",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.spaceAround,
            children: [
              _infoTile(
                context: context,
                icon: Icons.star,
                value: views?.toString() ?? '0',
                label: "Ratings",
                theme: theme,
                // width: isMobile ? 110 : 140,
              ),
              const SizedBox(width: 8),
              _infoTile(
                context: context,
                icon: Icons.people,
                value: "${reviews.length}+",
                label: "Reviews",
                theme: theme,
                // width: isMobile ? 110 : 140,
              ),
              const SizedBox(width: 8),
              _infoTile(
                context: context,
                icon: Icons.timer,
                value: "${product['preparationTime'] ?? 0} Min",
                label: "Preparation",
                theme: theme,
                // width: isMobile ? 110 : 140,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Text(
          "Description",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product['content'] ?? 'No description available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            height: 1.5,
          ),
        ),
      ],
    );

    // REVIEWS SECTION
    final Widget reviewsSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          reviews.isNotEmpty
              ? "Reviews (${reviews.length})"
              : "Reviews",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (reviews.isNotEmpty) ...[
          ...reviews
              .map(
                (review) =>
                    _reviewCard(review as Map<String, dynamic>, theme),
              )
              .toList(),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.reviews,
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                ),
                const SizedBox(width: 12),
                Text(
                  "No reviews yet",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TOP IMAGE (full width but constrained center on big screens)
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
                  child: Image.network(
                    product['image'] ?? 'https://via.placeholder.com/400',
                    width: double.infinity,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: imageHeight,
                        color: theme.colorScheme.surface,
                        child: Icon(
                          Icons.fastfood,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: isMobile ? 16 : 24,
                  left: isMobile ? 16 : 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // CONTENT SCROLL
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 16,
                ),
                child: isDesktop || isTablet
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: infoSection),
                          const SizedBox(width: 24),
                          Expanded(child: reviewsSection),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          infoSection,
                          const SizedBox(height: 24),
                          reviewsSection,
                          const SizedBox(height: 80),
                        ],
                      ),
              ),
            ),
          ),
        ),

        // Bottom "Add to cart" bar (centered & constrained on large screens)
        Container(
          color: theme.cardColor,
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : (isTablet ? 420 : double.infinity),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        foregroundColor: theme.colorScheme.onSurface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: theme.cardColor,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => BottomSheetContent(
                            product: product,
                            theme: theme,
                            userId: widget.currentUserId,
                            productId: recomentID,
                            restaurantId: widget.restaurantId,
                          ),
                        );
                      },
                      child: Text(
                        "Add to Cart",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

Widget _infoTile({
  required BuildContext context,
  required IconData icon,
  required String value,
  required String label,
  required ThemeData theme,
}) {
  // Decide size based on screen type
  double size;
  if (Responsive.isDesktop(context)) {
    size = 120;
  } else if (Responsive.isTablet(context)) {
    size = 110;
  } else {
    size = 95; // mobile
  }

  return SizedBox(
    width: size,
    height: size,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center, // 👈 important for "\nMin"
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget _reviewCard(Map<String, dynamic> review, ThemeData theme) {
    final user = review['user'] ?? {};
    final stars = review['stars'] ?? 0;
    final comment = review['comment'] ?? '';
    final createdAt = review['createdAt'] ?? '';

    final reviewId = review['_id'] ?? review['id'] ?? review['reviewId'];
    final ownerId = review['userId'] ?? user['_id'];
    final bool isOwner = ownerId == widget.currentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: user['profileImg'] != null
                ? NetworkImage(user['profileImg']!)
                : null,
            child: user['profileImg'] == null
                ? Icon(Icons.person, color: theme.colorScheme.primary)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < stars ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        );
                      }),
                    ),
                    if (isOwner && reviewId != null) ...[
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditReviewDialog(review, reviewId);
                          } else if (value == 'delete') {
                            _confirmDeleteReview(reviewId);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ],
                  ],
                ),
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return '';
    }
  }
}

class BottomSheetContent extends StatefulWidget {
  final Map<String, dynamic> product;
  final ThemeData theme;
  final String userId;
  final String productId;
  final String restaurantId;

  const BottomSheetContent({
    super.key,
    required this.product,
    required this.theme,
    required this.userId,
    required this.productId,
    required this.restaurantId,
  });

  @override
  State<BottomSheetContent> createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  String _selectedVariation = 'Half';
  int _quantity = 1;
  Set<String> _selectedAddOns = {};
  int _basePrice = 0;

  late Map<String, int> variations;
  late Map<String, int> addOns;

  bool _hasVariation = false;

  @override
  void initState() {
    super.initState();

    // Base price from product
    final num basePriceNum = widget.product['price'] ?? 0;
    _basePrice = basePriceNum is int ? basePriceNum : basePriceNum.toInt();

    // NEW: use halfPlatePrice & fullPlatePrice if available
    final num? halfNum = widget.product['halfPlatePrice'];
    final num? fullNum = widget.product['fullPlatePrice'];

    final int halfPriceFromApi =
        halfNum == null ? 0 : (halfNum is int ? halfNum : halfNum.toInt());
    final int fullPriceFromApi =
        fullNum == null ? 0 : (fullNum is int ? fullNum : fullNum.toInt());

    if (halfPriceFromApi > 0 || fullPriceFromApi > 0) {
      // We have new fields from API
      final int fullPrice =
          fullPriceFromApi > 0 ? fullPriceFromApi : _basePrice;
      final int halfPrice = halfPriceFromApi;

      if (halfPrice > 0) {
        // Both half & full available -> show variation
        _hasVariation = true;
        variations = {'Half': halfPrice, 'Full': fullPrice};
        _selectedVariation = 'Half';
      } else {
        // Only full available -> no variation
        _hasVariation = false;
        variations = {'Full': fullPrice};
        _selectedVariation = 'Full';
      }

      _basePrice = fullPrice;
    } else {
      // FALLBACK: old logic using vendorHalfPercentage if no new price fields
      final vendorHalfPercentage = widget.product['vendorHalfPercentage'] ?? 10;
      final int halfPrice =
          (_basePrice * (100 - vendorHalfPercentage) / 100).round();
      _hasVariation = true;
      variations = {'Half': halfPrice, 'Full': _basePrice};
      _selectedVariation = 'Half';
    }

    // Old add-on logic kept (even though no UI right now)
    addOns = {
      '1 Plate': widget.product['vendor_Platecost']?.toInt() ?? 10,
      '2 Plates': (widget.product['vendor_Platecost']?.toInt() ?? 10) * 2,
    };
  }

  int get _plateItemsCount {
    int count = 0;
    if (_selectedAddOns.contains('1 Plate')) count += 1;
    if (_selectedAddOns.contains('2 Plates')) count += 2;
    return count;
  }

  int get totalPrice {
    int variationPrice = variations[_selectedVariation] ?? _basePrice;
    int addOnTotal = _selectedAddOns.fold(
      0,
      (sum, key) => sum + (addOns[key] ?? 0),
    );
    return (variationPrice + addOnTotal) * _quantity;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isDesktop = Responsive.isDesktop(context);

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        final isLoading = cartProvider.isLoading;

        // Figure out IDs safely from product map
        final product = widget.product;
        final restaurantProductId = widget.productId.isNotEmpty
            ? widget.productId
            : (product['restaurantId'] ?? product['_id'] ?? widget.productId);

        final recommendedId =
            product['_id'] ?? product['id'] ?? widget.productId;

        final double maxWidth =
            isDesktop ? 500 : (isTablet ? 450 : double.infinity);

        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: isMobile ? 16 : 24,
                right: isMobile ? 16 : 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.theme.colorScheme.onSurface
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.product['name'] ?? 'Product',
                    style: widget.theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  /// VARIATION SECTION
                  if (_hasVariation) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Variation",
                        style:
                            widget.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...variations.entries.map(
                      (entry) => RadioListTile<String>(
                        title: Text(
                          "${entry.key} ₹${entry.value}",
                          style: widget.theme.textTheme.bodyMedium,
                        ),
                        value: entry.key,
                        groupValue: _selectedVariation,
                        onChanged: (val) {
                          setState(() => _selectedVariation = val!);
                        },
                        activeColor: widget.theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: widget.theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: widget.theme.dividerColor),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() {
                                        _quantity--;
                                      })
                                  : null,
                              icon: Icon(
                                Icons.remove,
                                color:
                                    widget.theme.colorScheme.primary,
                              ),
                            ),
                            Container(
                              width: 40,
                              alignment: Alignment.center,
                              child: Text(
                                "$_quantity",
                                style: widget.theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() {
                                _quantity++;
                              }),
                              icon: Icon(
                                Icons.add,
                                color:
                                    widget.theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final success = await addToCartWithVendorGuard(
                                  context: context,
                                  cartProvider: cartProvider,
                                  restaurantIdOfProduct:
                                      widget.restaurantId,
                                  restaurantProductId: restaurantProductId,
                                  recommendedId: recommendedId,
                                  quantity: _quantity,
                                  variation: _selectedVariation,
                                  plateItems: 0,
                                  userId: widget.userId.toString(),
                                );

                                if (success) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${widget.product['name'] ?? 'Item'} added to cart!',
                                        ),
                                        behavior:
                                            SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>NavbarScreen(initialIndex: 2,)));

                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          cartProvider.error ??
                                              'Failed to add item to cart',
                                        ),
                                        behavior:
                                            SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.theme.colorScheme.primary,
                          foregroundColor:
                              widget.theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                    widget.theme.colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                "Add Item | ₹$totalPrice",
                                style: widget
                                    .theme.textTheme.bodyLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
