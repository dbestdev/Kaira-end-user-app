import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';

class ChangePhonePage extends StatefulWidget {
  final String currentPhone;

  const ChangePhonePage({super.key, required this.currentPhone});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final _formKey = GlobalKey<FormState>();
  final _newPhoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  bool _isVerifyingOtp = false;
  bool _isPhoneValid = false;
  bool _showPhoneError = false;
  late final StorageService _storageService;

  // PinPut theme
  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 24,
      color: Color(0xFF2C2C2C),
      fontWeight: FontWeight.w700,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade400, width: 1.5),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade200,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
  );

  final focusedPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 24,
      color: Color(0xFF2196F3),
      fontWeight: FontWeight.w700,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFF2196F3), width: 2.5),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2196F3).withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
  );

  final submittedPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 24,
      color: Colors.white,
      fontWeight: FontWeight.w700,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFF4CAF50),
      border: Border.all(color: const Color(0xFF4CAF50), width: 2),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
  );

  @override
  void initState() {
    super.initState();
    _storageService = StorageService(FlutterSecureStorage());
    _newPhoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _newPhoneController.removeListener(_validatePhone);
    _newPhoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _validatePhone() {
    final phone = _newPhoneController.text.trim();
    bool isValid = false;

    try {
      if (phone.isNotEmpty) {
        // Check if it's a valid Nigerian phone number
        isValid = PhoneUtils.isValidNigerianPhone(phone);

        // Check if it's different from current phone
        if (isValid) {
          isValid = !PhoneUtils.areEqual(phone, widget.currentPhone);
        }
      }
    } catch (e) {
      isValid = false;
    }

    setState(() {
      _isPhoneValid = isValid;
      // Show error if user has typed something but it's invalid
      _showPhoneError = phone.isNotEmpty && !isValid;
    });
  }

  Future<void> _sendOtpToNewPhone() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storageService.getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Normalize phone number before sending
      final normalizedPhone = PhoneUtils.normalizePhoneNumber(
        _newPhoneController.text.trim(),
      );

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/change-phone/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'newPhoneNumber': normalizedPhone}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          setState(() {
            _otpSent = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('OTP sent to ${_newPhoneController.text.trim()}'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          final errorMessage = responseData['message'] ?? 'Failed to send OTP';
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage = responseData['message'] ?? 'Failed to send OTP';
        throw Exception(errorMessage);
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtpAndChangePhone() async {
    if (_otpController.text.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter the 6-digit OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isVerifyingOtp = true;
    });

    try {
      final token = await _storageService.getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Normalize phone number before sending
      final normalizedPhone = PhoneUtils.normalizePhoneNumber(
        _newPhoneController.text.trim(),
      );

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/auth/change-phone/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'newPhoneNumber': normalizedPhone,
          'otp': _otpController.text,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Update local storage with complete updated user data from server
        final updatedUserData = responseData['data']['user'];
        await _storageService.storeUserData(jsonEncode(updatedUserData));

        // Also update SharedPreferences for HomePage compatibility
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(updatedUserData));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phone number changed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Return the complete updated user data so parent can refresh
          Navigator.of(context).pop(updatedUserData);
        }
      } else {
        throw Exception(responseData['message'] ?? 'Failed to verify OTP');
      }
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingOtp = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Change Phone Number',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_otpSent) ...[
                _buildPhoneInputSection(),
                const SizedBox(height: 24),
                _buildSendOtpButton(),
              ] else ...[
                _buildOtpInputSection(),
                const SizedBox(height: 24),
                _buildVerifyOtpButton(),
                const SizedBox(height: 16),
                _buildResendOtpButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter New Phone Number',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your new phone number below. We\'ll send a verification code to confirm the change.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _newPhoneController,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              try {
                if (!PhoneUtils.isValidNigerianPhone(value)) {
                  return 'Please enter a valid Nigerian phone number';
                }
                if (PhoneUtils.areEqual(value, widget.currentPhone)) {
                  return 'This is already your current phone number';
                }
              } catch (e) {
                return 'Please enter a valid Nigerian phone number';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Enter new phone number',
              prefixIcon: Icon(
                Icons.phone_outlined,
                color: _showPhoneError ? Colors.red : const Color(0xFF2196F3),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showPhoneError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showPhoneError ? Colors.red : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showPhoneError ? Colors.red : const Color(0xFF2196F3),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              filled: true,
              fillColor: _showPhoneError
                  ? Colors.red.withValues(alpha: 0.05)
                  : Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          if (_showPhoneError) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Invalid phone number',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOtpInputSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OTP Instructions with Enhanced Styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      color: const Color(0xFF2196F3),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phone Number Change Verification',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            'We sent a 6-digit code to verify your new phone:\n',
                      ),
                      TextSpan(
                        text: _newPhoneController.text.trim(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const TextSpan(
                        text: '\n\nThis code will expire in 10 minutes.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Enhanced OTP Input Container
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Pinput(
                  controller: _otpController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) {
                    // Auto-verify when 6 digits are entered
                    _verifyOtpAndChangePhone();
                  },
                ),
                const SizedBox(height: 16),

                // Security Note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade200, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security_outlined,
                        color: Colors.amber.shade700,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'For your security, this code can only be used once',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSendOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_isLoading || !_isPhoneValid) ? null : _sendOtpToNewPhone,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isPhoneValid
              ? const Color(0xFF2196F3)
              : Colors.grey.shade300,
          foregroundColor: _isPhoneValid ? Colors.white : Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Send Verification Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isPhoneValid ? Colors.white : Colors.grey.shade500,
                ),
              ),
      ),
    );
  }

  Widget _buildVerifyOtpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isVerifyingOtp ? null : _verifyOtpAndChangePhone,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF2196F3).withValues(alpha: 0.3),
        ),
        child: _isVerifyingOtp
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Verify & Update Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResendOtpButton() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: TextButton.icon(
          onPressed: _isLoading ? null : _sendOtpToNewPhone,
          icon: Icon(Icons.refresh, size: 16, color: const Color(0xFF2196F3)),
          label: Text(
            'Resend Code',
            style: TextStyle(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
