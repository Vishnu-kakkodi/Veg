// class RestaurantProductResponse {
//   final bool success;
//   final String message;
//   final int totalRecommendedItems;
//   final List<RecommendedProduct> recommendedProducts;

//   RestaurantProductResponse({
//     this.success = false,
//     this.message = "",
//     this.totalRecommendedItems = 0,
//     this.recommendedProducts = const [],
//   });

//   factory RestaurantProductResponse.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return RestaurantProductResponse();

//     return RestaurantProductResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? "",
//       totalRecommendedItems: json['totalRecommendedItems'] ?? 0,
//       recommendedProducts: (json['recommendedProducts'] is List)
//           ? (json['recommendedProducts'] as List)
//               .map((e) => RecommendedProduct.fromJson(e))
//               .toList()
//           : [],
//     );
//   }
// }

// class RecommendedProduct {
//   final String id;
//   final String productId;
//   final String restaurantName;
//   final String locationName;
//   final List<String> type;
//   final String status;
//   final double rating;
//   final int viewCount;
//   final RecommendedItem recommendedItem;

//   RecommendedProduct({
//     this.id = "",
//     this.productId = "",
//     this.restaurantName = "",
//     this.locationName = "",
//     this.type = const [],
//     this.status = "",
//     this.rating = 0.0,
//     this.viewCount = 0,
//     RecommendedItem? recommendedItem,
//   }) : recommendedItem = recommendedItem ?? RecommendedItem();

//   factory RecommendedProduct.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return RecommendedProduct();

//     return RecommendedProduct(
//       id: json['_id'] ?? "",
//       productId: json['productId'] ?? "",
//       restaurantName: json['restaurantName'] ?? "",
//       locationName: json['locationName'] ?? "",
//       type: json['type'] is List ? List<String>.from(json['type']) : [],
//       status: json['status'] ?? "",
//       rating: (json['rating'] ?? 0).toDouble(),
//       viewCount: json['viewCount'] ?? 0,
//       recommendedItem: RecommendedItem.fromJson(json['recommendedItem']),
//     );
//   }
// }

// class RecommendedItem {
//   final String itemId;
//   final String name;
//   final int price;
//   final double rating;
//   final int viewCount;
//   final String content;
//   final String image;
//   final Addons addons;
//   final Category category;
//   final int vendorHalfPercentage;
//   final int vendorPlateCost;

//   RecommendedItem({
//     this.itemId = "",
//     this.name = "",
//     this.price = 0,
//     this.rating = 0.0,
//     this.viewCount = 0,
//     this.content = "",
//     this.image = "",
//     Addons? addons,
//     Category? category,
//     this.vendorHalfPercentage = 0,
//     this.vendorPlateCost = 0,
//   })  : addons = addons ?? Addons(),
//         category = category ?? Category();

//   factory RecommendedItem.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return RecommendedItem();

//     return RecommendedItem(
//       itemId: json['_id'] ?? "",
//       name: json['name'] ?? "",
//       price: json['price'] ?? 0,
//       rating: (json['rating'] ?? 0).toDouble(),
//       viewCount: json['viewCount'] ?? 0,
//       content: json['content'] ?? "",
//       image: json['image'] ?? "",
//       addons: Addons.fromJson(json['addons']),
//       category: Category.fromJson(json['category']),
//       vendorHalfPercentage: json['vendorHalfPercentage'] ?? 0,
//       vendorPlateCost: json['vendor_Platecost'] ?? 0,
//     );
//   }
// }

// class Addons {
//   final Variation variation;
//   final Plates plates;
//   final String productName;

//   Addons({
//     Variation? variation,
//     Plates? plates,
//     this.productName = "",
//   })  : variation = variation ?? Variation(),
//         plates = plates ?? Plates();

//   factory Addons.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return Addons();
//     return Addons(
//       variation: Variation.fromJson(json['variation']),
//       plates: Plates.fromJson(json['plates']),
//       productName: json['productName'] ?? "",
//     );
//   }
// }

// class Variation {
//   final String name;
//   final List<String> type;

//   Variation({
//     this.name = "",
//     this.type = const [],
//   });

//   factory Variation.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return Variation();

