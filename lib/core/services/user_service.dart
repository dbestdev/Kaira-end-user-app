import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get('/auth/profile');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await _apiService.put('/auth/profile', profileData);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile picture (placeholder for future implementation)
  Future<Map<String, dynamic>> uploadProfilePicture(String imagePath) async {
    try {
      // TODO: Implement file upload when backend supports it
      throw UnimplementedError('Profile picture upload not yet implemented');
    } catch (e) {
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    try {
      final response = await _apiService.get('/auth/stats');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
