import 'package:dio/dio.dart';
import '../models/payment_method_model.dart';
import 'api_service.dart';

class PaymentMethodsService {
  final ApiService _apiService;

  PaymentMethodsService(this._apiService);

  /// Get all payment methods for the current user
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('/payment-methods');

      if (response is List) {
        return response
            .map((json) => PaymentMethodModel.fromJson(json))
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

  /// Get the default payment method
  Future<PaymentMethodModel?> getDefaultPaymentMethod() async {
    try {
      final response = await _apiService.get('/payment-methods/default');
      return response != null ? PaymentMethodModel.fromJson(response) : null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No default payment method
      }
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get a specific payment method by ID
  Future<PaymentMethodModel> getPaymentMethod(String id) async {
    try {
      final response = await _apiService.get('/payment-methods/$id');
      return PaymentMethodModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Add a new payment method
  Future<PaymentMethodModel> addPaymentMethod(
    Map<String, dynamic> paymentMethodData,
  ) async {
    try {
      final response = await _apiService.post(
        '/payment-methods',
        paymentMethodData,
      );
      return PaymentMethodModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Update a payment method
  Future<PaymentMethodModel> updatePaymentMethod(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _apiService.put('/payment-methods/$id', updates);
      return PaymentMethodModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Set a payment method as default
  Future<PaymentMethodModel> setDefaultPaymentMethod(String id) async {
    try {
      final response = await _apiService.patch(
        '/payment-methods/$id/set-default',
        {},
      );
      return PaymentMethodModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Verify a payment method
  Future<PaymentMethodModel> verifyPaymentMethod(String id) async {
    try {
      final response = await _apiService.patch(
        '/payment-methods/$id/verify',
        {},
      );
      return PaymentMethodModel.fromJson(response);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Remove a payment method
  Future<void> removePaymentMethod(String id) async {
    try {
      await _apiService.delete('/payment-methods/$id');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  String _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data?['message'] ?? 'Server error';

    switch (statusCode) {
      case 400:
        return message;
      case 401:
        return 'Invalid credentials. Please log in again.';
      case 403:
        return 'You do not have permission to perform this action.';
      case 404:
        return 'Payment method not found.';
      case 409:
        return message; // Conflict, e.g., duplicate default
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return 'Connection timed out. Please check your internet connection.';
        }
        if (e.type == DioExceptionType.cancel) {
          return 'Request was cancelled.';
        }
        if (e.type == DioExceptionType.connectionError) {
          return 'No internet connection. Please check your network.';
        }
        if (e.type == DioExceptionType.badCertificate) {
          return 'Security certificate error.';
        }
        if (e.type == DioExceptionType.unknown) {
          return 'An unexpected error occurred. Please try again.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
