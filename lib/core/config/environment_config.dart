import 'app_mode.dart';

enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment get _environment {
    // Use app mode configuration to determine environment
    switch (AppModeConfig.currentMode) {
      case AppMode.development:
        return Environment.development;
      case AppMode.production:
        return Environment.production;
    }
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  // API Base URLs for different environments
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        // For Android emulator, use 10.0.2.2 (maps to host machine's localhost)
        // For iOS simulator, use localhost
        // For web, use localhost
        return 'http://10.0.2.2:3000';
      case Environment.staging:
        return 'https://staging-api.kaira.com';
      case Environment.production:
        return 'https://kaira-backend-api-production.up.railway.app';
    }
  }

  // WebSocket URLs for different environments
  static String get webSocketUrl {
    switch (_environment) {
      case Environment.development:
        return 'ws://10.0.2.2:3000';
      case Environment.staging:
        return 'wss://staging-ws.kaira.com';
      case Environment.production:
        return 'wss://ws.kaira.com';
    }
  }

  // App configuration for different environments
  static Map<String, dynamic> get appConfig {
    switch (_environment) {
      case Environment.development:
        return {
          'enableLogging': true,
          'enableAnalytics': false,
          'enableCrashReporting': false,
          'connectionTimeout': 30000,
          'receiveTimeout': 30000,
          'maxRetries': 3,
          'skipAuthentication': AppModeConfig.skipAuthentication,
          'skipOnboarding': AppModeConfig.skipOnboarding,
        };
      case Environment.staging:
        return {
          'enableLogging': true,
          'enableAnalytics': true,
          'enableCrashReporting': false,
          'connectionTimeout': 30000,
          'receiveTimeout': 30000,
          'maxRetries': 3,
          'skipAuthentication': false,
          'skipOnboarding': false,
        };
      case Environment.production:
        return {
          'enableLogging': false,
          'enableAnalytics': true,
          'enableCrashReporting': true,
          'connectionTimeout': 15000,
          'receiveTimeout': 15000,
          'maxRetries': 2,
          'skipAuthentication': false,
          'skipOnboarding': false,
        };
    }
  }

  // Get configuration value
  static T getConfig<T>(String key, {T? defaultValue}) {
    final config = appConfig[key];
    if (config != null && config is T) {
      return config;
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    throw Exception(
      'Configuration key "$key" not found for environment $_environment',
    );
  }

  // Feature flags for different environments
  static Map<String, bool> get featureFlags {
    switch (_environment) {
      case Environment.development:
        return {
          'enableDebugMode': true,
          'enableTestData': true,
          'enableMockServices': true,
          'enablePerformanceMonitoring': false,
          'enableA/BTesting': false,
        };
      case Environment.staging:
        return {
          'enableDebugMode': true,
          'enableTestData': false,
          'enableMockServices': false,
          'enablePerformanceMonitoring': true,
          'enableA/BTesting': true,
        };
      case Environment.production:
        return {
          'enableDebugMode': false,
          'enableTestData': false,
          'enableMockServices': false,
          'enablePerformanceMonitoring': true,
          'enableA/BTesting': true,
        };
    }
  }

  // Get feature flag value
  static bool getFeatureFlag(String key, {bool defaultValue = false}) {
    return featureFlags[key] ?? defaultValue;
  }

  // Check if feature is enabled
  static bool isFeatureEnabled(String key) {
    return getFeatureFlag(key);
  }

  // Get environment name as string
  static String get environmentName {
    switch (_environment) {
      case Environment.development:
        return 'Development';
      case Environment.staging:
        return 'Staging';
      case Environment.production:
        return 'Production';
    }
  }

  // Get environment color for UI
  static int get environmentColor {
    switch (_environment) {
      case Environment.development:
        return 0xFF2196F3; // Blue
      case Environment.staging:
        return 0xFFFF9800; // Orange
      case Environment.production:
        return 0xFF4CAF50; // Green
    }
  }
}
