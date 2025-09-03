import 'package:flutter/foundation.dart';

class Logger {
  static void debug(String message) {
    if (kDebugMode) {
      print('🐛 DEBUG: $message');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }
}
