import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:veegify/model/nearby_restaurants_model.dart';
import 'package:veegify/services/nearby_restaurants_service.dart';

class RestaurantProvider with ChangeNotifier {
  List<NearbyRestaurantModel> _nearbyRestaurants = [];
  bool _isLoading = false;

  List<NearbyRestaurantModel> get nearbyRestaurants => _nearbyRestaurants;
  bool get isLoading => _isLoading;

  Future<void> getNearbyRestaurants(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _nearbyRestaurants = await RestaurantService.fetchNearbyRestaurants(userId);
    } catch (error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
