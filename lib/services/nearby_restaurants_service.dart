import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:veegify/constants/api.dart';
import 'package:veegify/model/nearby_restaurants_model.dart';

class RestaurantService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  static Future<List<NearbyRestaurantModel>> fetchNearbyRestaurants(String userId) async {
    print("UserId: $userId");
    final Uri url = Uri.parse('$_baseUrl/nearby/$userId');
    print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk$url");

    try {
      print(url);
      final http.Response response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          final List<dynamic> restaurants = data['data'];
          return restaurants
              .map((json) => NearbyRestaurantModel.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to load nearby restaurants.');
        }
      } else {
        throw HttpException('Server responded with status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again later.');
    } on FormatException {
      throw Exception('Bad response format from server.');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
