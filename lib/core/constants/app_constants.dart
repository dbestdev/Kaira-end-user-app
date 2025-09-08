import '../config/environment_config.dart';

class AppConstants {
  // App Info
  static const String appName = 'Kaira';
  static const String appVersion = '1.0.0';

  // API Endpoints
  // Use environment configuration for base URL
  static String get baseUrl => EnvironmentConfig.apiBaseUrl;
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String servicesEndpoint = '/services';
  static const String artisansEndpoint = '/artisans';
  static const String bookingsEndpoint = '/bookings';
  static const String paymentsEndpoint = '/payments';
  static const String notificationsEndpoint = '/notifications';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'isLoggedIn';
  static const String themeKey = 'app_theme';
  static const String languageKey = 'app_language';
  static const String locationKey = 'user_location';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Timeouts
  static int get connectionTimeout =>
      EnvironmentConfig.getConfig('connectionTimeout', defaultValue: 30000);
  static int get receiveTimeout =>
      EnvironmentConfig.getConfig('receiveTimeout', defaultValue: 30000);

  // Pagination
  static const int defaultPageSize = 20;

  // Location
  static const double defaultLatitude = 0.0;
  static const double defaultLongitude = 0.0;
  static const double defaultZoom = 15.0;
  static const double searchRadius = 10.0; // km

  // Service Categories
  static const List<String> serviceCategories = [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Carpentry',
    'Painting',
    'Landscaping',
    'HVAC',
    'Moving',
  ];

  // Development Flags
  static bool get skipAuthentication =>
      EnvironmentConfig.getConfig('skipAuthentication', defaultValue: false);
  static bool get skipOnboarding =>
      EnvironmentConfig.getConfig('skipOnboarding', defaultValue: false);
}
