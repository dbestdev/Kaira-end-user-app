import 'package:dio/dio.dart';
import '../models/favorite_artisan_model.dart';
import 'api_service.dart';

class FavoriteArtisansService {
  final ApiService _apiService;

  FavoriteArtisansService(this._apiService);

  /// Get all favorite artisans for the current user
  Future<List<FavoriteArtisanModel>> getFavoriteArtisans() async {
    try {
      final response = await _apiService.get('/favorite-artisans');

      // The backend returns a list directly
      if (response is List) {
        // Process favorite artisans
        return response
            .map((json) => FavoriteArtisanModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Expected list response, got: ${response.runtimeType}');
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Add an artisan to favorites
  Future<FavoriteArtisanModel> addToFavorites(String artisanId) async {
    try {
      final response = await _apiService.post('/favorite-artisans', {
        'artisanId': artisanId,
      });
      return FavoriteArtisanModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove an artisan from favorites
  Future<void> removeFromFavorites(String artisanId) async {
    try {
      await _apiService.delete('/favorite-artisans/$artisanId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Check if an artisan is in favorites
  Future<bool> isFavorite(String artisanId) async {
    try {
      final response = await _apiService.get(
        '/favorite-artisans/check/$artisanId',
      );
      final isFav = response['isFavorite'] ?? false;
      return isFav;
    } on DioException {
      // If there's an error, assume it's not a favorite
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get the count of favorite artisans
  Future<int> getFavoriteCount() async {
    try {
      final response = await _apiService.get('/favorite-artisans/count');
      return response['count'] ?? 0;
    } on DioException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Toggle favorite status (add if not favorite, remove if favorite)
  Future<bool> toggleFavorite(String artisanId) async {
    try {
      final isCurrentlyFavorite = await isFavorite(artisanId);

      if (isCurrentlyFavorite) {
        await removeFromFavorites(artisanId);
        return false; // Now not favorite
      } else {
        await addToFavorites(artisanId);
        return true; // Now favorite
      }
    } catch (e) {
      throw Exception('Failed to toggle favorite status: $e');
    }
  }

  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';

        switch (statusCode) {
          case 400:
            return 'Invalid request: $message';
          case 401:
            return 'Please log in to continue.';
          case 403:
            return 'You do not have permission to perform this action.';
          case 404:
            return 'Artisan not found.';
          case 409:
            return 'This artisan is already in your favorites.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Error: $message';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.badCertificate:
        return 'Security certificate error.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
