
// // provider/CartProvider/cart_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:veegify/helper/toast_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/services/CartService/cart_service.dart';

// class CartProvider extends ChangeNotifier {
//   CartModel? _cart;
//   AppliedCoupon? _appliedCoupon;
//   bool _isLoading = false;
//   String? _error;
//   String _userId = '';

//   // Toast callback for custom toast handling
//   Function(String message, {bool isError, bool isWarning, bool isInfo})? 
//       onShowToast;

//   // Getters
//   CartModel? get cart => _cart;
//   AppliedCoupon? get appliedCoupon => _appliedCoupon;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   List<CartProduct> get items => _cart?.products ?? [];
//   int get totalItems => _cart?.totalItems ?? 0;

//   /// Now doubles, matching CartModel (safe for int/double/string from API)
//   double get subtotal => _cart?.subTotal ?? 0.0;
//   double get deliveryCharge => _cart?.deliveryCharge ?? 0.0;
//   double get couponDiscount => _cart?.couponDiscount ?? 0.0;
//   double get gstOnDelivery => _cart?.gstOnDelivery ?? 0.0;
//   double get packingCharges => _cart?.packingCharges ?? 0.0;
//   double get amountSavedOnOrder => _cart?.amountSavedOnOrder ?? 0.0;
//   double get gstAmount => _cart?.gstAmount ?? 0.0;
//   double get totalPayable => _cart?.finalAmount ?? 0.0;
//   double get platformCharge => _cart?.platformCharge ?? 0.0;

//   bool get hasItems => items.isNotEmpty;
//   String get restaurantId => _cart?.restaurantId ?? '';

//   // Coupon info from chargeCalculations
//   String? get appliedCouponId => _cart?.appliedCouponId;
//   String? get appliedCouponCode => _cart?.appliedCouponCode;
//   CouponDiscountInfo? get appliedCouponInfo => _cart?.appliedCouponInfo;
  
//   // Check if coupon is applied
//   bool get hasAppliedCoupon => appliedCouponId != null && appliedCouponId!.isNotEmpty;

//   bool get hasInactiveProducts {
//     return items.any((p) => !p.isProductActive);
//   }

//   // Vendor active status
//   bool get isVendorActive {
//     if (!hasItems) return true;
//     return items.every((p) => p.isVendorActive);
//   }

//   // Set toast callback
//   void setToastCallback(Function(String message, {bool isError, bool isWarning, bool isInfo}) callback) {
//     onShowToast = callback;
//   }

//   // Helper method to show toast
//   void _showToast(
//     String message, {
//     bool isError = false,
//     bool isWarning = false,
//     bool isInfo = false,
//   }) {
//     if (onShowToast != null) {
//       onShowToast!(message, isError: isError, isWarning: isWarning, isInfo: isInfo);
//     } else {
//       // Fallback to ToastHelper if callback not set
//       if (isError) {
//         ToastHelper.showErrorToast(message);
//       } else if (isWarning) {
//         ToastHelper.showWarningToast(message);
//       } else if (isInfo) {
//         ToastHelper.showInfoToast(message);
//       } else {
//         ToastHelper.showSuccessToast(message);
//       }
//     }
//   }

//   // Set user ID
//   void setUserId(String userId) {
//     if (_userId != userId) {
//       _userId = userId;
//       notifyListeners();
//     }
//   }

//   // Compare two carts to decide if they are effectively the same
//   bool _isSameCart(CartModel? a, CartModel? b) {
//     if (a == null && b == null) return true;
//     if (a == null || b == null) return false;
//     if (a.id != b.id) return false;
//     if (a.products.length != b.products.length) return false;
//     // Compare each product's id and quantity
//     for (int i = 0; i < a.products.length; i++) {
//       if (a.products[i].id != b.products[i].id) return false;
//       if (a.products[i].quantity != b.products[i].quantity) return false;
//     }
//     // Compare final amount (most important for price changes)
//     if (a.finalAmount != b.finalAmount) return false;
//     // Compare applied coupon id
//     if (a.appliedCouponId != b.appliedCouponId) return false;
//     return true;
//   }

//   // Load cart from API
//   Future<void> loadCart(String? userId) async {
//     if (_isLoading) return;

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Loading cart for user: $userId");
//       final cartResponse = await CartService.getCart(userId.toString());

//       CartModel? newCart = cartResponse?.cart;
//       AppliedCoupon? newAppliedCoupon = cartResponse?.appliedCoupon;

//       // Only update and notify if cart actually changed
//       if (!_isSameCart(_cart, newCart) || 
//           _appliedCoupon?.id != newAppliedCoupon?.id) {
//         _cart = newCart;
//         _appliedCoupon = newAppliedCoupon;
//         print("✅ Cart changed, notifying listeners");
        
//         if (newCart != null) {
//           _showToast('Cart loaded successfully', isInfo: true);
//         }
        
//         // Log coupon info if available
//         if (_cart?.appliedCouponInfo != null) {
//           print("✅ Applied coupon: ${_cart?.appliedCouponInfo?.couponCode} (${_cart?.appliedCouponInfo?.couponId})");
//         }
        
//         notifyListeners();
//       } else {
//         print("ℹ️ Cart unchanged, skipping notify");
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error loading cart: $e', isError: true);
//       print('❌ Error loading cart: $e');
//     } finally {
//       _setLoadingState(false);
//     }
//   }

//   // Add item to cart
//   Future<bool> addItemToCart({
//     required String restaurantProductId,
//     required String recommendedId,
//     required int quantity,
//     required String variation,
//     required int plateItems,
//     String? couponId,
//     String? userId,
//   }) async {
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Adding item to cart");

