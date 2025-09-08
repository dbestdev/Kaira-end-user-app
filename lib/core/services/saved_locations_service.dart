import '../models/saved_location_model.dart';
import 'api_service.dart';

class SavedLocationsService {
  static final SavedLocationsService _instance =
      SavedLocationsService._internal();
  factory SavedLocationsService() => _instance;
  SavedLocationsService._internal();

  final ApiService _apiService = ApiService();

  /// Get all saved locations for the current user
  Future<List<SavedLocationModel>> getSavedLocations() async {
    try {
      final data = await _apiService.get('/saved-locations');
      final List<dynamic> locationsJson = data['locations'] ?? [];
      return locationsJson
          .map((json) => SavedLocationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error fetching saved locations: $e');
    }
  }

  /// Add a new saved location
  Future<SavedLocationModel> addSavedLocation({
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? placeId,
  }) async {
    try {
      final data = await _apiService.post('/saved-locations', {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'placeId': placeId,
      });
      return SavedLocationModel.fromJson(data['location']);
    } catch (e) {
      throw Exception('Error adding saved location: $e');
    }
  }

  /// Update an existing saved location
  Future<SavedLocationModel> updateSavedLocation({
    required String id,
    required String name,
    required String address,
    required double latitude,
    required double longitude,
    String? description,
    String? placeId,
  }) async {
    try {
      final data = await _apiService.put('/saved-locations/$id', {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'placeId': placeId,
      });
      return SavedLocationModel.fromJson(data['location']);
    } catch (e) {
      throw Exception('Error updating saved location: $e');
    }
  }

  /// Delete a saved location
  Future<void> deleteSavedLocation(String id) async {
    try {
      await _apiService.delete('/saved-locations/$id');
    } catch (e) {
      throw Exception('Error deleting saved location: $e');
    }
  }

  /// Set a location as default
  Future<SavedLocationModel> setDefaultLocation(String id) async {
    try {
      final data = await _apiService.patch(
        '/saved-locations/$id/set-default',
        {},
      );
      return SavedLocationModel.fromJson(data['location']);
    } catch (e) {
      throw Exception('Error setting default location: $e');
    }
  }
}
