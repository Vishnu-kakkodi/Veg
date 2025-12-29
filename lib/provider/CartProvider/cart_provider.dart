
// provider/CartProvider/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:veegify/model/CartModel/cart_model.dart';
import 'package:veegify/services/CartService/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartModel? _cart;
  AppliedCoupon? _appliedCoupon;
  bool _isLoading = false;
  String? _error;
  String _userId = '';

  // Getters
  CartModel? get cart => _cart;
  AppliedCoupon? get appliedCoupon => _appliedCoupon;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<CartProduct> get items => _cart?.products ?? [];
  int get totalItems => _cart?.totalItems ?? 0;

  /// Now doubles, matching CartModel (safe for int/double/string from API)
  double get subtotal => _cart?.subTotal ?? 0.0;
  double get deliveryCharge => _cart?.deliveryCharge ?? 0.0;
  double get couponDiscount => _cart?.couponDiscount ?? 0.0;
    double get gstOnDelivery => _cart?.gstOnDelivery ?? 0.0;
        double get packingCharges => _cart?.packingCharges ?? 0.0;
                double get amountSavedOnOrder => _cart?.amountSavedOnOrder ?? 0.0;


    double get gstAmount => _cart?.gstAmount ?? 0.0;

  double get totalPayable => _cart?.finalAmount ?? 0.0;
    double get platformCharge => _cart?.platformCharge ?? 0.0;


  bool get hasItems => items.isNotEmpty;
  String get restaurantId => _cart?.restaurantId ?? '';


  bool get hasInactiveProducts {
    return items.any((p) => !p.isProductActive);
  }

  // 🔥 NEW: whole vendor active?
  bool get isVendorActive {
    // If no items, treat as active so UI won't block.
    if (!hasItems) return true;
    return items.every((p) => p.isVendorActive);
  }
  // Set user ID
  void setUserId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  // Load cart from API
  Future<void> loadCart(String? userId) async {
    if (_isLoading) return;

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Loading cart for user: $userId");
      final cartResponse = await CartService.getCart(userId.toString());

      if (cartResponse != null) {
        _cart = cartResponse.cart;
        _appliedCoupon = cartResponse.appliedCoupon;
        print("✅ Cart loaded with ${items.length} items");
      } else {
        _cart = null;
        _appliedCoupon = null;
        print("ℹ️ No cart found - empty state");
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading cart: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  // Add item to cart
  // Future<bool> addItemToCart({
  //   required String restaurantProductId,
  //   required String recommendedId,
  //   required int quantity,
  //   required String variation,
  //   required int plateItems,
  //   String? couponId,
  //   String? userId,
  // }) async {
  //   if (_isLoading) return false;

  //   _setLoadingState(true);
  //   _error = null;

  //   try {
  //     print("🔄 Adding item to cart");
  //     final request = AddToCartRequest(
  //       products: [
  //         CartProductRequest(
  //           restaurantProductId: restaurantProductId,
  //           recommendedId: recommendedId,
  //           quantity: quantity,
  //           addOn: CartAddOnRequest(
  //             variation: variation,
  //             plateitems: plateItems,
  //           ),
  //         ),
  //       ],
  //       couponId: couponId ?? _appliedCoupon?.id,
  //     );

  //     final response = await CartService.addToCart(userId.toString(), request);

  //     if (response.success) {
  //       _cart = response.cart;
  //       _appliedCoupon = response.appliedCoupon;
  //       print("✅ Item added successfully");
  //       _setLoadingState(false);
  //       return true;
  //     } else {
  //       _error = response.message;
  //       print("❌ Failed to add item: ${response.message}");
  //       _setLoadingState(false);
  //       return false;
  //     }
  //   } catch (e) {
  //     _error = e.toString();
  //     print('❌ Error adding item: $e');
  //     _setLoadingState(false);
  //     return false;
  //   }
  // }


Future<bool> addItemToCart({
  required String restaurantProductId,
  required String recommendedId,
  required int quantity,
  required String variation,
  required int plateItems,
  String? couponId,
  String? userId,
}) async {
  if (_isLoading) return false;

  _setLoadingState(true);
  _error = null;

  try {
    print("🔄 Adding item to cart");

    // 👇 derive flags from variation value
    final lowerVar = variation.toLowerCase();
    bool? isHalfPlate;
    bool? isFullPlate;

    if (lowerVar == 'half') {
      isHalfPlate = true;
    } else if (lowerVar == 'full') {
      isFullPlate = true;
    }
    // For "Regular" or anything else, both stay null (optional)

    final request = AddToCartRequest(
      products: [
        CartProductRequest(
          restaurantProductId: restaurantProductId,
          recommendedId: recommendedId,
          quantity: quantity,
          addOn: CartAddOnRequest(
            // variation: variation,
            plateitems: plateItems,
          ),
                      isHalfPlate: isHalfPlate,   // 👈 NEW
            isFullPlate: isFullPlate,   // 👈 NEW
        ),
      ],
      couponId: couponId ?? _appliedCoupon?.id,
    );

    final response = await CartService.addToCart(userId.toString(), request);

    if (response.success) {
      _cart = response.cart;
      _appliedCoupon = response.appliedCoupon;
      print("✅ Item added successfully");
      _setLoadingState(false);
      return true;
    } else {
      _error = response.message;
      print("❌ Failed to add item: ${response.message}");
      _setLoadingState(false);
      return false;
    }
  } catch (e) {
    _error = e.toString();
    print('❌ Error adding item: $e');
    _setLoadingState(false);
    return false;
  }
}



  // Increment item quantity
  Future<bool> incrementQuantity(String cartProductId, String? userIdd) async {
    if (_cart == null || _isLoading) return false;

    final cartProduct = items.firstWhere(
      (product) => product.id == cartProductId,
      orElse: () => throw Exception('Product not found'),
    );

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Incrementing quantity for: ${cartProduct.name}");
      final response = await CartService.updateQuantity(
        userId: userIdd.toString(),
        restaurantProductId: cartProduct.restaurantProductId,
        recommendedId: cartProduct.recommendedId,
        action: 'inc',
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        print("✅ Quantity incremented");
        _setLoadingState(false);
        return true;
      } else {
        _error = response.message;
        print("❌ Failed to increment: ${response.message}");
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error incrementing: $e');
      _setLoadingState(false);
      return false;
    }
  }

  // Decrement item quantity
  Future<bool> decrementQuantity(String cartProductId, String? userIdd) async {
    if (_cart == null || _isLoading) return false;

    final cartProduct = items.firstWhere(
      (product) => product.id == cartProductId,
      orElse: () => throw Exception('Product not found'),
    );

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Decrementing quantity for: ${cartProduct.name}");
      final response = await CartService.updateQuantity(
        userId: userIdd.toString(),
        restaurantProductId: cartProduct.restaurantProductId,
        recommendedId: cartProduct.recommendedId,
        action: 'dec',
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        print("✅ Quantity decremented");
        _setLoadingState(false);
        return true;
      } else {
        _error = response.message;
        print("❌ Failed to decrement: ${response.message}");
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error decrementing: $e');
      _setLoadingState(false);
      return false;
    }
  }

  // Remove item from cart
  Future<bool> removeItem(String cartProductId, String? usrIdd) async {
    if (_cart == null || _isLoading) return false;

    // Safely find the cartProduct
    CartProduct? cartProduct;
    try {
      cartProduct = items.firstWhere((product) => product.id == cartProductId);
      loadCart(usrIdd.toString());
    } catch (e) {
      _error = 'Product not found';
      print('❌ removeItem: product not found for id $cartProductId');
      return false;
    }

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Removing item: ${cartProduct.name}");
      final response = await CartService.deleteCartProduct(
        userId: usrIdd.toString(),
        productId: cartProduct.restaurantProductId,
        recommendedId: cartProduct.recommendedId,
      );

      if (response.success) {
        // If server returned a complete cart, use it.
        final returnedCart = response.cart;
        final returnedProducts = returnedCart?.products;

        if (returnedCart != null &&
            (returnedProducts != null && returnedProducts.isNotEmpty)) {
          _cart = returnedCart;
          _appliedCoupon = response.appliedCoupon;
          print("✅ Item removed (updated cart from response)");
        } else {
          // Fallback: re-fetch the cart from server to avoid showing empty state
          print("⚠️ Response cart incomplete — reloading cart from server");
          final reloadUserId =
              _userId.isNotEmpty ? _userId : usrIdd.toString();
          await loadCart(reloadUserId);
          // loadCart sets _cart/_appliedCoupon and notifies listeners
        }

        _setLoadingState(false);
        return true;
      } else {
        _error = response.message;
        print("❌ Failed to remove: ${response.message}");
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error removing item: $e');
      _setLoadingState(false);
      return false;
    }
  }

  // Apply coupon
  Future<bool> applyCoupon(String couponCode) async {
    if (_cart == null || items.isEmpty || _isLoading) {
      _error = 'Cart is empty';
      return false;
    }

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Applying coupon: $couponCode");
      final coupon = await CartService.validateCoupon(couponCode);

      if (coupon == null) {
        _error = 'Invalid coupon code';
        _setLoadingState(false);
        return false;
      }

      if (subtotal < coupon.minCartAmount) {
        _error =
            'Minimum cart amount of ₹${coupon.minCartAmount} required';
        _setLoadingState(false);
        return false;
      }

      final currentProducts = items
          .map((item) => CartProductRequest(
                restaurantProductId: item.restaurantProductId,
                recommendedId: item.recommendedId,
                quantity: item.quantity,
                addOn: CartAddOnRequest(
                  // variation: item.addOn.variation,
                  plateitems: item.addOn.plateitems,
                ),
              ))
          .toList();

      final response = await CartService.applyCoupon(
        userId: _userId,
        couponId: coupon.id,
        currentProducts: currentProducts,
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        print("✅ Coupon applied");
        _setLoadingState(false);
        return true;
      } else {
        _error = response.message;
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error applying coupon: $e');
      _setLoadingState(false);
      return false;
    }
  }

  // Remove coupon
  Future<bool> removeCoupon() async {
    if (_cart == null || items.isEmpty || _isLoading) return false;

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Removing coupon");
      final currentProducts = items
          .map((item) => CartProductRequest(
                restaurantProductId: item.restaurantProductId,
                recommendedId: item.recommendedId,
                quantity: item.quantity,
                addOn: CartAddOnRequest(
                  // variation: item.addOn.variation,
                  plateitems: item.addOn.plateitems,
                ),
              ))
          .toList();

      final response = await CartService.addToCart(
        _userId,
        AddToCartRequest(products: currentProducts),
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        print("✅ Coupon removed");
        _setLoadingState(false);
        return true;
      } else {
        _error = response.message;
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error removing coupon: $e');
      _setLoadingState(false);
      return false;
    }
  }

  // Clear cart
  Future<bool> clearCart() async {
    if (_isLoading) return false;

    _setLoadingState(true);
    _error = null;

    try {
      print("🔄 Clearing cart");
      final response = await CartService.clearCart(_userId);

      if (response.success) {
        _cart = null;
        _appliedCoupon = null;
        print("✅ Cart cleared");
        _setLoadingState(false);
        return true;
      } else {
        _error = response.message;
        _setLoadingState(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error clearing cart: $e');
      _setLoadingState(false);
      return false;
    }
  }

  // Helper methods
  CartProduct? getCartProduct(String recommendedId) {
    return items
        .where((item) => item.recommendedId == recommendedId)
        .firstOrNull;
  }

  bool hasItem(String recommendedId) {
    return items.any((item) => item.recommendedId == recommendedId);
  }

  int getItemQuantity(String recommendedId) {
    final item = getCartProduct(recommendedId);
    return item?.quantity ?? 0;
  }

  // Private helper
  void _setLoadingState(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  // Legacy support
  List<CartItem> get legacyItems {
    return items
        .map((item) => CartItem(
              id: item.id,
              title: item.name,
              image: item.image,
              basePrice: item.basePrice, // already double
              variation: item.addOn.variation,
              addOns: {'${item.addOn.plateitems} Plates'},
              quantity: item.quantity,
              isVeg: true,
            ))
        .toList();
  }
}

// Legacy CartItem class
class CartItem {
  final String id;
  final String title;
  final String? image;
  final double basePrice;
  final String variation;
  final Set<String> addOns;
  final int quantity;
  final bool isVeg;

  CartItem({
    required this.id,
    required this.title,
    this.image,
    required this.basePrice,
    required this.variation,
    required this.addOns,
    required this.quantity,
    required this.isVeg,
  });

  double get totalPrice => basePrice * quantity;
}
