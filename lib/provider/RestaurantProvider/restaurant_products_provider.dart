

// import 'package:flutter/material.dart';
// import 'package:veegify/model/restaurant_product_model.dart';
// import 'package:veegify/services/restaurant_product_service.dart';

// class RestaurantProductsProvider with ChangeNotifier {
//   List<RecommendedProduct> _recommendedProducts = [];
//   bool _isLoading = false;
//   String? _error;
//   String _restaurantName = '';
//   String _locationName = '';
//   double _rating = 0.0;
//   int _totalRecommendedItems = 0;

//   // Getters
//   List<RecommendedProduct> get recommendedProducts => _recommendedProducts;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   String get restaurantName => _restaurantName;
//   String get locationName => _locationName;
//   double get rating => _rating;
//   int get totalRecommendedItems => _totalRecommendedItems;

//   // Get all recommended items for display with their product IDs
//   List<RecommendedItemWithId> get allRecommendedItems {
//     return _recommendedProducts.map((product) => RecommendedItemWithId(
//       productId: product.productId,
//       recommendedItem: product.recommendedItem,
//     )).toList();
//   }

// Future<void> fetchRestaurantProducts(String restaurantId) async {
//   _isLoading = true;
//   _error = null;
//   notifyListeners();

//   try {
//     final response = await RestaurantService.getRestaurantProducts(restaurantId);

//     if (response.success && response.recommendedProducts.isNotEmpty) {
//       _recommendedProducts = response.recommendedProducts;
//       _totalRecommendedItems = response.totalRecommendedItems;

//       final first = _recommendedProducts.first;
//       _restaurantName = first.restaurantName;
//       _locationName = first.locationName;
//       _rating = first.rating;
//       _error = null;

//     } else {
//       _recommendedProducts = [];
//       _totalRecommendedItems = 0;
//       _restaurantName = "";
//       _locationName = "";
//       _rating = 0.0;
//       _error = "NO_PRODUCTS";
//     }

//   } catch (e) {
//     _error = "ERROR";
//     _recommendedProducts = [];
//     _totalRecommendedItems = 0;
//   } finally {
//     _isLoading = false;
//     notifyListeners();
//   }
// }


//   void clearData() {
//     _recommendedProducts = [];
//     _error = null;
//     _restaurantName = '';
//     _locationName = '';
//     _rating = 0.0;
//     _totalRecommendedItems = 0;
//     notifyListeners();
//   }

//   // Search functionality
//   List<RecommendedItemWithId> searchItems(String query) {
//     if (query.isEmpty) return allRecommendedItems;
    
//     return allRecommendedItems.where((itemWithId) =>
//       itemWithId.recommendedItem.name.toLowerCase().contains(query.toLowerCase()) ||
//       itemWithId.recommendedItem.category.categoryName.toLowerCase().contains(query.toLowerCase())
//     ).toList();
//   }

//   // Get product by recommended item name
//   RecommendedProduct? getProductByRecommendedItem(RecommendedItem item) {
//     try {
//       return _recommendedProducts.firstWhere(
//         (product) => product.recommendedItem.name == item.name
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   // Get product ID by recommended item name
//   String? getProductIdByItem(RecommendedItem item) {
//     final product = getProductByRecommendedItem(item);
//     return product?.productId; // This returns the productId from the API
//   }
// }




// // import 'package:flutter/material.dart';
// // import 'package:veegify/model/restaurant_product_model.dart';
// // import 'package:veegify/services/restaurant_product_service.dart';

// // class RestaurantProductsProvider with ChangeNotifier {
// //   List<RestaurantProduct> _products = [];
// //   bool _isLoading = false;
// //   String? _error;
// //   String _restaurantName = '';
// //   String _locationName = '';
// //   double _rating = 0.0;

// //   // Getters
// //   List<RestaurantProduct> get products => _products;
// //   bool get isLoading => _isLoading;
// //   String? get error => _error;
// //   String get restaurantName => _restaurantName;
// //   String get locationName => _locationName;
// //   double get rating => _rating;

// //   // Get recommended items from all products
// //   List<RecommendedItem> get allRecommendedItems {
// //     return _products.map((p) => p.recommendedItem).toList();
// //   }

// //   Future<void> fetchRestaurantProducts(String restaurantId) async {
// //     _isLoading = true;
// //     _error = null;
// //     notifyListeners();

// //     try {
// //       final response = await RestaurantService.getRestaurantProducts(restaurantId);

// //       if (response.success && response.recommendedProducts.isNotEmpty) {
// //         _products = response.recommendedProducts;

