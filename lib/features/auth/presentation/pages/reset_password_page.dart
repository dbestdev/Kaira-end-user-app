import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
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

class _ResetPasswordPageState extends State<ResetPasswordPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _successMessage;

  // Real-time validation states
  bool _isNewPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  // Computed property to check if form is complete and valid
  bool get _isFormComplete => _isNewPasswordValid && _isConfirmPasswordValid;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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

  void _validateNewPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _isNewPasswordValid = false;
      } else {
        // Password validation: minimum 8 characters, at least one uppercase, one lowercase, one number, one special character
        final passwordRegex = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
        );
        _isNewPasswordValid = passwordRegex.hasMatch(value);
      }
    });
  }

  void _validateConfirmPassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _isConfirmPasswordValid = false;
      } else {
        _isConfirmPasswordValid = value == _newPasswordController.text;
      }
    });
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) {
      return; // Prevent multiple submissions
    }

    try {
      setState(() {
        _isLoading = true;
        _successMessage = null;
      });

      final response = await _authService.resetPassword(
        email: widget.email,
        resetToken: widget.resetToken,
        newPassword: _newPasswordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _successMessage =
              response['message'] ?? 'Password reset successfully!';
        });

        // Navigate to login page immediately
        if (mounted) {
          // Navigate to login page
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show user-friendly error message
        String errorMessage = 'Password reset failed';
        if (e.toString().contains('Invalid reset token') ||
            e.toString().contains('Token expired')) {
          errorMessage =
              'Reset link has expired. Please request a new password reset.';
        } else if (e.toString().contains('Connection failed') ||
            e.toString().contains('No internet connection') ||
            e.toString().contains('Connection timeout')) {
          errorMessage =
              'Cannot connect to server. Please check your internet connection and try again.';
        } else if (e.toString().contains('Password too weak')) {
          errorMessage =
              'Password is too weak. Please choose a stronger password.';
        } else if (e.toString().contains('Passwords do not match')) {
          errorMessage =
              'Passwords do not match. Please make sure both passwords are identical.';
        } else {
          errorMessage = 'Password reset failed: ${e.toString()}';
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

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
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
                                  Icons.lock_open,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const Text(
                                'Create a new secure password',
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
                        // Description
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2196F3,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(
                                0xFF2196F3,
                              ).withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF2196F3),
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Create a strong password that you\'ll remember. Make sure it meets all the requirements below.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF2196F3),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // New Password Field
                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'New Password',
                          hint: 'Enter your new password',
                          icon: Icons.lock_outline,
                          isValid: _isNewPasswordValid,
                          onChanged: _validateNewPassword,
                          obscureText: _obscureNewPassword,
                          onToggleObscure: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'New password is required';
                            }
                            if (!_isNewPasswordValid) {
                              return 'Password must meet all requirements';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password Requirements
                        _buildPasswordRequirements(),

                        const SizedBox(height: 20),

                        // Confirm Password Field
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Confirm your new password',
                          icon: Icons.lock_outline,
                          isValid: _isConfirmPasswordValid,
                          onChanged: _validateConfirmPassword,
                          obscureText: _obscureConfirmPassword,
                          onToggleObscure: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (!_isConfirmPasswordValid) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        _buildSubmitButton(),

                        const SizedBox(height: 24),

                        // Success Messages
                        if (_successMessage != null) _buildSuccessMessage(),

                        // Back to Login Button
                        ...[
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Having trouble? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    '/login',
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: Color(0xFF2196F3),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isValid,
    required Function(String) onChanged,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: isValid ? const Color(0xFF2196F3) : Colors.grey.shade400,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey.shade600,
              ),
              onPressed: onToggleObscure,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid ? const Color(0xFF2196F3) : Colors.grey.shade300,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isValid ? const Color(0xFF2196F3) : Colors.grey.shade300,
                width: 1,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _newPasswordController.text;
    final hasMinLength = password.length >= 8;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[@$!%*?&]'));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          _buildRequirementItem('At least 8 characters', hasMinLength),
          _buildRequirementItem('One uppercase letter (A-Z)', hasUppercase),
          _buildRequirementItem('One lowercase letter (a-z)', hasLowercase),
          _buildRequirementItem('One number (0-9)', hasNumber),
          _buildRequirementItem(
            'One special character (@\$!%*?&)',
            hasSpecialChar,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green : Colors.grey.shade400,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green.shade700 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
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
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !_isFormComplete)
            ? null
            : _handleResetPassword,
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
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFormComplete ? Icons.check_circle : Icons.lock,
                    size: 20,
                    color: _isFormComplete
                        ? Colors.white
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isFormComplete
                        ? 'Reset Password'
                        : 'Complete Requirements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
}