//     return Variation(
//       name: json['name'] ?? "",
//       type: json['type'] is List ? List<String>.from(json['type']) : [],
//     );
//   }
// }

// class Plates {
//   final String name;

//   Plates({this.name = ""});

//   factory Plates.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return Plates();
//     return Plates(name: json['name'] ?? "");
//   }
// }

// class Category {
//   final String id;
//   final String categoryName;
//   final String imageUrl;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final int v;

//   Category({
//     this.id = "",
//     this.categoryName = "",
//     this.imageUrl = "",
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     this.v = 0,
//   })  : createdAt = createdAt ?? DateTime.now(),
//         updatedAt = updatedAt ?? DateTime.now();

//   factory Category.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return Category();

//     return Category(
//       id: json['_id'] ?? "",
//       categoryName: json['categoryName'] ?? "",
//       imageUrl: json['imageUrl'] ?? "",
//       createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? "") ?? DateTime.now(),
//       v: json['__v'] ?? 0,
//     );
//   }
// }

// class RecommendedItemWithId {
//   final String productId;
//   final String id;
//   final RecommendedItem recommendedItem;

//   RecommendedItemWithId({
//     this.productId = "",
//     this.id = "",
//     RecommendedItem? recommendedItem,
//   }) : recommendedItem = recommendedItem ?? RecommendedItem();
// }























import 'dart:convert';

/// Top level response model
class RestaurantProductResponse {
  final bool success;
  final String message;
  final int totalRecommendedItems;
  final int totalRatings;
  final int totalReviews;
  final List<RecommendedProduct> recommendedProducts;
  final List<RestaurantReview> restaurantReviews;
  final String restaurantStatus;

  RestaurantProductResponse({
    this.success = false,
    this.message = "",
    this.totalRecommendedItems = 0,
    this.totalRatings = 0,
    this.totalReviews = 0,
    this.recommendedProducts = const [],
    this.restaurantReviews = const [],
    this.restaurantStatus = ''
  });

  factory RestaurantProductResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantProductResponse();

    return RestaurantProductResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? "",
      totalRecommendedItems: json['totalRecommendedItems'] ?? 0,
      restaurantStatus: json['restaurantStatus'] ?? "",
      totalRatings: json['totalRatings'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      recommendedProducts: (json['recommendedProducts'] is List)
          ? (json['recommendedProducts'] as List)
              .map((e) => RecommendedProduct.fromJson(e))
              .toList()
          : [],
      restaurantReviews: (json['restaurantReviews'] is List)
          ? (json['restaurantReviews'] as List)
              .map((e) => RestaurantReview.fromJson(e))
              .toList()
          : [],
    );
  }
}

/// Single recommended product (wrapping a single recommended item)
class RecommendedProduct {
  final String id;
  final String productId;
  final String restaurantName;
  final String locationName;
  final List<String> type; // kept for backward compatibility (may be empty)
  final String status;
  final double rating; // restaurant/product level rating if backend sends it
  final int viewCount;
  final RecommendedItem recommendedItem;

  RecommendedProduct({
    this.id = "",
    this.productId = "",
    this.restaurantName = "",
    this.locationName = "",
    this.type = const [],
    this.status = "",
    this.rating = 0.0,
    this.viewCount = 0,
    RecommendedItem? recommendedItem,
  }) : recommendedItem = recommendedItem ?? RecommendedItem();

  factory RecommendedProduct.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return RecommendedProduct();

    return RecommendedProduct(
      id: json['_id'] ?? "",
      productId: json['productId'] ?? "",
      restaurantName: json['restaurantName'] ?? "",
      locationName: json['locationName'] ?? "",
      type: json['type'] is List ? List<String>.from(json['type']) : [],
      status: json['status'] ?? "",
      rating: (json['rating'] ?? 0).toDouble(),
      viewCount: json['viewCount'] ?? 0,
      recommendedItem: RecommendedItem.fromJson(json['recommendedItem']),
    );
  }
}

