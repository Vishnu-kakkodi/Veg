import 'package:flutter/material.dart';
import 'package:veegify/model/category_model.dart';
import 'package:veegify/services/category_service.dart';

class CategoryProvider with ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  List<Category> get categories => _categories;
    String? _error;


  bool _isLoading = false;
  bool get isLoading => _isLoading;
    String? get error => _error;


  Future<void> fetchCategories() async {
    try {
      _isLoading = true;
          _error = null;

      notifyListeners();

      final response = await _categoryService.fetchCategory();

      if (response['success'] == true && response['data'] != null) {
        print("Response Data DSDSDSD${response['success']}");
        _categories = (response['data'] as List)
            .map((item) => Category.fromJson(item))
            .toList();
      } else {

        throw Exception("Invalid response format");
      }
    } catch (e) {
      print("Category Fetch Failed: $e");
            _error = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
