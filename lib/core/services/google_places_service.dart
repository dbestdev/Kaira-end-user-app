import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class GooglePlace {
  final String placeId;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? photoReference;

  GooglePlace({
    required this.placeId,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.photoReference,
  });

  factory GooglePlace.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    return GooglePlace(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: json['formatted_address'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      photoReference: json['photos']?.isNotEmpty == true
          ? json['photos'][0]['photo_reference']
          : null,
    );
  }
}

class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Google Places API key - now using secure configuration
  static String get _apiKey => ApiKeys.googlePlacesApiKey;
  static bool get _isApiKeyConfigured => ApiKeys.isGooglePlacesConfigured;

  /// Search for places using Google Places Autocomplete API (faster)
  Future<List<GooglePlace>> searchPlaces(String query) async {
    if (query.trim().isEmpty || query.trim().length < 2) return [];

    // Check if API key is configured
    if (!_isApiKeyConfigured || _apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      throw Exception(
        'Google Places API key not configured. Please add your API key to google_places_service.dart',
      );
    }

    try {
      // Use Autocomplete API for faster results - no need to fetch details for each
      final url = Uri.parse(
        '$_baseUrl/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey&types=establishment|geocode',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check for API errors
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          throw Exception(
            'Google Places API error: ${data['error_message'] ?? data['status']}',
          );
        }

        final List<dynamic> predictions = data['predictions'] ?? [];

        // Convert predictions to GooglePlace objects (fast, no additional API calls)
        return predictions.map((prediction) {
          final structuredFormatting =
              prediction['structured_formatting'] ?? {};
          return GooglePlace(
            placeId: prediction['place_id'] ?? '',
            name:
                structuredFormatting['main_text'] ??
                prediction['description'] ??
                '',
            address: prediction['description'] ?? '',
            latitude: 0.0, // Will be fetched when place is selected
            longitude: 0.0, // Will be fetched when place is selected
          );
        }).toList();
      } else {
        throw Exception('Failed to search places: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching places: $e');
    }
  }

  /// Get place details by place ID
  Future<GooglePlace> getPlaceDetails(String placeId) async {
    // Check if API key is configured
    if (!_isApiKeyConfigured || _apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      throw Exception(
        'Google Places API key not configured. Please add your API key to google_places_service.dart',
      );
    }

    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=place_id,name,formatted_address,geometry,photos&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check for API errors
        if (data['status'] != 'OK') {
          throw Exception(
            'Google Places API error: ${data['error_message'] ?? data['status']}',
          );
        }

        final result = data['result'];
        if (result != null) {
          return GooglePlace.fromJson(result);
        } else {
          throw Exception('Place not found');
        }
      } else {
        throw Exception('Failed to get place details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting place details: $e');
    }
  }
}