//       final lowerVar = variation.toLowerCase();
//       bool? isHalfPlate;
//       bool? isFullPlate;

//       if (lowerVar == 'half') {
//         isHalfPlate = true;
//       } else if (lowerVar == 'full') {
//         isFullPlate = true;
//       }

//       final request = AddToCartRequest(
//         products: [
//           CartProductRequest(
//             restaurantProductId: restaurantProductId,
//             recommendedId: recommendedId,
//             quantity: quantity,
//             addOn: CartAddOnRequest(
//               plateitems: plateItems,
//             ),
//             isHalfPlate: isHalfPlate,
//             isFullPlate: isFullPlate,
//           ),
//         ],
//         couponId: couponId ?? _appliedCoupon?.id,
//       );

//       final response = await CartService.addToCart(userId.toString(), request);

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message from API or default
//         final successMessage = response.message ?? 'Item added to cart successfully';
//         _showToast(successMessage);
        
//         print("✅ Item added successfully");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message from API
//         final errorMessage = response.message ?? 'Failed to add item';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to add item: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error adding item: $e', isError: true);
//       print('❌ Error adding item: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Increment item quantity
//   Future<bool> incrementQuantity(String cartProductId, String? userIdd) async {
//     if (_cart == null) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     final cartProduct = items.firstWhere(
//       (product) => product.id == cartProductId,
//       orElse: () => throw Exception('Product not found'),
//     );

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Incrementing quantity for: ${cartProduct.name}");
//       final response = await CartService.updateQuantity(
//         userId: userIdd.toString(),
//         restaurantProductId: cartProduct.restaurantProductId,
//         recommendedId: cartProduct.recommendedId,
//         action: 'inc',
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Quantity increased';
//         _showToast(successMessage);
        
//         print("✅ Quantity incremented");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to increase quantity';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to increment: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error increasing quantity: $e', isError: true);
//       print('❌ Error incrementing: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Decrement item quantity
//   Future<bool> decrementQuantity(String cartProductId, String? userIdd) async {
//     if (_cart == null) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     final cartProduct = items.firstWhere(
//       (product) => product.id == cartProductId,
//       orElse: () => throw Exception('Product not found'),
//     );

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Decrementing quantity for: ${cartProduct.name}");
//       final response = await CartService.updateQuantity(
//         userId: userIdd.toString(),
//         restaurantProductId: cartProduct.restaurantProductId,
//         recommendedId: cartProduct.recommendedId,
//         action: 'dec',
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Quantity decreased';
//         _showToast(successMessage);
        
//         print("✅ Quantity decremented");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to decrease quantity';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to decrement: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error decreasing quantity: $e', isError: true);
//       print('❌ Error decrementing: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Remove item from cart
//   Future<bool> removeItem(String cartProductId, String? usrIdd) async {
//     if (_cart == null) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     // Safely find the cartProduct
//     CartProduct? cartProduct;
//     try {
//       cartProduct = items.firstWhere((product) => product.id == cartProductId);
//     } catch (e) {
//       _error = 'Product not found';
//       _showToast('Product not found', isError: true);
//       print('❌ removeItem: product not found for id $cartProductId');
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Removing item: ${cartProduct.name}");
//       final response = await CartService.deleteCartProduct(
//         userId: usrIdd.toString(),
//         productId: cartProduct.restaurantProductId,
//         recommendedId: cartProduct.recommendedId,
//       );

//       if (response.success) {
//         // Show success message
//         final successMessage = response.message ?? 'Item removed from cart';
//         _showToast(successMessage);
        
//         // If server returned a complete cart, use it.
//         final returnedCart = response.cart;
//         final returnedProducts = returnedCart?.products;

//         if (returnedCart != null &&
//             (returnedProducts != null && returnedProducts.isNotEmpty)) {
//           _cart = returnedCart;
//           _appliedCoupon = response.appliedCoupon;
//           print("✅ Item removed (updated cart from response)");
//         } else {
//           // Fallback: re-fetch the cart from server to avoid showing empty state
//           print("⚠️ Response cart incomplete — reloading cart from server");
//           final reloadUserId = _userId.isNotEmpty ? _userId : usrIdd.toString();
//           await loadCart(reloadUserId);
//         }

//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to remove item';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to remove: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error removing item: $e', isError: true);
//       print('❌ Error removing item: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Apply coupon
//   Future<bool> applyCoupon(String couponCode) async {
//     if (_cart == null || items.isEmpty) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Applying coupon: $couponCode");
      
//       // First validate coupon
//       final coupon = await CartService.validateCoupon(couponCode);

//       if (coupon == null) {
//         _error = 'Invalid coupon code';
//         _showToast('Invalid coupon code', isError: true);
//         _setLoadingState(false);
//         return false;
//       }

//       if (subtotal < coupon.minCartAmount) {
//         _error = 'Minimum cart amount of ₹${coupon.minCartAmount} required';
//         _showToast('Minimum cart amount of ₹${coupon.minCartAmount} required', isWarning: true);
//         _setLoadingState(false);
//         return false;
//       }

//       final currentProducts = items
//           .map((item) => CartProductRequest(
//                 restaurantProductId: item.restaurantProductId,
//                 recommendedId: item.recommendedId,
//                 quantity: item.quantity,
//                 addOn: CartAddOnRequest(
//                   plateitems: item.addOn.plateitems,
//                 ),
//               ))
//           .toList();

//       final response = await CartService.applyCoupon(
//         userId: _userId,
//         couponId: coupon.id,
//         currentProducts: currentProducts,
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Coupon applied successfully';
//         _showToast(successMessage);
        
