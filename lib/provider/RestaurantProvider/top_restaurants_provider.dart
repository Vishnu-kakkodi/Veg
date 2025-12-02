// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:veegify/model/nearby_restaurants_model.dart';
// import 'package:veegify/services/nearby_restaurants_service.dart';
// import 'package:veegify/services/top_restaurants_service.dart';

// class TopRestaurantsProvider with ChangeNotifier {
//   List<NearbyRestaurantModel> _topnearbyRestaurants = [];
//   bool _isLoading = false;

//   List<NearbyRestaurantModel> get nearbyRestaurants => _topnearbyRestaurants;
//   bool get isLoading => _isLoading;

//   Future<void> getTopNearbyRestaurants(String userId) async {
//     _isLoading = true;
//     notifyListeners();

//     try {
//       _topnearbyRestaurants = await TopRestaurantsService.fetchTopNearbyRestaurants(userId);
//     } catch (error) {
//       Fluttertoast.showToast(
//         msg: error.toString(),
//         toastLength: Toast.LENGTH_LONG,
//         gravity: ToastGravity.BOTTOM,
//       );
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }




import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:veegify/model/nearby_restaurants_model.dart';
import 'package:veegify/services/top_restaurants_service.dart';

class TopRestaurantsProvider with ChangeNotifier {
  List<NearbyRestaurantModel> _topRestaurants = [];
  bool _isLoading = false;

  List<NearbyRestaurantModel> get topRestaurants => _topRestaurants;
  bool get isLoading => _isLoading;

  Future<void> getTopRestaurants(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _topRestaurants = await TopRestaurantsService.fetchTopNearbyRestaurants(userId);
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