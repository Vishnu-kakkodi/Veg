// providers/profile_provider.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:veegify/helper/storage_helper.dart';
import 'package:veegify/model/user_model.dart';

class ProfileProvider extends ChangeNotifier {
  User? _user;
  String? _imageUrl;
  bool _loading = false;
  String? _error;

  // Base API host - change if needed
  static const String baseHost = "http://31.97.206.144:5051";

  User? get user => _user;
  String? get imageUrl => _imageUrl;
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  // Load user from local storage (UserPreferences)
  Future<void> loadLocalUser() async {
    final saved = UserPreferences.getUser();
    if (saved != null) {
      _user = saved;
      _imageUrl = saved.profileImg;
      notifyListeners();
    }
  }

  // Fetch fresh profile from server
Future<void> fetchUserProfile() async {
  if (_user == null) return;
  _setLoading(true);
  _setError(null);
  try {
    final url = Uri.parse("$baseHost/api/usersprofile/${_user!.userId}");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final u = data['user'];

      // Backend returns firstName/lastName in some endpoints; adapt accordingly
      final firstName = u['firstName'] ?? u['fullName'] ?? '';
      final lastName = u['lastName'] ?? '';
      final fullName = (firstName.toString().trim().isNotEmpty)
          ? (lastName.toString().trim().isNotEmpty ? '$firstName $lastName' : firstName)
          : (u['fullName'] ?? '');

      final id = u['_id'] ?? u['userId'] ?? _user!.userId;

      _user = User(
        userId: id,
        fullName: fullName,
        email: u['email'] ?? '',
        phoneNumber: u['phoneNumber'] ?? '',
        profileImg: u['profileImg'] ?? '',
      );
      _imageUrl = _user!.profileImg;
      UserPreferences.saveUser(_user!);
      _setLoading(false);
      notifyListeners();
    } else {
      _setLoading(false);
      _setError("Failed to fetch profile: ${res.statusCode}");
    }
  } catch (e) {
    _setLoading(false);
    _setError("Error fetching profile: $e");
  }
}

// Edit name & email using the /api/updateuser/{id} endpoint
Future<bool> editProfile({
  required String firstName,
  required String lastName,
  required String email,
}) async {
  if (_user == null) return false;
  _setLoading(true);
  _setError(null);
  try {
    final url = Uri.parse("$baseHost/api/updateuser/${_user!.userId}");
    final res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      }),
    );

    if (res.statusCode == 200) {
      // parse returned user and update local model
      final data = jsonDecode(res.body);
      final u = data['user'] ?? {};
      final fn = u['firstName'] ?? '';
      final ln = u['lastName'] ?? '';
      final fullName = (fn.toString().trim().isNotEmpty)
          ? (ln.toString().trim().isNotEmpty ? '$fn $ln' : fn)
          : (u['fullName'] ?? _user!.fullName);

      _user = User(
        userId: u['_id'] ?? _user!.userId,
        fullName: fullName,
        email: u['email'] ?? email,
        phoneNumber: u['phoneNumber'] ?? _user!.phoneNumber,
        profileImg: u['profileImg'] ?? _user!.profileImg,
      );
      _imageUrl = _user!.profileImg;
      UserPreferences.saveUser(_user!);
      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _setLoading(false);
      _setError("Update failed: ${res.statusCode} ${res.body}");
      return false;
    }
  } catch (e) {
    _setLoading(false);
    _setError("Edit error: $e");
    return false;
  }
}

  // Upload profile image (File)
  Future<bool> uploadProfileImage(File file) async {
    print("hhhhhhhhhhhhhhhhhhhhhh1111111");

    if (_user == null) return false;
    _setLoading(true);
    _setError(null);
        print("hhhhhhhhhhhhhhhhhhhhhh1111111");

    try {
          print("hhhhhhhhhhhhhhhhhhhhhh1111111");

      final url = Uri.parse("$baseHost/api/uploadprofile-image/${_user!.userId}");
      final request = http.MultipartRequest("PUT", url);
      request.files.add(await http.MultipartFile.fromPath("image", file.path));
      final streamed = await request.send();
      final resBody = await streamed.stream.bytesToString();
print("hhhhhhhhhhhhhhhhhhhhhh${resBody}");
      if (streamed.statusCode == 200) {
        // Try to parse response for new image url; otherwise fetch profile again
        try {
          final decoded = jsonDecode(resBody);
          final userData = decoded['user'] ?? decoded;
          final newImg = userData['profileImg'] ?? userData['profile_image'] ?? null;
          if (newImg != null) {
            _imageUrl = newImg;
            _user = _user!.copyWith(profileImg: newImg);
            UserPreferences.saveUser(_user!);
          }
        } catch (_) {
          // ignore parse errors - we'll fetch fresh profile
        }
        // refresh server copy
        await fetchUserProfile();
        _setLoading(false);
        return true;
      } else {
        _setLoading(false);
        _setError("Upload failed (${streamed.statusCode}): $resBody");
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError("Upload error: $e");
      return false;
    }
  }

  // Pick image from gallery then upload
  Future<bool> pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return false;
    final file = File(picked.path);
    return await uploadProfileImage(file);
  }

}
