import 'package:flutter/material.dart';

class PrivacySecurityPage extends StatefulWidget {
  const PrivacySecurityPage({super.key});

  @override
  State<PrivacySecurityPage> createState() => _PrivacySecurityPageState();
}

class _PrivacySecurityPageState extends State<PrivacySecurityPage> {
  // Privacy settings
  bool _allowLocationTracking = true;
  bool _allowPushNotifications = true;
  bool _allowEmailNotifications = true;
  bool _allowSmsNotifications = true;
  bool _showProfileToPublic = false;
  bool _allowDataAnalytics = true;
  bool _allowMarketingEmails = false;

  // Security settings
  bool _twoFactorAuth = false;
  bool _biometricAuth = false;
  bool _sessionTimeout = true;
  bool _loginNotifications = true;
  bool _deviceManagement = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1A1A1A)),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Status Card
            _buildSecurityStatusCard(),
            const SizedBox(height: 24),

            // Privacy Settings Section
            _buildSectionHeader('Privacy Settings', Icons.privacy_tip_outlined),
            const SizedBox(height: 16),
            _buildPrivacySettings(),
            const SizedBox(height: 24),

            // Security Settings Section
            _buildSectionHeader('Security Settings', Icons.security_outlined),
            const SizedBox(height: 16),
            _buildSecuritySettings(),
            const SizedBox(height: 24),

            // Data & Account Section
            _buildSectionHeader('Data & Account', Icons.data_usage_outlined),
            const SizedBox(height: 16),
            _buildDataAccountSettings(),
            const SizedBox(height: 24),

            // Legal & Compliance Section
            _buildSectionHeader('Legal & Compliance', Icons.gavel_outlined),
            const SizedBox(height: 16),
            _buildLegalCompliance(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Security',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _twoFactorAuth ? 'High Security' : 'Standard Security',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _twoFactorAuth ? Icons.check_circle : Icons.warning_amber,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _twoFactorAuth
                          ? '2FA Enabled'
                          : 'Enable 2FA for better security',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!_twoFactorAuth)
            TextButton(
              onPressed: _enableTwoFactorAuth,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
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

  Widget _buildPrivacySettings() {
    return Column(
      children: [
        _buildSettingTile(
          title: 'Location Tracking',
          subtitle:
              'Allow Kaira to access your location for better service recommendations',
          icon: Icons.location_on_outlined,
          value: _allowLocationTracking,
          onChanged: (value) => setState(() => _allowLocationTracking = value),
        ),
        _buildSettingTile(
          title: 'Push Notifications',
          subtitle:
              'Receive notifications about bookings, messages, and updates',
          icon: Icons.notifications_outlined,
          value: _allowPushNotifications,
          onChanged: (value) => setState(() => _allowPushNotifications = value),
        ),
        _buildSettingTile(
          title: 'Email Notifications',
          subtitle: 'Receive important updates and security alerts via email',
          icon: Icons.email_outlined,
          value: _allowEmailNotifications,
          onChanged: (value) =>
              setState(() => _allowEmailNotifications = value),
        ),
        _buildSettingTile(
          title: 'SMS Notifications',
          subtitle: 'Receive booking confirmations and security codes via SMS',
          icon: Icons.sms_outlined,
          value: _allowSmsNotifications,
          onChanged: (value) => setState(() => _allowSmsNotifications = value),
        ),
        _buildSettingTile(
          title: 'Public Profile',
          subtitle: 'Allow other users to view your profile information',
          icon: Icons.public_outlined,
          value: _showProfileToPublic,
          onChanged: (value) => setState(() => _showProfileToPublic = value),
        ),
        _buildSettingTile(
          title: 'Data Analytics',
          subtitle: 'Help improve Kaira by sharing anonymous usage data',
          icon: Icons.analytics_outlined,
          value: _allowDataAnalytics,
          onChanged: (value) => setState(() => _allowDataAnalytics = value),
        ),
        _buildSettingTile(
          title: 'Marketing Emails',
          subtitle: 'Receive promotional offers and service updates',
          icon: Icons.campaign_outlined,
          value: _allowMarketingEmails,
          onChanged: (value) => setState(() => _allowMarketingEmails = value),
        ),
      ],
    );
  }

  Widget _buildSecuritySettings() {
    return Column(
      children: [
        _buildSettingTile(
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security to your account',
          icon: Icons.security_outlined,
          value: _twoFactorAuth,
          onChanged: (value) => setState(() => _twoFactorAuth = value),
          isSecurity: true,
        ),
        _buildSettingTile(
          title: 'Biometric Authentication',
          subtitle: 'Use fingerprint or face recognition to sign in',
          icon: Icons.fingerprint_outlined,
          value: _biometricAuth,
          onChanged: (value) => setState(() => _biometricAuth = value),
          isSecurity: true,
        ),
        _buildSettingTile(
          title: 'Session Timeout',
          subtitle: 'Automatically sign out after period of inactivity',
          icon: Icons.timer_outlined,
          value: _sessionTimeout,
          onChanged: (value) => setState(() => _sessionTimeout = value),
        ),
        _buildSettingTile(
          title: 'Login Notifications',
          subtitle: 'Get notified when someone signs into your account',
          icon: Icons.login_outlined,
          value: _loginNotifications,
          onChanged: (value) => setState(() => _loginNotifications = value),
        ),
        _buildSettingTile(
          title: 'Device Management',
          subtitle: 'View and manage devices signed into your account',
          icon: Icons.devices_outlined,
          value: _deviceManagement,
          onChanged: (value) => setState(() => _deviceManagement = value),
        ),
      ],
    );
  }

  Widget _buildDataAccountSettings() {
    return Column(
      children: [
        _buildActionTile(
          title: 'Download My Data',
          subtitle: 'Get a copy of all your data',
          icon: Icons.download_outlined,
          onTap: _downloadUserData,
        ),
        _buildActionTile(
          title: 'Data Usage',
          subtitle: 'View how your data is being used',
          icon: Icons.data_usage_outlined,
          onTap: _viewDataUsage,
        ),
        _buildActionTile(
          title: 'Account Activity',
          subtitle: 'Review recent account activity',
          icon: Icons.history_outlined,
          onTap: _viewAccountActivity,
        ),
        _buildActionTile(
          title: 'Connected Apps',
          subtitle: 'Manage third-party app connections',
          icon: Icons.apps_outlined,
          onTap: _manageConnectedApps,
        ),
      ],
    );
  }

  Widget _buildLegalCompliance() {
    return Column(
      children: [
        _buildActionTile(
          title: 'Privacy Policy',
          subtitle: 'Read our privacy policy',
          icon: Icons.privacy_tip_outlined,
          onTap: _viewPrivacyPolicy,
        ),
        _buildActionTile(
          title: 'Terms of Service',
          subtitle: 'Read our terms of service',
          icon: Icons.description_outlined,
          onTap: _viewTermsOfService,
        ),
        _buildActionTile(
          title: 'Cookie Policy',
          subtitle: 'Learn about our cookie usage',
          icon: Icons.cookie_outlined,
          onTap: _viewCookiePolicy,
        ),
        _buildActionTile(
          title: 'GDPR Rights',
          subtitle: 'Your data protection rights',
          icon: Icons.gavel_outlined,
          onTap: _viewGDPRRights,
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isSecurity = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSecurity ? Colors.orange.shade200 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSecurity
                  ? Colors.orange.shade50
                  : const Color(0xFF2196F3).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isSecurity
                  ? Colors.orange.shade600
                  : const Color(0xFF2196F3),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: isSecurity ? Colors.orange : const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF2196F3),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(icon, color: Colors.grey.shade400, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Action methods
  void _enableTwoFactorAuth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Two-Factor Authentication'),
        content: const Text(
          'Two-factor authentication adds an extra layer of security to your account. You\'ll need to verify your identity using a second method when signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _twoFactorAuth = true);
              _showSuccessMessage('Two-factor authentication enabled');
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _downloadUserData() {
    _showComingSoonDialog('Download My Data');
  }

  void _viewDataUsage() {
    _showComingSoonDialog('Data Usage');
  }

  void _viewAccountActivity() {
    _showComingSoonDialog('Account Activity');
  }

  void _manageConnectedApps() {
    _showComingSoonDialog('Connected Apps');
  }

  void _viewPrivacyPolicy() {
    _showComingSoonDialog('Privacy Policy');
  }

  void _viewTermsOfService() {
    _showComingSoonDialog('Terms of Service');
  }

  void _viewCookiePolicy() {
    _showComingSoonDialog('Cookie Policy');
  }

  void _viewGDPRRights() {
    _showComingSoonDialog('GDPR Rights');
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy & Security Help'),
        content: const Text(
          'This screen allows you to manage your privacy and security settings. You can control what data is shared, enable security features, and manage your account preferences.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text(
          'This feature is coming soon! We\'re working hard to bring you the best privacy and security tools.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
