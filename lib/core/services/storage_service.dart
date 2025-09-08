import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class StorageService {
  final FlutterSecureStorage _secureStorage;
  late final SharedPreferences _preferences;

  StorageService(this._secureStorage);

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Secure Storage Methods
  Future<void> storeSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Shared Preferences Methods
  Future<void> storeData(String key, dynamic value) async {
    if (value is String) {
      await _preferences.setString(key, value);
    } else if (value is int) {
      await _preferences.setInt(key, value);
    } else if (value is double) {
      await _preferences.setDouble(key, value);
    } else if (value is bool) {
      await _preferences.setBool(key, value);
    } else if (value is List<String>) {
      await _preferences.setStringList(key, value);
    }
  }

  T? getData<T>(String key) {
    return _preferences.get(key) as T?;
  }

  Future<void> removeData(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clearData() async {
    await _preferences.clear();
  }

  // Auth Token Methods
  Future<void> storeAuthToken(String token) async {
    await storeSecureData(AppConstants.tokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return await getSecureData(AppConstants.tokenKey);
  }

  Future<void> clearAuthToken() async {
    await deleteSecureData(AppConstants.tokenKey);
  }

  // User Data Methods
  Future<void> storeUserData(String userData) async {
    await storeSecureData(AppConstants.userKey, userData);
  }

  Future<String?> getUserData() async {
    return await getSecureData(AppConstants.userKey);
  }

  Future<void> clearUserData() async {
    await deleteSecureData(AppConstants.userKey);
  }

  // Location Methods
  Future<void> storeUserLocation(double latitude, double longitude) async {
    await storeData('${AppConstants.locationKey}_lat', latitude);
    await storeData('${AppConstants.locationKey}_lng', longitude);
  }

  Map<String, double>? getUserLocation() {
    final lat = getData<double>('${AppConstants.locationKey}_lat');
    final lng = getData<double>('${AppConstants.locationKey}_lng');

    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all data (logout)
  Future<void> logout() async {
    await clearAuthToken();
    await clearUserData();
    await clearData();
  }
}
