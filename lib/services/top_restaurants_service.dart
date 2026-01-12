import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/model/nearby_restaurants_model.dart';

class TopRestaurantsService {
  static const String baseUrl = 'https://api.vegiffyy.com/api/top-nearby';

  static Future<List<NearbyRestaurantModel>> fetchTopNearbyRestaurants(String userId) async {
    final url = Uri.parse('$baseUrl/$userId');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] == true) {
        List<dynamic> restaurants = data['data'];
        return restaurants
            .map((json) => NearbyRestaurantModel.fromJson(json))
            .toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load restaurants');
      }
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
}
