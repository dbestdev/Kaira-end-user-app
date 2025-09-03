import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Last Updated
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.security, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: September 2, 2024',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Privacy Policy Content
            _buildSection(
              '1. Introduction',
              'Kaira ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and website. Please read this privacy policy carefully. If you do not agree with the terms of this privacy policy, please do not access the application.',
            ),
            _buildSection(
              '2. Information We Collect',
              'We collect information you provide directly to us, such as when you create an account, book a service, or contact us for support.\n\nPersonal Information:\n• Name and contact information (email, phone number)\n• Profile information and preferences\n• Payment information (processed securely by third-party providers)\n• Service requests and booking history\n• Communications with us and service providers\n\nAutomatically Collected Information:\n• Device information (device type, operating system, unique device identifiers)\n• Usage information (features used, time spent, pages viewed)\n• Location information (with your permission)\n• Log information (IP address, access times, app features used)',
            ),
            _buildSection(
              '3. How We Use Your Information',
              'We use the information we collect to:\n\n• Provide, maintain, and improve our services\n• Process transactions and send related information\n• Send technical notices, updates, and support messages\n• Respond to your comments and questions\n• Communicate with you about services, offers, and events\n• Monitor and analyze trends and usage\n• Personalize and improve your experience\n• Detect, investigate, and prevent fraudulent transactions\n• Comply with legal obligations',
            ),
            _buildSection(
              '4. Information Sharing and Disclosure',
              'We do not sell, trade, or otherwise transfer your personal information to third parties except in the following circumstances:\n\n• With service providers who assist us in operating our platform\n• With service providers you book through our platform (limited to necessary information)\n• When required by law or to protect our rights\n• In connection with a business transfer or acquisition\n• With your explicit consent\n\nWe may share aggregated, non-personally identifiable information for business purposes.',
            ),
            _buildSection(
              '5. Data Security',
              'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. These measures include:\n\n• Encryption of data in transit and at rest\n• Regular security assessments and updates\n• Access controls and authentication\n• Secure data storage and backup procedures\n• Employee training on data protection\n\nHowever, no method of transmission over the internet or electronic storage is 100% secure.',
            ),
            _buildSection(
              '6. Data Retention',
              'We retain your personal information for as long as necessary to provide our services and fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law. We will delete or anonymize your personal information when it is no longer needed.',
            ),
            _buildSection(
              '7. Your Rights and Choices',
              'You have certain rights regarding your personal information:\n\n• Access: Request access to your personal information\n• Correction: Request correction of inaccurate information\n• Deletion: Request deletion of your personal information\n• Portability: Request a copy of your data in a portable format\n• Restriction: Request restriction of processing\n• Objection: Object to certain processing activities\n• Withdraw Consent: Withdraw consent where processing is based on consent\n\nTo exercise these rights, please contact us using the information provided below.',
            ),
            _buildSection(
              '8. Location Information',
              'We may collect and use location information to:\n\n• Show you nearby service providers\n• Provide location-based services\n• Improve our services and user experience\n• Ensure service provider availability in your area\n\nYou can control location sharing through your device settings. Note that some features may not work properly if location services are disabled.',
            ),
            _buildSection(
              '9. Cookies and Tracking Technologies',
              'We use cookies and similar tracking technologies to:\n\n• Remember your preferences and settings\n• Analyze how you use our services\n• Provide personalized content and advertisements\n• Improve our services and user experience\n\nYou can control cookies through your browser settings, but disabling cookies may affect the functionality of our services.',
            ),
            _buildSection(
              '10. Third-Party Services',
              'Our services may contain links to third-party websites or services. We are not responsible for the privacy practices of these third parties. We encourage you to read their privacy policies before providing any personal information.',
            ),
            _buildSection(
              '11. Children\'s Privacy',
              'Our services are not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13. If we become aware that we have collected personal information from a child under 13, we will take steps to delete such information.',
            ),
            _buildSection(
              '12. International Data Transfers',
              'Your information may be transferred to and processed in countries other than your country of residence. We ensure that such transfers comply with applicable data protection laws and implement appropriate safeguards to protect your information.',
            ),
            _buildSection(
              '13. Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date. We encourage you to review this Privacy Policy periodically for any changes.',
            ),
            _buildSection(
              '14. Compliance with Laws',
              'This Privacy Policy is designed to comply with applicable data protection laws, including:\n\n• Nigeria Data Protection Regulation (NDPR)\n• General Data Protection Regulation (GDPR)\n• California Consumer Privacy Act (CCPA)\n• Other applicable local and international privacy laws',
            ),
            _buildSection(
              '15. Contact Us',
              'If you have any questions about this Privacy Policy or our privacy practices, please contact us at:\n\nEmail: privacy@kaira.com\nPhone: +234 800 123 4567\nAddress: 123 Victoria Island, Lagos, Nigeria\n\nData Protection Officer: dpo@kaira.com',
            ),

            const SizedBox(height: 32),

            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.privacy_tip,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Your Privacy Matters',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We are committed to protecting your privacy and ensuring the security of your personal information. If you have any concerns or questions about how we handle your data, please don\'t hesitate to contact us.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
