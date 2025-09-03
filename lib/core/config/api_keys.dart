// API Keys Configuration
// This file should be added to .gitignore to prevent committing sensitive keys
// For production, use environment variables or secure key management

class ApiKeys {
  // Google Places API Key
  // TODO: Move this to environment variables or secure storage
  // For now, this is a placeholder - replace with your actual API key
  static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';

  // Other API keys can be added here
  // static const String mapboxApiKey = 'YOUR_MAPBOX_API_KEY_HERE';
  // static const String firebaseApiKey = 'YOUR_FIREBASE_API_KEY_HERE';

  // Validation methods
  static bool get isGooglePlacesConfigured =>
      googlePlacesApiKey != 'YOUR_GOOGLE_PLACES_API_KEY_HERE' &&
      googlePlacesApiKey.isNotEmpty;
}
