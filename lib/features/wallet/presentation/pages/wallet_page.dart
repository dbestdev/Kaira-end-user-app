import 'package:flutter/material.dart';

class WalletPage extends StatefulWidget {
  final double initialBalance;

  const WalletPage({super.key, this.initialBalance = 0});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  late double _balance;
  int _selectedFilterIndex = 0; // 0: All, 1: Credit, 2: Debit
  final List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _balance = widget.initialBalance;
    _seedTransactions();
  }

  void _seedTransactions() {
    _transactions.addAll([
      {
        'type': 'credit',
        'title': 'Wallet Top-up',
        'amount': 20000.0,
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'method': 'Card',
      },
      {
        'type': 'debit',
        'title': 'Artisan Service - Plumbing',
        'amount': 8500.0,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'method': 'Wallet',
      },
      {
        'type': 'credit',
        'title': 'Refund - Cleaning',
        'amount': 3500.0,
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'method': 'Wallet',
      },
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      body: Column(
        children: [
          _buildBalanceCard(),
          _buildQuickActions(),
          _buildPayoutInfo(),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(child: _buildTransactionsList()),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  '₦${_balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.green.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Secured by Kaira Pay',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _onFundWallet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Fund Wallet'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _onWithdraw,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2196F3),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_downward),
                label: const Text('Withdraw'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          _buildActionTile(Icons.history, 'History', () {}),
          const SizedBox(width: 12),
          _buildActionTile(Icons.receipt_long, 'Bills', () {}),
          const SizedBox(width: 12),
          _buildActionTile(Icons.card_giftcard, 'Promo', () {}),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2196F3)),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Artisan Payouts',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  'Artisans receive earnings directly to their linked bank accounts. Users can fund their wallets to pay for services seamlessly and securely.',
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('All', 0),
          const SizedBox(width: 8),
          _buildFilterChip('Credit', 1),
          const SizedBox(width: 8),
          _buildFilterChip('Debit', 2),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final bool selected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
      selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.15),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF2196F3) : Colors.grey.shade700,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? const Color(0xFF2196F3) : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildTransactionsList() {
    final filtered = _transactions.where((t) {
      if (_selectedFilterIndex == 0) return true;
      if (_selectedFilterIndex == 1) return t['type'] == 'credit';
      return t['type'] == 'debit';
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No transactions found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final t = filtered[index];
        final bool isCredit = t['type'] == 'credit';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCredit ? Colors.green : Colors.red).withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCredit ? Icons.south_west : Icons.north_east,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['title'],
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(t['date'])} • ${t['method']}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                (isCredit ? '+₦' : '-₦') +
                    (t['amount'] as double).toStringAsFixed(2),
                style: TextStyle(
                  color: isCredit ? Colors.green.shade700 : Colors.red.shade700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onFundWallet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final TextEditingController amountController = TextEditingController(
          text: '5000',
        );
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Fund Wallet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (₦)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final amt in [2000, 5000, 10000, 20000])
                      ChoiceChip(
                        label: Text('₦$amt'),
                        selected: false,
                        onSelected: (_) =>
                            amountController.text = amt.toString(),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _buildPaymentMethodTile(
                  icon: Icons.credit_card,
                  title: 'Debit/Credit Card',
                  onTap: () => _completeFunding(amountController.text),
                ),
                _buildPaymentMethodTile(
                  icon: Icons.account_balance,
                  title: 'Bank Transfer',
                  onTap: () => _completeFunding(amountController.text),
                ),
                _buildPaymentMethodTile(
                  icon: Icons.account_balance_wallet,
                  title: 'USSD',
                  onTap: () => _completeFunding(amountController.text),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF2196F3).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF2196F3)),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _completeFunding(String amountText) {
    final amount = double.tryParse(amountText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() {
      _balance += amount;
      _transactions.insert(0, {
        'type': 'credit',
        'title': 'Wallet Top-up',
        'amount': amount,
        'date': DateTime.now(),
        'method': 'Card',
      });
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Wallet funded successfully')));
  }

  void _onWithdraw() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Withdraw coming soon')));
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
