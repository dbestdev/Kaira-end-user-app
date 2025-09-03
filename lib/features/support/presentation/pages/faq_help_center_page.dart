import 'package:flutter/material.dart';

class FAQHelpCenterPage extends StatefulWidget {
  const FAQHelpCenterPage({super.key});

  @override
  State<FAQHelpCenterPage> createState() => _FAQHelpCenterPageState();
}

class _FAQHelpCenterPageState extends State<FAQHelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];
  List<FAQItem> _allFAQs = [];
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Getting Started',
    'Bookings',
    'Payments',
    'Account',
    'Technical',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFAQs();
    _filteredFAQs = _allFAQs;
  }

  void _initializeFAQs() {
    _allFAQs = [
      // Getting Started
      FAQItem(
        question: 'How do I create an account?',
        answer:
            'To create an account, tap the "Sign Up" button on the welcome screen. Enter your email, phone number, and create a secure password. You\'ll receive a verification code via SMS to complete the registration.',
        category: 'Getting Started',
        isExpanded: false,
      ),
      FAQItem(
        question: 'How do I find artisans near me?',
        answer:
            'Use the search bar on the home screen to search for services. You can also browse by categories or use the location filter to find artisans in your area. The app will show you the nearest available artisans.',
        category: 'Getting Started',
        isExpanded: false,
      ),
      FAQItem(
        question: 'What services are available on Kaira?',
        answer:
            'Kaira offers a wide range of home and professional services including plumbing, electrical work, cleaning, painting, carpentry, gardening, appliance repair, and many more. Browse our service categories to see all available options.',
        category: 'Getting Started',
        isExpanded: false,
      ),

      // Bookings
      FAQItem(
        question: 'How do I book a service?',
        answer:
            '1. Search for the service you need\n2. Select an artisan from the list\n3. Choose your preferred date and time\n4. Add any special instructions\n5. Select your payment method\n6. Confirm your booking',
        category: 'Bookings',
        isExpanded: false,
      ),
      FAQItem(
        question: 'Can I reschedule or cancel my booking?',
        answer:
            'Yes! You can reschedule or cancel your booking up to 2 hours before the scheduled time. Go to "My Bookings" in your profile, select the booking, and choose to reschedule or cancel. Cancellation fees may apply for last-minute cancellations.',
        category: 'Bookings',
        isExpanded: false,
      ),
      FAQItem(
        question: 'How do I track my booking status?',
        answer:
            'You can track your booking status in real-time through the "My Bookings" section. You\'ll receive notifications when the artisan accepts, is on the way, arrives, and completes the service.',
        category: 'Bookings',
        isExpanded: false,
      ),
      FAQItem(
        question: 'What if my artisan doesn\'t show up?',
        answer:
            'If your artisan doesn\'t show up within 15 minutes of the scheduled time, you can report this in the app. We\'ll immediately assign you a replacement artisan and may provide compensation for the inconvenience.',
        category: 'Bookings',
        isExpanded: false,
      ),

      // Payments
      FAQItem(
        question: 'What payment methods do you accept?',
        answer:
            'We accept all major credit and debit cards (Visa, Mastercard, Verve), bank transfers, and digital wallets. You can also fund your Kaira wallet for faster future payments.',
        category: 'Payments',
        isExpanded: false,
      ),
      FAQItem(
        question: 'When do I pay for services?',
        answer:
            'Payment is processed when you confirm your booking. The amount is held securely until the service is completed. Once the artisan marks the job as complete, the payment is released to them.',
        category: 'Payments',
        isExpanded: false,
      ),
      FAQItem(
        question: 'How do I get a refund?',
        answer:
            'Refunds are processed automatically if a service is cancelled or if you\'re not satisfied with the work. Refunds typically take 3-5 business days to appear in your account. Contact support for urgent refund requests.',
        category: 'Payments',
        isExpanded: false,
      ),
      FAQItem(
        question: 'Are there any hidden fees?',
        answer:
            'No hidden fees! The price you see is the price you pay. We may charge a small service fee (usually 2-5%) which is clearly displayed before you confirm your booking.',
        category: 'Payments',
        isExpanded: false,
      ),

      // Account
      FAQItem(
        question: 'How do I update my profile information?',
        answer:
            'Go to your profile page and tap "Edit Profile". You can update your name, phone number, email, and profile picture. Some changes may require verification.',
        category: 'Account',
        isExpanded: false,
      ),
      FAQItem(
        question: 'How do I change my password?',
        answer:
            'Go to Profile > Privacy & Security > Change Password. Enter your current password and create a new secure password. Make sure it\'s at least 8 characters with a mix of letters, numbers, and symbols.',
        category: 'Account',
        isExpanded: false,
      ),
      FAQItem(
        question: 'Can I delete my account?',
        answer:
            'Yes, you can delete your account by going to Profile > Privacy & Security > Delete Account. This action is permanent and will cancel all pending bookings. Contact support if you need help with this process.',
        category: 'Account',
        isExpanded: false,
      ),

      // Technical
      FAQItem(
        question: 'The app is not working properly. What should I do?',
        answer:
            'Try these troubleshooting steps:\n1. Close and restart the app\n2. Check your internet connection\n3. Update to the latest version\n4. Clear app cache\n5. Restart your device\nIf problems persist, contact our technical support.',
        category: 'Technical',
        isExpanded: false,
      ),
      FAQItem(
        question: 'How do I enable notifications?',
        answer:
            'Go to your device Settings > Apps > Kaira > Notifications and make sure notifications are enabled. You can also manage notification preferences within the app in Profile > Notifications.',
        category: 'Technical',
        isExpanded: false,
      ),
      FAQItem(
        question: 'Is my data secure?',
        answer:
            'Yes! We use industry-standard encryption to protect your personal and payment information. We never share your data with third parties without your consent. Read our Privacy Policy for more details.',
        category: 'Technical',
        isExpanded: false,
      ),
    ];
  }

  void _filterFAQs() {
    setState(() {
      _filteredFAQs = _allFAQs.where((faq) {
        final matchesCategory =
            _selectedCategory == 'All' || faq.category == _selectedCategory;
        final matchesSearch =
            _searchController.text.isEmpty ||
            faq.question.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            faq.answer.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _toggleFAQ(int index) {
    setState(() {
      _filteredFAQs[index].isExpanded = !_filteredFAQs[index].isExpanded;
    });
  }

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
          'FAQ & Help Center',
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
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => _filterFAQs(),
                  decoration: InputDecoration(
                    hintText: 'Search FAQs...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF2196F3),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _filterFAQs();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2196F3),
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                            _filterFAQs();
                          },
                          selectedColor: const Color(
                            0xFF2196F3,
                          ).withValues(alpha: 0.2),
                          checkmarkColor: const Color(0xFF2196F3),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF2196F3)
                                : Colors.grey.shade700,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // FAQ List
          Expanded(
            child: _filteredFAQs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFAQs.length,
                    itemBuilder: (context, index) {
                      final faq = _filteredFAQs[index];
                      return _buildFAQItem(faq, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No FAQs Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              faq.category,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: Icon(
            faq.isExpanded ? Icons.expand_less : Icons.expand_more,
            color: const Color(0xFF2196F3),
          ),
          onExpansionChanged: (expanded) => _toggleFAQ(index),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
    this.isExpanded = false,
  });
}
