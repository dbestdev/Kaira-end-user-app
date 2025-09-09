import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import 'dart:io';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const EditProfilePage({super.key, this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  late final StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _storageService = StorageService(FlutterSecureStorage());
    _initializeFields();
  }

  void _initializeFields() {
    final userData = widget.userData ?? {};
    _firstNameController.text = userData['firstName'] ?? '';
    _lastNameController.text = userData['lastName'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _phoneController.text = PhoneUtils.formatForDisplay(
      userData['phoneNumber'] ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _cancelPhotoSelection() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveProfilePicture() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _storageService.getAuthToken();

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      // Prepare the multipart request
      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${AppConstants.baseUrl}/auth/profile'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'multipart/form-data';

      // Add profile picture
      final fileBytes = await _selectedImage!.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'profilePicture',
        fileBytes,
        filename:
            'profile_picture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          // Update local storage with new user data
          final updatedUserData = responseData['data']['user'];
          await _storageService.storeUserData(jsonEncode(updatedUserData));

          if (mounted) {
            setState(() {
              _selectedImage =
                  null; // Clear selected image after successful save
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Return updated data to parent
            Navigator.of(context).pop(updatedUserData);
          }
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to update profile picture',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['message'] ?? 'Failed to update profile picture',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile picture: $e'),
            backgroundColor: Colors.red,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(),
              const SizedBox(height: 32),

              // Personal Information Section
              _buildSectionHeader('Personal Information', Icons.person),
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),
              const SizedBox(height: 32),

              // Contact Information Section
              _buildSectionHeader('Contact Information', Icons.contact_phone),
              const SizedBox(height: 16),
              _buildContactInfoSection(),
              const SizedBox(height: 32),

              // Security Section
              _buildSectionHeader('Security', Icons.security),
              const SizedBox(height: 16),
              _buildSecuritySection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _selectedImage == null ? _showImagePicker : null,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedImage != null
                          ? Colors.orange
                          : const Color(0xFF2196F3),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _selectedImage != null
                        ? Image.file(
                            _selectedImage!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : (widget.userData?['profilePicture'] != null)
                        ? Image.network(
                            widget.userData!['profilePicture'],
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildDefaultAvatar();
                            },
                          )
                        : _buildDefaultAvatar(),
                  ),
                ),
              ),
              // Loading overlay
              if (_isLoading)
                Positioned.fill(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _selectedImage == null
              ? TextButton.icon(
                  onPressed: _showImagePicker,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Change Photo'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2196F3),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _cancelPhotoSelection,
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Cancel'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _saveProfilePicture,
                      icon: const Icon(Icons.check, size: 18),
                      label: Text(_isLoading ? 'Saving...' : 'Save'),
                      style: TextButton.styleFrom(
                        foregroundColor: _isLoading
                            ? Colors.grey
                            : const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFF2196F3),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 60),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2196F3), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      children: [
        _buildReadOnlyFieldWithoutEdit(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        _buildReadOnlyFieldWithoutEdit(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      children: [
        _buildReadOnlyField(
          controller: _emailController,
          label: 'Email Address',
          icon: Icons.email_outlined,
          onEditTap: () async {
            final result = await Navigator.pushNamed(
              context,
              '/change-email',
              arguments: {'currentEmail': _emailController.text},
            );

            // Update email field if email was changed
            if (result != null) {
              if (result is String) {
                // Legacy support for string result
                setState(() {
                  _emailController.text = result;
                });
              } else if (result is Map<String, dynamic>) {
                // New user data object result - update email and return to parent
                setState(() {
                  _emailController.text =
                      result['email'] ?? _emailController.text;
                });
                // Return the updated user data to parent so Profile tab and Drawer can refresh
                Navigator.of(context).pop(result);
                return;
              }
            }
          },
        ),
        const SizedBox(height: 16),
        _buildReadOnlyField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          onEditTap: () async {
            final result = await Navigator.pushNamed(
              context,
              '/change-phone',
              arguments: {'currentPhone': _phoneController.text},
            );

            // Update phone field if phone was changed
            if (result != null) {
              if (result is String) {
                // Legacy support for string result
                setState(() {
                  _phoneController.text = result;
                });
              } else if (result is Map<String, dynamic>) {
                // New user data object result - update phone and return to parent
                setState(() {
                  _phoneController.text =
                      result['phoneNumber'] ?? _phoneController.text;
                });
                // Return the updated user data to parent so Profile tab and Drawer can refresh
                Navigator.of(context).pop(result);
                return;
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                '/change-password',
              );

              // Show success message if password was changed
              if (result == true && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security_outlined,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Update your account password',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onEditTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
          onPressed: onEditTap,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildReadOnlyFieldWithoutEdit({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2196F3)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
