import 'package:flutter/foundation.dart';
import '../config/app_mode.dart';

class Logger {
  static void debug(String message) {
    if (AppModeConfig.isDevelopment && kDebugMode) {
      print('🐛 DEBUG: $message');
    }
  }

  static void info(String message) {
    if (AppModeConfig.isDevelopment && kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (AppModeConfig.isDevelopment && kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }

  static void success(String message) {
    if (AppModeConfig.isDevelopment && kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }
}
