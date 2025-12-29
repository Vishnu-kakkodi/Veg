class HomeSection {
  final String type;
  final String? title;
  final dynamic data;

  HomeSection({
    required this.type,
    this.title,
    this.data,
  });

  factory HomeSection.fromJson(Map<String, dynamic> json) {
    return HomeSection(
      type: json['type'],
      title: json['title'],
      data: json['data'],
    );
  }
}
