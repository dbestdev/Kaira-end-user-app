// App Mode Configuration
// Change this value to switch between development and production modes
//
// Development Mode:
// - Skips authentication
// - Shows development indicators
// - Goes directly to onboarding then guest dashboard
// - Uses localhost API endpoints
//
// Production Mode:
// - Full authentication flow
// - No development indicators
// - Normal app flow with login/signup
// - Uses production API endpoints

enum AppMode { development, production }

class AppModeConfig {
  // Change this to switch modes
  static const AppMode currentMode = AppMode.development;

  // Helper getters
  static bool get isDevelopment => currentMode == AppMode.development;
  static bool get isProduction => currentMode == AppMode.production;

  // Development flags
  static bool get skipAuthentication => isDevelopment;
  static bool get skipOnboarding => false; // Always show onboarding
  static bool get showDevIndicators => isDevelopment;

  // Environment selection
  static String get environmentName =>
      isDevelopment ? 'development' : 'production';

  // Quick mode switching
  static void setDevelopmentMode() {
    // This would need to be implemented with a more sophisticated approach
    // For now, just change the currentMode constant above
    print(
      'To switch to development mode, change currentMode to AppMode.development',
    );
  }

  static void setProductionMode() {
    // This would need to be implemented with a more sophisticated approach
    // For now, just change the currentMode constant above
    print(
      'To switch to production mode, change currentMode to AppMode.production',
    );
  }
}
