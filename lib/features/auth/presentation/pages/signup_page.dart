import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/auth_service.dart';
import 'otp_verification_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
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

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  DateTime? _lastSubmissionTime;

  // Real-time validation states
  bool _isFirstNameValid = false;
  bool _isLastNameValid = false;
  bool _isPhoneValid = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Computed property to check if form is complete and valid
  bool get _isFormComplete =>
      _isFirstNameValid &&
      _isLastNameValid &&
      _isPhoneValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _isConfirmPasswordValid &&
      _acceptTerms;

  // Helper method to calculate form completion percentage
  double _getFormCompletionPercentage() {
    int completedFields = 0;
    int totalFields =
        7; // 7 total requirements: 6 form fields + terms acceptance

    if (_isFirstNameValid) completedFields++;
    if (_isLastNameValid) completedFields++;
    if (_isPhoneValid) completedFields++;
    if (_isEmailValid) completedFields++;
    if (_isPasswordValid) completedFields++;
    if (_isConfirmPasswordValid) completedFields++;
    if (_acceptTerms) completedFields++;

    // Ensure percentage doesn't exceed 100%
    double percentage = completedFields / totalFields;
    return percentage > 1.0 ? 1.0 : percentage;
  }

  // Helper method to get form completion message
  String _getFormCompletionMessage() {
    if (_isFormComplete) {
      return 'All fields completed! You can now create your account.';
    }

    List<String> missingFields = [];
    if (!_isFirstNameValid) missingFields.add('First Name');
    if (!_isLastNameValid) missingFields.add('Last Name');
    if (!_isPhoneValid) missingFields.add('Phone Number');
    if (!_isEmailValid) missingFields.add('Email');
    if (!_isPasswordValid) missingFields.add('Password');
    if (!_isConfirmPasswordValid) missingFields.add('Confirm Password');
    if (!_acceptTerms) missingFields.add('Terms & Conditions');

    if (missingFields.length == 1) {
      return 'Complete ${missingFields.first} to continue.';
    } else if (missingFields.length <= 3) {
      return 'Complete ${missingFields.take(2).join(', ')} to continue.';
    } else {
      return 'Complete ${missingFields.length} more fields to continue.';
    }
  }

  // Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    // Calculate strength score
    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    // Determine strength level and color
    String strengthText;
    Color strengthColor;
    double strengthValue;

    switch (score) {
      case 0:
      case 1:
        strengthText = 'Very Weak';
        strengthColor = Colors.red;
        strengthValue = 0.2;
        break;
      case 2:
        strengthText = 'Weak';
        strengthColor = Colors.orange;
        strengthValue = 0.4;
        break;
      case 3:
        strengthText = 'Fair';
        strengthColor = Colors.yellow.shade700;
        strengthValue = 0.6;
        break;
      case 4:
        strengthText = 'Good';
        strengthColor = Colors.lightBlue;
        strengthValue = 0.8;
        break;
      case 5:
        strengthText = 'Strong';
        strengthColor = Colors.green;
        strengthValue = 1.0;
        break;
      default:
        strengthText = 'Very Weak';
        strengthColor = Colors.red;
        strengthValue = 0.2;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: strengthColor,
              ),
            ),
            Text(
              '${(strengthValue * 100).round()}%',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: strengthValue,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  // Build password requirements grid
  Widget _buildPasswordRequirementsGrid() {
    final password = _passwordController.text;

    final requirements = [
      {
        'text': 'At least 8 characters',
        'met': password.length >= 8,
        'icon': Icons.check_circle,
      },
      {
        'text': 'One uppercase letter (A-Z)',
        'met': password.contains(RegExp(r'[A-Z]')),
        'icon': Icons.check_circle,
      },
      {
        'text': 'One lowercase letter (a-z)',
        'met': password.contains(RegExp(r'[a-z]')),
        'icon': Icons.check_circle,
      },
      {
        'text': 'One number (0-9)',
        'met': password.contains(RegExp(r'[0-9]')),
        'icon': Icons.check_circle,
      },
      {
        'text': 'One special character (!@#\$%^&*)',
        'met': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
        'icon': Icons.check_circle,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requirements',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.5,
          ),
          itemCount: requirements.length,
          itemBuilder: (context, index) {
            final requirement = requirements[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: requirement['met'] as bool
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: requirement['met'] as bool
                      ? Colors.green
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    requirement['met'] as bool
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 16,
                    color: requirement['met'] as bool
                        ? Colors.green
                        : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      requirement['text'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: requirement['met'] as bool
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontWeight: requirement['met'] as bool
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Nigerian phone number prefixes
  static const List<String> _validPrefixes = [
    '080',
    '081',
    '070',
    '071',
    '090',
    '091',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Real-time validation methods
  void _validateFirstName(String value) {
    setState(() {
      _isFirstNameValid = value.length >= 2;
    });
  }

  void _validateLastName(String value) {
    setState(() {
      _isLastNameValid = value.length >= 2;
    });
  }

  void _validatePhoneRealTime(String value) {
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    setState(() {
      _isPhoneValid =
          cleanPhone.length == 11 &&
          _validPrefixes.contains(cleanPhone.substring(0, 3));
    });
  }

  void _validateEmailRealTime(String value) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(value);
    });
  }

  void _validatePasswordRealTime(String value) {
    setState(() {
      _isPasswordValid =
          value.length >= 8 &&
          value.contains(RegExp(r'[A-Z]')) &&
          value.contains(RegExp(r'[a-z]')) &&
          value.contains(RegExp(r'[0-9]')) &&
          value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  void _validateConfirmPasswordRealTime(String value) {
    setState(() {
      _isConfirmPasswordValid =
          value == _passwordController.text && value.isNotEmpty;
    });
  }

  // Format phone number as user types
  void _formatPhoneNumber(String value) {
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digits.length <= 11) {
      String formatted = '';

      if (digits.isNotEmpty) {
        formatted = digits;

        if (digits.length > 3) {
          formatted = '${digits.substring(0, 3)} ${digits.substring(3)}';
        }
        if (digits.length > 6) {
          formatted =
              '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
        }
        if (digits.length > 9) {
          formatted =
              '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 9)} ${digits.substring(9)}';
        }
      }

      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      _validatePhoneRealTime(digits);
    }
  }

  // Custom form field builder with real-time validation
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isValid,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: suffixIcon,
            helperText: helperText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isValid ? Colors.green : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isValid ? Colors.green : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isValid ? Colors.green : const Color(0xFF2196F3),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: isValid
                ? Colors.green.withValues(alpha: 0.05)
                : Colors.grey.shade50,
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          validator: validator,
        ),
        if (controller.text.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 20,
            margin: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.error,
                  size: 16,
                  color: isValid ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isValid ? 'Valid' : 'Invalid',
                  style: TextStyle(
                    fontSize: 12,
                    color: isValid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _handleSignUp() async {
    // Prevent multiple submissions
    if (_isLoading) {
      return;
    }

    // Debounce: Prevent rapid-fire submissions (minimum 2 seconds between attempts)
    final now = DateTime.now();
    if (_lastSubmissionTime != null) {
      final timeDiff = now.difference(_lastSubmissionTime!).inSeconds;
      if (timeDiff < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please wait ${2 - timeDiff} seconds before trying again',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _lastSubmissionTime = now; // Update submission timestamp
    });

    try {
      // Prepare signup data
      final signUpData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'confirmPassword': _confirmPasswordController.text,
      };

      // Format phone number to international format (234...)
      final cleanPhone = signUpData['phoneNumber']!.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      // Validate phone number length
      if (cleanPhone.length != 11) {
        throw Exception('Phone number must be exactly 11 digits');
      }

      // Validate phone number prefix
      final prefix = cleanPhone.substring(0, 3);
      if (!_validPrefixes.contains(prefix)) {
        throw Exception(
          'Invalid phone number prefix. Must start with 080, 081, 070, 071, 090, or 091',
        );
      }

      // Format for Termii API (234... without + sign)
      final formattedPhone = '234${cleanPhone.substring(1)}'; // 2349037128859

      // Debug: Print the phone number formatting
      print('Original phone: ${signUpData['phoneNumber']}');
      print('Clean phone: $cleanPhone');
      print('Phone prefix: $prefix');
      print('Formatted phone: $formattedPhone');
      print('Formatted length: ${formattedPhone.length}');

      // Call backend to initiate signup
      final authService = AuthService();
      final response = await authService.initiateSignup(
        firstName: signUpData['firstName']!,
        lastName: signUpData['lastName']!,
        phoneNumber: formattedPhone,
        email: signUpData['email']!,
        password: signUpData['password']!,
        confirmPassword: signUpData['confirmPassword']!,
      );

      // Debug: Print the response for troubleshooting
      print('Signup response: $response');
      print('OTP sent status: ${response['data']?['otpSent']}');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Verify we got a successful response before navigating
        if (response['success'] == true) {
          // Check if OTP was actually sent successfully
          final data = response['data'];
          if (data != null && data['otpSent'] == true) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Signup initiated successfully!',
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );

            // Navigate to OTP verification page only after confirming OTP was sent
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpVerificationPage(
                  signUpData: signUpData,
                  phoneNumber: signUpData['phoneNumber']!,
                  email: signUpData['email']!,
                ),
              ),
            );
          } else {
            // OTP was not sent successfully
            throw Exception(
              'Failed to send verification code. Please try again.',
            );
          }
        } else if (response['success'] == false) {
          // Handle explicit failure response
          throw Exception(
            response['message'] ?? 'Signup failed. Please try again.',
          );
        } else {
          // Handle unexpected response format
          throw Exception('Unexpected response format. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        String errorMessage = 'Signup failed';
        if (e.toString().contains('Connection failed') ||
            e.toString().contains('No internet connection') ||
            e.toString().contains('Connection timeout')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else if (e.toString().contains('Failed to send verification code') ||
            e.toString().contains('Failed to send OTP')) {
          errorMessage =
              'Failed to send verification code. Please check your phone number and try again.';
        } else if (e.toString().contains(
              'Phone number is already registered',
            ) ||
            e.toString().contains('already registered')) {
          errorMessage =
              'This phone number is already registered. Please use a different number or try logging in.';
        } else if (e.toString().contains(
          'Email address is already registered',
        )) {
          errorMessage =
              'This email address is already registered. Please use a different email or try logging in.';
        } else if (e.toString().contains(
          'Please wait before requesting another OTP',
        )) {
          errorMessage =
              'Please wait a moment before requesting another verification code.';
        } else if (e.toString().contains('Invalid phone number format')) {
          errorMessage =
              'Invalid phone number format. Please enter a valid Nigerian phone number.';
        } else {
          errorMessage = 'Signup failed: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: CustomScrollView(
        slivers: [
          // Fixed Header with gradient
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
                              Icons.person_add,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Join Kaira',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'Connect with trusted artisans',
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

          // Form Content
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // First Name
                    _buildFormField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter your first name',
                      icon: Icons.person_outline,
                      isValid: _isFirstNameValid,
                      onChanged: _validateFirstName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        if (value.length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // Last Name
                    _buildFormField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      icon: Icons.person_outline,
                      isValid: _isLastNameValid,
                      onChanged: _validateLastName,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // Phone Number (Priority for Nigerian users)
                    _buildFormField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      hint: '080 123 456 78',
                      icon: Icons.phone_outlined,
                      isValid: _isPhoneValid,
                      onChanged: (value) {
                        _formatPhoneNumber(value);
                        _validatePhoneRealTime(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        final cleanPhone = value.replaceAll(
                          RegExp(r'[^\d]'),
                          '',
                        );
                        if (cleanPhone.length != 11) {
                          return 'Phone number must be 11 digits';
                        }
                        final prefix = cleanPhone.substring(0, 3);
                        if (!_validPrefixes.contains(prefix)) {
                          return 'Invalid Nigerian phone number prefix. Use: 080, 081, 070, 071, 090, 091';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      suffixIcon: const Icon(Icons.flag, color: Colors.green),
                      helperText: 'Nigerian number (11 digits)',
                    ),
                    const SizedBox(height: 20),

                    // Email
                    _buildFormField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'Enter your email address',
                      icon: Icons.email_outlined,
                      isValid: _isEmailValid,
                      onChanged: _validateEmailRealTime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(
                          r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                        );
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),

                    // Password
                    _buildFormField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a strong password',
                      icon: Icons.lock_outline,
                      isValid: _isPasswordValid,
                      onChanged: _validatePasswordRealTime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (!value.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        if (!value.contains(RegExp(r'[a-z]'))) {
                          return 'Password must contain at least one lowercase letter';
                        }
                        if (!value.contains(RegExp(r'[0-9]'))) {
                          return 'Password must contain at least one number';
                        }
                        if (!value.contains(
                          RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                        )) {
                          return 'Password must contain at least one special character (!@#\$%^&*)';
                        }
                        return null;
                      },
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      helperText:
                          'Min 8 chars, uppercase, lowercase, number, special char',
                    ),

                    // Password Strength Indicator
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.security,
                                  size: 20,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Password Strength',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildPasswordStrengthIndicator(),
                            const SizedBox(height: 12),
                            _buildPasswordRequirementsGrid(),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Confirm Password
                    _buildFormField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      icon: Icons.lock_outline,
                      isValid: _isConfirmPasswordValid,
                      onChanged: _validateConfirmPasswordRealTime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms and Conditions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _acceptTerms
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            activeColor: const Color(0xFF2196F3),
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to the '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Color(0xFF2196F3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Form Completion Progress
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Form Completion',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              Text(
                                '${(_getFormCompletionPercentage() * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _isFormComplete
                                      ? Colors.green
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _getFormCompletionPercentage(),
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isFormComplete
                                  ? Colors.green
                                  : const Color(0xFF2196F3),
                            ),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getFormCompletionMessage(),
                            style: TextStyle(
                              fontSize: 12,
                              color: _isFormComplete
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign Up Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: _isFormComplete
                            ? const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                              )
                            : null,
                        color: _isFormComplete ? null : Colors.grey.shade300,
                        boxShadow: _isFormComplete
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF2196F3,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: ElevatedButton(
                        onPressed: (_isLoading || !_isFormComplete)
                            ? null
                            : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: _isFormComplete
                              ? Colors.white
                              : Colors.grey.shade600,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isFormComplete
                                        ? Icons.check_circle
                                        : Icons.lock,
                                    size: 20,
                                    color: _isFormComplete
                                        ? Colors.white
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    _isFormComplete
                                        ? 'Create Account'
                                        : 'Complete Form to Continue',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
