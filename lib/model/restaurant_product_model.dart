
// import 'dart:convert';

// /// Top level response model
// class RestaurantProductResponse {
//   final bool success;
//   final String message;
//   final int totalRecommendedItems;
//   final int totalRatings;
//   final int totalReviews;
//   final List<RecommendedProduct> recommendedProducts;
//   final List<RestaurantReview> restaurantReviews;
//   final String restaurantStatus;

//   RestaurantProductResponse({
//     this.success = false,
//     this.message = "",
//     this.totalRecommendedItems = 0,
//     this.totalRatings = 0,
//     this.totalReviews = 0,
//     this.recommendedProducts = const [],
//     this.restaurantReviews = const [],
//     this.restaurantStatus = ''
//   });

//   factory RestaurantProductResponse.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return RestaurantProductResponse();

//     return RestaurantProductResponse(
//       success: json['success'] ?? false,
//       message: json['message'] ?? "",
//       totalRecommendedItems: json['totalRecommendedItems'] ?? 0,
//       restaurantStatus: json['restaurantStatus'] ?? "",
//       totalRatings: json['totalRatings'] ?? 0,
//       totalReviews: json['totalReviews'] ?? 0,
//       recommendedProducts: (json['recommendedProducts'] is List)
//           ? (json['recommendedProducts'] as List)
//               .map((e) => RecommendedProduct.fromJson(e))
//               .toList()
//           : [],
//       restaurantReviews: (json['restaurantReviews'] is List)
//           ? (json['restaurantReviews'] as List)
//               .map((e) => RestaurantReview.fromJson(e))
//               .toList()
//           : [],
//     );
//   }
// }

// /// Single recommended product (wrapping a single recommended item)
// class RecommendedProduct {
//   final String id;
//   final String productId;
//   final String restaurantName;
//   final String locationName;
//   final List<String> type; // kept for backward compatibility (may be empty)
//   final String status;
//   final double rating; // restaurant/product level rating if backend sends it
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

// /// Inner recommended item details
// class RecommendedItem {
//   final String itemId;
//   final String name;
//   final int price; // base price
//   final int halfPlatePrice;
//   final int fullPlatePrice;
//   final int discount; // percentage
//   final List<String> tags;
//   final double rating;
//   final int viewCount;
//   final String content;
//   final String image;
//   final Addons addons;
//   final Category category;
//   final int vendorHalfPercentage;
//   final int vendorPlateCost;
//   final String status;

//   RecommendedItem({
//     this.itemId = "",
//     this.name = "",
//     this.price = 0,
//     this.halfPlatePrice = 0,
//     this.fullPlatePrice = 0,
//     this.discount = 0,
//     this.tags = const [],
//     this.rating = 0.0,
//     this.viewCount = 0,
//     this.content = "",
//     this.image = "",
//     Addons? addons,
//     Category? category,
//     this.vendorHalfPercentage = 0,
//     this.vendorPlateCost = 0,
//     this.status = "",
//   })  : addons = addons ?? Addons(),
//         category = category ?? Category();

//   factory RecommendedItem.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return RecommendedItem();

//     return RecommendedItem(
//       itemId: json['_id'] ?? "",
//       name: json['name'] ?? "",
//       price: json['price'] ?? 0,
//       halfPlatePrice: json['halfPlatePrice'] ?? 0,
//       fullPlatePrice: json['fullPlatePrice'] ?? 0,
//       discount: json['discount'] ?? 0,
//       tags: json['tags'] is List ? List<String>.from(json['tags']) : [],
//       rating: (json['rating'] ?? 0).toDouble(),
//       viewCount: json['viewCount'] ?? 0,
//       content: json['content'] ?? "",
//       image: json['image'] ?? "",
//       addons: Addons.fromJson(json['addons']),
//       category: Category.fromJson(json['category']),
//       vendorHalfPercentage: json['vendorHalfPercentage'] ?? 0,
//       vendorPlateCost: json['vendor_Platecost'] ?? 0,
//       status: json['status'] ?? "",
//     );
//   }
// }

// /// Reviews for restaurant
// class RestaurantReview {
//   final String id;
//   final String userId;
//   final String username;
//   final String userimage;
//   final int stars;
//   final String comment;
//   final DateTime createdAt;

//   RestaurantReview({
//     this.id = "",
//     this.userId = "",
//     this.username = "",
//     this.userimage = "",
//     this.stars = 0,
//     this.comment = "",
//     DateTime? createdAt,
//   }) : createdAt = createdAt ?? DateTime.now();

//   factory RestaurantReview.fromJson(dynamic json) {
//     if (json is! Map<String, dynamic>) return RestaurantReview();
//     return RestaurantReview(
//       id: json['_id'] ?? "",
//       userId: json['_id'] ?? "",
//             username: json['firstName'] ?? "",

//       userimage: json['profileImg'] ?? "",

//       stars: json['stars'] ?? 0,
//       comment: json['comment'] ?? "",
//       createdAt: DateTime.tryParse(json['createdAt'] ?? "") ?? DateTime.now(),
//     );
//   }
// }

