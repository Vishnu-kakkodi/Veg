

// // services/cart_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:veegify/model/CartModel/cart_model.dart';

// class CartService {
//   static const String baseUrl = 'http://31.97.206.144:5051/api';
  
//   // Get cart by user ID
//   static Future<CartResponse?> getCart(String userId) async {
//     try {
//       print("Cart Printing UserId: $userId");
//       final response = await http.get(
//         Uri.parse('$baseUrl/cart/user/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       print('Get Cart Response Status: ${response.statusCode}');
//       print('Get Cart Response Body: ${response.body}');

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
        
//         // Check for 'data' field in API response
//         if (data['success'] == true && data['data'] != null) {
//           // Your API returns cart data under 'data' key, map it to 'cart' for CartResponse
//           final cartResponseData = {
//             'success': data['success'],
//             'message': data['message'] ?? '',
//             'distanceKm': data['distanceKm'] ?? 0.0,
//             'cart': data['data'], // Map API 'data' to model 'cart'
//             'appliedCoupon': data['appliedCoupon']
//           };
//           return CartResponse.fromJson(cartResponseData);
//         } else {
//           print('Cart not found or empty');
//           return null;
//         }
//       } else if (response.statusCode == 404) {
//         // Cart doesn't exist yet
//         print('Cart not found (404)');
//         return null;
//       } else {
//         throw Exception('Failed to get cart: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error getting cart: $e');
//       throw Exception('Failed to get cart: $e');
//     }
//   }

//   // Add items to cart (or update existing cart)
//   static Future<CartResponse> updateCart(String userId, AddToCartRequest request) async {
//     try {
//       final url = Uri.parse('$baseUrl/cart/$userId');
//       final payload = json.encode(request.toJson());

//       // Debug logs before API call
//       print("🔹 API URL: $url");
//       print("🔹 Request Headers: { 'Content-Type': 'application/json' }");
//       print("🔹 Request Payload: $payload");

//       final response = await http.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: payload,
//       );

//       print('Update Cart Response Status: ${response.statusCode}');
//       print('Update Cart Response Body: ${response.body}');

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         return CartResponse.fromJson(data);
//       } else {
//         final Map<String, dynamic> errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to update cart');
//       }
//     } catch (e) {
//       print('Error updating cart: $e');
//       throw Exception('Failed to update cart: $e');
//     }
//   }

//   // Add single item to cart
//   static Future<CartResponse> addItemToCart({
//     required String userId,
//     required String restaurantProductId,
//     required String recommendedId,
//     required int quantity,
//     required String variation,
//     required int plateItems,
//     String? couponId,
//     bool clearExisting = false,
//   }) async {
//     print("Restaurant ProductId: $restaurantProductId");
//     print("Recommended ProductId: $recommendedId");

//     final request = AddToCartRequest(
//       clearExisting: clearExisting,
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
//       couponId: couponId,
//     );

//     return await updateCart(userId, request);
//   }

//   // Update item quantity in cart
//   static Future<CartResponse> updateItemQuantity({
//     required String userId,
//     required String restaurantProductId,
//     required String recommendedId,
//     required int newQuantity,
//     required String variation,
//     required int plateItems,
//     String? couponId,
//   }) async {
//     final request = AddToCartRequest(
//       clearExisting: false,
//       products: [
//         CartProductRequest(
//           restaurantProductId: restaurantProductId,
//           recommendedId: recommendedId,
//           quantity: newQuantity,
//           addOn: CartAddOnRequest(
//             variation: variation,
//             plateitems: plateItems,
//           ),
//         ),
//       ],
//       couponId: couponId,
//     );

//     return await updateCart(userId, request);
//   }

//   // Remove item from cart (set quantity to 0)
//   static Future<CartResponse> removeItemFromCart({
//     required String userId,
//     required String restaurantProductId,
//     required String recommendedId,
//     required String variation,
//     required int plateItems,
//     String? couponId,
//   }) async {
//     final request = AddToCartRequest(
//       clearExisting: false,
//       products: [
//         CartProductRequest(
//           restaurantProductId: restaurantProductId,
//           recommendedId: recommendedId,
//           quantity: 0, // Setting quantity to 0 to remove item
//           addOn: CartAddOnRequest(
//             variation: variation,
//             plateitems: plateItems,
//           ),
//         ),
//       ],
//       couponId: couponId,
//     );

//     return await updateCart(userId, request);
//   }

//   // Apply coupon to cart
//   static Future<CartResponse> applyCoupon({
//     required String userId,
//     required String couponId,
//     required List<CartProductRequest> currentProducts,
//   }) async {
//     final request = AddToCartRequest(
//       clearExisting: false,
//       products: currentProducts,
//       couponId: couponId,
//     );

//     return await updateCart(userId, request);
//   }

//   // Clear entire cart
//   static Future<CartResponse> clearCart(String userId) async {
//     final request = AddToCartRequest(
//       clearExisting: true,
//       products: [], // Empty products array to clear cart
//     );

//     return await updateCart(userId, request);
//   }

//   // Get available coupons (if you have this endpoint)
//   static Future<List<AppliedCoupon>> getAvailableCoupons() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/coupons'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         final List<dynamic> couponsData = data['coupons'] ?? [];
        