/// Inner recommended item details
class RecommendedItem {
  final String itemId;
  final String name;
  final int price; // base price
  final int halfPlatePrice;
  final int fullPlatePrice;
  final int discount; // percentage
  final List<String> tags;
  final double rating;
  final int viewCount;
  final String content;
  final String image;
  final Addons addons;
  final Category category;
  final int vendorHalfPercentage;
  final int vendorPlateCost;
  final String status;

  RecommendedItem({
    this.itemId = "",
    this.name = "",
    this.price = 0,
    this.halfPlatePrice = 0,
    this.fullPlatePrice = 0,
    this.discount = 0,
    this.tags = const [],
    this.rating = 0.0,
    this.viewCount = 0,
    this.content = "",
    this.image = "",
    Addons? addons,
    Category? category,
    this.vendorHalfPercentage = 0,
    this.vendorPlateCost = 0,
    this.status = "",
  })  : addons = addons ?? Addons(),
        category = category ?? Category();

  factory RecommendedItem.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return RecommendedItem();

    return RecommendedItem(
      itemId: json['_id'] ?? "",
      name: json['name'] ?? "",
      price: json['price'] ?? 0,
      halfPlatePrice: json['halfPlatePrice'] ?? 0,
      fullPlatePrice: json['fullPlatePrice'] ?? 0,
      discount: json['discount'] ?? 0,
      tags: json['tags'] is List ? List<String>.from(json['tags']) : [],
      rating: (json['rating'] ?? 0).toDouble(),
      viewCount: json['viewCount'] ?? 0,
      content: json['content'] ?? "",
      image: json['image'] ?? "",
      addons: Addons.fromJson(json['addons']),
      category: Category.fromJson(json['category']),
      vendorHalfPercentage: json['vendorHalfPercentage'] ?? 0,
      vendorPlateCost: json['vendor_Platecost'] ?? 0,
      status: json['status'] ?? "",
    );
  }
}

/// Reviews for restaurant
class RestaurantReview {
  final String id;
  final String userId;
  final String username;
  final String userimage;
  final int stars;
  final String comment;
  final DateTime createdAt;

  RestaurantReview({
    this.id = "",
    this.userId = "",
    this.username = "",
    this.userimage = "",
    this.stars = 0,
    this.comment = "",
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RestaurantReview.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return RestaurantReview();
    return RestaurantReview(
      id: json['_id'] ?? "",
      userId: json['_id'] ?? "",
            username: json['firstName'] ?? "",

      userimage: json['profileImg'] ?? "",

      stars: json['stars'] ?? 0,
      comment: json['comment'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
    );
  }
}

/// For backward-compatibility with any existing addons logic
class Addons {
  final Variation variation;
  final Plates plates;
  final String productName;

  Addons({
    Variation? variation,
    Plates? plates,
    this.productName = "",
  })  : variation = variation ?? Variation(),
        plates = plates ?? Plates();

  factory Addons.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return Addons();
    return Addons(
      variation: Variation.fromJson(json['variation']),
      plates: Plates.fromJson(json['plates']),
      productName: json['productName'] ?? "",
    );
  }
}

class Variation {
  final String name;
  final List<String> type;

  Variation({
    this.name = "",
    this.type = const [],
  });

  factory Variation.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return Variation();

    return Variation(
      name: json['name'] ?? "",
      type: json['type'] is List ? List<String>.from(json['type']) : [],
    );
  }
}

class Plates {
  final String name;

  Plates({this.name = ""});

  factory Plates.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return Plates();
    return Plates(name: json['name'] ?? "");
  }
}

class Category {
  final String id;
  final String categoryName;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Category({
    this.id = "",
    this.categoryName = "",
    this.imageUrl = "",
    DateTime? createdAt,
    DateTime? updatedAt,
    this.v = 0,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Category.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return Category();

    return Category(
      id: json['_id'] ?? "",
      categoryName: json['categoryName'] ?? "",
      imageUrl: json['imageUrl'] ?? "",
      createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? "") ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }
}

/// Helper model used in UI to keep productId with item
class RecommendedItemWithId {
  final String productId;
  final String id;
  final RecommendedItem recommendedItem;

  RecommendedItemWithId({
    this.productId = "",
    this.id = "",
    RecommendedItem? recommendedItem,
  }) : recommendedItem = recommendedItem ?? RecommendedItem();
}
