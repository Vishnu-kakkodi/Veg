import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:veegify/constants/api.dart';
import 'package:veegify/model/category_model.dart'; 


class CategoryService {
  Future<Map<String, dynamic>> fetchCategory() async {
    try {
      final url = Uri.parse(ApiConstants.category);

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print("Responseeeeeeeeeeeeeeeeeeeeeeee:${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Something went wrong: $e');
    }
  }
}