//         print("✅ Coupon applied");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to apply coupon';
//         _showToast(errorMessage, isError: true);
        
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error applying coupon: $e', isError: true);
//       print('❌ Error applying coupon: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Remove coupon
//   Future<bool> removeCoupon() async {
//     if (_cart == null || items.isEmpty) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Removing coupon");
//       final currentProducts = items
//           .map((item) => CartProductRequest(
//                 restaurantProductId: item.restaurantProductId,
//                 recommendedId: item.recommendedId,
//                 quantity: item.quantity,
//                 addOn: CartAddOnRequest(
//                   plateitems: item.addOn.plateitems,
//                 ),
//               ))
//           .toList();

//       final response = await CartService.addToCart(
//         _userId,
//         AddToCartRequest(products: currentProducts),
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Coupon removed successfully';
//         _showToast(successMessage);
        
//         print("✅ Coupon removed");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to remove coupon';
//         _showToast(errorMessage, isError: true);
        
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error removing coupon: $e', isError: true);
//       print('❌ Error removing coupon: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Clear cart
//   Future<bool> clearCart() async {
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Clearing cart");
//       final response = await CartService.clearCart(_userId);

//       if (response.success) {
//         _cart = null;
//         _appliedCoupon = null;
        
//         // Show success message
//         final successMessage = response.message ?? 'Cart cleared successfully';
//         _showToast(successMessage);
        
//         print("✅ Cart cleared");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to clear cart';
//         _showToast(errorMessage, isError: true);
        
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error clearing cart: $e', isError: true);
//       print('❌ Error clearing cart: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Helper methods
//   CartProduct? getCartProduct(String recommendedId) {
//     return items
//         .where((item) => item.recommendedId == recommendedId)
//         .firstOrNull;
//   }

//   bool hasItem(String recommendedId) {
//     return items.any((item) => item.recommendedId == recommendedId);
//   }

//   int getItemQuantity(String recommendedId) {
//     final item = getCartProduct(recommendedId);
//     return item?.quantity ?? 0;
//   }

//   // Private helper
//   void _setLoadingState(bool loading) {
//     if (_isLoading != loading) {
//       _isLoading = loading;
//       notifyListeners();
//     }
//   }

//   // Legacy support
//   List<CartItem> get legacyItems {
//     return items
//         .map((item) => CartItem(
//               id: item.id,
//               title: item.name,
//               image: item.image,
//               basePrice: item.basePrice,
//               variation: item.addOn.variation,
//               addOns: {'${item.addOn.plateitems} Plates'},
//               quantity: item.quantity,
//               isVeg: true,
//             ))
//         .toList();
//   }
// }

// // Legacy CartItem class
// class CartItem {
//   final String id;
//   final String title;
//   final String? image;
//   final double basePrice;
//   final String variation;
//   final Set<String> addOns;
//   final int quantity;
//   final bool isVeg;

//   CartItem({
//     required this.id,
//     required this.title,
//     this.image,
//     required this.basePrice,
//     required this.variation,
//     required this.addOns,
//     required this.quantity,
//     required this.isVeg,
//   });

//   double get totalPrice => basePrice * quantity;
// }





// // provider/CartProvider/cart_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:veegify/helper/toast_helper.dart';
// import 'package:veegify/model/CartModel/cart_model.dart';
// import 'package:veegify/services/CartService/cart_service.dart';

// class CartProvider extends ChangeNotifier {
//   CartModel? _cart;
//   AppliedCoupon? _appliedCoupon;
//   bool _isLoading = false;
//   String? _error;
//   String _userId = '';

//   // Toast callback for custom toast handling
//   Function(String message, {bool isError, bool isWarning, bool isInfo})? 
//       onShowToast;

//   // Getters
//   CartModel? get cart => _cart;
//   AppliedCoupon? get appliedCoupon => _appliedCoupon;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   List<CartProduct> get items => _cart?.products ?? [];
//   int get totalItems => _cart?.totalItems ?? 0;

//   /// Now doubles, matching CartModel (safe for int/double/string from API)
//   double get subtotal => _cart?.subTotal ?? 0.0;
//   double get deliveryCharge => _cart?.deliveryCharge ?? 0.0;
//   double get couponDiscount => _cart?.couponDiscount ?? 0.0;
//   double get gstOnDelivery => _cart?.gstOnDelivery ?? 0.0;
//   double get packingCharges => _cart?.packingCharges ?? 0.0;
//   double get amountSavedOnOrder => _cart?.amountSavedOnOrder ?? 0.0;
//   double get gstAmount => _cart?.gstAmount ?? 0.0;
//   double get totalPayable => _cart?.finalAmount ?? 0.0;
//   double get platformCharge => _cart?.platformCharge ?? 0.0;

//   bool get hasItems => items.isNotEmpty;
//   String get restaurantId => _cart?.restaurantId ?? '';

//   // Coupon info from chargeCalculations
//   String? get appliedCouponId => _cart?.appliedCouponId;
//   String? get appliedCouponCode => _cart?.appliedCouponCode;
//   CouponDiscountInfo? get appliedCouponInfo => _cart?.appliedCouponInfo;
  
//   // Check if coupon is applied
//   bool get hasAppliedCoupon => appliedCouponId != null && appliedCouponId!.isNotEmpty;

//   bool get hasInactiveProducts {
//     return items.any((p) => !p.isProductActive);
//   }

//   // Vendor active status
//   bool get isVendorActive {
//     if (!hasItems) return true;
//     return items.every((p) => p.isVendorActive);
//   }

