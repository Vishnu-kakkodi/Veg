import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/model/wishlist_model.dart';

class WishlistService {
  static const String baseUrl = "https://api.vegiffyy.com/api";

  // Toggle wishlist (add/remove)
  static Future<bool> toggleWishlist(String userId, String productId) async {
    final url = Uri.parse("$baseUrl/wishlist/$userId");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"productId": productId}),
    );

    print("Response Printin Toggle wishliast: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["isInWishlist"] ?? false;
    } else {
      throw Exception(
        "Failed to toggle wishlist: ${response.statusCode} ${response.body}",
      );
    }
  }

  // Get full wishlist
  static Future<List<WishlistProduct>> getWishlist(String userId) async {
    print("khhsshhjlhljhlhlhhafhhaskhsklfhsakfhsjkl$userId");
    final url = Uri.parse("$baseUrl/wishlist/$userId");
    print(url);
    final response = await http.get(url);
print("Responseeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee; ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["wishlist"] is List) {
        return (data["wishlist"] as List)
            .map((json) => WishlistProduct.fromJson(json))
            .toList();
      } else {
        throw Exception("Invalid wishlist format");
      }
    } else {
      throw Exception(
        "Failed to fetch wishlist: ${response.statusCode} ${response.body}",
      );
    }
  }

  // Get a single product (used after toggling wishlist)
  static Future<WishlistProduct> getProduct(String productId) async {
    final url = Uri.parse("$baseUrl/products/$productId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return WishlistProduct.fromJson(data);
    } else {
      throw Exception(
        "Failed to fetch product: ${response.statusCode} ${response.body}",
      );
    }
  }
}