// /// For backward-compatibility with any existing addons logic
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

// /// Helper model used in UI to keep productId with item
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

/// ---------- SAFE HELPERS ----------

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1';
  }
  if (value is num) return value != 0;
  return false;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

String _toStringValue(dynamic value) {
  if (value == null) return "";
  if (value is String) return value;
  return value.toString();
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => _toStringValue(e)).toList();
  }
  return const [];
}

DateTime _toDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

/// ---------- TOP LEVEL RESPONSE ----------

class RestaurantProductResponse {
  final bool success;
  final String message;
  final int totalRecommendedItems;
  final int totalRatings;
  final int totalReviews;
  final List<RecommendedProduct> recommendedProducts;
  final List<RestaurantReview> restaurantReviews;
  final String restaurantStatus;
    final String restaurantImage;


  RestaurantProductResponse({
    this.success = false,
    this.message = "",
    this.totalRecommendedItems = 0,
    this.totalRatings = 0,
    this.totalReviews = 0,
    this.recommendedProducts = const [],
    this.restaurantReviews = const [],
    this.restaurantStatus = '',
    this.restaurantImage = ''
  });

  factory RestaurantProductResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RestaurantProductResponse();

    // Safe lists
    final recProdRaw = json['recommendedProducts'];
    final reviewsRaw = json['restaurantReviews'];

    List<RecommendedProduct> recProducts = [];
    if (recProdRaw is List) {
      recProducts = recProdRaw
          .map((e) => RecommendedProduct.fromJson(e))
          .toList();
    }

    List<RestaurantReview> reviews = [];
    if (reviewsRaw is List) {
      reviews = reviewsRaw
          .map((e) => RestaurantReview.fromJson(e))
          .toList();
    }

    return RestaurantProductResponse(
      success: _toBool(json['success']),
      message: _toStringValue(json['message']),
      totalRecommendedItems: _toInt(json['totalRecommendedItems']),
      restaurantStatus: _toStringValue(json['restaurantStatus']),
            restaurantImage: _toStringValue(json['restaurantImage']),

      totalRatings: _toInt(json['totalRatings']),
      totalReviews: _toInt(json['totalReviews']),
      recommendedProducts: recProducts,
      restaurantReviews: reviews,
    );
  }
}

/// ---------- RECOMMENDED PRODUCT WRAPPER ----------

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
      id: _toStringValue(json['_id']),
      productId: _toStringValue(json['productId']),
      restaurantName: _toStringValue(json['restaurantName']),
      locationName: _toStringValue(json['locationName']),
      type: _toStringList(json['type']),
      status: _toStringValue(json['status']),
      rating: _toDouble(json['rating']),
      viewCount: _toInt(json['viewCount']),
      recommendedItem: RecommendedItem.fromJson(json['recommendedItem']),
    );
  }
}

/// ---------- INNER RECOMMENDED ITEM ----------

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
      itemId: _toStringValue(json['_id']),
      name: _toStringValue(json['name']),
      price: _toInt(json['price']),
      halfPlatePrice: _toInt(json['halfPlatePrice']),
      fullPlatePrice: _toInt(json['fullPlatePrice']),
      discount: _toInt(json['discount']),
      tags: _toStringList(json['tags']),
      rating: _toDouble(json['rating']),
      viewCount: _toInt(json['viewCount']),
      content: _toStringValue(json['content']),
      image: _toStringValue(json['image']),
      addons: Addons.fromJson(json['addons']),
      category: Category.fromJson(json['category']),
      vendorHalfPercentage: _toInt(json['vendorHalfPercentage']),
      vendorPlateCost: _toInt(json['vendor_Platecost']),
      status: _toStringValue(json['status']),
    );
  }
}

/// ---------- RESTAURANT REVIEWS ----------

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
      id: _toStringValue(json['_id']),
      // If backend ever sends a real userId, you can switch to that key.
      userId: _toStringValue(json['userId'] ?? json['_id']),
      username: _toStringValue(json['firstName']),
      userimage: _toStringValue(json['profileImg']),
      // ⭐ THIS WAS FAILING: "3" (String) → int
      stars: _toInt(json['stars']),
      comment: _toStringValue(json['comment']),
      createdAt: _toDateTime(json['createdAt']),
    );
  }
}

/// ---------- ADDONS / VARIATION / PLATES ----------

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
      productName: _toStringValue(json['productName']),
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
      name: _toStringValue(json['name']),
      type: _toStringList(json['type']),
    );
  }
}

class Plates {
  final String name;

  Plates({this.name = ""});

  factory Plates.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) return Plates();
    return Plates(name: _toStringValue(json['name']));
  }
}

/// ---------- CATEGORY ----------

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
      id: _toStringValue(json['_id']),
      categoryName: _toStringValue(json['categoryName']),
      imageUrl: _toStringValue(json['imageUrl']),
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
      v: _toInt(json['__v']),
    );
  }
}

/// ---------- HELPER MODEL FOR UI ----------

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