//   // Set toast callback
//   void setToastCallback(Function(String message, {bool isError, bool isWarning, bool isInfo}) callback) {
//     onShowToast = callback;
//   }

//   // Helper method to show toast
//   void _showToast(
//     String message, {
//     bool isError = false,
//     bool isWarning = false,
//     bool isInfo = false,
//   }) {
//     if (onShowToast != null) {
//       onShowToast!(message, isError: isError, isWarning: isWarning, isInfo: isInfo);
//     } else {
//       // Fallback to ToastHelper if callback not set
//       if (isError) {
//         ToastHelper.showErrorToast(message);
//       } else if (isWarning) {
//         ToastHelper.showWarningToast(message);
//       } else if (isInfo) {
//         ToastHelper.showInfoToast(message);
//       } else {
//         ToastHelper.showSuccessToast(message);
//       }
//     }
//   }

//   // Set user ID
//   void setUserId(String userId) {
//     if (_userId != userId) {
//       _userId = userId;
//       notifyListeners();
//     }
//   }

//   // Compare two carts to decide if they are effectively the same
//   bool _isSameCart(CartModel? a, CartModel? b) {
//     if (a == null && b == null) return true;
//     if (a == null || b == null) return false;
//     if (a.id != b.id) return false;
//     if (a.products.length != b.products.length) return false;
//     // Compare each product's id and quantity
//     for (int i = 0; i < a.products.length; i++) {
//       if (a.products[i].id != b.products[i].id) return false;
//       if (a.products[i].quantity != b.products[i].quantity) return false;
//     }
//     // Compare final amount (most important for price changes)
//     if (a.finalAmount != b.finalAmount) return false;
//     // Compare applied coupon id
//     if (a.appliedCouponId != b.appliedCouponId) return false;
//     return true;
//   }

//   // Load cart from API
//   Future<void> loadCart(String? userId) async {
//     if (_isLoading) return;

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Loading cart for user: $userId");
//       final cartResponse = await CartService.getCart(userId.toString());

//       CartModel? newCart = cartResponse?.cart;
//       AppliedCoupon? newAppliedCoupon = cartResponse?.appliedCoupon;

//       // Only update and notify if cart actually changed
//       if (!_isSameCart(_cart, newCart) || 
//           _appliedCoupon?.id != newAppliedCoupon?.id) {
//         _cart = newCart;
//         _appliedCoupon = newAppliedCoupon;
//         print("✅ Cart changed, notifying listeners");
        
//         if (newCart != null) {
//           _showToast('Cart loaded successfully', isInfo: true);
//         }
        
//         // Log coupon info if available
//         if (_cart?.appliedCouponInfo != null) {
//           print("✅ Applied coupon: ${_cart?.appliedCouponInfo?.couponCode} (${_cart?.appliedCouponInfo?.couponId})");
//         }
        
//         notifyListeners();
//       } else {
//         print("ℹ️ Cart unchanged, skipping notify");
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error loading cart: $e', isError: true);
//       print('❌ Error loading cart: $e');
//     } finally {
//       _setLoadingState(false);
//     }
//   }

//   // Add item to cart
//   Future<bool> addItemToCart({
//     required String restaurantProductId,
//     required String recommendedId,
//     required int quantity,
//     required String variation,
//     required int plateItems,
//     String? couponId,
//     String? userId,
//   }) async {
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Adding item to cart");

//       final lowerVar = variation.toLowerCase();
//       bool? isHalfPlate;
//       bool? isFullPlate;

//       if (lowerVar == 'half') {
//         isHalfPlate = true;
//       } else if (lowerVar == 'full') {
//         isFullPlate = true;
//       }

//       final request = AddToCartRequest(
//         products: [
//           CartProductRequest(
//             restaurantProductId: restaurantProductId,
//             recommendedId: recommendedId,
//             quantity: quantity,
//             addOn: CartAddOnRequest(
//               plateitems: plateItems,
//             ),
//             isHalfPlate: isHalfPlate,
//             isFullPlate: isFullPlate,
//           ),
//         ],
//         couponId: couponId ?? _appliedCoupon?.id,
//       );

//       final response = await CartService.addToCart(userId.toString(), request);

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message from API or default
//         final successMessage = response.message ?? 'Item added to cart successfully';
//         _showToast(successMessage);
        
//         print("✅ Item added successfully");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message from API
//         final errorMessage = response.message ?? 'Failed to add item';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to add item: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error adding item: $e', isError: true);
//       print('❌ Error adding item: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Increment item quantity
//   Future<bool> incrementQuantity(String cartProductId, String? userIdd) async {
//     if (_cart == null) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     final cartProduct = items.firstWhere(
//       (product) => product.id == cartProductId,
//       orElse: () => throw Exception('Product not found'),
//     );

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Incrementing quantity for: ${cartProduct.name}");
//       final response = await CartService.updateQuantity(
//         userId: userIdd.toString(),
//         restaurantProductId: cartProduct.restaurantProductId,
//         recommendedId: cartProduct.recommendedId,
//         action: 'inc',
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Quantity increased';
//         _showToast(successMessage);
        
//         print("✅ Quantity incremented");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to increase quantity';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to increment: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error increasing quantity: $e', isError: true);
//       print('❌ Error incrementing: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Decrement item quantity
//   Future<bool> decrementQuantity(String cartProductId, String? userIdd) async {
//     if (_cart == null) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     final cartProduct = items.firstWhere(
//       (product) => product.id == cartProductId,
//       orElse: () => throw Exception('Product not found'),
//     );

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Decrementing quantity for: ${cartProduct.name}");
//       final response = await CartService.updateQuantity(
//         userId: userIdd.toString(),
//         restaurantProductId: cartProduct.restaurantProductId,
//         recommendedId: cartProduct.recommendedId,
//         action: 'dec',
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Quantity decreased';
//         _showToast(successMessage);
        
