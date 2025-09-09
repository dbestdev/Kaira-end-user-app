import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/phone_utils.dart';

// Custom phone number formatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 11 digits
    if (digitsOnly.length > 11) {
      digitsOnly = digitsOnly.substring(0, 11);
    }

    // Format with spaces: 08012345678 -> 080 123 456 78
    String formatted = '';
    if (digitsOnly.isNotEmpty) {
      if (digitsOnly.length >= 3) {
        formatted = digitsOnly.substring(0, 3);
        if (digitsOnly.length >= 6) {
          formatted += ' ${digitsOnly.substring(3, 6)}';
          if (digitsOnly.length >= 9) {
            formatted += ' ${digitsOnly.substring(6, 9)}';
            if (digitsOnly.length >= 10) {
              formatted += ' ${digitsOnly.substring(9)}';
            }
          } else if (digitsOnly.length > 6) {
            formatted += ' ${digitsOnly.substring(6)}';
          }
        } else if (digitsOnly.length > 3) {
          formatted += ' ${digitsOnly.substring(3)}';
        }
      } else {
        formatted = digitsOnly;
      }
    }

    // Calculate cursor position
    int cursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
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

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _usePhoneNumber = true; // Default to phone number for Nigerian users

  bool _rememberMe = false; // Remember me option

  @override
  void initState() {
    super.initState();
    _restoreCredentials();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Nigerian phone number validation
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    try {
      if (!PhoneUtils.isValidNigerianPhone(value)) {
        return 'Please enter a valid Nigerian phone number';
      }
    } catch (e) {
      return 'Please enter a valid Nigerian phone number';
    }

    return null;
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  void _handleLogin() async {
    final startTime = DateTime.now();
    print('🚀 [${startTime.toIso8601String()}] Login process started');

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      print('⏱️ [${DateTime.now().toIso8601String()}] UI set to loading state');

      try {
        // Get the identifier (phone or email) based on current mode
        final identifier = _usePhoneNumber
            ? PhoneUtils.normalizePhoneNumber(_phoneController.text.trim())
            : _emailController.text.trim();

        final password = _passwordController.text;
        print(
          '📝 [${DateTime.now().toIso8601String()}] Credentials prepared, calling auth service...',
        );

        // Call the auth service
        final authService = AuthService();
        final apiCallStart = DateTime.now();
        final response = await authService.login(
          identifier: identifier,
          password: password,
        );
        final apiCallEnd = DateTime.now();
        final apiDuration = apiCallEnd.difference(apiCallStart).inMilliseconds;

        print(
          '✅ [${apiCallEnd.toIso8601String()}] API call completed in ${apiDuration}ms',
        );
        print(
          '📦 [${DateTime.now().toIso8601String()}] Login response received: ${response.toString()}',
        );

        // Save credentials if remember me is checked
        final saveCredentialsStart = DateTime.now();
        await _saveCredentials();
        final saveCredentialsEnd = DateTime.now();
        print(
          '💾 [${saveCredentialsEnd.toIso8601String()}] Save credentials completed in ${saveCredentialsEnd.difference(saveCredentialsStart).inMilliseconds}ms',
        );

        // Store user data
        final storeDataStart = DateTime.now();
        try {
          await _storeUserData(response);
          final storeDataEnd = DateTime.now();
          print(
            '🗄️ [${storeDataEnd.toIso8601String()}] Store user data completed in ${storeDataEnd.difference(storeDataStart).inMilliseconds}ms',
          );
        } catch (e) {
          final storeDataEnd = DateTime.now();
          print(
            '❌ [${storeDataEnd.toIso8601String()}] Error during user data storage: $e (took ${storeDataEnd.difference(storeDataStart).inMilliseconds}ms)',
          );
        }

        // Handle successful login - set loading to false after all operations
        final setStateStart = DateTime.now();
        setState(() {
          _isLoading = false;
        });
        print('🔄 [${DateTime.now().toIso8601String()}] UI set to not loading');

        // Show success message briefly
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back! ${response['user']?['firstName'] ?? ''}',
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          print(
            '📱 [${DateTime.now().toIso8601String()}] Success message shown',
          );
        }

        // Set login status and navigate to home page
        final prefsStart = DateTime.now();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        final prefsEnd = DateTime.now();
        print(
          '🔐 [${prefsEnd.toIso8601String()}] Login status saved in ${prefsEnd.difference(prefsStart).inMilliseconds}ms',
        );

        // Navigate to home page immediately
        final navStart = DateTime.now();
        Navigator.of(context).pushReplacementNamed('/home');
        final navEnd = DateTime.now();
        print(
          '🏠 [${navEnd.toIso8601String()}] Navigation completed in ${navEnd.difference(navStart).inMilliseconds}ms',
        );

        final totalTime = navEnd.difference(startTime).inMilliseconds;
        print(
          '🎉 [${navEnd.toIso8601String()}] LOGIN COMPLETED in ${totalTime}ms total',
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Show user-friendly error message
          String errorMessage = 'Login failed';
          if (e.toString().contains('Invalid credentials') ||
              e.toString().contains('Invalid email/phone or password')) {
            errorMessage =
                'Invalid email/phone number or password. Please check your credentials and try again.';
          } else if (e.toString().contains('Connection failed') ||
              e.toString().contains('No internet connection') ||
              e.toString().contains('Connection timeout')) {
            errorMessage =
                'Cannot connect to server. Please check your internet connection and try again.';
          } else if (e.toString().contains('Account not verified')) {
            errorMessage =
                'Your account is not verified. Please check your email for verification instructions.';
          } else if (e.toString().contains('Account deactivated')) {
            errorMessage =
                'Your account has been deactivated. Please contact support for assistance.';
          } else {
            errorMessage = 'Login failed: ${e.toString()}';
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
  }

  // Save credentials if remember me is checked
  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      // TODO: Implement secure storage for credentials
      // For now, we'll just store a flag that credentials should be remembered
    }
  }

  // Restore credentials on app start
  Future<void> _restoreCredentials() async {
    // TODO: Implement secure storage retrieval
    // For now, we'll just check if credentials should be restored
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
                              Icons.login,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'Sign in to your account',
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
                    // Login Method Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _usePhoneNumber = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _usePhoneNumber
                                      ? const Color(0xFF2196F3)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: _usePhoneNumber
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Phone Number',
                                      style: TextStyle(
                                        color: _usePhoneNumber
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _usePhoneNumber = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: !_usePhoneNumber
                                      ? const Color(0xFF2196F3)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.email,
                                      color: !_usePhoneNumber
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: !_usePhoneNumber
                                            ? Colors.white
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Phone Number Field (Default for Nigerian users)
                    if (_usePhoneNumber) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '080 123 456 78',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          suffixIcon: const Icon(
                            Icons.flag,
                            color: Colors.green,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2,
                            ),
                          ),
                          helperText: 'Nigerian number (11 digits)',
                        ),
                        inputFormatters: [_PhoneNumberFormatter()],

                        validator: _validatePhoneNumber,
                      ),
                    ],

                    // Email Field
                    if (!_usePhoneNumber) ...[
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFF2196F3),
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const Text(
                              'Remember Me',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        // Forgot Password
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgot-password');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    const SizedBox(height: 16),

                    // Login Button
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Continue as Guest Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/guest-dashboard',
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2196F3),
                          side: const BorderSide(
                            color: Color(0xFF2196F3),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue as Guest',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            'Sign Up',
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

  // Store user data after successful login
  Future<void> _storeUserData(Map<String, dynamic> response) async {
    final storeStart = DateTime.now();
    print(
      '🗄️ [${storeStart.toIso8601String()}] Starting to store user data...',
    );

    try {
      final initStart = DateTime.now();
      final storageService = StorageService(FlutterSecureStorage());
      await storageService.initialize();
      final initEnd = DateTime.now();
      print(
        '🔧 [${initEnd.toIso8601String()}] Storage service initialized in ${initEnd.difference(initStart).inMilliseconds}ms',
      );

      // The backend returns: { success: true, message: "...", data: { accessToken: "...", user: { ... } } }
      final responseData = response['data'];
      final userData = responseData?['user'];
      print('📊 [${DateTime.now().toIso8601String()}] Response data parsed');
      print('👤 [${DateTime.now().toIso8601String()}] User data: $userData');

      if (userData != null) {
        // Store user data in secure storage
        final storeUserStart = DateTime.now();
        print('💾 [${storeUserStart.toIso8601String()}] Storing user data...');
        await storageService.storeUserData(jsonEncode(userData));
        final storeUserEnd = DateTime.now();
        print(
          '✅ [${storeUserEnd.toIso8601String()}] User data stored successfully in ${storeUserEnd.difference(storeUserStart).inMilliseconds}ms',
        );

        // Store auth token if available
        final accessToken = responseData?['accessToken'];
        if (accessToken != null) {
          final storeTokenStart = DateTime.now();
          print(
            '🔑 [${storeTokenStart.toIso8601String()}] Storing auth token: ${accessToken.substring(0, 20)}...',
          );
          await storageService.storeAuthToken(accessToken);
          final storeTokenEnd = DateTime.now();
          print(
            '✅ [${storeTokenEnd.toIso8601String()}] Auth token stored successfully in ${storeTokenEnd.difference(storeTokenStart).inMilliseconds}ms',
          );
        } else {
          print(
            '⚠️ [${DateTime.now().toIso8601String()}] No access token found in response',
          );
        }
      } else {
        print(
          '⚠️ [${DateTime.now().toIso8601String()}] No user data found in response',
        );
      }

      final storeEnd = DateTime.now();
      print(
        '🎯 [${storeEnd.toIso8601String()}] User data storage completed in ${storeEnd.difference(storeStart).inMilliseconds}ms total',
      );
    } catch (e) {
      final storeEnd = DateTime.now();
      print(
        '❌ [${storeEnd.toIso8601String()}] Error storing user data: $e (took ${storeEnd.difference(storeStart).inMilliseconds}ms)',
      );
    }
  }
}
