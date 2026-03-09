import 'dart:convert';
import 'package:veegify/model/restaurant_product_model.dart';
import 'package:http/http.dart' as http;

class RestaurantService {
  static const String _baseUrl = 'https://api.vegiffyy.com/api';

  static Future<RestaurantProductResponse> getRestaurantProducts(String restaurantId, String? categoryName) async {
    try {
      print("🆔 Restaurant ID: $restaurantId");
      print("📁 Category Name: $categoryName");

      final String endpoint;
      if(categoryName == null || categoryName.isEmpty || categoryName == " "){
        endpoint = '$_baseUrl/restaurant-products/$restaurantId';
      } else {
        endpoint = '$_baseUrl/restaurant-products/$restaurantId?categoryName=$categoryName';
      }

      print("🔗 Endpoint: $endpoint");

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      print("📥 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Log the new fields to verify they exist
        print("✅ fssaiNo: ${jsonData['fssaiNo']}");
        print("✅ fullAddress: ${jsonData['fullAddress']}");
        print("✅ disclaimers: ${jsonData['disclaimers']}");
        
        return RestaurantProductResponse.fromJson(jsonData);
      }

      if (response.statusCode == 404) {
        print("❌ 404 - No products found");
        return RestaurantProductResponse(
          success: false,
          message: "No products found",
          recommendedProducts: [],
          totalRecommendedItems: 0,
        );
      }

      print("❌ Server error: ${response.statusCode}");
      return RestaurantProductResponse(
        success: false,
        message: "Server error",
        recommendedProducts: [],
        totalRecommendedItems: 0,
      );
    } catch (e, stackTrace) {
      print("🔥 Exception: $e");
      print("📚 Stack trace: $stackTrace");
      return RestaurantProductResponse(
        success: false,
        message: "Request failed",
        recommendedProducts: [],
        totalRecommendedItems: 0,
      );
    }
  }
}