// //         // Set restaurant info from the first product
// //         final firstProduct = _products.first;
// //         _restaurantName = firstProduct.restaurantName;
// //         _locationName = firstProduct.locationName;
// //         _rating = firstProduct.rating;

// //         _error = null;
// //       } else {
// //         _error = 'No products found';
// //       }
// //     } catch (e) {
// //       _error = e.toString();
// //     } finally {
// //       _isLoading = false;
// //       notifyListeners();
// //     }
// //   }

// //   void clearData() {
// //     _products = [];
// //     _error = null;
// //     _restaurantName = '';
// //     _locationName = '';
// //     _rating = 0.0;
// //     notifyListeners();
// //   }

// //   // Search functionality
// //   List<RecommendedItem> searchItems(String query) {
// //     if (query.isEmpty) return allRecommendedItems;

// //     return allRecommendedItems
// //         .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
// //         .toList();
// //   }
// // }




















// import 'package:flutter/material.dart';
// import 'package:veegify/model/restaurant_product_model.dart';
// import 'package:veegify/services/restaurant_product_service.dart';

// class RestaurantProductsProvider with ChangeNotifier {
//   List<RecommendedProduct> _recommendedProducts = [];
//   List<RestaurantReview> _restaurantReviews = [];

//   bool _isLoading = false;
//   String? _error;
//   String _restaurantName = '';
//   String _locationName = '';
//   double _rating = 0.0;
//   int _totalRecommendedItems = 0;
//   int _totalRatings = 0;
//   int _totalReviews = 0;

//   // Getters
//   List<RecommendedProduct> get recommendedProducts => _recommendedProducts;
//   List<RestaurantReview> get restaurantReviews => _restaurantReviews;

//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   String get restaurantName => _restaurantName;
//   String get locationName => _locationName;
//   double get rating => _rating;
//   int get totalRecommendedItems => _totalRecommendedItems;
//   int get totalRatings => _totalRatings;
//   int get totalReviews => _totalReviews;

//   // Get all recommended items for display with their product IDs
//   List<RecommendedItemWithId> get allRecommendedItems {
//     return _recommendedProducts
//         .map(
//           (product) => RecommendedItemWithId(
//             productId: product.productId,
//             recommendedItem: product.recommendedItem,
//           ),
//         )
//         .toList();
//   }

//   Future<void> fetchRestaurantProducts(String restaurantId) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final response =
//           await RestaurantService.getRestaurantProducts(restaurantId);

//       if (response.success && response.recommendedProducts.isNotEmpty) {
//         _recommendedProducts = response.recommendedProducts;
//         _totalRecommendedItems = response.totalRecommendedItems;

//         _restaurantReviews = response.restaurantReviews;
//         _totalRatings = response.totalRatings;
//         _totalReviews = response.totalReviews;

//         // Restaurant info from first product
//         final first = _recommendedProducts.first;
//         _restaurantName = first.restaurantName;
//         _locationName = first.locationName;

//         // Derive rating from totalRatings / totalReviews if available
//         if (_totalReviews > 0) {
//           _rating = _totalRatings / _totalReviews;
//         } else {
//           _rating = first.rating; // fallback if backend still sends rating
//         }

//         _error = null;
//       } else {
//         _recommendedProducts = [];
//         _restaurantReviews = [];
//         _totalRecommendedItems = 0;
//         _totalRatings = 0;
//         _totalReviews = 0;
//         _restaurantName = "";
//         _locationName = "";
//         _rating = 0.0;
//         _error = "NO_PRODUCTS";
//       }
//     } catch (e) {
//       _error = "ERROR";
//       _recommendedProducts = [];
//       _restaurantReviews = [];
//       _totalRecommendedItems = 0;
//       _totalRatings = 0;
//       _totalReviews = 0;
//       _restaurantName = "";
//       _locationName = "";
//       _rating = 0.0;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clearData() {
//     _recommendedProducts = [];
//     _restaurantReviews = [];
//     _error = null;
//     _restaurantName = '';
//     _locationName = '';
//     _rating = 0.0;
//     _totalRecommendedItems = 0;
//     _totalRatings = 0;
//     _totalReviews = 0;
//     notifyListeners();
//   }

//   // Search functionality
//   List<RecommendedItemWithId> searchItems(String query) {
//     if (query.isEmpty) return allRecommendedItems;

//     return allRecommendedItems.where((itemWithId) {
//       final name = itemWithId.recommendedItem.name.toLowerCase();
//       final category =
//           itemWithId.recommendedItem.category.categoryName.toLowerCase();
//       return name.contains(query.toLowerCase()) ||
//           category.contains(query.toLowerCase());
//     }).toList();
//   }

