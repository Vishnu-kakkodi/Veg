
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:veegify/model/order.dart';

class ReviewDialog extends StatefulWidget {
  final Order order;
  final String userId;
  final VoidCallback onReviewSubmitted;

  /// Optional existing restaurant review info (for edit/delete use later).
  final String? existingRestaurantReviewId;
  final int? existingRestaurantRating;
  final String? existingRestaurantComment;

  const ReviewDialog({
    super.key,
    required this.order,
    required this.userId,
    required this.onReviewSubmitted,
    this.existingRestaurantReviewId,
    this.existingRestaurantRating,
    this.existingRestaurantComment,
  });

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  // Product review state (multi-product, your original logic)
  final Map<String, Map<String, dynamic>> _selectedProducts = {};
  bool _isSubmitting = false;

  // Restaurant review state
  int _restaurantRating = 0;
  final TextEditingController _restaurantReviewController =
      TextEditingController();
  bool _isRestaurantSubmitting = false;
  String? _restaurantReviewId; // if set => edit/delete

  @override
  void initState() {
    super.initState();

    // Initialize all products as unselected
    for (final product in widget.order.products) {
      _selectedProducts[product.id] = {
        'selected': false,
        'rating': 0,
        'review': '',
        'product': product,
        'isSubmitting': false,
      };
    }

    // Initialize restaurant review if existing
    _restaurantReviewId = widget.existingRestaurantReviewId;
    _restaurantRating = widget.existingRestaurantRating ?? 0;
    _restaurantReviewController.text = widget.existingRestaurantComment ?? '';
  }

  // ---------- RESTAURANT REVIEW API CALLS ----------

  Future<void> _submitRestaurantReview() async {
    if (_restaurantRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please rate the restaurant'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isRestaurantSubmitting = true;
    });

    try {
      // Adjust this if your Order model exposes restaurantId differently
      final restaurantId = widget.order.restaurant.id;

      final uri = _restaurantReviewId == null
          ? Uri.parse('https://api.vegiffyy.com/api/addrestureview')
          : Uri.parse('https://api.vegiffyy.com/api/editrestureview');

      final payload = {
        "restaurantId": restaurantId,
        "userId": widget.userId,
        "stars": _restaurantRating,
        "comment": _restaurantReviewController.text.trim(),
        if (_restaurantReviewId != null) "reviewId": _restaurantReviewId,
      };

      final response = await (_restaurantReviewId == null
          ? http.post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            )
          : http.put(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            ));

