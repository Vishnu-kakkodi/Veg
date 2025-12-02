import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/constants/api.dart';

class RestaurantReviewService {
  static const String _baseUrl = ApiConstants.baseUrl;

  // EDIT review
  static Future<bool> editRestaurantReview({
    required String restaurantId,
    required String userId,
    required String reviewId,
    required int stars,
    required String comment,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/editrestureview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "restaurantId": restaurantId,
          "userId": userId,
          "stars": stars,
          "comment": comment,
          "reviewId": reviewId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // DELETE review
  static Future<bool> deleteRestaurantReview({
    required String restaurantId,
    required String userId,
    required String reviewId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/deleterestureview'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "restaurantId": restaurantId,
          "userId": userId,
          "reviewId": reviewId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
