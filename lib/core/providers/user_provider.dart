import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/user_service.dart';

// User Service Provider
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// User Data Provider
class UserDataNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  UserDataNotifier() : super(const AsyncValue.loading()) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        state = AsyncValue.data(userData);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Load user data from server
  Future<void> loadFromServer() async {
    try {
      final userService = UserService();
      final response = await userService.getUserProfile();

      if (response['success'] == true) {
        final userData = response['data']?['user'] ?? response;

        // Store in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(userData));

        // Update state
        state = AsyncValue.data(userData);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> newUserData) async {
    try {
      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(newUserData));

      // Update state
      state = AsyncValue.data(newUserData);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Clear user data
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userData');

      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// User Data Provider
final userDataProvider =
    StateNotifierProvider<UserDataNotifier, AsyncValue<Map<String, dynamic>?>>((
      ref,
    ) {
      return UserDataNotifier();
    });

// User Profile Provider (for home page)
class UserProfileNotifier
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  UserProfileNotifier() : super(const AsyncValue.loading()) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      // First try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        state = AsyncValue.data(_buildUserDataFromResponse(userData));
        return;
      }

      // If no local data, try to load from server
      final userService = UserService();
      final response = await userService.getUserProfile();
      final userData = response['data']?['user'] ?? response;

      state = AsyncValue.data(_buildUserDataFromResponse(userData));
    } catch (e) {
      // Return default user data if server fails
      state = AsyncValue.data(_getDefaultUserData());
    }
  }

  // Refresh user profile from server
  Future<void> refresh() async {
    try {
      final userService = UserService();
      final response = await userService.getUserProfile();
      final userData = response['data']?['user'] ?? response;

      // Store in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(userData));

      // Update state
      state = AsyncValue.data(_buildUserDataFromResponse(userData));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Build user data from API response
  Map<String, dynamic> _buildUserDataFromResponse(
    Map<String, dynamic> userData,
  ) {
    return {
      'name': '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
          .trim(),
      'email': userData['email'] ?? '',
      'phoneNumber': userData['phoneNumber'] ?? '',
      'firstName': userData['firstName'],
      'lastName': userData['lastName'],
      'createdAt': userData['createdAt'],
      'isVerified': userData['isVerified'],
      'rating': (userData['rating'] ?? 0.0).toDouble(),
      'reviewsCount': userData['reviewsCount'] ?? 0,
      'profilePicture': userData['profilePicture'],
      'wallet':
          userData['wallet'] ??
          {
            'balance': 0.0,
            'currency': 'NGN',
            'fundingHistory': [],
            'withdrawalHistory': [],
            'transactionHistory': [],
            'lastTransactionDate': null,
            'totalFunded': 0.0,
            'totalWithdrawn': 0.0,
            'isActive': true,
          },
      'bookings':
          userData['bookings'] ??
          {
            'totalBookings': 0,
            'completedBookings': 0,
            'pendingBookings': 0,
            'activeBookings': 0,
            'cancelledBookings': 0,
            'upcomingBookings': 0,
            'totalSpent': 0.0,
            'averageBookingValue': 0.0,
            'lastBookingDate': null,
            'favoriteServices': [],
            'bookingHistory': [],
          },
      'walletBalance': (userData['wallet']?['balance'] ?? 0.0).toDouble(),
      'totalBookings': userData['bookings']?['totalBookings'] ?? 0,
      'completedBookings': userData['bookings']?['completedBookings'] ?? 0,
      'totalSpent': (userData['bookings']?['totalSpent'] ?? 0.0).toDouble(),
    };
  }

  // Get default user data
  Map<String, dynamic> _getDefaultUserData() {
    return {
      'name': '',
      'email': '',
      'phoneNumber': '',
      'firstName': '',
      'lastName': '',
      'createdAt': null,
      'isVerified': false,
      'rating': 0.0,
      'reviewsCount': 0,
      'profilePicture': null,
      'wallet': {
        'balance': 0.0,
        'currency': 'NGN',
        'fundingHistory': [],
        'withdrawalHistory': [],
        'transactionHistory': [],
        'lastTransactionDate': null,
        'totalFunded': 0.0,
        'totalWithdrawn': 0.0,
        'isActive': true,
      },
      'bookings': {
        'totalBookings': 0,
        'completedBookings': 0,
        'pendingBookings': 0,
        'activeBookings': 0,
        'cancelledBookings': 0,
        'upcomingBookings': 0,
        'totalSpent': 0.0,
        'averageBookingValue': 0.0,
        'lastBookingDate': null,
        'favoriteServices': [],
        'bookingHistory': [],
      },
      'walletBalance': 0.0,
      'totalBookings': 0,
      'completedBookings': 0,
      'totalSpent': 0.0,
    };
  }
}

// User Profile Provider
final userProfileProvider =
    StateNotifierProvider<
      UserProfileNotifier,
      AsyncValue<Map<String, dynamic>>
    >((ref) {
      return UserProfileNotifier();
    });
