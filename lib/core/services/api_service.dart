import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';
// import '../utils/logger.dart'; // Removed - using silent error handling

class ApiService {
  static String get baseUrl => AppConstants.baseUrl;
  static String get apiUrl => '$baseUrl/auth';

  late final Dio _dio;
  late final StorageService _storageService;

  ApiService() {
    _storageService = StorageService(FlutterSecureStorage());
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false, // Disable request body logging for performance
        responseBody: false, // Disable response body logging for performance
        logPrint: (object) {
          // Only log in debug mode and for important requests
          if (kDebugMode) {
            print('DIO: $object');
          }
        },
      ),
    );

    // Add authentication interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests that need authentication
          if (_needsAuthentication(options.path)) {
            print('Adding auth token to request: ${options.path}');
            try {
              final token = await _getAuthToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
                print(
                  'Authorization header added: Bearer ${token.substring(0, 20)}...',
                );
              } else {
                print('No auth token found for request: ${options.path}');
              }
            } catch (e) {
              print('Error adding auth token: $e');
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  // Generic GET request
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic PUT request
  Future<Map<String, dynamic>> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic PATCH request
  Future<Map<String, dynamic>> patch(String endpoint, dynamic data) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Handle Dio errors and convert to user-friendly messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';

      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Invalid credentials. Please check your email/phone and password.';
        } else if (e.response?.statusCode == 400) {
          final data = e.response?.data;
          if (data is Map<String, dynamic>) {
            // Return the exact error message from backend
            if (data['message'] != null) {
              return data['message'];
            }
            // Check for nested error messages
            if (data['error'] != null) {
              return data['error'];
            }
          }
          return 'Invalid request. Please check your input.';
        } else if (e.response?.statusCode == 404) {
          return 'Service not found. Please try again later.';
        } else if (e.response?.statusCode == 409) {
          // Conflict - user already exists
          final data = e.response?.data;
          if (data is Map<String, dynamic> && data['message'] != null) {
            return data['message'];
          }
          return 'Account already exists. Please use different details or try logging in.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error. Please try again later.';
        }
        return 'Something went wrong. Please try again.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  // Test connection to backend
  Future<bool> testConnection() async {
    try {
      await _dio.get('/');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if the endpoint needs authentication
  bool _needsAuthentication(String path) {
    // Add paths that require authentication
    final protectedPaths = [
      '/auth/profile',
      '/auth/stats',
      '/auth/logout',
      '/auth/refresh-token',
      '/notifications',
      '/users',
      '/bookings',
      '/payments',
      '/artisans',
      '/services',
      '/saved-locations',
      '/favorite-artisans',
      '/payment-methods',
    ];

    return protectedPaths.any((protectedPath) => path.contains(protectedPath));
  }

  // Get auth token from secure storage
  Future<String?> _getAuthToken() async {
    try {
      final token = await _storageService.getAuthToken();
      print(
        'Retrieved auth token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}',
      );
      return token;
    } catch (e) {
      print('Error retrieving auth token: $e');
      return null;
    }
  }
}
