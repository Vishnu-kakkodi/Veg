// category_based_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:veegify/views/home/recommended_screen.dart';

class CategoryBasedScreen extends StatefulWidget {
  final String userId;
  final String categoryId;
  final String title;

  CategoryBasedScreen({
    super.key,
    required this.userId,
    required this.categoryId,
    required this.title,
  });

  @override
  State<CategoryBasedScreen> createState() => _CategoryBasedScreenState();
}

class _CategoryBasedScreenState extends State<CategoryBasedScreen> {
  List<Map<String, dynamic>> restaurants = [];
  bool isLoading = true;
  String errorMessage = '';
  String categoryName = 'Category'; // Default name, will be updated from API

  @override
  void initState() {
    super.initState();
    fetchRestaurantsByCategory();
  }

  // Generic extractor for nested string-like values
  String _extractString(dynamic value, [String defaultValue = '']) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    if (value is num) return value.toString();
    if (value is Map && value.isNotEmpty) {
      // common keys that might contain a string
      return (value['url'] ??
              value['name'] ??
              value['restaurantName'] ??
              value['categoryName'] ??
              value['locationName'] ??
              '')
          .toString();
    }
    return value.toString();
  }

  String _getRestaurantName(Map<String, dynamic> restaurant) {
    // 1) explicit restaurantName
    if (restaurant['restaurantName'] != null) {
      return _extractString(restaurant['restaurantName'], 'Unknown Restaurant');
    }

    // 2) direct name
    if (restaurant['name'] != null) {
      return _extractString(restaurant['name'], 'Unknown Restaurant');
    }

    // 3) nested restaurant object
    if (restaurant['restaurant'] != null && restaurant['restaurant'] is Map) {
      final r = restaurant['restaurant'] as Map;
      if (r['restaurantName'] != null) return _extractString(r['restaurantName'], 'Unknown Restaurant');
      if (r['name'] != null) return _extractString(r['name'], 'Unknown Restaurant');
    }

    return 'Unknown Restaurant';
  }

  String _getRestaurantImage(Map<String, dynamic> restaurant) {
    // API might return image as a String url or as an object { url: "...", public_id: ... }
    final img = restaurant['image'] ?? restaurant['images'] ?? restaurant['photo'];
    if (img == null) {
      return 'https://res.cloudinary.com/dwmna13fi/image/upload/v1752579676/categories/zs5fbmetun8k3vpuxzms.jpg';
    }

    if (img is String) return img;
    if (img is Map) {
      // try common keys
      final url = img['url'] ?? img['secure_url'] ?? img['image'] ?? img['img'];
      if (url != null) return url.toString();
      // if map contains nested structure
      if (img['data'] != null && img['data'] is Map && img['data']['url'] != null) {
        return img['data']['url'].toString();
      }
    }

    // fallback to placeholder
    return 'https://res.cloudinary.com/dwmna13fi/image/upload/v1752579676/categories/zs5fbmetun8k3vpuxzms.jpg';
  }

  String _getLocation(Map<String, dynamic> restaurant) {
    // 1) explicit locationName
    if (restaurant['locationName'] != null) {
      return _extractString(restaurant['locationName'], 'Location not available');
    }

    // 2) explicit location field which might be GeoJSON point or string
    if (restaurant['location'] != null) {
      final loc = restaurant['location'];
      if (loc is String) return loc;
      if (loc is Map) {
        // If GeoJSON Point: { type: 'Point', coordinates: [lng, lat] }
        if (loc['type'] == 'Point' && loc['coordinates'] is List && loc['coordinates'].length >= 2) {
          final coords = loc['coordinates'] as List;
          return 'Lat: ${coords[1]}, Lng: ${coords[0]}';
        }
        // maybe contains a name field
        if (loc['name'] != null) return _extractString(loc['name'], 'Location not available');
      }
    }

    // 3) nested restaurant object
    if (restaurant['restaurant'] != null && restaurant['restaurant'] is Map) {
      final r = restaurant['restaurant'] as Map;
      if (r['locationName'] != null) return _extractString(r['locationName'], 'Location not available');
      if (r['location'] != null) return _extractString(r['location'], 'Location not available');
    }

    return 'Location not available';
  }

  String _getCategoryName(Map<String, dynamic> restaurant) {
    // Try top-level categoryName
    if (restaurant['categoryName'] != null) return _extractString(restaurant['categoryName'], 'Category');

    // Common key 'categorie' (as in your earlier code)
    if (restaurant['categorie'] != null) {
      final c = restaurant['categorie'];
      if (c is Map) {
        return _extractString(c['categoryName'] ?? c['name'], 'Category');
      }
      return _extractString(c, 'Category');
    }

    // nested fields
    if (restaurant['categories'] != null) {
      final cats = restaurant['categories'];
      if (cats is List && cats.isNotEmpty) {
        // maybe list of ids; can't resolve names, so return first id (or 'Category')
        return _extractString(cats[0], 'Category');
      }
    }

    return 'Category';
  }

  String _getRestaurantId(Map<String, dynamic> restaurant) {
    // try _id then id then nested
    if (restaurant['_id'] != null) return restaurant['_id'].toString();
    if (restaurant['id'] != null) return restaurant['id'].toString();

    if (restaurant['restaurant'] != null && restaurant['restaurant'] is Map) {
      final r = restaurant['restaurant'] as Map;
      if (r['_id'] != null) return r['_id'].toString();
      if (r['id'] != null) return r['id'].toString();
    }

    // fallback: empty string or a default; better to return empty so navigation can validate
    return '';
  }

  Future<void> fetchRestaurantsByCategory() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      print("Category ID: ${widget.categoryId}");
      final response = await http.get(
        Uri.parse(
            'http://31.97.206.144:5051/api/resturentbycat/${widget.userId}?categoryName=${Uri.encodeComponent(widget.title)}'),
      );
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List rawList = data['data'] ?? [];
          setState(() {
            restaurants = rawList.map<Map<String, dynamic>>((e) {
              if (e is Map) return Map<String, dynamic>.from(e);
              return {'_raw': e};
            }).toList();

            if (restaurants.isNotEmpty) {
              categoryName = _getCategoryName(restaurants[0]);
            }
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = data['message'] ?? 'Failed to load data';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.colorScheme.onSurface,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            else if (errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchRestaurantsByCategory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              const SizedBox(height: 8),

              // If the API returned successfully but no restaurants, show the same placeholder image
              if (restaurants.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Image.asset(
                          "assets/images/no food.png",
                          width: 180,
                          color: isDark ? null : null,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "No restaurants found",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No restaurants available for "${widget.title}".',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                // List of Restaurants
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = restaurants[index];
                      final imageUrl = _getRestaurantImage(restaurant);
                      final restId = _getRestaurantId(restaurant);

                      return GestureDetector(
                        onTap: () {
                          if (restId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Restaurant id not available'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RestaurantDetailScreen(
                                restaurantId: restId,
                                categoryName: widget.title,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.grey[700]! : const Color.fromARGB(255, 196, 196, 196),
                            ),
                            color: isDark ? theme.cardColor : Colors.white,
                            boxShadow: [
                              if (!isDark)
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Restaurant Image with Heart Icon
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imageUrl,
                                      height: 122,
                                      width: 122,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        height: 122,
                                        width: 122,
                                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                                        child: Icon(
                                          Icons.error,
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: isDark ? theme.cardColor : Colors.white,
                                      child: Icon(
                                        Icons.favorite_border,
                                        size: 16,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Restaurant Info
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getRestaurantName(restaurant),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(20),
                                              color: theme.colorScheme.primary,
                                            ),
                                            child: Icon(
                                              Icons.star,
                                              size: 16,
                                              color: theme.colorScheme.onPrimary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _extractString(restaurant['rating'] ?? 0),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _extractString(
                                          restaurant['content'] ?? restaurant['description'],
                                          'No description available',
                                        ),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: theme.colorScheme.primary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              _getLocation(restaurant).replaceAll('[', '').replaceAll(']', ''),
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}