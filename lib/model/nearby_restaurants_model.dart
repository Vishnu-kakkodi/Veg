// class NearbyRestaurantModel {
//   final String id;
//   final String restaurantName;
//   final String description;
//   final String imageUrl;
//   final double rating; // ✅ use double for flexibility
//   final dynamic startingPrice;
//   final String locationName;
//   final String status;

//   NearbyRestaurantModel({
//     required this.id,
//     required this.restaurantName,
//     required this.description,
//     required this.imageUrl,
//     required this.rating,
//     required this.startingPrice,
//     required this.locationName,
//     required this.status
//   });

//   factory NearbyRestaurantModel.fromJson(Map<String, dynamic> json) {
//     return NearbyRestaurantModel(
//       id: json['_id'],
//       restaurantName: json['restaurantName'],
//       description: json['description'],
//       imageUrl: json['image']['url'],
//       rating: (json['rating'] is int) 
//           ? (json['rating'] as int).toDouble() 
//           : (json['rating'] as num).toDouble(), // ✅ handles both int & double
//       startingPrice: json['startingPrice'],
//       locationName:  json['locationName'],
//       status: json['status'] ?? ""
//     );
//   }
// }

















class NearbyRestaurantModel {
  final String id;
  final String restaurantName;
  final String description;
  final String imageUrl;
  final double rating; // ✅ use double for flexibility
  final dynamic startingPrice;
  final String locationName;
  final String status;

  NearbyRestaurantModel({
    required this.id,
    required this.restaurantName,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.startingPrice,
    required this.locationName,
    required this.status,
  });

  factory NearbyRestaurantModel.fromJson(Map<String, dynamic> json) {
    double _toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    String image = '';
    if (json['image'] is Map) {
      image = json['image']['url']?.toString() ?? '';
    }

    return NearbyRestaurantModel(
      id: json['_id']?.toString() ?? '',
      restaurantName: json['restaurantName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: image,
      rating: _toDouble(json['rating']),
      startingPrice: json['startingPrice'],
      locationName: json['locationName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
