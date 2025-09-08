# 🗺️ Google Maps Setup Guide

## 🔧 **Setup Instructions**

### **1. Get Google Maps API Key**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable the following APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Maps JavaScript API**
   - **Places API**
   - **Geocoding API**
4. Create credentials → API Key
5. Restrict the API key to your app's package name and bundle ID

### **2. Configure API Key**

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in these files with your actual API key:

#### **Android Configuration:**
- `android/app/src/main/AndroidManifest.xml` (line 42)
- Set environment variable: `GOOGLE_MAPS_API_KEY=your_key_here`

#### **iOS Configuration:**
- `ios/Runner/Info.plist` (line 57)
- `ios/Runner/AppDelegate.swift` (line 11)

#### **Web Configuration:**
- `web/index.html` (line 36)

#### **Flutter Code:**
- `lib/core/constants/maps_constants.dart` (line 4)

### **3. Test the Map**

1. Run the app: `flutter run`
2. Navigate to `/map-test` route
3. Check the debug information panel
4. Verify location permissions are granted

### **4. Common Issues & Solutions**

#### **Map Not Displaying:**
- ✅ Check API key is correct
- ✅ Verify APIs are enabled in Google Cloud Console
- ✅ Check location permissions
- ✅ Ensure internet connection
- ✅ Try on physical device (not emulator)

#### **Location Not Working:**
- ✅ Check location permissions in device settings
- ✅ Ensure location services are enabled
- ✅ Try different location accuracy settings

#### **API Key Errors:**
- ✅ Verify API key restrictions
- ✅ Check package name matches Google Cloud Console
- ✅ Ensure all required APIs are enabled

### **5. Debug Steps**

1. **Check Console Logs:**
   ```bash
   flutter run --verbose
   ```

2. **Test Map Test Page:**
   - Navigate to `/map-test`
   - Check debug information
   - Verify location and map creation

3. **Verify Permissions:**
   - Android: Check in device settings
   - iOS: Check in device settings

### **6. Production Considerations**

- Use different API keys for development and production
- Set up proper API key restrictions
- Monitor API usage and costs
- Implement proper error handling

## 🚀 **Quick Test**

1. Replace API key in all configuration files
2. Run: `flutter clean && flutter pub get`
3. Run: `flutter run`
4. Navigate to map test page
5. Verify map displays correctly

## 📞 **Support**

If you're still having issues:
1. Check the debug information in the map test page
2. Verify all configuration files have the correct API key
3. Test on a physical device
4. Check Google Cloud Console for API usage and errors
