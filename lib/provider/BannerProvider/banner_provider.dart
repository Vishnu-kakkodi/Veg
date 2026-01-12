import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../model/banner_model.dart';

class BannerProvider with ChangeNotifier {
  List<BannerModel> _banners = [];
  bool _isLoading = false;

  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;

  Future<void> fetchBanners() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.vegiffyy.com/api/banners'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['data'];

        _banners = data.map((item) => BannerModel.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching banners: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
