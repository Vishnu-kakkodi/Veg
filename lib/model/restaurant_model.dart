// class RestaurantModel {
//   final String imagePath;
//   final String name;
//   final double rating;
//   final String description;
//   final int price;

//   const RestaurantModel({
//     required this.imagePath,
//     required this.name,
//     required this.rating,
//     required this.description,
//     required this.price,
//   });
// }

















class RestaurantModel {
  final String imagePath;
  final String name;
  final double rating;
  final String description;
  final int price;

  const RestaurantModel({
    required this.imagePath,
    required this.name,
    required this.rating,
    required this.description,
    required this.price,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      imagePath: json['imagePath']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '') ?? 0.0,
      description: json['description']?.toString() ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toInt()
          : int.tryParse(json['price']?.toString() ?? '') ?? 0,
    );
  }
}

