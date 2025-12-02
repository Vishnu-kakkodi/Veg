class ApiConstants {
  static const String baseUrl = 'http://31.97.206.144:5051/api';

  // Auth Endpoints
  static const String register = '$baseUrl/register';

  // Category Endpoints
  static const String category = '$baseUrl/category';

  // Location Endpoint
  static String location(String userId) => '$baseUrl/location/$userId';
}
