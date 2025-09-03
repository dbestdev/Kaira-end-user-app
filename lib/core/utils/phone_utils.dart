class PhoneUtils {
  /// Normalize phone number to consistent format
  /// Removes all non-digit characters and formats to international format
  /// Returns normalized phone number (13 digits starting with 234)
  static String normalizePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      throw Exception('Phone number is required');
    }

    // Remove all non-digit characters (spaces, dashes, parentheses, etc.)
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different input formats
    if (cleanPhone.length == 11 && cleanPhone.startsWith('0')) {
      // Nigerian format: 08012345678 -> 2348012345678
      cleanPhone = '234${cleanPhone.substring(1)}';
    } else if (cleanPhone.length == 10) {
      // 10 digits without country code: 8012345678 -> 2348012345678
      cleanPhone = '234$cleanPhone';
    } else if (cleanPhone.length == 13 && cleanPhone.startsWith('234')) {
      // Already in correct format: 2348012345678
      // Keep as is
    } else if (cleanPhone.length == 14 && cleanPhone.startsWith('234')) {
      // International format with +: +2348012345678 -> 2348012345678
      cleanPhone = cleanPhone.substring(1);
    } else {
      throw Exception(
        'Invalid phone number format: $phoneNumber. Expected Nigerian number (e.g., 08012345678)',
      );
    }

    // Validate the final format
    if (cleanPhone.length != 13 || !cleanPhone.startsWith('234')) {
      throw Exception(
        'Invalid phone number format: $phoneNumber. Expected Nigerian number (e.g., 08012345678)',
      );
    }

    return cleanPhone;
  }

  /// Convert 13-digit format back to 11-digit format for display
  /// Converts 2348012345678 -> 08012345678
  static String toDisplayFormat(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return phoneNumber;
    }

    // Remove all non-digit characters
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // If it's 13 digits starting with 234, convert to 11-digit format
    if (cleanPhone.length == 13 && cleanPhone.startsWith('234')) {
      return '0${cleanPhone.substring(3)}';
    }

    // If it's already 11 digits, return as is
    if (cleanPhone.length == 11 && cleanPhone.startsWith('0')) {
      return cleanPhone;
    }

    // Return original if format is not recognized
    return phoneNumber;
  }

  /// Validate phone number format
  /// Returns true if phone number is valid Nigerian mobile number
  static bool isValidNigerianPhone(String phoneNumber) {
    try {
      String normalized = normalizePhoneNumber(phoneNumber);
      // Check if it's a valid Nigerian mobile number
      RegExp mobileRegex = RegExp(r'^234[789][01]\d{8}$');
      return mobileRegex.hasMatch(normalized);
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for display (adds spaces for readability)
  /// Returns formatted phone number for display
  static String formatForDisplay(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return phoneNumber;
    }

    // Convert to 11-digit format first
    String displayPhone = toDisplayFormat(phoneNumber);

    // Add spaces for readability: 08012345678 -> 080 123 456 78
    if (displayPhone.length == 11 && displayPhone.startsWith('0')) {
      return '${displayPhone.substring(0, 3)} ${displayPhone.substring(3, 6)} ${displayPhone.substring(6, 9)} ${displayPhone.substring(9)}';
    }

    return displayPhone;
  }

  /// Compare two phone numbers (normalizes both before comparison)
  /// Returns true if phone numbers are the same
  static bool areEqual(String phone1, String phone2) {
    try {
      String normalized1 = normalizePhoneNumber(phone1);
      String normalized2 = normalizePhoneNumber(phone2);
      return normalized1 == normalized2;
    } catch (e) {
      return false;
    }
  }

  /// Format phone number for input (removes spaces and special characters)
  /// Returns clean phone number for API calls
  static String formatForInput(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }
}
