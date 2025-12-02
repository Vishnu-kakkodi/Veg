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
}
