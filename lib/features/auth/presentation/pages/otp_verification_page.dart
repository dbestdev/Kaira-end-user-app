import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final Map<String, dynamic> signUpData;
  final String phoneNumber;
  final String email;

  const OtpVerificationPage({
    super.key,
    required this.signUpData,
    required this.phoneNumber,
    required this.email,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<TextEditingController> _smsOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _emailOtpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  final List<FocusNode> _smsOtpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final List<FocusNode> _emailOtpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isSmsOtpVerified = false;
  bool _isEmailOtpVerified = false;
  bool _isResendingSms = false;
  bool _isResendingEmail = false;

  String? _successMessage;

  // Separate timers for SMS and Email OTP resend countdown
  int _smsResendCountdown = 60;
  bool _canResendSms = false;
  int _emailResendCountdown = 60;
  bool _canResendEmail = false;

  final AuthService _authService = AuthService();

  // Helper method to format phone number to international format
  String _formatPhoneNumber(String phoneNumber) {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return '234${cleanPhone.substring(1)}'; // Remove leading 0 and add 234 (without +)
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _sendInitialOtp();
    // Don't start timer immediately - wait for initial OTP to be sent
  }

  void _startSmsResendTimer() {
    _canResendSms = false;
    _smsResendCountdown = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_smsResendCountdown > 0) {
            _smsResendCountdown--;
          } else {
            _canResendSms = true;
            _smsResendCountdown = 0;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startEmailResendTimer() {
    _canResendEmail = false;
    _emailResendCountdown = 60;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_emailResendCountdown > 0) {
            _emailResendCountdown--;
          } else {
            _canResendEmail = true;
            _emailResendCountdown = 0;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resetSmsResendTimer() {
    _canResendSms = false;
    _smsResendCountdown = 60;
    _startSmsResendTimer();
  }

  void _resetEmailResendTimer() {
    _canResendEmail = false;
    _emailResendCountdown = 60;
    _startEmailResendTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  // Timer methods removed - no more waiting restrictions

  Future<void> _sendInitialOtp() async {
    // OTP is already sent during signup initiation
    // Just start the resend timer and show success message
    if (mounted) {
      setState(() {
        _isLoading = false;
        _successMessage = 'SMS OTP sent to ${widget.phoneNumber}';
      });

      // Start the SMS resend timer
      _startSmsResendTimer();

      // Clear success message immediately
      setState(() {
        _successMessage = null;
      });
    }
  }

  Future<void> _verifySmsOtp() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final smsOtp = _smsOtpControllers.map((c) => c.text).join();

      if (smsOtp.length != 6) {
        throw Exception('Please enter a valid 6-digit OTP');
      }

      final formattedPhone = _formatPhoneNumber(widget.phoneNumber);
      await _authService.verifySmsOtp(
        phoneNumber: formattedPhone,
        otpCode: smsOtp,
        email: widget.email, // Pass email for backend to send email OTP
      );

      if (mounted) {
        setState(() {
          _isSmsOtpVerified = true;
          _isLoading = false;
          _successMessage = 'Phone number verified! Check your email for OTP.';
        });

        // Start the email resend timer when email OTP section becomes visible
        _startEmailResendTimer();

        // Clear success message immediately
        setState(() {
          _successMessage = null;
        });

        // Email OTP is automatically sent by backend after SMS verification
        // No need to send it again from frontend
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Clear OTP input fields on error
        _clearSmsOtpFields();

        // Show user-friendly error message
        String errorMessage = 'SMS verification failed';
        if (e.toString().contains('Invalid OTP') ||
            e.toString().contains('OTP expired')) {
          errorMessage =
              'Invalid or expired OTP. Please check your SMS and try again.';
        } else if (e.toString().contains('timeout') ||
            e.toString().contains('Connection timeout')) {
          errorMessage =
              'SMS verification is taking longer than expected. Please wait and try again.';
        } else if (e.toString().contains('Connection failed') ||
            e.toString().contains('No internet connection')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else {
          errorMessage = 'SMS verification failed: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Email timer method removed - no more waiting restrictions

  Future<void> _verifyEmailOtp() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final emailOtp = _emailOtpControllers.map((c) => c.text).join();

      if (emailOtp.length != 6) {
        throw Exception('Please enter a valid 6-digit OTP');
      }

      // Complete signup with email verification
      final response = await _authService.verifyEmailOtp(
        email: widget.email,
        otpCode: emailOtp,
        signUpData: widget.signUpData,
      );

      if (mounted) {
        // Check if account already exists
        final data = response['data'];
        if (data != null && data['accountExists'] == true) {
          _successMessage = 'Account already exists! You can now login.';
        } else {
          _successMessage =
              'Account created successfully! Welcome to Kaira! 🎉';
        }

        setState(() {
          _isEmailOtpVerified = true;
          _isLoading = false;
        });

        // Store user data and authentication status immediately
        final storageService = StorageService(FlutterSecureStorage());
        await storageService.initialize();

        // Store user data from the response
        if (data != null && data['user'] != null) {
          await storageService.storeUserData(jsonEncode(data['user']));

          // Store auth token if available
          final accessToken = data['accessToken'];
          if (accessToken != null) {
            print(
              'Storing auth token from OTP verification: ${accessToken.substring(0, 20)}...',
            );
            await storageService.storeAuthToken(accessToken);
            print('Auth token stored successfully from OTP verification');
          } else {
            print('No access token found in OTP verification response');
          }
        }

        // Navigate immediately after storing data
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Clear OTP input fields on error
        _clearEmailOtpFields();

        // Show user-friendly error message
        String errorMessage = 'Email verification failed';
        if (e.toString().contains('No pending Email OTP found')) {
          errorMessage =
              'No pending email verification found. Please request a new OTP.';
        } else if (e.toString().contains('Invalid OTP') ||
            e.toString().contains('OTP expired')) {
          errorMessage =
              'Invalid or expired OTP. Please check your email and try again.';
        } else if (e.toString().contains('already verified')) {
          errorMessage = 'Email already verified. You can proceed to login.';
        } else if (e.toString().contains('timeout') ||
            e.toString().contains('Connection timeout')) {
          errorMessage =
              'Email verification is taking longer than expected. Please wait and try again.';
        } else if (e.toString().contains('Connection failed') ||
            e.toString().contains('No internet connection')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else {
          errorMessage = 'Email verification failed: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _resendSmsOtp() async {
    if (_isResendingSms) return; // Prevent multiple simultaneous requests

    try {
      setState(() {
        _isResendingSms = true;

        _successMessage = null;
      });

      final formattedPhone = _formatPhoneNumber(widget.phoneNumber);
      await _authService.resendOtp(identifier: formattedPhone, type: 'sms');

      if (mounted) {
        setState(() {
          _isResendingSms = false;
          _successMessage = 'SMS OTP resent successfully!';
        });

        // Reset SMS resend timer
        _resetSmsResendTimer();

        // Clear success message immediately
        setState(() {
          _successMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResendingSms = false;
        });

        // Clear OTP input fields on error
        _clearSmsOtpFields();

        // Show user-friendly error message
        String errorMessage = 'Failed to resend SMS OTP';
        if (e.toString().contains('Connection failed') ||
            e.toString().contains('No internet connection') ||
            e.toString().contains('Connection timeout')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else {
          errorMessage = 'Failed to resend SMS OTP: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _resendEmailOtp() async {
    if (_isResendingEmail) return; // Prevent multiple simultaneous requests

    try {
      setState(() {
        _isResendingEmail = true;

        _successMessage = null;
      });

      await _authService.resendOtp(identifier: widget.email, type: 'email');

      if (mounted) {
        setState(() {
          _isResendingEmail = false;
          _successMessage = 'Email OTP resent successfully!';
        });

        // Reset email resend timer
        _resetEmailResendTimer();

        // Clear success message immediately
        setState(() {
          _successMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResendingEmail = false;
        });

        // Clear OTP input fields after error
        _clearEmailOtpFields();

        // Show user-friendly error message
        String errorMessage = 'Failed to resend email OTP';
        if (e.toString().contains('Connection failed') ||
            e.toString().contains('No internet connection') ||
            e.toString().contains('Connection timeout')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else {
          errorMessage = 'Failed to resend email OTP: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _onSmsOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _smsOtpFocusNodes[index + 1].requestFocus();
    }
  }

  void _onEmailOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _emailOtpFocusNodes[index + 1].requestFocus();
    }
  }

  // Clear OTP input fields
  void _clearSmsOtpFields() {
    for (var controller in _smsOtpControllers) {
      controller.clear();
    }
    // Reset focus to first field
    if (_smsOtpFocusNodes.isNotEmpty) {
      _smsOtpFocusNodes[0].requestFocus();
    }
  }

  void _clearEmailOtpFields() {
    for (var controller in _emailOtpControllers) {
      controller.clear();
    }
    // Reset focus to first field
    if (_emailOtpFocusNodes.isNotEmpty) {
      _emailOtpFocusNodes[0].requestFocus();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    for (var controller in _smsOtpControllers) {
      controller.dispose();
    }
    for (var controller in _emailOtpControllers) {
      controller.dispose();
    }
    for (var node in _smsOtpFocusNodes) {
      node.dispose();
    }
    for (var node in _emailOtpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      bottomNavigationBar: _buildBottomButton(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Fixed Header with gradient - matching SignUp page
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 200,
                  maxHeight: 200,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF2196F3),
                          Color(0xFF1976D2),
                          Color(0xFF0D47A1),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Background patterns
                        Positioned(
                          top: -50,
                          right: -50,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -30,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Back button
                        Positioned(
                          top: 50,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF2196F3),
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        // Content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.verified_user,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Verify Your Account',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Text(
                                'Complete your registration',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),

                      const SizedBox(height: 32),

                      // SMS OTP Section
                      if (!_isSmsOtpVerified) _buildSmsOtpSection(),

                      // Email OTP Section
                      if (_isSmsOtpVerified) _buildEmailOtpSection(),

                      const SizedBox(height: 32),

                      // Success Messages
                      if (_successMessage != null) _buildSuccessMessage(),

                      // Bottom spacing for fixed button
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildProgressStep(
                number: 1,
                title: 'Phone Verification',
                isCompleted: _isSmsOtpVerified,
                isActive: !_isSmsOtpVerified,
              ),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: _isSmsOtpVerified
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              _buildProgressStep(
                number: 2,
                title: 'Email Verification',
                isCompleted: _isEmailOtpVerified,
                isActive: _isSmsOtpVerified && !_isEmailOtpVerified,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _isSmsOtpVerified
                ? 'Phone verified! Now verify your email to complete registration.'
                : 'First, verify your phone number with the OTP sent via SMS.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep({
    required int number,
    required String title,
    required bool isCompleted,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFF2196F3)
                : isActive
                ? const Color(0xFF2196F3)
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    number.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isCompleted
                ? const Color(0xFF2196F3)
                : isActive
                ? const Color(0xFF2196F3)
                : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSmsOtpSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.phone_android,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Phone Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Enter the 6-digit code sent to ${widget.phoneNumber}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // OTP Input Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: 45,
                height: 55,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: TextFormField(
                  controller: _smsOtpControllers[index],
                  focusNode: _smsOtpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => _onSmsOtpChanged(value, index),
                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Resend OTP Button
          Center(
            child: TextButton(
              onPressed: (_isResendingSms || !_canResendSms)
                  ? null
                  : _resendSmsOtp,
              child: _isResendingSms
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2196F3),
                        ),
                      ),
                    )
                  : !_canResendSms
                  ? Text(
                      _smsResendCountdown > 0
                          ? 'Resend in $_smsResendCountdown seconds'
                          : 'Resend SMS OTP',
                      style: TextStyle(
                        color: _smsResendCountdown > 0
                            ? Colors.grey.shade500
                            : Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const Text(
                      'Resend SMS OTP',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailOtpSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.email,
                  color: Color(0xFF2196F3),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Verification',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      'Enter the 6-digit code sent to ${widget.email}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // OTP Input Fields
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return Container(
                width: 45,
                height: 55,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: TextFormField(
                  controller: _emailOtpControllers[index],
                  focusNode: _emailOtpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => _onEmailOtpChanged(value, index),

                  decoration: InputDecoration(
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 4,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Resend OTP Button
          Center(
            child: TextButton(
              onPressed: (_isResendingEmail || !_canResendEmail)
                  ? null
                  : _resendEmailOtp,
              child: _isResendingEmail
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF2196F3),
                        ),
                      ),
                    )
                  : !_canResendEmail
                  ? Text(
                      _emailResendCountdown > 0
                          ? 'Resend in $_emailResendCountdown seconds'
                          : 'Resend Email OTP',
                      style: TextStyle(
                        color: _emailResendCountdown > 0
                            ? Colors.grey.shade500
                            : Color(0xFF2196F3),
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : const Text(
                      'Resend Email OTP',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _successMessage!,
              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    if (_isEmailOtpVerified) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
          child: const Center(
            child: Text(
              'Account Created Successfully! 🎉',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    if (_isSmsOtpVerified) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyEmailOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Verify Email OTP',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
          ),
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifySmsOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Verify SMS OTP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}

// Custom SliverPersistentHeaderDelegate for fixed header
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