//         return couponsData
//             .map((coupon) => AppliedCoupon.fromJson(coupon))
//             .toList();
//       } else {
//         throw Exception('Failed to get coupons: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error getting coupons: $e');
//       return [];
//     }
//   }

//   // Validate coupon code
//   static Future<AppliedCoupon?> validateCoupon(String couponCode) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/coupon/validate/$couponCode'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data['success'] == true && data['coupon'] != null) {
//           return AppliedCoupon.fromJson(data['coupon']);
//         }
//       }
//       return null;
//     } catch (e) {
//       print('Error validating coupon: $e');
//       return null;
//     }
//   }
// }











// services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/model/CartModel/cart_model.dart';

class CartService {
  static const String baseUrl = 'http://31.97.206.144:5051/api';

  // Get cart by user ID
  static Future<CartResponse?> getCart(String userId) async {
    try {
      print("🔹 Getting cart for userId: $userId");
      final response = await http.get(
        Uri.parse('$baseUrl/cart/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('✅ Get Cart Status: ${response.statusCode}');
      print('📦 Get Cart Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final cartResponseData = {
            'success': data['success'],
            'message': data['message'] ?? '',
            'distanceKm': data['distanceKm'] ?? 0.0,
            'cart': data['data'],
            'appliedCoupon': data['appliedCoupon'],
            'couponDiscount': data['couponDiscount'] ?? 0,
          };
          return CartResponse.fromJson(cartResponseData);
        } else {
          print('ℹ️ Cart is empty or not found');
          return null;
        }
      } else if (response.statusCode == 404) {
        print('ℹ️ Cart not found (404)');
        return null;
      } else {
        throw Exception('Failed to get cart: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting cart: $e');
      rethrow;
    }
  }

  // Add items to cart
  static Future<CartResponse> addToCart(
      String userId, AddToCartRequest request) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$userId');
      final payload = json.encode(request.toJson());

      print("🔹 Adding to cart");
      print("🔹 URL: $url");
      print("🔹 Payload: $payload");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      print('✅ Add to Cart Status: ${response.statusCode}');
      print('📦 Add to Cart Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CartResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add to cart');
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      rethrow;
    }
  }

  // Update item quantity using new endpoint
  static Future<CartResponse> updateQuantity({
    required String userId,
    required String restaurantProductId,
    required String recommendedId,
    required String action, // "inc" or "dec"
  }) async {
    try {
      print("llllllllllllllllllllllllllll$userId");
      final url = Uri.parse('$baseUrl/update-quantity/$userId');
      final request = UpdateQuantityRequest(
        restaurantProductId: restaurantProductId,
        recommendedId: recommendedId,
        action: action,
      );
      final payload = json.encode(request.toJson());

      print("🔹 Updating quantity");
      print("🔹 URL: $url");
      print("🔹 Action: $action");
      print("🔹 Payload: $payload");

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      );

      print('✅ Update Quantity Status: ${response.statusCode}');
      print('📦 Update Quantity Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CartResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update quantity');
      }
    } catch (e) {
      print('❌ Error updating quantity: $e');
      rethrow;
    }
  }

  // Delete item from cart using new endpoint
  static Future<CartResponse> deleteCartProduct({
    required String userId,
    required String productId,
    required String recommendedId,
  }) async {
    print("UserId:$userId");
        print("UserId:$productId");

    print("UserId:$recommendedId");

    try {
      final url = Uri.parse(
          '$baseUrl/deletecartproduct/$userId/$productId/$recommendedId');

      print("🔹 Deleting cart product");
      print("🔹 URL: $url");

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('✅ Delete Product Status: ${response.statusCode}');
      print('📦 Delete Product Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return CartResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      print('❌ Error deleting product: $e');
      rethrow;
    }
  }

  // Apply coupon
  static Future<CartResponse> applyCoupon({
    required String userId,
    required String couponId,
    required List<CartProductRequest> currentProducts,
  }) async {
    final request = AddToCartRequest(
      products: currentProducts,
      couponId: couponId,
    );

    return await addToCart(userId, request);
  }

  // Clear entire cart
  static Future<CartResponse> clearCart(String userId) async {
    final request = AddToCartRequest(products: []);
    return await addToCart(userId, request);
  }

  // Validate coupon code
  static Future<AppliedCoupon?> validateCoupon(String couponCode) async {
    try {
      print("🔹 Validating coupon: $couponCode");
      final response = await http.get(
        Uri.parse('$baseUrl/coupon/validate/$couponCode'),
        headers: {'Content-Type': 'application/json'},
      );

      print('✅ Validate Coupon Status: ${response.statusCode}');
      print('📦 Validate Coupon Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['coupon'] != null) {
          return AppliedCoupon.fromJson(data['coupon']);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error validating coupon: $e');
      return null;
    }
  }

  // Get available coupons
  static Future<List<AppliedCoupon>> getAvailableCoupons() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/coupons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> couponsData = data['coupons'] ?? [];

        return couponsData
            .map((coupon) => AppliedCoupon.fromJson(coupon))
            .toList();
      } else {
        throw Exception('Failed to get coupons: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting coupons: $e');
      return [];
    }
  }
}