      if (response.statusCode == 200) {
        // Optionally, parse and update _restaurantReviewId from response if backend returns it.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _restaurantReviewId == null
                  ? 'Restaurant review added successfully!'
                  : 'Restaurant review updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to submit restaurant review');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting restaurant review: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestaurantSubmitting = false;
        });
      }
    }
  }

  Future<void> _deleteRestaurantReview() async {
    if (_restaurantReviewId == null) return;

    setState(() {
      _isRestaurantSubmitting = true;
    });

    try {
      final restaurantId = widget.order.restaurant.id;

      final uri = Uri.parse('https://api.vegiffyy.com/api/deleterestureview');

      final payload = {
        "restaurantId": restaurantId,
        "userId": widget.userId,
        "reviewId": _restaurantReviewId,
      };

      final response = await http.delete(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        setState(() {
          _restaurantReviewId = null;
          _restaurantRating = 0;
          _restaurantReviewController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restaurant review deleted'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete restaurant review');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting restaurant review: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestaurantSubmitting = false;
        });
      }
    }
  }

  // ---------- PRODUCT REVIEWS (YOUR ORIGINAL MULTI-PRODUCT LOGIC) ----------

  Future<void> _submitReviews() async {
    // Check if at least one product is selected and rated
    final selectedProducts = _selectedProducts.entries
        .where((entry) => entry.value['selected'] == true)
        .toList();

    print("----- Selected Products -----");
    for (final entry in selectedProducts) {
      final product = entry.value['product'] as OrderProduct;
      final rating = entry.value['rating'];
      final review = entry.value['review'];

      print("Product ID: ${product.recommendedId}");
      print("Product Name: ${product.name}");
      print("Rating: $rating");
      print("Review: $review");
      print("-----------------------------");
    }

    if (selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one product to review'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Check if all selected products have ratings
    for (final entry in selectedProducts) {
      if (entry.value['rating'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please rate ${entry.value['product'].name}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    bool allSuccessful = true;
    int successfulCount = 0;

    // Submit reviews for all selected products with separate API calls
    for (final entry in selectedProducts) {
      final product = entry.value['product'] as OrderProduct;
      final rating = entry.value['rating'] as int;
      final review = entry.value['review'] as String;

      // Update individual product submitting state
      setState(() {
        _selectedProducts[product.id]?['isSubmitting'] = true;
      });

      try {
        print("ProductId:${product.recommendedId}, UserId:${widget.userId}");

        final response = await http.post(
          Uri.parse('https://api.vegiffyy.com/api/addreview'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "productId": product.recommendedId,
            "userId": widget.userId,
            "stars": rating,
            "comment": review.trim(),
          }),
        );

        print("Product review response: ${response.body}");

        if (response.statusCode == 200) {
          successfulCount++;
          // Mark as submitted
          setState(() {
            _selectedProducts[product.id]?['selected'] = false;
          });
        } else {
          allSuccessful = false;
          throw Exception('Failed to submit review for ${product.name}');
        }
      } catch (e) {
        allSuccessful = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting review for ${product.name}: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _selectedProducts[product.id]?['isSubmitting'] = false;
          });
        }
      }
    }

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      if (allSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successfulCount review${successfulCount > 1 ? 's' : ''} submitted successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onReviewSubmitted();
        Navigator.of(context).pop();
      } else if (successfulCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$successfulCount review${successfulCount > 1 ? 's' : ''} submitted, but some failed',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        // Don't close the dialog if some failed, let user retry
      }
    }
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      final current = _selectedProducts[productId]?['selected'] == true;
      _selectedProducts[productId]?['selected'] = !current;
    });
  }

  void _updateProductRating(String productId, int rating) {
    setState(() {
      _selectedProducts[productId]?['rating'] = rating;
    });
  }

  void _updateProductReview(String productId, String review) {
    setState(() {
      _selectedProducts[productId]?['review'] = review;
    });
  }

  bool get _hasSelectedProducts {
    return _selectedProducts.entries.any(
      (entry) => entry.value['selected'] == true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    
    final selectedCount = _selectedProducts.entries
        .where((entry) => entry.value['selected'] == true)
        .length;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        ),
        title: Text(
          'Rate Your Order',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_hasSelectedProducts)
            Padding(
              padding: EdgeInsets.only(right: isWeb ? 24 : 16),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 16 : 12,
                    vertical: isWeb ? 8 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$selectedCount selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: isWeb ? const BoxConstraints(maxWidth: 900) : null,
          child: Column(
            children: [
              // Order Info Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWeb ? 20 : 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    bottom: BorderSide(
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isWeb ? 60 : 50,
                      height: isWeb ? 60 : 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isWeb ? 14 : 12),
                      ),
                      child: widget.order.products.isNotEmpty &&
                              widget.order.products.first.image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                isWeb ? 14 : 12,
                              ),
                              child: Image.network(
                                widget.order.products.first.image.toString(),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.restaurant,
                              color: theme.colorScheme.primary,
                              size: isWeb ? 28 : 24,
                            ),
                    ),
                    SizedBox(width: isWeb ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.order.restaurant.restaurantName,
                            style: (isWeb
                                    ? theme.textTheme.titleLarge
                                    : theme.textTheme.titleMedium)
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Order #${widget.order.id.substring(0, 8)}...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Instruction
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWeb ? 20 : 16),
                color: theme.colorScheme.primary.withOpacity(0.05),
                child: Text(
                  'Rate the restaurant and products in this order',
                  style: (isWeb
                          ? theme.textTheme.bodyLarge
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // CONTENT: restaurant review + product list
              Expanded(
                child: isWeb ? _buildWebLayout(theme) : _buildMobileLayout(theme),
              ),

              // Submit Button (for product reviews)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isWeb ? 20 : 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  border: Border(
                    top: BorderSide(
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting || !_hasSelectedProducts
                            ? null
                            : _submitReviews,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isWeb ? 18 : 16,
                          ),
                        ),
                        child: _isSubmitting
                            ? SizedBox(
                                width: isWeb ? 24 : 20,
                                height: isWeb ? 24 : 20,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Submit ${selectedCount > 0 ? '$selectedCount ' : ''}Review${selectedCount > 1 ? 's' : ''}',
                                style: (isWeb
                                        ? theme.textTheme.titleMedium
                                        : theme.textTheme.bodyLarge)
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mobile Layout - Original stacked layout
  Widget _buildMobileLayout(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildRestaurantReviewSection(theme, false),
        _buildProductsList(theme, false),
      ],
    );
  }

  // Web Layout - Side by side layout
  Widget _buildWebLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Restaurant Review (fixed width)
        SizedBox(
          width: 400,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildRestaurantReviewSection(theme, true),
          ),
        ),
        
        // Divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: theme.dividerColor.withOpacity(0.3),
        ),
        
        // Right side: Products List (expandable)
        Expanded(
          child: _buildProductsList(theme, true),
        ),
      ],
    );
  }

  // Restaurant Review Section
  Widget _buildRestaurantReviewSection(ThemeData theme, bool isWeb) {
    return Container(
      margin: EdgeInsets.all(isWeb ? 0 : 12),
      padding: EdgeInsets.all(isWeb ? 20 : 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(isWeb ? 16 : 12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: theme.colorScheme.primary,
                size: isWeb ? 28 : 24,
              ),
              SizedBox(width: isWeb ? 12 : 8),
              Text(
                'Restaurant Rating',
                style: (isWeb
                        ? theme.textTheme.titleLarge
                        : theme.textTheme.titleMedium)
                    ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 16 : 12),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _restaurantRating = index + 1;
                    });
                  },
                  child: Icon(
                    index < _restaurantRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: isWeb ? 42 : 36,
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          Center(
            child: Text(
              _restaurantRating == 0
                  ? 'Tap to rate the restaurant'
                  : '$_restaurantRating ${_restaurantRating == 1 ? 'star' : 'stars'}',
              style: (isWeb
                      ? theme.textTheme.bodyLarge
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: isWeb ? 20 : 16),
          Text(
            'Your Review for Restaurant (Optional)',
            style: (isWeb
                    ? theme.textTheme.bodyLarge
                    : theme.textTheme.bodyMedium)
                ?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isWeb ? 12 : 8),
          TextField(
            controller: _restaurantReviewController,
            maxLines: isWeb ? 4 : 3,
            decoration: InputDecoration(
              hintText: 'Share your experience with the restaurant...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
              contentPadding: EdgeInsets.all(isWeb ? 16 : 12),
            ),
          ),
          SizedBox(height: isWeb ? 16 : 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isRestaurantSubmitting ? null : _submitRestaurantReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: isWeb ? 16 : 14,
                    ),
                  ),
                  child: _isRestaurantSubmitting
                      ? SizedBox(
                          width: isWeb ? 24 : 20,
                          height: isWeb ? 24 : 20,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          _restaurantReviewId == null
                              ? 'Submit Restaurant Review'
                              : 'Update Restaurant Review',
                          style: (isWeb
                                  ? theme.textTheme.bodyLarge
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              if (_restaurantReviewId != null) ...[
                SizedBox(width: isWeb ? 12 : 8),
                IconButton(
                  onPressed:
                      _isRestaurantSubmitting ? null : _deleteRestaurantReview,
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: isWeb ? 28 : 24,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Products List
  Widget _buildProductsList(ThemeData theme, bool isWeb) {
    return ListView.builder(
      physics: isWeb
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !isWeb,
      padding: EdgeInsets.all(isWeb ? 16 : 8),
      itemCount: widget.order.products.length,
      itemBuilder: (context, index) {
        final product = widget.order.products[index];
        final productData = _selectedProducts[product.id]!;
        final isSelected = productData['selected'] as bool;
        final rating = productData['rating'] as int;
        final review = productData['review'] as String;
        final isSubmitting = productData['isSubmitting'] as bool;

        return Container(
          margin: EdgeInsets.symmetric(
            vertical: isWeb ? 12 : 8,
            horizontal: isWeb ? 8 : 0,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: isWeb ? BorderRadius.circular(16) : null,
            border: isSelected
                ? Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  )
                : isWeb
                    ? Border.all(
                        color: theme.dividerColor.withOpacity(0.3),
                      )
                    : null,
          ),
          child: Column(
            children: [
              // Product Header with Checkbox
              ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 20 : 16,
                  vertical: isWeb ? 8 : 0,
                ),
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    _toggleProductSelection(product.id);
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                title: Text(
                  product.name,
                  style: (isWeb
                          ? theme.textTheme.titleMedium
                          : theme.textTheme.bodyLarge)
                      ?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${product.quantity}x • ₹${(product.quantity * product.basePrice).toStringAsFixed(2)}',
                    style: (isWeb
                            ? theme.textTheme.bodyMedium
                            : theme.textTheme.bodyMedium)
                        ?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                trailing: isSubmitting
                    ? SizedBox(
                        width: isWeb ? 24 : 20,
                        height: isWeb ? 24 : 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),

              // Rating Section (only show if selected)
              if (isSelected) ...[
                Divider(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.3),
                ),
                Padding(
                  padding: EdgeInsets.all(isWeb ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Star Rating
                      Text(
                        'Rate this product',
                        style: (isWeb
                                ? theme.textTheme.bodyLarge
                                : theme.textTheme.bodyMedium)
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isWeb ? 16 : 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              _updateProductRating(
                                product.id,
                                index + 1,
                              );
                            },
                            child: Icon(
                              index < rating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: isWeb ? 42 : 36,
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: isWeb ? 12 : 8),
                      Center(
                        child: Text(
                          rating == 0
                              ? 'Tap to rate'
                              : '$rating ${rating == 1 ? 'star' : 'stars'}',
                          style: (isWeb
                                  ? theme.textTheme.bodyLarge
                                  : theme.textTheme.bodyMedium)
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: isWeb ? 20 : 16),

                      // Review Text Field
                      Text(
                        'Your Review (Optional)',
                        style: (isWeb
                                ? theme.textTheme.bodyLarge
                                : theme.textTheme.bodyMedium)
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isWeb ? 12 : 8),
                      TextField(
                        onChanged: (value) {
                          _updateProductReview(product.id, value);
                        },
                        maxLines: isWeb ? 4 : 3,
                        decoration: InputDecoration(
                          hintText:
                              'Share your experience with ${product.name}...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.dividerColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          contentPadding: EdgeInsets.all(isWeb ? 16 : 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _restaurantReviewController.dispose();
    super.dispose();
  }
}

