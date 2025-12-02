import 'dart:convert';

import 'package:veegify/model/restaurant_product_model.dart';
import 'package:http/http.dart' as http;

class RestaurantService {
  static const String _baseUrl = 'http://31.97.206.144:5051/api';

  static Future<RestaurantProductResponse> getRestaurantProducts(String restaurantId, String? categoryName) async {
    try {
      print("lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll$restaurantId");
            print("lllllllllllllllllllllllllllllllllllllllllllllllllllllllllllllll$categoryName");

      final String endpoint;
     if(categoryName ==" " || categoryName == null){
      endpoint = '$_baseUrl/restaurant-products/$restaurantId';
     }else{
       endpoint = '$_baseUrl/restaurant-products/$restaurantId?categoryName=$categoryName';
     }

     print(endpoint);

            final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
      );

      print("Response ${response.statusCode} → ${response.body}");

      if (response.statusCode == 200) {
        return RestaurantProductResponse.fromJson(json.decode(response.body));
      }

      if (response.statusCode == 404) {
        return RestaurantProductResponse(
          success: false,
          message: "No products found",
          recommendedProducts: [],
          totalRecommendedItems: 0,
        );
      }

      return RestaurantProductResponse(
        success: false,
        message: "Server error",
        recommendedProducts: [],
        totalRecommendedItems: 0,
      );
    } catch (e) {
      return RestaurantProductResponse(
        success: false,
        message: "Request failed",
        recommendedProducts: [],
        totalRecommendedItems: 0,
      );
    }
  }
}
