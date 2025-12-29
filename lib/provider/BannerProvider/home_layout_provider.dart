import 'package:flutter/material.dart';
import 'package:veegify/model/Home/home_section.dart';

class HomeLayoutProvider extends ChangeNotifier {
  dynamic? heroVideo;
  List<HomeSection> sections = [];
  bool isLoading = false;

  Future<void> fetchHomeLayout() async {
    isLoading = true;
    notifyListeners();

    // 🔥 Simulated API response (replace with real API)
    final response = {
      "heroVideo":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "sections": [
        {
          "type": "ad_banner",
          "data": {
            "image":
                "https://cdn.example.com/weekend_offer.png",
          }
        },
        {
          "type": "horizontal_cards",
          "title": "Weekend Specials",
          "data": [
            {
              "id": "1",
              "title": "Biriyani Fest",
              "image":
                  "https://cdn.example.com/biriyani.png"
            }
          ]
        },
        { "type": "nearby_restaurants" },
        { "type": "top_restaurants" }
      ]
    };

    heroVideo = response['heroVideo'];

    sections = (response['sections'] as List)
        .map((e) => HomeSection.fromJson(e))
        .toList();

    isLoading = false;
    notifyListeners();
  }
}