//         print("✅ Quantity decremented");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to decrease quantity';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to decrement: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error decreasing quantity: $e', isError: true);
//       print('❌ Error decrementing: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Remove item from cart
//   Future<bool> removeItem(String cartProductId, String? usrIdd) async {
//     if (_cart == null) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     // Safely find the cartProduct
//     CartProduct? cartProduct;
//     try {
//       cartProduct = items.firstWhere((product) => product.id == cartProductId);
//     } catch (e) {
//       _error = 'Product not found';
//       _showToast('Product not found', isError: true);
//       print('❌ removeItem: product not found for id $cartProductId');
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Removing item: ${cartProduct.name}");
//       final response = await CartService.deleteCartProduct(
//         userId: usrIdd.toString(),
//         productId: cartProduct.restaurantProductId,
//         recommendedId: cartProduct.recommendedId,
//       );

//       if (response.success) {
//         // Show success message
//         final successMessage = response.message ?? 'Item removed from cart';
//         _showToast(successMessage);
        
//         // If server returned a complete cart, use it.
//         final returnedCart = response.cart;
//         final returnedProducts = returnedCart?.products;

//         if (returnedCart != null &&
//             (returnedProducts != null && returnedProducts.isNotEmpty)) {
//           _cart = returnedCart;
//           _appliedCoupon = response.appliedCoupon;
//           print("✅ Item removed (updated cart from response)");
//         } else {
//           // Fallback: re-fetch the cart from server to avoid showing empty state
//           print("⚠️ Response cart incomplete — reloading cart from server");
//           final reloadUserId = _userId.isNotEmpty ? _userId : usrIdd.toString();
//           await loadCart(reloadUserId);
//         }

//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to remove item';
//         _showToast(errorMessage, isError: true);
        
//         print("❌ Failed to remove: ${response.message}");
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error removing item: $e', isError: true);
//       print('❌ Error removing item: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Apply coupon
//   Future<bool> applyCoupon(String couponCode) async {
//     if (_cart == null || items.isEmpty) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Applying coupon: $couponCode");
      
//       // First validate coupon
//       final coupon = await CartService.validateCoupon(couponCode);

//       if (coupon == null) {
//         _error = 'Invalid coupon code';
//         _showToast('Invalid coupon code', isError: true);
//         _setLoadingState(false);
//         return false;
//       }

//       if (subtotal < coupon.minCartAmount) {
//         _error = 'Minimum cart amount of ₹${coupon.minCartAmount} required';
//         _showToast('Minimum cart amount of ₹${coupon.minCartAmount} required', isWarning: true);
//         _setLoadingState(false);
//         return false;
//       }

//       final currentProducts = items
//           .map((item) => CartProductRequest(
//                 restaurantProductId: item.restaurantProductId,
//                 recommendedId: item.recommendedId,
//                 quantity: item.quantity,
//                 addOn: CartAddOnRequest(
//                   plateitems: item.addOn.plateitems,
//                 ),
//               ))
//           .toList();

//       final response = await CartService.applyCoupon(
//         userId: _userId,
//         couponId: coupon.id,
//         currentProducts: currentProducts,
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Coupon applied successfully';
//         _showToast(successMessage);
        
//         print("✅ Coupon applied");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to apply coupon';
//         _showToast(errorMessage, isError: true);
        
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error applying coupon: $e', isError: true);
//       print('❌ Error applying coupon: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Remove coupon
//   Future<bool> removeCoupon() async {
//     if (_cart == null || items.isEmpty) {
//       _showToast('Cart is empty', isWarning: true);
//       return false;
//     }
    
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Removing coupon");
//       final currentProducts = items
//           .map((item) => CartProductRequest(
//                 restaurantProductId: item.restaurantProductId,
//                 recommendedId: item.recommendedId,
//                 quantity: item.quantity,
//                 addOn: CartAddOnRequest(
//                   plateitems: item.addOn.plateitems,
//                 ),
//               ))
//           .toList();

//       final response = await CartService.addToCart(
//         _userId,
//         AddToCartRequest(products: currentProducts),
//       );

//       if (response.success) {
//         _cart = response.cart;
//         _appliedCoupon = response.appliedCoupon;
        
//         // Show success message
//         final successMessage = response.message ?? 'Coupon removed successfully';
//         _showToast(successMessage);
        
//         print("✅ Coupon removed");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to remove coupon';
//         _showToast(errorMessage, isError: true);
        
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error removing coupon: $e', isError: true);
//       print('❌ Error removing coupon: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Clear cart
//   Future<bool> clearCart() async {
//     if (_isLoading) {
//       _showToast('Please wait...', isInfo: true);
//       return false;
//     }

//     _setLoadingState(true);
//     _error = null;

//     try {
//       print("🔄 Clearing cart");
//       final response = await CartService.clearCart(_userId);

//       if (response.success) {
//         _cart = null;
//         _appliedCoupon = null;
        
//         // Show success message
//         final successMessage = response.message ?? 'Cart cleared successfully';
//         _showToast(successMessage);
        
//         print("✅ Cart cleared");
//         notifyListeners();
//         _setLoadingState(false);
//         return true;
//       } else {
//         _error = response.message;
        
//         // Show error message
//         final errorMessage = response.message ?? 'Failed to clear cart';
//         _showToast(errorMessage, isError: true);
        
