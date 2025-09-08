import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _bookingUpdates = true;
  bool _promotionalOffers = false;

  // App settings
  bool _darkMode = false;
  bool _locationServices = true;
  bool _biometricAuth = false;
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account', Icons.account_circle_outlined),
            const SizedBox(height: 16),
            _buildAccountSettings(),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications', Icons.notifications_outlined),
            const SizedBox(height: 16),
            _buildNotificationSettings(),
            const SizedBox(height: 24),

            // App Preferences Section
            _buildSectionHeader('App Preferences', Icons.tune_outlined),
            const SizedBox(height: 16),
            _buildAppSettings(),
            const SizedBox(height: 24),

            // Privacy & Security Section
            _buildSectionHeader('Privacy & Security', Icons.security_outlined),
            const SizedBox(height: 16),
            _buildPrivacySecuritySettings(),
            const SizedBox(height: 24),

            // Support Section
            _buildSectionHeader('Support', Icons.help_outline),
            const SizedBox(height: 16),
            _buildSupportSettings(),
            const SizedBox(height: 40),
          ],
        ),
      ),
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
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () {
            Navigator.pushNamed(context, '/edit-profile');
          },
        ),
        _buildActionTile(
          icon: Icons.lock_outline,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () {
            Navigator.pushNamed(context, '/change-password');
          },
        ),
        _buildActionTile(
          icon: Icons.email_outlined,
          title: 'Change Email',
          subtitle: 'Update your email address',
          onTap: () {
            Navigator.pushNamed(context, '/change-email');
          },
        ),
        _buildActionTile(
          icon: Icons.phone_outlined,
          title: 'Change Phone',
          subtitle: 'Update your phone number',
          onTap: () {
            Navigator.pushNamed(context, '/change-phone');
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive notifications on your device',
          icon: Icons.notifications_outlined,
          value: _pushNotifications,
          onChanged: (value) => setState(() => _pushNotifications = value),
        ),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive updates via email',
          icon: Icons.email_outlined,
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
        ),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive updates via SMS',
          icon: Icons.sms_outlined,
          value: _smsNotifications,
          onChanged: (value) => setState(() => _smsNotifications = value),
        ),
        _buildSwitchTile(
          title: 'Booking Updates',
          subtitle: 'Get notified about booking changes',
          icon: Icons.calendar_today_outlined,
          value: _bookingUpdates,
          onChanged: (value) => setState(() => _bookingUpdates = value),
        ),
        _buildSwitchTile(
          title: 'Promotional Offers',
          subtitle: 'Receive special offers and discounts',
          icon: Icons.local_offer_outlined,
          value: _promotionalOffers,
          onChanged: (value) => setState(() => _promotionalOffers = value),
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return Column(
      children: [
        _buildSwitchTile(
          title: 'Dark Mode',
          subtitle: 'Use dark theme throughout the app',
          icon: Icons.dark_mode_outlined,
          value: _darkMode,
          onChanged: (value) => setState(() => _darkMode = value),
        ),
        _buildSwitchTile(
          title: 'Location Services',
          subtitle: 'Allow app to access your location',
          icon: Icons.location_on_outlined,
          value: _locationServices,
          onChanged: (value) => setState(() => _locationServices = value),
        ),
        _buildSwitchTile(
          title: 'Biometric Authentication',
          subtitle: 'Use fingerprint or face recognition',
          icon: Icons.fingerprint_outlined,
          value: _biometricAuth,
          onChanged: (value) => setState(() => _biometricAuth = value),
        ),
        _buildSwitchTile(
          title: 'Auto Sync',
          subtitle: 'Automatically sync data in background',
          icon: Icons.sync_outlined,
          value: _autoSync,
          onChanged: (value) => setState(() => _autoSync = value),
        ),
      ],
    );
  }

  Widget _buildPrivacySecuritySettings() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy & Security',
          subtitle: 'Manage your privacy and security settings',
          onTap: () {
            Navigator.pushNamed(context, '/privacy-security');
          },
        ),
        _buildActionTile(
          icon: Icons.data_usage_outlined,
          title: 'Data Usage',
          subtitle: 'View and manage your data usage',
          onTap: () {
            _showComingSoon('Data Usage');
          },
        ),
        _buildActionTile(
          icon: Icons.storage_outlined,
          title: 'Storage',
          subtitle: 'Manage app storage and cache',
          onTap: () {
            _showComingSoon('Storage');
          },
        ),
      ],
    );
  }

  Widget _buildSupportSettings() {
    return Column(
      children: [
        _buildActionTile(
          icon: Icons.help_outline,
          title: 'Help Center',
          subtitle: 'Find answers to common questions',
          onTap: () {
            Navigator.pushNamed(context, '/faq-help-center');
          },
        ),
        _buildActionTile(
          icon: Icons.contact_support_outlined,
          title: 'Contact Support',
          subtitle: 'Get help from our support team',
          onTap: () {
            Navigator.pushNamed(context, '/contact-support');
          },
        ),
        _buildActionTile(
          icon: Icons.feedback_outlined,
          title: 'Send Feedback',
          subtitle: 'Share your thoughts and suggestions',
          onTap: () {
            Navigator.pushNamed(context, '/send-feedback');
          },
        ),
        _buildActionTile(
          icon: Icons.info_outline,
          title: 'About Kaira',
          subtitle: 'App version and information',
          onTap: () {
            Navigator.pushNamed(context, '/about-kaira');
          },
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Color(0xFF2196F3),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2196F3), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2196F3),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }
}
