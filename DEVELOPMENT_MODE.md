# Development Mode Configuration

## Overview

The End User App has been configured with a development mode that skips authentication and goes directly to the onboarding and guest dashboard during development. This makes it easier to test the app without going through the full authentication flow.

## How It Works

### Development Mode (Default)
- **Authentication**: Skipped - app goes directly to onboarding
- **Onboarding**: Still shown to users
- **Navigation**: Onboarding → Guest Dashboard
- **API Endpoints**: Uses localhost (http://10.0.2.2:3000)
- **Indicators**: Shows "DEV MODE" and "DEV" indicators

### Production Mode
- **Authentication**: Full flow with login/signup
- **Onboarding**: Shown to new users
- **Navigation**: Splash → Onboarding → Login/Signup → Home
- **API Endpoints**: Uses production URLs
- **Indicators**: No development indicators

## Switching Modes

To switch between development and production modes, edit the file:

```
lib/core/config/app_mode.dart
```

Change this line:
```dart
static const AppMode currentMode = AppMode.development;
```

To:
```dart
static const AppMode currentMode = AppMode.production;
```

## Configuration Files

### 1. App Mode Configuration
- **File**: `lib/core/config/app_mode.dart`
- **Purpose**: Controls the main app behavior
- **Usage**: Change `currentMode` to switch modes

### 2. Environment Configuration
- **File**: `lib/core/config/environment_config.dart`
- **Purpose**: Manages API endpoints and environment-specific settings
- **Usage**: Automatically configured based on app mode

### 3. App Constants
- **File**: `lib/core/constants/app_constants.dart`
- **Purpose**: Provides app-wide constants and configuration access
- **Usage**: Automatically configured based on environment

## Development Mode Features

### Visual Indicators
- **Onboarding Page**: Shows "DEV MODE" badge
- **Guest Dashboard**: Shows "DEV" badge in app bar
- **Splash Screen**: Skips authentication checks

### Behavior Changes
- **Authentication Flow**: Completely bypassed
- **Storage**: Still saves onboarding completion status
- **Navigation**: Direct path to guest dashboard
- **API Calls**: Uses localhost endpoints

## Production Mode Features

### Normal Flow
- **Splash Screen**: Checks authentication status
- **Onboarding**: Shown to new users
- **Authentication**: Full login/signup flow
- **Home Screen**: Protected routes for authenticated users

### Security
- **JWT Tokens**: Required for protected routes
- **User Sessions**: Properly managed
- **API Security**: Production endpoints with authentication

## Testing

### Development Testing
1. Run the app
2. App goes directly to onboarding
3. Complete onboarding
4. App goes to guest dashboard
5. All features accessible without authentication

### Production Testing
1. Change mode to `AppMode.production`
2. Run the app
3. App follows normal authentication flow
4. Test login/signup functionality
5. Verify protected routes work correctly

## When to Use Each Mode

### Development Mode
- ✅ **During development**
- ✅ **Testing UI components**
- ✅ **Demo purposes**
- ✅ **Quick feature testing**
- ❌ **Not for production builds**

### Production Mode
- ✅ **Production builds**
- ✅ **Testing authentication flow**
- ✅ **User acceptance testing**
- ✅ **Security testing**
- ❌ **Not for development**

## Troubleshooting

### Common Issues

1. **App still shows authentication**
   - Check `app_mode.dart` file
   - Ensure `currentMode` is set to `AppMode.development`
   - Restart the app

2. **API calls failing**
   - Verify backend is running on localhost:3000
   - Check network configuration
   - Ensure correct API endpoints

3. **Development indicators not showing**
   - Check `AppConstants.skipAuthentication` value
   - Verify environment configuration
   - Restart the app

### Reset Development Mode
If you need to reset the development mode:

1. Edit `lib/core/config/app_mode.dart`
2. Set `currentMode = AppMode.development`
3. Clear app data or uninstall/reinstall
4. Restart the app

## Future Enhancements

### Planned Features
- **Runtime Mode Switching**: Switch modes without rebuilding
- **Environment Variables**: Use .env files for configuration
- **Build Variants**: Different builds for different modes
- **Feature Flags**: More granular control over features

### Current Limitations
- **Rebuild Required**: Mode changes require app restart
- **Single Mode**: Can't switch modes at runtime
- **Manual Configuration**: Requires editing source code

## Support

For questions or issues with development mode:

1. Check this documentation
2. Review the configuration files
3. Check console logs for errors
4. Verify backend connectivity
5. Contact the development team
