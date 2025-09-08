import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/user_provider.dart';

class OtpVerificationPageRiverpod extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String email;
  final Map<String, dynamic> signUpData;

  const OtpVerificationPageRiverpod({
    super.key,
    required this.phoneNumber,
    required this.email,
    required this.signUpData,
  });

  @override
  ConsumerState<OtpVerificationPageRiverpod> createState() =>
      _OtpVerificationPageRiverpodState();
}

class _OtpVerificationPageRiverpodState
    extends ConsumerState<OtpVerificationPageRiverpod> {
  final List<TextEditingController> _smsOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _emailOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  bool _isSmsOtpVerified = false;
  bool _isEmailOtpVerified = false;
  String? _successMessage;

  // SMS OTP timer
  int _smsResendSeconds = 0;
  bool _canResendSms = true;

  @override
  void initState() {
    super.initState();
    _sendInitialOtp();
  }

  @override
  void dispose() {
    for (var controller in _smsOtpControllers) {
      controller.dispose();
    }
    for (var controller in _emailOtpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _sendInitialOtp() async {
    // OTP is already sent during signup initiation
    // Just start the resend timer and show success message
    if (mounted) {
      setState(() {
        _successMessage = 'SMS OTP sent to ${widget.phoneNumber}';
      });
      _startSmsResendTimer();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    }
  }

  void _startSmsResendTimer() {
    _canResendSms = false;
    _smsResendSeconds = 60;
    setState(() {});

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _smsResendSeconds--;
        });
        return _smsResendSeconds > 0;
      }
      return false;
    }).then((_) {
      if (mounted) {
        setState(() {
          _canResendSms = true;
        });
      }
    });
  }

  Future<void> _verifySmsOtp() async {
    final smsOtp = _smsOtpControllers.map((c) => c.text).join();

    if (smsOtp.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    await ref
        .read(authStateProvider.notifier)
        .verifySmsOtp(phoneNumber: widget.phoneNumber, otpCode: smsOtp);

    final authState = ref.read(authStateProvider);
    if (authState.error != null) {
      _showError(authState.error!);
    } else {
      setState(() {
        _isSmsOtpVerified = true;
        _successMessage = 'SMS OTP verified successfully!';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    }
  }

  Future<void> _verifyEmailOtp() async {
    final emailOtp = _emailOtpControllers.map((c) => c.text).join();

    if (emailOtp.length != 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    await ref
        .read(authStateProvider.notifier)
        .verifyEmailOtp(
          email: widget.email,
          otpCode: emailOtp,
          signUpData: widget.signUpData,
        );

    final authState = ref.read(authStateProvider);
    if (authState.error != null) {
      _showError(authState.error!);
    } else {
      // Store user data and navigate immediately
      final userData = authState.user;
      if (userData != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userData', jsonEncode(userData));

        // Update user data provider
        await ref.read(userDataProvider.notifier).updateUserData(userData);
      }

      setState(() {
        _isEmailOtpVerified = true;
        _successMessage = 'Account created successfully! Welcome to Kaira! 🎉';
      });

      // Navigate immediately
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _clearSmsOtpFields() {
    for (var controller in _smsOtpControllers) {
      controller.clear();
    }
  }

  void _clearEmailOtpFields() {
    for (var controller in _emailOtpControllers) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Verify Your Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent verification codes to your phone and email',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Success/Error Messages
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),

              // SMS OTP Section
              _buildOtpSection(
                title: 'SMS Verification',
                subtitle:
                    'Enter the 6-digit code sent to ${widget.phoneNumber}',
                controllers: _smsOtpControllers,
                isVerified: _isSmsOtpVerified,
                onVerify: _verifySmsOtp,
                onResend: () async {
                  await ref
                      .read(authStateProvider.notifier)
                      .sendOtp(identifier: widget.phoneNumber, type: 'sms');
                  _startSmsResendTimer();
                  _clearSmsOtpFields();
                },
                canResend: _canResendSms,
                resendSeconds: _smsResendSeconds,
                isLoading: authState.isLoading,
              ),

              const SizedBox(height: 40),

              // Email OTP Section
              if (_isSmsOtpVerified)
                _buildOtpSection(
                  title: 'Email Verification',
                  subtitle: 'Enter the 6-digit code sent to ${widget.email}',
                  controllers: _emailOtpControllers,
                  isVerified: _isEmailOtpVerified,
                  onVerify: _verifyEmailOtp,
                  onResend: () async {
                    await ref
                        .read(authStateProvider.notifier)
                        .sendOtp(identifier: widget.email, type: 'email');
                    _clearEmailOtpFields();
                  },
                  canResend: true,
                  resendSeconds: 0,
                  isLoading: authState.isLoading,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpSection({
    required String title,
    required String subtitle,
    required List<TextEditingController> controllers,
    required bool isVerified,
    required VoidCallback onVerify,
    required VoidCallback onResend,
    required bool canResend,
    required int resendSeconds,
    required bool isLoading,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            if (isVerified)
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 20),

        // OTP Input Fields
        Pinput(
          length: 6,
          controller: controllers[0],
          focusNode: FocusNode(),
          defaultPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          focusedPinTheme: PinTheme(
            width: 50,
            height: 50,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            // Handle OTP input
            for (int i = 0; i < 6; i++) {
              if (i < value.length) {
                controllers[i].text = value[i];
              } else {
                controllers[i].clear();
              }
            }
          },
        ),

        const SizedBox(height: 20),

        // Verify Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    isVerified ? 'Verified' : 'Verify',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Resend Button
        Center(
          child: TextButton(
            onPressed: canResend ? onResend : null,
            child: Text(
              canResend ? 'Resend Code' : 'Resend in ${resendSeconds}s',
              style: TextStyle(
                color: canResend ? Colors.blue : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
