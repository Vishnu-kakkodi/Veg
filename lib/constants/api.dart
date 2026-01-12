class ApiConstants {
  static const String baseUrl = 'https://api.vegiffyy.com/api';

  // Auth Endpoints
  static const String register = '$baseUrl/register';

  // Category Endpoints
  static const String category = '$baseUrl/category';

  // Location Endpoint
  static String location(String userId) => '$baseUrl/location/$userId';
}
