import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Provider
class AuthStateNotifier extends StateNotifier<AuthStateData> {
  AuthStateNotifier() : super(const AuthStateData(
    isLoading: false,
    isAuthenticated: false,
    user: null,
    error: null,
  ));

  final AuthService _authService = AuthService();

  // Login method
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.login(
        identifier: identifier,
        password: password,
      );
      
      if (response['success'] == true) {
        final userData = response['data']['user'];
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: userData,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Signup initiation
  Future<void> initiateSignup({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.initiateSignup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
      );
      
      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Signup failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Verify SMS OTP
  Future<void> verifySmsOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.verifyOtp(
        identifier: phoneNumber,
        type: 'sms',
        code: otpCode,
      );
      
      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'SMS verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Verify Email OTP and complete signup
  Future<void> verifyEmailOtp({
    required String email,
    required String otpCode,
    required Map<String, dynamic> signUpData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.verifyEmailOtp(
        email: email,
        otpCode: otpCode,
        signUpData: signUpData,
      );
      
      if (response['success'] == true) {
        final userData = response['data']?['user'];
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: userData,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Email verification failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Send OTP
  Future<void> sendOtp({
    required String identifier,
    required String type,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _authService.sendOtp(
        identifier: identifier,
        type: type,
      );
      
      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      await _authService.logout();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth State Provider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthStateData>((ref) {
  return AuthStateNotifier();
});

// Auth State Data Class
class AuthStateData {
  final bool isLoading;
  final bool isAuthenticated;
  final Map<String, dynamic>? user;
  final String? error;

  const AuthStateData({
    required this.isLoading,
    required this.isAuthenticated,
    required this.user,
    required this.error,
  });

  AuthStateData copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    Map<String, dynamic>? user,
    String? error,
  }) {
    return AuthStateData(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}