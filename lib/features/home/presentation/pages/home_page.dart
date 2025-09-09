import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'notifications_screen.dart';
import '../../../../core/utils/phone_utils.dart';

import 'package:end_user_app/features/services/presentation/pages/all_services_page.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:end_user_app/features/artisans/presentation/pages/artisan_profile_page.dart';
import 'package:end_user_app/features/bookings/presentation/pages/booking_page.dart';
import 'package:end_user_app/features/wallet/presentation/pages/wallet_page.dart';
import 'package:end_user_app/core/constants/app_constants.dart';
import 'package:end_user_app/core/services/user_service.dart';
import 'package:end_user_app/core/services/notifications_service.dart';
import 'package:end_user_app/core/services/storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late GoogleMapController _mapController;

  // Map and location variables
  Position? _currentPosition;
  String _currentAddress = 'Getting your location...';
  Set<Marker> _markers = {};
  bool _isLocationLoading = true;
  bool _isDistancePanelCollapsed = false;

  // Draggable sheet variables
  double _sheetHeight = 0.50; // 50% of screen height (initial expanded state)
  final double _minHeight = 0.23; // Minimum height to fit search form
  final double _maxHeight = 0.70; // 70% of screen height

  // Bottom navigation variables
  int _currentIndex = 0;
  final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      color: const Color(0xFF2196F3),
    ),
    BottomNavItem(
      icon: Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark,
      label: 'Bookings',
      color: const Color(0xFFFF9800),
    ),
    BottomNavItem(
      icon: Icons.person_outlined,
      activeIcon: Icons.person,
      label: 'Profile',
      color: const Color(0xFF9C27B0),
    ),
  ];

  // Autosuggest variables
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _showSuggestions = false;
  Timer? _searchDebounceTimer;

  // Loading states for better UX
  bool _isArtisanSearchLoading = false;

  // Artisan results state variables
  List<Map<String, dynamic>> _foundArtisans = [];
  String _selectedServiceName = '';
  bool _showingArtisans = false;

  // Polyline state variables
  final Set<Polyline> _polylines = {};
  final Map<String, List<LatLng>> _routePoints =
      {}; // Store route points for each artisan

  // Double-back-to-exit state
  DateTime? _lastBackPressAt;

  // Current user data
  Map<String, dynamic> _currentUser = {
    'name': 'Kaira User',
    'email': 'user@kaira.app',
    'rating': 0.0,
    'reviewsCount': 0,
    'walletBalance': 0.0,
  };

  // Services
  final UserService _userService = UserService();
  final NotificationsService _notificationsService = NotificationsService();

  // Notification state
  int _unreadNotificationCount = 0;
  Timer? _notificationRefreshTimer;
  DateTime? _lastNotificationRefresh;
  DateTime? _lastUserProfileRefresh;

  Widget _buildDrawerHeader() {
    final double rating = (_currentUser['rating'] is num)
        ? (_currentUser['rating'] as num).toDouble()
        : 0.0;
    final int reviewsCount = (_currentUser['reviewsCount'] is num)
        ? (_currentUser['reviewsCount'] as num).toInt()
        : 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _navigateToProfile,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2196F3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _currentUser['profilePicture'] != null
                  ? ClipOval(
                      child: Image.network(
                        _currentUser['profilePicture'],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          );
                        },
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentUser['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentUser['email'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($reviewsCount reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletBadge(dynamic balance) {
    final double amount = (balance is num) ? balance.toDouble() : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Text(
        '₦${amount.toStringAsFixed(0)}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF9800),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color color,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement actual sign out logic
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    print(
      '🏠 HomePage initState called at ${DateTime.now().toIso8601String()}',
    );
    WidgetsBinding.instance.addObserver(this);
    _getCurrentLocation();
    _loadUserData();
    _loadNotificationStats();
    _startNotificationRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationRefreshTimer?.cancel();
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh notification stats when app becomes active (with debouncing)
      if (_lastNotificationRefresh == null ||
          DateTime.now().difference(_lastNotificationRefresh!).inSeconds > 10) {
        _loadNotificationStats();
      }
    }
  }

  // Override didChangeDependencies to refresh when returning from other screens
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only refresh notification stats if we haven't loaded them recently
    // This prevents duplicate API calls during normal app lifecycle
    final now = DateTime.now();
    final shouldRefresh =
        _lastNotificationRefresh == null ||
        now.difference(_lastNotificationRefresh!).inSeconds > 5;

    print(
      '🔍 didChangeDependencies called - shouldRefresh: $shouldRefresh, lastRefresh: $_lastNotificationRefresh',
    );

    if (shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('🔄 Calling _loadNotificationStats from didChangeDependencies');
        _loadNotificationStats();
      });
    } else {
      print('⏭️ Skipping notification refresh - too recent');
    }
  }

  // Load notification stats with global debouncing
  Future<void> _loadNotificationStats() async {
    final now = DateTime.now();
    final shouldRefresh =
        _lastNotificationRefresh == null ||
        now.difference(_lastNotificationRefresh!).inSeconds >
            2; // Reduced to 2 seconds for initial load

    print(
      '📊 _loadNotificationStats called at ${now.toIso8601String()} - shouldRefresh: $shouldRefresh',
    );

    if (!shouldRefresh) {
      print(
        '⏭️ Skipping notification refresh - too recent (${now.difference(_lastNotificationRefresh!).inSeconds}s ago)',
      );
      return;
    }

    // Set timestamp immediately to prevent duplicate calls
    _lastNotificationRefresh = now;

    try {
      final stats = await _notificationsService.getNotificationStats();
      if (mounted) {
        setState(() {
          _unreadNotificationCount = stats.unread;
        });
        print('✅ Notification stats updated - unread: ${stats.unread}');
      }
    } catch (e) {
      // Log error for debugging
      print('Notification stats error: $e');
      // Handle error silently for user experience
    }
  }

  // Start periodic refresh timer for notification stats
  void _startNotificationRefreshTimer() {
    _notificationRefreshTimer = Timer.periodic(
      const Duration(
        seconds: 30,
      ), // Refresh every 30 seconds to reduce API calls
      (timer) {
        if (mounted) {
          _loadNotificationStats();
        }
      },
    );
  }

  // Public method to refresh notification stats (can be called from other screens)
  void refreshNotificationStats() {
    _loadNotificationStats();
  }

  // Load user data from local storage first, then server
  Future<void> _loadUserData() async {
    try {
      // First, try to load from local storage (this is the correct user data)
      await _loadLocalUserData();

      // If we have local data, use it and optionally sync with server in background
      if (_currentUser['email'] != null && _currentUser['email'].isNotEmpty) {
        // Optionally sync with server in background (don't wait for it)
        _syncWithServerInBackground();
      } else {
        // Only call server if no local data
        await _loadFromServer();
      }
    } catch (e) {
      // Keep default values if loading fails
    } finally {}
  }

  // Load user data from server with debouncing
  Future<void> _loadFromServer() async {
    final now = DateTime.now();
    final shouldRefresh =
        _lastUserProfileRefresh == null ||
        now.difference(_lastUserProfileRefresh!).inSeconds > 2;

    print(
      '👤 _loadFromServer called at ${now.toIso8601String()} - shouldRefresh: $shouldRefresh',
    );

    if (!shouldRefresh) {
      print(
        '⏭️ Skipping user profile load - too recent (${now.difference(_lastUserProfileRefresh!).inSeconds}s ago)',
      );
      return;
    }

    // Set timestamp immediately to prevent duplicate calls
    _lastUserProfileRefresh = now;

    try {
      final userProfile = await _userService.getUserProfile();

      // Update current user data with server data
      final userData = userProfile['data']?['user'] ?? userProfile;

      setState(() {
        _currentUser = _buildUserDataFromResponse(userData);
      });
      print('✅ User profile loaded from server');
    } catch (serverError) {
      // Keep existing data if server fails
      print('❌ User profile load failed: $serverError');
    }
  }

  // Sync with server in background (non-blocking) with debouncing
  Future<void> _syncWithServerInBackground() async {
    final now = DateTime.now();
    final shouldRefresh =
        _lastUserProfileRefresh == null ||
        now.difference(_lastUserProfileRefresh!).inSeconds > 2;

    print(
      '👤 _syncWithServerInBackground called at ${now.toIso8601String()} - shouldRefresh: $shouldRefresh',
    );

    if (!shouldRefresh) {
      print(
        '⏭️ Skipping user profile refresh - too recent (${now.difference(_lastUserProfileRefresh!).inSeconds}s ago)',
      );
      return;
    }

    // Set timestamp immediately to prevent duplicate calls
    _lastUserProfileRefresh = now;

    try {
      final userProfile = await _userService.getUserProfile();
      final userData = userProfile['data']?['user'] ?? userProfile;

      // Only update if we got valid data
      if (userData['email'] != null && userData['email'].isNotEmpty) {
        setState(() {
          _currentUser = _buildUserDataFromResponse(userData);
        });
        print('✅ User profile updated from server');
      }
    } catch (e) {
      // Don't update UI if sync fails
      print('❌ User profile sync failed: $e');
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

  // Load user data from local storage
  Future<void> _loadLocalUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('userData');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);

        setState(() {
          _currentUser = {
            'name':
                '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'
                    .trim(),
            'email': userData['email'] ?? '',
            'phoneNumber': userData['phoneNumber'] ?? '',
            'rating': userData['rating'] ?? 0.0,
            'reviewsCount': userData['reviewsCount'] ?? 0,
            'walletBalance': userData['walletBalance'] ?? 0.0,
            'profilePicture': userData['profilePicture'],
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'createdAt': userData['createdAt'],
            'totalBookings': userData['totalBookings'] ?? 0,
            'completedBookings': userData['completedBookings'] ?? 0,
            'totalSpent': userData['totalSpent'] ?? 0.0,
          };
        });
      }
    } catch (e) {}
  }

  // Navigate to profile page
  void _navigateToProfile() {
    Navigator.pop(context); // Close drawer
    setState(() => _currentIndex = 2); // Switch to Profile tab
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocationLoading = false;
            _currentAddress = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocationLoading = false;
          _currentAddress = 'Location permanently denied';
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        // Create custom user marker
        final userMarkerIcon = await _createCustomMarkerIcon(
          color: const Color(0xFF2196F3),
          icon: Icons.person_pin_circle,
          label: 'You',
          isUser: true,
        );

        setState(() {
          _currentPosition = position;
          _currentAddress = address;
          _isLocationLoading = false;
          _markers = {
            Marker(
              markerId: const MarkerId('user_location'),
              position: LatLng(position.latitude, position.longitude),
              infoWindow: InfoWindow(
                title: '📍 Your Location',
                snippet: address,
              ),
              icon: userMarkerIcon,
              anchor: const Offset(0.5, 1.0),
            ),
          };
        });
      }
    } catch (e) {
      setState(() {
        _isLocationLoading = false;
        _currentAddress = 'Unable to get location';
      });
    }
  }

  // Autosuggest methods (OPTIMIZED WITH DEBOUNCING)
  Future<void> _fetchAutosuggestions(String query) async {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Debounce the search to prevent excessive API calls
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _performAutosuggestSearch(query);
    });
  }

  Future<void> _performAutosuggestSearch(String query) async {
    print('🔍 Services Autosuggest - Searching for: "$query"');
    print(
      '🔍 Services Autosuggest - URL: ${AppConstants.baseUrl}/services/autosuggest',
    );

    try {
      // Get auth token for the request
      final storageService = StorageService(FlutterSecureStorage());
      await storageService.initialize();
      final authToken = await storageService.getAuthToken();

      print(
        '🔍 Services Autosuggest - Auth token: ${authToken != null ? 'Present' : 'Missing'}',
      );

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
        print('🔍 Services Autosuggest - Authorization header added');
      } else {
        print(
          '🔍 Services Autosuggest - No auth token, proceeding without authentication',
        );
      }

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/services/autosuggest'),
        headers: headers,
        body: json.encode({'query': query}),
      );

      print(
        '🔍 Services Autosuggest - Response status: ${response.statusCode}',
      );
      print('🔍 Services Autosuggest - Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('🔍 Services Autosuggest - Parsed data: $data');

        if (data['success'] == true) {
          final results = List<Map<String, dynamic>>.from(
            data['results'] ?? [],
          );
          print('🔍 Services Autosuggest - Found ${results.length} results');

          if (results.isEmpty) {
            // Add a "no services found" message
            results.add({
              'type': 'no_results',
              'id': 'no_results',
              'name': 'No services found for "$query"',
              'description': 'Try a different search term',
              'icon': 'search_off',
              'color': '#757575',
            });
          }

          setState(() {
            _searchSuggestions = results;
            _showSuggestions = true; // Always show suggestions, even if empty
          });
        } else {
          print('🔍 Services Autosuggest - API returned success: false');
          setState(() {
            _searchSuggestions = [];
            _showSuggestions = false;
          });
        }
      } else {
        print('🔍 Services Autosuggest - HTTP error: ${response.statusCode}');
        setState(() {
          _searchSuggestions = [];
          _showSuggestions = false;
        });
      }
    } catch (e) {
      print('🔍 Services Autosuggest - Exception: $e');
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Set new timer for debounced search - faster response
    _searchDebounceTimer = Timer(const Duration(milliseconds: 150), () {
      _fetchAutosuggestions(query);
    });
  }

  void _onSuggestionSelected(Map<String, dynamic> suggestion) {
    setState(() {
      _searchController.text = suggestion['name'];
      _showSuggestions = false;
    });

    // Search for artisans offering this service
    if (suggestion['type'] == 'service') {
      _searchArtisansForService(suggestion['id'], suggestion['name']);
    } else if (suggestion['type'] == 'category') {
      // For categories, trigger autosuggestions directly
      _fetchAutosuggestions(suggestion['name']);
    }
  }

  // Handle category tap - auto-fill search and trigger autosuggestions
  Future<void> _onCategoryTapped(String categoryName) async {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Navigate to ServiceCategoryPage to show artisans on map
    Navigator.pushNamed(
      context,
      '/service-category',
      arguments: {
        'categoryName': categoryName,
        'categoryIcon': _getCategoryIcon(categoryName),
        'categoryColor': _getCategoryColor(categoryName),
      },
    );
  }

  // Helper method to get category icon
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'carpentry':
        return Icons.carpenter;
      case 'painting':
        return Icons.format_paint;
      default:
        return Icons.build;
    }
  }

  // Helper method to get category color
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'plumbing':
        return const Color(0xFF2196F3);
      case 'electrical':
        return const Color(0xFFFF9800);
      case 'cleaning':
        return const Color(0xFF4CAF50);
      case 'carpentry':
        return const Color(0xFF795548);
      case 'painting':
        return const Color(0xFFE91E63);
      default:
        return const Color(0xFF2196F3);
    }
  }

  // Search for artisans offering a specific service
  Future<void> _searchArtisansForService(
    String serviceId,
    String serviceName,
  ) async {
    try {
      setState(() {
        _isArtisanSearchLoading = true;
        _showingArtisans = false;
      });

      // Get current user location (for now, using Lagos coordinates)
      // TODO: Get actual user location from GPS
      const double userLatitude = 6.5244;
      const double userLongitude = 3.3792;

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/artisans/search'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'serviceId': serviceId,
          'latitude': userLatitude,
          'longitude': userLongitude,
          'radiusKm': 25,
          'sortBy': 'distance',
          'sortOrder': 'asc',
          'limit': 10,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final artisans = data['artisans'] as List;

          if (artisans.isNotEmpty) {
            // Limit the number of artisans to prevent performance issues
            final limitedArtisans = artisans.take(10).toList();

            // Store artisans and show them in the transformed draggable
            setState(() {
              _foundArtisans = List<Map<String, dynamic>>.from(limitedArtisans);
              _selectedServiceName = serviceName;
              _showingArtisans = true;
              _isArtisanSearchLoading = false;
            });

            // Add artisan markers to the map
            _addArtisanMarkersToMap(limitedArtisans);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'No artisans found for $serviceName in your area',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${data['message']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isArtisanSearchLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching for artisans: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isArtisanSearchLoading = false;
      });
    }
  }

  // Create custom marker icons with different colors and labels
  Future<BitmapDescriptor> _createCustomMarkerIcon({
    required Color color,
    required IconData icon,
    required String label,
    required bool isUser,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    const double size = 120.0;
    const double markerSize = 80.0;
    const double iconSize = 24.0;

    // Create marker background (teardrop shape)
    final markerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final markerBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw teardrop shape for marker
    final markerPath = Path();
    const center = Offset(size / 2, size / 2 - 10);
    const radius = markerSize / 2;

    // Circle part
    markerPath.addOval(Rect.fromCircle(center: center, radius: radius));

    // Point part (teardrop bottom)
    markerPath.moveTo(center.dx, center.dy + radius);
    markerPath.lineTo(center.dx - 8, center.dy + radius + 15);
    markerPath.lineTo(center.dx + 8, center.dy + radius + 15);
    markerPath.close();

    canvas.drawPath(markerPath, markerPaint);
    canvas.drawPath(markerPath, markerBorderPaint);

    // Draw icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2 - 5,
      ),
    );

    // Draw label background if not user
    if (!isUser && label.isNotEmpty) {
      final labelBgPaint = Paint()
        ..color = Colors.black87
        ..style = PaintingStyle.fill;

      final labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      labelPainter.layout();

      final labelBgRect = Rect.fromLTWH(size / 2 - 25, center.dy + 20, 50, 16);

      final labelBgRRect = RRect.fromRectAndRadius(
        labelBgRect,
        const Radius.circular(8),
      );

      canvas.drawRRect(labelBgRRect, labelBgPaint);
      labelPainter.paint(
        canvas,
        Offset(size / 2 - labelPainter.width / 2, center.dy + 22),
      );
    }

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  // Helper method to format hourly rate (handles both string and number)
  String _formatHourlyRate(dynamic hourlyRate) {
    if (hourlyRate == null) return '0';

    try {
      if (hourlyRate is String) {
        final rate = double.tryParse(hourlyRate);
        return rate?.toStringAsFixed(0) ?? '0';
      } else if (hourlyRate is num) {
        return hourlyRate.toStringAsFixed(0);
      } else {
        return '0';
      }
    } catch (e) {
      return '0';
    }
  }

  // Helper method to format distance (handles both string and number)
  String _formatDistance(dynamic distance) {
    if (distance == null) return '0.0';

    try {
      if (distance is String) {
        final dist = double.tryParse(distance);
        return dist?.toStringAsFixed(1) ?? '0.0';
      } else if (distance is num) {
        return distance.toStringAsFixed(1);
      } else {
        return '0.0';
      }
    } catch (e) {
      return '0.0';
    }
  }

  // Add artisan markers to the map (CREATIVE LIGHTWEIGHT VERSION)
  void _addArtisanMarkersToMap(List<dynamic> artisans) async {
    final Set<Marker> artisanMarkers = {};
    final Set<Polyline> artisanPolylines = {};

    // Create distinctive user marker with custom icon (lightweight)
    final userMarkerIcon = await _createLightweightUserMarker();
    final userMarker = Marker(
      markerId: const MarkerId('user_location'),
      position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      icon: userMarkerIcon,
      infoWindow: const InfoWindow(
        title: '📍 Your Location',
        snippet: 'You are here',
      ),
      anchor: const Offset(0.5, 0.5),
    );

    // Replace user marker in the set
    _markers.removeWhere((marker) => marker.markerId.value == 'user_location');
    _markers.add(userMarker);

    // Store artisan data for distance panel
    _foundArtisans = artisans.cast<Map<String, dynamic>>();

    // Process artisans in batches to prevent UI freezing
    const int batchSize = 5;
    for (int i = 0; i < artisans.length; i += batchSize) {
      final batch = artisans.skip(i).take(batchSize);

      for (final artisan in batch) {
        if (artisan['location']?['latitude'] != null &&
            artisan['location']?['longitude'] != null &&
            _currentPosition != null) {
          final artisanLat = double.parse(
            artisan['location']['latitude'].toString(),
          );
          final artisanLng = double.parse(
            artisan['location']['longitude'].toString(),
          );

          // Create distinctive artisan marker (lightweight)
          final artisanMarkerIcon = await _createLightweightArtisanMarker(
            artisan,
            i,
          );
          final marker = Marker(
            markerId: MarkerId('artisan_${artisan['id']}'),
            position: LatLng(artisanLat, artisanLng),
            icon: artisanMarkerIcon,
            infoWindow: InfoWindow(
              title: '🔧 ${artisan['name'] ?? 'Professional Artisan'}',
              snippet:
                  '${_formatDistance(artisan['distance'])}km away • ₦${_formatHourlyRate(artisan['hourlyRate'])}/hr',
            ),
            anchor: const Offset(0.5, 0.5),
          );

          // Create curved polyline like Uber/Bolt
          final routePoints = _generateCurvedRoute(
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            LatLng(artisanLat, artisanLng),
            i,
          );

          // Store route points for this artisan
          _routePoints['route_to_${artisan['id']}'] = routePoints;

          // Create creative curved polyline with distance display
          final polyline = Polyline(
            polylineId: PolylineId('route_to_${artisan['id']}'),
            points: routePoints,
            color: _getArtisanRouteColor(i),
            width: 5,
            geodesic: false, // Use custom curved path
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            patterns: [PatternItem.dash(25), PatternItem.gap(15)],
          );

          artisanMarkers.add(marker);
          artisanPolylines.add(polyline);
        }
      }

      // Update UI after each batch to prevent freezing
      if (i + batchSize < artisans.length) {
        setState(() {
          _markers.addAll(artisanMarkers);
          _polylines.addAll(artisanPolylines);
        });

        // Small delay to allow UI to update
        await Future.delayed(const Duration(milliseconds: 50));

        // Clear the sets for next batch
        artisanMarkers.clear();
        artisanPolylines.clear();
      }
    }

    // Final update with remaining markers
    setState(() {
      _markers.addAll(artisanMarkers);
      _polylines.addAll(artisanPolylines);
    });

    // Adjust map camera to show all markers
    _adjustMapCameraToShowAllMarkers();
  }

  // Create BIG user marker with shadow effects
  Future<BitmapDescriptor> _createLightweightUserMarker() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    // Create shadow effect (multiple layers)
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(const Offset(55, 55), 50, paint);

    paint.color = Colors.black.withOpacity(0.2);
    canvas.drawCircle(const Offset(52, 52), 50, paint);

    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawCircle(const Offset(50, 50), 50, paint);

    // Create main blue circle with gradient effect
    paint.color = const Color(0xFF2196F3);
    canvas.drawCircle(const Offset(50, 50), 50, paint);

    // Add inner highlight
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(const Offset(45, 45), 35, paint);

    // Add white border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    canvas.drawCircle(const Offset(50, 50), 50, paint);

    // Add person icon with shadow
    paint.color = Colors.black.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    final shadowPainter = TextPainter(
      text: const TextSpan(
        text: '👤',
        style: TextStyle(fontSize: 50, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    shadowPainter.layout();
    shadowPainter.paint(
      canvas,
      Offset(
        50 - shadowPainter.width / 2 + 2,
        50 - shadowPainter.height / 2 + 2,
      ),
    );

    // Add person icon
    paint.color = Colors.white;
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '👤',
        style: TextStyle(fontSize: 50, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(50 - textPainter.width / 2, 50 - textPainter.height / 2),
    );

    // Add "YOU" label with background
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 85, 40, 20),
        const Radius.circular(10),
      ),
      paint,
    );

    paint.color = const Color(0xFF2196F3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(30, 85, 40, 20),
        const Radius.circular(10),
      ),
      paint,
    );

    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'YOU',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF2196F3),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(50 - labelPainter.width / 2, 90));

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(100, 110);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  // Create BIG artisan marker with shadow effects
  Future<BitmapDescriptor> _createLightweightArtisanMarker(
    Map<String, dynamic> artisan,
    int index,
  ) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    // Get artisan's first name for personalization
    final String firstName = (artisan['name'] ?? 'Artisan').toString().split(
      ' ',
    )[0];
    final String firstLetter = firstName.isNotEmpty
        ? firstName[0].toUpperCase()
        : 'A';

    // Create a colorful circular marker
    final List<Color> colors = [
      const Color(0xFFFF5722), // Orange
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF9800), // Amber
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];

    final Color markerColor = colors[index % colors.length];

    // Create shadow effect (multiple layers)
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawCircle(const Offset(55, 55), 50, paint);

    paint.color = Colors.black.withOpacity(0.2);
    canvas.drawCircle(const Offset(52, 52), 50, paint);

    paint.color = Colors.black.withOpacity(0.1);
    canvas.drawCircle(const Offset(50, 50), 50, paint);

    // Draw main circle
    paint.color = markerColor;
    canvas.drawCircle(const Offset(50, 50), 50, paint);

    // Add inner highlight
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(const Offset(45, 45), 35, paint);

    // Add white border
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6;
    canvas.drawCircle(const Offset(50, 50), 50, paint);

    // Add tools icon with shadow
    paint.color = Colors.black.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    final shadowPainter = TextPainter(
      text: const TextSpan(
        text: '🔧',
        style: TextStyle(fontSize: 40, color: Colors.black),
      ),
      textDirection: TextDirection.ltr,
    );
    shadowPainter.layout();
    shadowPainter.paint(
      canvas,
      Offset(
        50 - shadowPainter.width / 2 + 2,
        50 - shadowPainter.height / 2 - 3 + 2,
      ),
    );

    // Add tools icon
    paint.color = Colors.white;
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🔧',
        style: TextStyle(fontSize: 40, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(50 - textPainter.width / 2, 50 - textPainter.height / 2 - 3),
    );

    // Add artisan's first letter with shadow
    paint.color = Colors.black.withOpacity(0.3);
    final letterShadowPainter = TextPainter(
      text: TextSpan(
        text: firstLetter,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    letterShadowPainter.layout();
    letterShadowPainter.paint(
      canvas,
      Offset(50 - letterShadowPainter.width / 2 + 1, 50 + 12 + 1),
    );

    // Add artisan's first letter
    final letterPainter = TextPainter(
      text: TextSpan(
        text: firstLetter,
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    letterPainter.layout();
    letterPainter.paint(canvas, Offset(50 - letterPainter.width / 2, 50 + 12));

    // Add artisan name with background
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(50, 85),
          width: firstName.length * 8.0 + 16,
          height: 18,
        ),
        const Radius.circular(9),
      ),
      paint,
    );

    paint.color = markerColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(50, 85),
          width: firstName.length * 8.0 + 16,
          height: 18,
        ),
        const Radius.circular(9),
      ),
      paint,
    );

    final namePainter = TextPainter(
      text: TextSpan(
        text: firstName,
        style: TextStyle(
          fontSize: 12,
          color: markerColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(50 - namePainter.width / 2, 78));

    final ui.Picture picture = pictureRecorder.endRecording();
    final ui.Image image = await picture.toImage(100, 110);
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  // Generate curved route like Uber/Bolt
  List<LatLng> _generateCurvedRoute(LatLng start, LatLng end, int index) {
    final List<LatLng> points = [];

    // Calculate distance for curve intensity adjustment
    final double distance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    // Adjust curve intensity based on distance
    final double distanceFactor = (distance / 1000).clamp(0.5, 2.0);

    // Create different curve patterns based on index
    final List<double> curvePatterns = [
      0.3,
      0.5,
      0.7,
      0.4,
      0.6,
      0.8,
      0.35,
      0.65,
    ];
    final double curveIntensity = curvePatterns[index % curvePatterns.length];

    // Calculate control points for Bezier curve
    final double midLat = (start.latitude + end.latitude) / 2;
    final double midLng = (start.longitude + end.longitude) / 2;

    // Add curve offset based on index for variety and distance
    final double latOffset =
        (index % 2 == 0 ? 1 : -1) * 0.01 * curveIntensity * distanceFactor;
    final double lngOffset =
        (index % 3 == 0 ? 1 : -1) * 0.01 * curveIntensity * distanceFactor;

    final LatLng controlPoint1 = LatLng(
      start.latitude + (midLat - start.latitude) * 0.5 + latOffset,
      start.longitude + (midLng - start.longitude) * 0.5 + lngOffset,
    );

    final LatLng controlPoint2 = LatLng(
      midLat + (end.latitude - midLat) * 0.5 - latOffset,
      midLng + (end.longitude - midLng) * 0.5 - lngOffset,
    );

    // Generate points along the curved path
    const int numPoints = 20;
    for (int i = 0; i <= numPoints; i++) {
      final double t = i / numPoints.toDouble();

      // Cubic Bezier curve calculation
      final double lat = _cubicBezier(
        start.latitude,
        controlPoint1.latitude,
        controlPoint2.latitude,
        end.latitude,
        t,
      );

      final double lng = _cubicBezier(
        start.longitude,
        controlPoint1.longitude,
        controlPoint2.longitude,
        end.longitude,
        t,
      );

      points.add(LatLng(lat, lng));
    }

    return points;
  }

  // Cubic Bezier curve calculation
  double _cubicBezier(double p0, double p1, double p2, double p3, double t) {
    final double u = 1 - t;
    final double tt = t * t;
    final double uu = u * u;
    final double uuu = uu * u;
    final double ttt = tt * t;

    return uuu * p0 + 3 * uu * t * p1 + 3 * u * tt * p2 + ttt * p3;
  }

  // Calculate different travel distances
  Map<String, String> _calculateTravelDistances(LatLng start, LatLng end) {
    final double straightDistance = Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );

    // Convert to kilometers
    final double distanceKm = straightDistance / 1000;

    // Calculate different travel modes with realistic factors
    final double walkingDistance =
        distanceKm * 1.3; // Walking is typically 30% longer
    final double drivingDistance =
        distanceKm * 1.15; // Driving is typically 15% longer
    final double ridingDistance =
        distanceKm * 1.1; // Riding (bike/motorcycle) is typically 10% longer

    return {
      'walking': '${walkingDistance.toStringAsFixed(1)} km',
      'driving': '${drivingDistance.toStringAsFixed(1)} km',
      'riding': '${ridingDistance.toStringAsFixed(1)} km',
      'straight': '${distanceKm.toStringAsFixed(1)} km',
    };
  }

  // Calculate travel times
  Map<String, String> _calculateTravelTimes(double distanceKm) {
    // Average speeds (km/h)
    const double walkingSpeed = 5.0;
    const double drivingSpeed = 30.0;
    const double ridingSpeed = 25.0;

    final int walkingMinutes = ((distanceKm / walkingSpeed) * 60).round();
    final int drivingMinutes = ((distanceKm / drivingSpeed) * 60).round();
    final int ridingMinutes = ((distanceKm / ridingSpeed) * 60).round();

    return {
      'walking': '${walkingMinutes} min',
      'driving': '${drivingMinutes} min',
      'riding': '${ridingMinutes} min',
    };
  }

  // Build distance information panel with toggle
  Widget _buildDistancePanel() {
    if (_foundArtisans.isEmpty || _currentPosition == null) {
      return const SizedBox.shrink();
    }

    // Get the closest artisan for distance calculations
    final closestArtisan = _foundArtisans.first;
    final artisanLat = double.parse(
      closestArtisan['location']['latitude'].toString(),
    );
    final artisanLng = double.parse(
      closestArtisan['location']['longitude'].toString(),
    );

    final distances = _calculateTravelDistances(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      LatLng(artisanLat, artisanLng),
    );

    final times = _calculateTravelTimes(
      Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            artisanLat,
            artisanLng,
          ) /
          1000,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: _isDistancePanelCollapsed
          ? null
          : 200, // Let it size naturally when collapsed
      height: _isDistancePanelCollapsed
          ? null
          : 200, // Let it size naturally when collapsed
      padding: _isDistancePanelCollapsed
          ? EdgeInsets.zero
          : const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDistancePanelCollapsed
            ? Colors.transparent
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(
          12,
        ), // Same rounded corners for both states
        boxShadow: _isDistancePanelCollapsed
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: _isDistancePanelCollapsed
          ? _buildCollapsedPanel()
          : _buildExpandedPanel(distances, times),
    );
  }

  // Build collapsed panel (exact same size as hamburger menu)
  Widget _buildCollapsedPanel() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDistancePanelCollapsed = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8), // Same padding as hamburger
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), // Same color as hamburger
          borderRadius: BorderRadius.circular(
            12,
          ), // Same border radius as hamburger
        ),
        child: const Icon(
          Icons.route,
          color: Color(0xFF2196F3), // Same color as hamburger
          size: 24, // Same size as hamburger
        ),
      ),
    );
  }

  // Build expanded panel (full content)
  Widget _buildExpandedPanel(
    Map<String, String> distances,
    Map<String, String> times,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with toggle button
          Row(
            children: [
              const Icon(Icons.route, color: Color(0xFF2196F3), size: 16),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Travel Info',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isDistancePanelCollapsed = true;
                  });
                },
                child: const Icon(Icons.close, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distance and time info - more compact
          _buildCompactTravelInfoRow(
            icon: Icons.directions_walk,
            label: 'Walk',
            distance: distances['walking']!,
            time: times['walking']!,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 8),

          _buildCompactTravelInfoRow(
            icon: Icons.directions_car,
            label: 'Drive',
            distance: distances['driving']!,
            time: times['driving']!,
            color: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 8),

          _buildCompactTravelInfoRow(
            icon: Icons.two_wheeler,
            label: 'Ride',
            distance: distances['riding']!,
            time: times['riding']!,
            color: const Color(0xFFFF9800),
          ),
          const SizedBox(height: 8),

          _buildCompactTravelInfoRow(
            icon: Icons.straighten,
            label: 'Direct',
            distance: distances['straight']!,
            time: '',
            color: const Color(0xFF9E9E9E),
          ),
        ],
      ),
    );
  }

  // Build compact travel info row
  Widget _buildCompactTravelInfoRow({
    required IconData icon,
    required String label,
    required String distance,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                distance,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (time.isNotEmpty)
                Text(
                  time,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Get different colors for artisan routes
  Color _getArtisanRouteColor(int index) {
    final List<Color> routeColors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF5722), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF9800), // Amber
      const Color(0xFF795548), // Brown
    ];

    return routeColors[index % routeColors.length];
  }

  // Adjust map camera to show user location and all artisan markers
  void _adjustMapCameraToShowAllMarkers() {
    if (_currentPosition == null || _foundArtisans.isEmpty) {
      return;
    }

    // Calculate bounds to include user location and all artisans
    double minLat = _currentPosition!.latitude;
    double maxLat = _currentPosition!.latitude;
    double minLng = _currentPosition!.longitude;
    double maxLng = _currentPosition!.longitude;

    for (final artisan in _foundArtisans) {
      if (artisan['location']?['latitude'] != null &&
          artisan['location']?['longitude'] != null) {
        final lat = double.parse(artisan['location']['latitude'].toString());
        final lng = double.parse(artisan['location']['longitude'].toString());

        minLat = min(minLat, lat);
        maxLat = max(maxLat, lat);
        minLng = min(minLng, lng);
        maxLng = max(maxLng, lng);
      }
    }

    // Add padding to bounds (more padding to show routes clearly)
    const padding = 0.002; // About 200m padding to show routes
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    // Animate camera to show all markers
    _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // Padding in pixels
      ),
    );
  }

  // Navigate to artisan profile page
  void _navigateToArtisanProfile(Map<String, dynamic> artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtisanProfilePage(artisan: artisan),
      ),
    );
  }

  // Navigate to booking page
  void _navigateToBooking(Map<String, dynamic> artisan) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookingPage(artisan: artisan)),
    );
  }

  // Go back to original draggable
  void _goBackToOriginalDraggable() {
    setState(() {
      _showingArtisans = false;
      _foundArtisans = [];
      _selectedServiceName = '';

      // Clear search field
      _searchController.clear();
      _showSuggestions = false;
      _searchSuggestions.clear();

      // Remove artisan markers from map
      _markers.removeWhere(
        (marker) => marker.markerId.value.startsWith('artisan_'),
      );

      // Remove artisan polylines from map
      _polylines.removeWhere(
        (polyline) => polyline.polylineId.value.startsWith('route_to_'),
      );

      // Clear route points
      _routePoints.clear();
    });

    // Reset map to user location
    if (_currentPosition != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  // Build the artisan search loading screen
  Widget _buildArtisanSearchLoading() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.search,
                  size: 20,
                  color: Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Finding Artisans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Searching for nearby professionals...',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Loading content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF2196F3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Searching for artisans...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we find the best professionals near you',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Build the artisans draggable (smaller, fixed height)
  Widget _buildArtisansDraggable() {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: _goBackToOriginalDraggable,
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
                style: IconButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF2196F3,
                  ).withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Artisans for $_selectedServiceName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      '${_foundArtisans.length} found in your area',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Artisans list (fixed height, not scrollable)
        Expanded(
          child: SizedBox(
            height: 200, // Fixed height
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _foundArtisans.length,
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Disable scrolling
              itemBuilder: (context, index) {
                final artisan = _foundArtisans[index];
                return _buildArtisanCard(artisan);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Build individual artisan card
  Widget _buildArtisanCard(Map<String, dynamic> artisan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Artisan header
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xFF2196F3),
                backgroundImage:
                    artisan['avatar'] != null &&
                        artisan['avatar'].toString().startsWith('http')
                    ? NetworkImage(artisan['avatar'])
                    : null,
                child:
                    artisan['avatar'] == null ||
                        !artisan['avatar'].toString().startsWith('http')
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null,
              ),

              const SizedBox(width: 16),

              // Artisan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artisan['name'] ?? 'Professional Artisan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.amber[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${artisan['rating'] ?? '0'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${artisan['totalReviews'] ?? '0'} reviews)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Distance
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_formatDistance(artisan['distance'])} km',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Service details
          Row(
            children: [
              Icon(Icons.work, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  artisan['services']?[0]?['name'] ?? 'Service',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
              Text(
                '₦${_formatHourlyRate(artisan['hourlyRate'])}/hr',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _navigateToArtisanProfile(artisan),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2196F3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(color: Color(0xFF2196F3)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _navigateToBooking(artisan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDrawerHeader(),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildDrawerItem(
                        icon: Icons.account_circle_outlined,
                        title: 'My Profile',
                        subtitle: 'View and edit your details',
                        color: const Color(0xFF2196F3),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 2);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Wallet',
                        subtitle: 'Manage your payments',
                        color: const Color(0xFFFF9800),
                        trailing: _buildWalletBadge(
                          _currentUser['walletBalance'],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletPage(
                                initialBalance:
                                    (_currentUser['walletBalance'] as num)
                                        .toDouble(),
                              ),
                            ),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.bookmark_border_rounded,
                        title: 'My Bookings',
                        subtitle: 'Active and history',
                        color: const Color(0xFF4CAF50),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _currentIndex = 1);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.support_agent_outlined,
                        title: 'Support',
                        subtitle: 'Get help and contact us',
                        color: const Color(0xFF9C27B0),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/contact-support');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.info_outline,
                        title: 'About Kaira',
                        subtitle: 'Version 1.0.0',
                        color: Colors.grey.shade700,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/about-kaira');
                        },
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'More',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        subtitle: 'Notifications, privacy, etc.',
                        color: Colors.grey.shade800,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        title: 'Sign Out',
                        subtitle: 'Log out of your account',
                        color: Colors.red.shade600,
                        onTap: () {
                          Navigator.pop(context);
                          _showSignOutDialog();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeScreen(),
            _buildBookingsScreen(),
            _buildProfileScreen(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final DateTime now = DateTime.now();
    if (_lastBackPressAt == null ||
        now.difference(_lastBackPressAt!) > const Duration(seconds: 2)) {
      _lastBackPressAt = now;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    // Exit the app on second back within 2 seconds
    SystemNavigator.pop();
    return false;
  }

  Widget _buildHomeScreen() {
    return Stack(
      children: [
        // Map Background
        _buildMapBackground(),

        // Top App Bar - Only hamburger menu and notification icon
        _buildTopAppBar(),

        // Distance Information Panel
        if (_foundArtisans.isNotEmpty)
          Positioned(top: 140, right: 16, child: _buildDistancePanel()),

        // Draggable Sheet
        Positioned(bottom: 0, left: 0, right: 0, child: _buildDraggableSheet()),
      ],
    );
  }

  Widget _buildBookingsScreen() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'My Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false, // Remove back button
          elevation: 0,
          bottom: TabBar(
            labelColor: const Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            indicatorColor: const Color(0xFF2196F3),
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.schedule, size: 20), text: 'Active'),
              Tab(icon: Icon(Icons.history, size: 20), text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildActiveBookingsTab(), _buildBookingHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildActiveBookingsTab() {
    // Sample active bookings data
    final List<Map<String, dynamic>> activeBookings = [
      {
        'id': 'BK001',
        'serviceName': 'Plumbing Repair',
        'artisanName': 'John\'s Plumbing',
        'artisanAvatar': '👨‍🔧',
        'status': 'In Progress',
        'statusColor': Colors.orange,
        'scheduledDate': 'Today, 2:00 PM',
        'address': '123 Main St, Lagos',
        'amount': '₦15,000',
        'progress': 0.6,
        'estimatedTime': '2 hours remaining',
        'description': 'Fix leaking kitchen sink and replace faucet',
      },
      {
        'id': 'BK002',
        'serviceName': 'Electrical Installation',
        'artisanName': 'Mike\'s Electrical',
        'artisanAvatar': '⚡',
        'status': 'Scheduled',
        'statusColor': Colors.blue,
        'scheduledDate': 'Tomorrow, 10:00 AM',
        'address': '456 Oak Ave, Lagos',
        'amount': '₦25,000',
        'progress': 0.0,
        'estimatedTime': 'Scheduled for tomorrow',
        'description': 'Install new ceiling fan and wiring',
      },
      {
        'id': 'BK003',
        'serviceName': 'House Cleaning',
        'artisanName': 'Clean Pro Services',
        'artisanAvatar': '🧹',
        'status': 'Confirmed',
        'statusColor': Colors.green,
        'scheduledDate': 'Today, 4:00 PM',
        'address': '789 Pine Rd, Lagos',
        'amount': '₦12,000',
        'progress': 0.0,
        'estimatedTime': 'Starting in 2 hours',
        'description': 'Deep cleaning of 3-bedroom apartment',
      },
    ];

    if (activeBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.schedule,
        title: 'No Active Bookings',
        subtitle: 'You don\'t have any active service bookings at the moment.',
        actionText: 'Book a Service',
        onAction: () {
          // TODO: Navigate to service booking
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeBookings.length,
      itemBuilder: (context, index) {
        final booking = activeBookings[index];
        return _buildActiveBookingCard(booking);
      },
    );
  }

  Widget _buildBookingHistoryTab() {
    // Sample booking history data
    final List<Map<String, dynamic>> completedBookings = [
      {
        'id': 'BK004',
        'serviceName': 'Carpentry Work',
        'artisanName': 'Bob\'s Carpentry',
        'artisanAvatar': '🔨',
        'status': 'Completed',
        'statusColor': Colors.green,
        'completedDate': '2 days ago',
        'address': '321 Elm St, Lagos',
        'amount': '₦18,000',
        'rating': 5,
        'review': 'Excellent work! Very professional and timely.',
        'description': 'Custom bookshelf installation',
      },
      {
        'id': 'BK005',
        'serviceName': 'Painting Service',
        'artisanName': 'Paint Masters',
        'artisanAvatar': '🎨',
        'status': 'Completed',
        'statusColor': Colors.green,
        'completedDate': '1 week ago',
        'address': '654 Maple Dr, Lagos',
        'amount': '₦35,000',
        'rating': 4,
        'review': 'Good quality work, but took longer than expected.',
        'description': 'Interior painting of living room and kitchen',
      },
      {
        'id': 'BK006',
        'serviceName': 'HVAC Maintenance',
        'artisanName': 'Cool Air Pro',
        'artisanAvatar': '❄️',
        'status': 'Completed',
        'statusColor': Colors.green,
        'completedDate': '2 weeks ago',
        'address': '987 Cedar Ln, Lagos',
        'amount': '₦22,000',
        'rating': 5,
        'review': 'Outstanding service! Fixed the issue quickly.',
        'description': 'AC unit maintenance and filter replacement',
      },
    ];

    if (completedBookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Booking History',
        subtitle: 'Your completed service bookings will appear here.',
        actionText: 'Book Your First Service',
        onAction: () {
          // TODO: Navigate to service booking
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedBookings.length,
      itemBuilder: (context, index) {
        final booking = completedBookings[index];
        return _buildCompletedBookingCard(booking);
      },
    );
  }

  Widget _buildActiveBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: booking['statusColor'].withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: booking['statusColor'],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  booking['scheduledDate'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service and artisan info
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          booking['artisanAvatar'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['serviceName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'by ${booking['artisanName']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          booking['amount'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  booking['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['address'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar for in-progress bookings
                if (booking['status'] == 'In Progress') ...[
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: booking['progress'],
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            booking['statusColor'],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(booking['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: booking['statusColor'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Estimated time
                Text(
                  booking['estimatedTime'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to booking details
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Contact artisan
                        },
                        icon: const Icon(Icons.message, size: 18),
                        label: const Text('Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with completion status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  booking['completedDate'],
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Booking details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service and artisan info
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          booking['artisanAvatar'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['serviceName'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            'by ${booking['artisanName']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          booking['amount'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  booking['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 16),

                // Address
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['address'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Rating
                Row(
                  children: [
                    ...List.generate(5, (index) {
                      return Icon(
                        index < booking['rating']
                            ? Icons.star
                            : Icons.star_border,
                        size: 20,
                        color: index < booking['rating']
                            ? Colors.amber
                            : Colors.grey.shade400,
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      '${booking['rating']}.0',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),

                if (booking['review'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      '"${booking['review']}"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to booking details
                        },
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(color: Color(0xFF2196F3)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Book again
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: const Text('Book Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 50, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with User Avatar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2196F3),
            automaticallyImplyLeading: false, // Remove back button
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: _currentUser['profilePicture'] != null
                            ? ClipOval(
                                child: Image.network(
                                  _currentUser['profilePicture'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        '👤',
                                        style: TextStyle(fontSize: 50),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Text(
                                  '👤',
                                  style: TextStyle(fontSize: 50),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      // User Name
                      Text(
                        '${_currentUser['firstName'] ?? ''} ${_currentUser['lastName'] ?? ''}'
                                .trim()
                                .isNotEmpty
                            ? '${_currentUser['firstName'] ?? ''} ${_currentUser['lastName'] ?? ''}'
                                  .trim()
                            : 'Kaira User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // User Email
                      Text(
                        _currentUser['email'] ?? 'user@kaira.app',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User Phone Number
                      if (_currentUser['phoneNumber'] != null &&
                          _currentUser['phoneNumber'].toString().isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              PhoneUtils.formatForDisplay(
                                _currentUser['phoneNumber'] ?? '',
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Section
                  _buildQuickStatsSection(),
                  const SizedBox(height: 24),

                  // Account Actions Section
                  _buildSectionHeader('Account', Icons.account_circle),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your personal information',
                    color: const Color(0xFF2196F3),
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/edit-profile',
                        arguments: {'userData': _currentUser},
                      );

                      // Refresh user data if profile was updated
                      if (result != null) {
                        await _loadUserData();
                        // Also refresh notification stats in case new notifications were created
                        _loadNotificationStats();
                      }
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: _unreadNotificationCount > 0
                        ? '$_unreadNotificationCount unread notifications'
                        : 'Manage your notification preferences',
                    color: const Color(0xFFFF9800),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsScreen(
                            onNotificationChanged: _loadNotificationStats,
                          ),
                        ),
                      );
                      // Refresh notification stats when returning
                      _loadNotificationStats();
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.security,
                    title: 'Privacy & Security',
                    subtitle: 'Control your privacy settings',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy-security');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Service Preferences Section
                  _buildSectionHeader('Service Preferences', Icons.tune),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Locations',
                    subtitle: 'Manage your favorite addresses',
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.pushNamed(context, '/saved-locations');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.favorite_outline,
                    title: 'Favorite Artisans',
                    subtitle: 'View your preferred service providers',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pushNamed(context, '/favorite-artisans');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage your payment options',
                    color: const Color(0xFF607D8B),
                    onTap: () {
                      Navigator.pushNamed(context, '/payment-methods');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Support & Help Section
                  _buildSectionHeader('Support & Help', Icons.help_outline),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.help_outline,
                    title: 'FAQ & Help Center',
                    subtitle: 'Find answers to common questions',
                    color: const Color(0xFF795548),
                    onTap: () {
                      Navigator.pushNamed(context, '/faq-help-center');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.support_agent,
                    title: 'Contact Support',
                    subtitle: 'Get help from our support team',
                    color: const Color(0xFF00BCD4),
                    onTap: () {
                      Navigator.pushNamed(context, '/contact-support');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Help us improve the app',
                    color: const Color(0xFFFF5722),
                    onTap: () {
                      Navigator.pushNamed(context, '/send-feedback');
                    },
                  ),
                  const SizedBox(height: 24),

                  // App Information Section
                  _buildSectionHeader('App Information', Icons.info_outline),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    color: const Color(0xFF3F51B5),
                    onTap: () {
                      Navigator.pushNamed(context, '/terms-of-service');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Learn about data protection',
                    color: const Color(0xFF009688),
                    onTap: () {
                      Navigator.pushNamed(context, '/privacy-policy');
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.info_outline,
                    title: 'About Kaira',
                    subtitle: 'App version and information',
                    color: const Color(0xFF673AB7),
                    onTap: () {
                      Navigator.pushNamed(context, '/about-kaira');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Account Actions Section
                  _buildSectionHeader('Account Actions', Icons.settings),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    color: const Color(0xFFFF9800),
                    onTap: () {
                      _showSignOutDialog();
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    color: const Color(0xFFF44336),
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.schedule,
                  value: '${_currentUser['bookings']?['activeBookings'] ?? 0}',
                  label: 'Active\nBookings',
                  color: const Color(0xFF2196F3),
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.check_circle,
                  value:
                      '${_currentUser['bookings']?['completedBookings'] ?? 0}',
                  label: 'Completed\nServices',
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade300),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.star,
                  value:
                      '${(_currentUser['rating'] ?? 0.0).toStringAsFixed(1)}',
                  label: 'Average\nRating',
                  color: const Color(0xFFFF9800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Color(0xFFF44336)),
              SizedBox(width: 12),
              Text('Delete Account'),
            ],
          ),
          content: const Text(
            'This action cannot be undone. All your data, bookings, and preferences will be permanently deleted.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement account deletion logic
                // Show confirmation, delete account, etc.
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF44336),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDraggableSheet() {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _sheetHeight -= details.delta.dy / MediaQuery.of(context).size.height;
          _sheetHeight = _sheetHeight.clamp(_minHeight, _maxHeight);
        });
      },
      onVerticalDragEnd: (details) {
        // Don't snap - just ensure it stays within bounds
        setState(() {
          _sheetHeight = _sheetHeight.clamp(_minHeight, _maxHeight);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height:
            MediaQuery.of(context).size.height *
            (_showingArtisans ? 0.4 : _sheetHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: _isArtisanSearchLoading
              ? _buildArtisanSearchLoading()
              : _showingArtisans
              ? _buildArtisansDraggable()
              : Column(
                  children: [
                    // Drag Handle
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 6),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Fixed Search Section
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Find Your Perfect Service',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search for trusted professionals in your area',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Search Bar
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              onTap: () {
                                // Focus on search field
                              },
                              decoration: InputDecoration(
                                hintText: 'What service do you need?',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.grey.shade500,
                                ),
                                suffixIcon: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.tune,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),

                          // Suggestions moved into scrollable section to avoid overflow
                        ],
                      ),
                    ),

                    if (_showSuggestions && _searchSuggestions.isNotEmpty)
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: _searchSuggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _searchSuggestions[index];
                              final isNoResults =
                                  suggestion['type'] == 'no_results';

                              return ListTile(
                                leading: Icon(
                                  isNoResults
                                      ? Icons.search_off
                                      : suggestion['type'] == 'service'
                                      ? Icons.build
                                      : Icons.category,
                                  color: isNoResults
                                      ? Colors.grey
                                      : suggestion['color'] != null
                                      ? Color(
                                          int.parse(
                                            '0xFF${suggestion['color'].substring(1)}',
                                          ),
                                        )
                                      : Colors.grey,
                                ),
                                title: Text(
                                  suggestion['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: isNoResults ? Colors.grey : null,
                                    fontStyle: isNoResults
                                        ? FontStyle.italic
                                        : null,
                                  ),
                                ),
                                subtitle: Text(
                                  isNoResults
                                      ? suggestion['description'] ??
                                            'Try a different search term'
                                      : suggestion['type'] == 'service'
                                      ? 'Service'
                                      : 'Category',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: isNoResults
                                    ? null
                                    : () => _onSuggestionSelected(suggestion),
                              );
                            },
                          ),
                        ),
                      ),

                    // Scrollable Content Section - Made more flexible
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Service Categories
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Popular Services',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AllServicesPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF2196F3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Horizontal Scrollable Service Cards
                            SizedBox(
                              height: 107,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _buildServiceCategory(
                                    'Plumbing',
                                    Icons.plumbing,
                                    Colors.blue,
                                    'Fix leaks, install fixtures',
                                  ),
                                  _buildServiceCategory(
                                    'Electrical',
                                    Icons.electrical_services,
                                    Colors.orange,
                                    'Wiring, repairs, installations',
                                  ),
                                  _buildServiceCategory(
                                    'Cleaning',
                                    Icons.cleaning_services,
                                    Colors.green,
                                    'Home & office cleaning',
                                  ),
                                  _buildServiceCategory(
                                    'Carpentry',
                                    Icons.handyman,
                                    Colors.brown,
                                    'Furniture & repairs',
                                  ),
                                  _buildServiceCategory(
                                    'Painting',
                                    Icons.brush,
                                    Colors.purple,
                                    'Interior & exterior painting',
                                  ),
                                  _buildServiceCategory(
                                    'Gardening',
                                    Icons.eco,
                                    Colors.teal,
                                    'Landscaping & maintenance',
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Last Booked Services
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Last Booked Services',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentIndex =
                                          1; // Switch to Bookings tab
                                    });
                                  },
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2196F3),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Last Booked Services List
                            Column(
                              children: [
                                _buildBookedServiceItem(
                                  'Plumbing Service',
                                  'John Smith',
                                  'Completed',
                                  '2 days ago',
                                  Icons.plumbing,
                                  Colors.blue,
                                  'Fixed kitchen sink leak',
                                ),
                                const SizedBox(height: 12),
                                _buildBookedServiceItem(
                                  'House Cleaning',
                                  'Sarah Johnson',
                                  'Completed',
                                  '1 week ago',
                                  Icons.cleaning_services,
                                  Colors.green,
                                  'Deep cleaning - 3 bedrooms',
                                ),
                                const SizedBox(height: 12),
                                _buildBookedServiceItem(
                                  'Electrical Repair',
                                  'Mike Wilson',
                                  'Completed',
                                  '2 weeks ago',
                                  Icons.electrical_services,
                                  Colors.orange,
                                  'Fixed ceiling fan wiring',
                                ),
                                const SizedBox(height: 12),
                                _buildBookedServiceItem(
                                  'Carpentry Work',
                                  'David Brown',
                                  'Completed',
                                  '3 weeks ago',
                                  Icons.handyman,
                                  Colors.brown,
                                  'Built custom bookshelf',
                                ),
                                const SizedBox(height: 12),
                                _buildBookedServiceItem(
                                  'Painting Service',
                                  'Emma Davis',
                                  'Completed',
                                  '1 month ago',
                                  Icons.brush,
                                  Colors.purple,
                                  'Living room repainting',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    if (_currentPosition == null) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2), Color(0xFF0D47A1)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLocationLoading) ...[
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Getting your location...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.location_on,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentAddress,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * _minHeight,
      ),
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          zoom: 15.0,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: false,
        mapType: MapType.normal,
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 16,
          left: 20,
          right: 20,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(
                      onNotificationChanged: _loadNotificationStats,
                    ),
                  ),
                );
                // Refresh notification stats when returning from notifications screen
                _loadNotificationStats();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications,
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                    if (_unreadNotificationCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            _unreadNotificationCount > 99
                                ? '99+'
                                : _unreadNotificationCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRect(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2196F3),
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: _bottomNavItems.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(
                _currentIndex == _bottomNavItems.indexOf(item)
                    ? item.activeIcon
                    : item.icon,
                size: 24,
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // TODO: Implement navigation to different pages
    // For now, just update the index
  }

  Widget _buildServiceCategory(
    String title,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Direct Service Search
            _onCategoryTapped(title);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    color: color.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookedServiceItem(
    String serviceName,
    String professionalName,
    String status,
    String timeAgo,
    IconData icon,
    Color color,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'by $professionalName',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeAgo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}
