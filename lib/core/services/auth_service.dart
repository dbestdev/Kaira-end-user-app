import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login with email/phone and password
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final authStart = DateTime.now();
    print('🔐 [${authStart.toIso8601String()}] AuthService.login called');

    try {
      final apiStart = DateTime.now();
      print(
        '🌐 [${apiStart.toIso8601String()}] Making API call to /auth/login',
      );

      final response = await _apiService.post('/auth/login', {
        'identifier': identifier,
        'password': password,
      });

      final apiEnd = DateTime.now();
      print(
        '📡 [${apiEnd.toIso8601String()}] API call completed in ${apiEnd.difference(apiStart).inMilliseconds}ms',
      );
      print(
        '📦 [${apiEnd.toIso8601String()}] Response received: ${response.toString().substring(0, 100)}...',
      );

      return response;
    } catch (e) {
      final authEnd = DateTime.now();
      print(
        '❌ [${authEnd.toIso8601String()}] AuthService.login failed in ${authEnd.difference(authStart).inMilliseconds}ms: $e',
      );
      rethrow;
    }
  }

  // Initiate signup process
  Future<Map<String, dynamic>> initiateSignup({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    String? referralCode,
  }) async {
    try {
      final response = await _apiService.post('/auth/signup/initiate', {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        if (referralCode != null) 'referralCode': referralCode,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify SMS OTP
  Future<Map<String, dynamic>> verifySmsOtp({
    required String phoneNumber,
    required String otpCode,
    required String
    email, // Email address needed to send email OTP after SMS verification
  }) async {
    try {
      final response = await _apiService.post('/auth/signup/verify-sms', {
        'identifier': phoneNumber,
        'type': 'sms',
        'code': otpCode,
        'email': email,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify Email OTP and complete signup
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otpCode,
    required Map<String, dynamic> signUpData,
  }) async {
    try {
      // Email OTP verification might take longer due to account creation
      final response = await _apiService.post('/auth/signup/verify-email', {
        'identifier': email,
        'type': 'email',
        'code': otpCode,
        'signUpData': signUpData,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Send OTP (SMS or Email)
  Future<Map<String, dynamic>> sendOtp({
    required String identifier,
    required String type, // 'sms' or 'email'
  }) async {
    try {
      final response = await _apiService.post('/auth/send-otp', {
        'identifier': identifier,
        'type': type,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Forgot Password - Send OTP to registered email
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      final response = await _apiService.post('/auth/forgot-password', {
        'email': email,
      });

      return response;
    } catch (e) {
      // Provide more specific error messages
      if (e.toString().contains('timeout')) {
        throw Exception(
          'Request timed out. Please check your connection and try again.',
        );
      } else if (e.toString().contains('404')) {
        throw Exception(
          'Email not found. Please check your email address or sign up.',
        );
      } else if (e.toString().contains('500')) {
        throw Exception('Server error. Please try again later.');
      }
      rethrow;
    }
  }

  // Verify Forgot Password OTP
  Future<Map<String, dynamic>> verifyForgotPasswordOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final response = await _apiService.post(
        '/auth/forgot-password/verify-otp',
        {'email': email, 'otpCode': otpCode},
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password with reset token
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post('/auth/reset-password', {
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String identifier,
    required String type,
    required String code,
  }) async {
    try {
      final response = await _apiService.post('/auth/verify-otp', {
        'identifier': identifier,
        'type': type,
        'code': code,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String identifier,
    required String type,
  }) async {
    try {
      final response = await _apiService.post('/auth/resend-otp', {
        'identifier': identifier,
        'type': type,
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile (requires authentication)
  Future<Map<String, dynamic>> getProfile(String accessToken) async {
    try {
      final response = await _apiService.get('/auth/profile');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken(String accessToken) async {
    try {
      final response = await _apiService.post('/auth/refresh-token', {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<Map<String, dynamic>> logout(String accessToken) async {
    try {
      final response = await _apiService.post('/auth/logout', {});
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Test backend connection
  Future<bool> testConnection() async {
    try {
      return await _apiService.testConnection();
    } catch (e) {
      return false;
    }
  }
}