//         _setLoadingState(false);
//         return false;
//       }
//     } catch (e) {
//       _error = e.toString();
//       _showToast('Error clearing cart: $e', isError: true);
//       print('❌ Error clearing cart: $e');
//       _setLoadingState(false);
//       return false;
//     }
//   }

//   // Helper methods
//   CartProduct? getCartProduct(String recommendedId) {
//     return items
//         .where((item) => item.recommendedId == recommendedId)
//         .firstOrNull;
//   }

//   bool hasItem(String recommendedId) {
//     return items.any((item) => item.recommendedId == recommendedId);
//   }

//   int getItemQuantity(String recommendedId) {
//     final item = getCartProduct(recommendedId);
//     return item?.quantity ?? 0;
//   }

//   // Private helper with proper notification
//   void _setLoadingState(bool loading) {
//     if (_isLoading != loading) {
//       _isLoading = loading;
//       notifyListeners(); // This ensures UI updates when loading state changes
//     }
//   }

//   // Legacy support
//   List<CartItem> get legacyItems {
//     return items
//         .map((item) => CartItem(
//               id: item.id,
//               title: item.name,
//               image: item.image,
//               basePrice: item.basePrice,
//               variation: item.addOn.variation,
//               addOns: {'${item.addOn.plateitems} Plates'},
//               quantity: item.quantity,
//               isVeg: true,
//             ))
//         .toList();
//   }
// }

// // Legacy CartItem class
// class CartItem {
//   final String id;
//   final String title;
//   final String? image;
//   final double basePrice;
//   final String variation;
//   final Set<String> addOns;
//   final int quantity;
//   final bool isVeg;

//   CartItem({
//     required this.id,
//     required this.title,
//     this.image,
//     required this.basePrice,
//     required this.variation,
//     required this.addOns,
//     required this.quantity,
//     required this.isVeg,
//   });

//   double get totalPrice => basePrice * quantity;
// }










