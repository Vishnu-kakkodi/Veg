import 'package:flutter/material.dart';
import 'package:veegify/model/wishlist_model.dart';
import 'package:veegify/services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<WishlistProduct> _wishlist = [];
  bool _isLoading = false;
  String _error = '';

  List<WishlistProduct> get wishlist => _wishlist;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchWishlist(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      print("oooooooooooooo$userId");
      _wishlist = await WishlistService.getWishlist(userId);
      print("Fetched Wishlist Items:${_wishlist.length}");
for (var p in _wishlist) {
  print("wishlist item => id: ${p.id}, productId: ${p.restaurantId  }");
}
            notifyListeners();

    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(String userId, String productId) async {
    try {
      print("Printing User Id : $userId");
      print("Printing Product Id: $productId");
      final isInWishlist =
          await WishlistService.toggleWishlist(userId, productId);

      // if (isInWishlist) {
      //   // only add if not already in list
      //   final product = await WishlistService.getProduct(productId);
      //   if (!_wishlist.any((item) => item.id == product.id)) {
      //     _wishlist.add(product);
      //   }
      // } else {
      //   _wishlist.removeWhere((item) => item.id == productId);
      // }
      if (isInWishlist) {
  print("✅ ADDING ITEM TO WISHLIST");
  print("User tapped productId: $productId");

  final product = await WishlistService.getProduct(productId);

  print("API returned product => id: ${product.id}, productId: $productId");

  print("Current wishlist items BEFORE add:");
  for (var item in _wishlist) {
    print("item.id: ${item.id}, item.productId: $productId");
  }

  // Only add if not already in list
  if (!_wishlist.any((item) => item.id == product.id)) {
    print("Adding new wishlist item ✅");
    _wishlist.add(product);
  } else {
    print("Item already exists in wishlist ❗");
  }

  print("Current wishlist items AFTER add:");
  for (var item in _wishlist) {
    print("item.id: ${item.id}, item.productId: $productId");
  }

} else {
  print("❌ REMOVING ITEM FROM WISHLIST");
  print("User tapped productId: $productId");

  print("Current wishlist items BEFORE remove:");
  for (var item in _wishlist) {
    print("item.id: ${item.id}, item.productId: $productId");
  }

  _wishlist.removeWhere((item) {
    print("Comparing: item.id = ${item.id} WITH productId = $productId");
    return item.id == productId;
  });

  print("Current wishlist items AFTER remove:");
  for (var item in _wishlist) {
    print("item.id: ${item.id}, item.productId: $productId");
  }
}

await fetchWishlist(userId);



      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

bool isInWishlist(String productId) {
  print("Checking productId: $productId");
    print("Checking productId: ${_wishlist.length}");


  for (var item in _wishlist) {
    print("Wishlist item => item.id: ${item.id}, item.productId: $productId}");
  }

  return _wishlist.any((item) => item.id == productId);
}


  void clearError() {
    _error = '';
    notifyListeners();
  }
}
