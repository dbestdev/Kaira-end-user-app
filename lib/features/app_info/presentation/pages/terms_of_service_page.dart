import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
          'Terms of Service',
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Last updated: September 2, 2024',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Terms Content
            _buildSection(
              '1. Acceptance of Terms',
              'By accessing and using the Kaira mobile application and website (collectively, the "Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            _buildSection(
              '2. Description of Service',
              'Kaira is a platform that connects users with skilled artisans and service providers for various home and professional services including but not limited to plumbing, electrical work, cleaning, painting, carpentry, gardening, and appliance repair. We facilitate the connection between service providers and customers but are not directly involved in the provision of services.',
            ),
            _buildSection(
              '3. User Accounts',
              'To access certain features of the Service, you must register for an account. You agree to:\n\n• Provide accurate, current, and complete information during registration\n• Maintain and update your account information\n• Maintain the security of your password and account\n• Accept responsibility for all activities under your account\n• Notify us immediately of any unauthorized use of your account',
            ),
            _buildSection(
              '4. Service Bookings and Payments',
              'When you book a service through Kaira:\n\n• You agree to pay the quoted price for the service\n• Payment is processed securely through our payment partners\n• We may hold payment until service completion\n• Refunds are subject to our refund policy\n• You are responsible for any additional costs not included in the original quote\n• Cancellation policies apply as specified during booking',
            ),
            _buildSection(
              '5. User Responsibilities',
              'As a user of Kaira, you agree to:\n\n• Use the Service only for lawful purposes\n• Provide accurate information about your service needs\n• Treat service providers with respect and courtesy\n• Allow service providers reasonable access to perform their work\n• Pay for services as agreed\n• Not engage in fraudulent or deceptive practices\n• Comply with all applicable laws and regulations',
            ),
            _buildSection(
              '6. Service Provider Responsibilities',
              'Service providers using Kaira agree to:\n\n• Provide accurate information about their skills and qualifications\n• Complete services as described and agreed upon\n• Arrive on time for scheduled appointments\n• Maintain professional conduct and appearance\n• Provide quality workmanship\n• Comply with all applicable laws and regulations\n• Maintain appropriate insurance coverage',
            ),
            _buildSection(
              '7. Payment and Fees',
              'Kaira charges service fees for facilitating connections between users and service providers. These fees are clearly disclosed before booking confirmation. Payment terms include:\n\n• All prices are in Nigerian Naira (NGN)\n• Payment is required before service commencement\n• We accept major credit cards, bank transfers, and digital wallets\n• Service fees are non-refundable unless service is not provided\n• Additional charges may apply for last-minute bookings or cancellations',
            ),
            _buildSection(
              '8. Cancellation and Refund Policy',
              'Cancellation and refund terms:\n\n• Users may cancel bookings up to 2 hours before scheduled time\n• Cancellation fees may apply for last-minute cancellations\n• Refunds are processed within 3-5 business days\n• No refunds for completed services unless there is a valid complaint\n• Service providers may cancel due to emergency circumstances\n• We reserve the right to cancel bookings for safety or policy violations',
            ),
            _buildSection(
              '9. Intellectual Property',
              'The Service and its original content, features, and functionality are and will remain the exclusive property of Kaira and its licensors. The Service is protected by copyright, trademark, and other laws. Our trademarks and trade dress may not be used in connection with any product or service without our prior written consent.',
            ),
            _buildSection(
              '10. Privacy and Data Protection',
              'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service, to understand our practices. We collect, use, and protect your personal information in accordance with applicable data protection laws and our Privacy Policy.',
            ),
            _buildSection(
              '11. Limitation of Liability',
              'In no event shall Kaira, nor its directors, employees, partners, agents, suppliers, or affiliates, be liable for any indirect, incidental, special, consequential, or punitive damages, including without limitation, loss of profits, data, use, goodwill, or other intangible losses, resulting from your use of the Service.',
            ),
            _buildSection(
              '12. Disclaimers',
              'The Service is provided on an "AS IS" and "AS AVAILABLE" basis. Kaira expressly disclaims all warranties of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose, and non-infringement.',
            ),
            _buildSection(
              '13. Indemnification',
              'You agree to defend, indemnify, and hold harmless Kaira and its licensee and licensors, and their employees, contractors, agents, officers and directors, from and against any and all claims, damages, obligations, losses, liabilities, costs or debt, and expenses (including but not limited to attorney\'s fees).',
            ),
            _buildSection(
              '14. Termination',
              'We may terminate or suspend your account and bar access to the Service immediately, without prior notice or liability, under our sole discretion, for any reason whatsoever and without limitation, including but not limited to a breach of the Terms.',
            ),
            _buildSection(
              '15. Governing Law',
              'These Terms shall be interpreted and governed by the laws of the Federal Republic of Nigeria, without regard to its conflict of law provisions. Our failure to enforce any right or provision of these Terms will not be considered a waiver of those rights.',
            ),
            _buildSection(
              '16. Changes to Terms',
              'We reserve the right, at our sole discretion, to modify or replace these Terms at any time. If a revision is material, we will provide at least 30 days notice prior to any new terms taking effect. What constitutes a material change will be determined at our sole discretion.',
            ),
            _buildSection(
              '17. Contact Information',
              'If you have any questions about these Terms of Service, please contact us at:\n\nEmail: legal@kaira.com\nPhone: +234 800 123 4567\nAddress: 123 Victoria Island, Lagos, Nigeria',
            ),

            const SizedBox(height: 32),

            // Agreement Checkbox
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'By using Kaira, you acknowledge that you have read and agree to these Terms of Service.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
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