// provider/CartProvider/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:veegify/helper/toast_helper.dart';
import 'package:veegify/model/CartModel/cart_model.dart';
import 'package:veegify/services/CartService/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartModel? _cart;
  AppliedCoupon? _appliedCoupon;

  // Separate flags for first-time load vs background refresh
  bool _isLoading = false;        // true ONLY on the very first load (shows skeleton)
  bool _isRefreshing = false;     // true on background/polling refreshes (silent)
  String? _error;
  String _userId = '';

  // Toast callback for custom toast handling
  Function(String message, {bool isError, bool isWarning, bool isInfo})?
      onShowToast;

  // ── Getters ───────────────────────────────────────────────────────────────
  CartModel? get cart => _cart;
  AppliedCoupon? get appliedCoupon => _appliedCoupon;

  /// True only on the very first load when there is no data yet.
  /// Background polling refreshes do NOT set this — no skeleton flash.
  bool get isLoading => _isLoading;

  /// True during any background refresh (polling / manual pull-to-refresh).
  bool get isRefreshing => _isRefreshing;

  String? get error => _error;

  List<CartProduct> get items => _cart?.products ?? [];
  int get totalItems => _cart?.totalItems ?? 0;

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

  // Coupon info from chargeCalculations
  String? get appliedCouponId => _cart?.appliedCouponId;
  String? get appliedCouponCode => _cart?.appliedCouponCode;
  CouponDiscountInfo? get appliedCouponInfo => _cart?.appliedCouponInfo;
  bool get hasAppliedCoupon =>
      appliedCouponId != null && appliedCouponId!.isNotEmpty;

  bool get hasInactiveProducts => items.any((p) => !p.isProductActive);

  bool get isVendorActive {
    if (!hasItems) return true;
    return items.every((p) => p.isVendorActive);
  }

  // ── Toast ─────────────────────────────────────────────────────────────────
  void setToastCallback(
      Function(String message,
              {bool isError, bool isWarning, bool isInfo})
          callback) {
    onShowToast = callback;
  }

  void _showToast(
    String message, {
    bool isError = false,
    bool isWarning = false,
    bool isInfo = false,
  }) {
    if (onShowToast != null) {
      onShowToast!(message,
          isError: isError, isWarning: isWarning, isInfo: isInfo);
    } else {
      if (isError) {
        ToastHelper.showErrorToast(message);
      } else if (isWarning) {
        ToastHelper.showWarningToast(message);
      } else if (isInfo) {
        ToastHelper.showInfoToast(message);
      } else {
        ToastHelper.showSuccessToast(message);
      }
    }
  }

  // ── User ID ───────────────────────────────────────────────────────────────
  void setUserId(String userId) {
    if (_userId != userId) {
      _userId = userId;
      notifyListeners();
    }
  }

  // ── Cart equality check ───────────────────────────────────────────────────
  bool _isSameCart(CartModel? a, CartModel? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.id != b.id) return false;
    if (a.products.length != b.products.length) return false;
    for (int i = 0; i < a.products.length; i++) {
      if (a.products[i].id != b.products[i].id) return false;
      if (a.products[i].quantity != b.products[i].quantity) return false;
    }
    if (a.finalAmount != b.finalAmount) return false;
    if (a.appliedCouponId != b.appliedCouponId) return false;
    return true;
  }

  // ── Load cart ─────────────────────────────────────────────────────────────
  // • If we have NO data yet  → sets isLoading = true  (shows skeleton)
  // • If we already have data → sets isRefreshing = true (silent, no flicker)
  Future<void> loadCart(String? userId) async {
    // Prevent concurrent loads
    if (_isLoading || _isRefreshing) return;

    final bool firstLoad = !hasItems;

    if (firstLoad) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    } else {
      _isRefreshing = true;
      // Don't notify here — no need to redraw just for a silent refresh flag
    }

    try {
      debugPrint('🔄 loadCart — userId: $userId  firstLoad: $firstLoad');
      final cartResponse =
          await CartService.getCart(userId.toString());

      final CartModel? newCart = cartResponse?.cart;
      final AppliedCoupon? newCoupon = cartResponse?.appliedCoupon;

      // Only rebuild UI if something actually changed
      if (!_isSameCart(_cart, newCart) ||
          _appliedCoupon?.id != newCoupon?.id) {
        _cart = newCart;
        _appliedCoupon = newCoupon;

        debugPrint('✅ Cart changed — notifying listeners');
        if (_cart?.appliedCouponInfo != null) {
          debugPrint(
              '✅ Coupon: ${_cart?.appliedCouponInfo?.couponCode}');
        }
        notifyListeners();
      } else {
        debugPrint('ℹ️ Cart unchanged — skipping notify');
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ loadCart error: $e');
      // Only show error toast on first load; polling failures are silent
      if (firstLoad) {
        _showToast('Error loading cart: $e', isError: true);
        notifyListeners();
      }
    } finally {
      if (firstLoad) {
        _isLoading = false;
      } else {
        _isRefreshing = false;
      }
      notifyListeners();
    }
  }

  // ── Add item ──────────────────────────────────────────────────────────────
  Future<bool> addItemToCart({
    required String restaurantProductId,
    required String recommendedId,
    required int quantity,
    required String variation,
    required int plateItems,
    String? couponId,
    String? userId,
  }) async {
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    _setMutating(true);

    try {
      debugPrint('🔄 addItemToCart');

      final lowerVar = variation.toLowerCase();
      bool? isHalfPlate;
      bool? isFullPlate;

      if (lowerVar == 'half') {
        isHalfPlate = true;
      } else if (lowerVar == 'full') {
        isFullPlate = true;
      }

      final request = AddToCartRequest(
        products: [
          CartProductRequest(
            restaurantProductId: restaurantProductId,
            recommendedId: recommendedId,
            quantity: quantity,
            addOn: CartAddOnRequest(plateitems: plateItems),
            isHalfPlate: isHalfPlate,
            isFullPlate: isFullPlate,
          ),
        ],
        couponId: couponId ?? _appliedCoupon?.id,
      );

      final response =
          await CartService.addToCart(userId.toString(), request);

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        _showToast(response.message ?? 'Item added to cart successfully');
        debugPrint('✅ addItemToCart success');
        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to add item', isError: true);
        debugPrint('❌ addItemToCart failed: ${response.message}');
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error adding item: $e', isError: true);
      debugPrint('❌ addItemToCart exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Increment quantity ────────────────────────────────────────────────────
  Future<bool> incrementQuantity(
      String cartProductId, String? userIdd) async {
    if (_cart == null) {
      _showToast('Cart is empty', isWarning: true);
      return false;
    }
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    final cartProduct = items.firstWhere(
      (p) => p.id == cartProductId,
      orElse: () => throw Exception('Product not found'),
    );

    _setMutating(true);

    try {
      debugPrint('🔄 incrementQuantity: ${cartProduct.name}');
      final response = await CartService.updateQuantity(
        userId: userIdd.toString(),
        restaurantProductId: cartProduct.restaurantProductId,
        recommendedId: cartProduct.recommendedId,
        action: 'inc',
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        _showToast(response.message ?? 'Quantity increased');
        debugPrint('✅ incrementQuantity success');
        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to increase quantity',
            isError: true);
        debugPrint('❌ incrementQuantity failed: ${response.message}');
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error increasing quantity: $e', isError: true);
      debugPrint('❌ incrementQuantity exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Decrement quantity ────────────────────────────────────────────────────
  Future<bool> decrementQuantity(
      String cartProductId, String? userIdd) async {
    if (_cart == null) {
      _showToast('Cart is empty', isWarning: true);
      return false;
    }
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    final cartProduct = items.firstWhere(
      (p) => p.id == cartProductId,
      orElse: () => throw Exception('Product not found'),
    );

    _setMutating(true);

    try {
      debugPrint('🔄 decrementQuantity: ${cartProduct.name}');
      final response = await CartService.updateQuantity(
        userId: userIdd.toString(),
        restaurantProductId: cartProduct.restaurantProductId,
        recommendedId: cartProduct.recommendedId,
        action: 'dec',
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        _showToast(response.message ?? 'Quantity decreased');
        debugPrint('✅ decrementQuantity success');
        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to decrease quantity',
            isError: true);
        debugPrint('❌ decrementQuantity failed: ${response.message}');
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error decreasing quantity: $e', isError: true);
      debugPrint('❌ decrementQuantity exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Remove item ───────────────────────────────────────────────────────────
  Future<bool> removeItem(String cartProductId, String? usrIdd) async {
    if (_cart == null) {
      _showToast('Cart is empty', isWarning: true);
      return false;
    }
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    CartProduct? cartProduct;
    try {
      cartProduct =
          items.firstWhere((p) => p.id == cartProductId);
    } catch (_) {
      _error = 'Product not found';
      _showToast('Product not found', isError: true);
      debugPrint('❌ removeItem: product not found for id $cartProductId');
      return false;
    }

    _setMutating(true);

    try {
      debugPrint('🔄 removeItem: ${cartProduct.name}');
      final response = await CartService.deleteCartProduct(
        userId: usrIdd.toString(),
        productId: cartProduct.restaurantProductId,
        recommendedId: cartProduct.recommendedId,
      );

      if (response.success) {
        _showToast(response.message ?? 'Item removed from cart');

        final returnedCart = response.cart;
        final returnedProducts = returnedCart?.products;

        if (returnedCart != null &&
            returnedProducts != null &&
            returnedProducts.isNotEmpty) {
          _cart = returnedCart;
          _appliedCoupon = response.appliedCoupon;
          debugPrint('✅ removeItem — updated cart from response');
        } else {
          // Server returned empty/null cart — reload to get true state
          debugPrint(
              '⚠️ removeItem — response cart incomplete, reloading');
          _setMutating(false);
          final reloadId =
              _userId.isNotEmpty ? _userId : usrIdd.toString();
          await loadCart(reloadId);
          return true;
        }

        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to remove item',
            isError: true);
        debugPrint('❌ removeItem failed: ${response.message}');
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error removing item: $e', isError: true);
      debugPrint('❌ removeItem exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Apply coupon ──────────────────────────────────────────────────────────
  Future<bool> applyCoupon(String couponCode) async {
    if (_cart == null || items.isEmpty) {
      _showToast('Cart is empty', isWarning: true);
      return false;
    }
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    _setMutating(true);

    try {
      debugPrint('🔄 applyCoupon: $couponCode');

      final coupon = await CartService.validateCoupon(couponCode);

      if (coupon == null) {
        _error = 'Invalid coupon code';
        _showToast('Invalid coupon code', isError: true);
        _setMutating(false);
        return false;
      }

      if (subtotal < coupon.minCartAmount) {
        _error =
            'Minimum cart amount of ₹${coupon.minCartAmount} required';
        _showToast(
            'Minimum cart amount of ₹${coupon.minCartAmount} required',
            isWarning: true);
        _setMutating(false);
        return false;
      }

      final currentProducts = items
          .map((item) => CartProductRequest(
                restaurantProductId: item.restaurantProductId,
                recommendedId: item.recommendedId,
                quantity: item.quantity,
                addOn: CartAddOnRequest(plateitems: item.addOn.plateitems),
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
        _showToast(response.message ?? 'Coupon applied successfully');
        debugPrint('✅ applyCoupon success');
        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to apply coupon',
            isError: true);
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error applying coupon: $e', isError: true);
      debugPrint('❌ applyCoupon exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Remove coupon ─────────────────────────────────────────────────────────
  Future<bool> removeCoupon() async {
    if (_cart == null || items.isEmpty) {
      _showToast('Cart is empty', isWarning: true);
      return false;
    }
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    _setMutating(true);

    try {
      debugPrint('🔄 removeCoupon');

      final currentProducts = items
          .map((item) => CartProductRequest(
                restaurantProductId: item.restaurantProductId,
                recommendedId: item.recommendedId,
                quantity: item.quantity,
                addOn: CartAddOnRequest(plateitems: item.addOn.plateitems),
              ))
          .toList();

      final response = await CartService.addToCart(
        _userId,
        AddToCartRequest(products: currentProducts),
      );

      if (response.success) {
        _cart = response.cart;
        _appliedCoupon = response.appliedCoupon;
        _showToast(response.message ?? 'Coupon removed successfully');
        debugPrint('✅ removeCoupon success');
        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to remove coupon',
            isError: true);
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error removing coupon: $e', isError: true);
      debugPrint('❌ removeCoupon exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Clear cart ────────────────────────────────────────────────────────────
  Future<bool> clearCart() async {
    if (_isLoading) {
      _showToast('Please wait...', isInfo: true);
      return false;
    }

    _setMutating(true);

    try {
      debugPrint('🔄 clearCart');
      final response = await CartService.clearCart(_userId);

      if (response.success) {
        _cart = null;
        _appliedCoupon = null;
        _showToast(response.message ?? 'Cart cleared successfully');
        debugPrint('✅ clearCart success');
        notifyListeners();
        _setMutating(false);
        return true;
      } else {
        _error = response.message;
        _showToast(response.message ?? 'Failed to clear cart',
            isError: true);
        _setMutating(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _showToast('Error clearing cart: $e', isError: true);
      debugPrint('❌ clearCart exception: $e');
      _setMutating(false);
      return false;
    }
  }

  // ── Helper getters ────────────────────────────────────────────────────────
  CartProduct? getCartProduct(String recommendedId) =>
      items.where((i) => i.recommendedId == recommendedId).firstOrNull;

  bool hasItem(String recommendedId) =>
      items.any((i) => i.recommendedId == recommendedId);

  int getItemQuantity(String recommendedId) =>
      getCartProduct(recommendedId)?.quantity ?? 0;

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Used for mutation operations (add/remove/increment/decrement/coupon).
  /// Re-uses _isLoading so the skeleton is shown only when there is no data.
  /// When cart already has items, mutations are effectively silent spinners
  /// handled at widget level (button disabled states etc.).
  void _setMutating(bool value) {
    // Only set _isLoading if we have no data — otherwise stay silent
    final flag = !hasItems ? value : false;
    if (_isLoading != flag) {
      _isLoading = flag;
      notifyListeners();
    }
  }

  // ── Legacy support ────────────────────────────────────────────────────────
  List<CartItem> get legacyItems => items
      .map((item) => CartItem(
            id: item.id,
            title: item.name,
            image: item.image,
            basePrice: item.basePrice,
            variation: item.addOn.variation,
            addOns: {'${item.addOn.plateitems} Plates'},
            quantity: item.quantity,
            isVeg: true,
          ))
      .toList();
}

// ── Legacy CartItem ───────────────────────────────────────────────────────
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