//   // Get product by recommended item
//   RecommendedProduct? getProductByRecommendedItem(RecommendedItem item) {
//     try {
//       return _recommendedProducts.firstWhere(
//         (product) => product.recommendedItem.itemId == item.itemId,
//       );
//     } catch (e) {
//       return null;
//     }
//   }

//   // Get product ID by recommended item
//   String? getProductIdByItem(RecommendedItem item) {
//     final product = getProductByRecommendedItem(item);
//     return product?.productId;
//   }
// }














import 'package:flutter/material.dart';
import 'package:veegify/model/restaurant_product_model.dart';
import 'package:veegify/services/restaurant_product_service.dart';

class RestaurantProductsProvider with ChangeNotifier {
  List<RecommendedProduct> _recommendedProducts = [];
  List<RestaurantReview> _restaurantReviews = [];

  bool _isLoading = false;
  String? _error;
  String _restaurantName = '';
  String _locationName = '';
  double _rating = 0.0;
  int _totalRecommendedItems = 0;
  int _totalRatings = 0;
  int _totalReviews = 0;
    String _restaurantStatus = "";
    String _resImage = "";


  // Getters
  List<RecommendedProduct> get recommendedProducts => _recommendedProducts;
  List<RestaurantReview> get restaurantReviews => _restaurantReviews;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get restaurantName => _restaurantName;
  String get locationName => _locationName;
  double get rating => _rating;
  int get totalRecommendedItems => _totalRecommendedItems;
  int get totalRatings => _totalRatings;
  int get totalReviews => _totalReviews;
    String get restaurantStatus => _restaurantStatus;
    String get resImage => _resImage;


  // Get all recommended items for display with their product IDs
  List<RecommendedItemWithId> get allRecommendedItems {
    return _recommendedProducts
        .map(
          (product) => RecommendedItemWithId(
            productId: product.productId,
            recommendedItem: product.recommendedItem,
          ),
        )
        .toList();
  }

  Future<void> fetchRestaurantProducts(String restaurantId, String? categoryName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await RestaurantService.getRestaurantProducts(restaurantId,categoryName);

      if (response.success && response.recommendedProducts.isNotEmpty) {
        _recommendedProducts = response.recommendedProducts;
        _totalRecommendedItems = response.totalRecommendedItems;
                _restaurantStatus = response.restaurantStatus;
                                _resImage = response.restaurantImage;



        _restaurantReviews = response.restaurantReviews;
        _totalRatings = response.totalRatings;
        _totalReviews = response.totalReviews;

        // Restaurant info from first product
        final first = _recommendedProducts.first;
        _restaurantName = first.restaurantName;
        _locationName = first.locationName;

        // Derive rating from totalRatings / totalReviews if available
        if (_totalReviews > 0) {
          _rating = _totalRatings / _totalReviews;
        } else {
          _rating = first.rating; // fallback if backend still sends rating
        }

        _error = null;
      } else {
        _recommendedProducts = [];
        _restaurantReviews = [];
        _totalRecommendedItems = 0;
        _totalRatings = 0;
        _totalReviews = 0;
        _restaurantName = "";
        _locationName = "";
        _rating = 0.0;
        _error = "NO_PRODUCTS";
      }
    } catch (e) {
      _error = "ERROR";
      _recommendedProducts = [];
      _restaurantReviews = [];
      _totalRecommendedItems = 0;
      _totalRatings = 0;
      _totalReviews = 0;
      _restaurantName = "";
      _locationName = "";
      _rating = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _recommendedProducts = [];
    _restaurantReviews = [];
    _error = null;
    _restaurantName = '';
    _locationName = '';
    _rating = 0.0;
    _totalRecommendedItems = 0;
    _totalRatings = 0;
    _totalReviews = 0;
    notifyListeners();
  }

  // Search functionality
  List<RecommendedItemWithId> searchItems(String query) {
    if (query.isEmpty) return allRecommendedItems;

    return allRecommendedItems.where((itemWithId) {
      final name = itemWithId.recommendedItem.name.toLowerCase();
      final category =
          itemWithId.recommendedItem.category.categoryName.toLowerCase();
      return name.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase());
    }).toList();
  }

  // Get product by recommended item
  RecommendedProduct? getProductByRecommendedItem(RecommendedItem item) {
    try {
      return _recommendedProducts.firstWhere(
        (product) => product.recommendedItem.itemId == item.itemId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get product ID by recommended item
  String? getProductIdByItem(RecommendedItem item) {
    final product = getProductByRecommendedItem(item);
    return product?.productId;
  }
}
