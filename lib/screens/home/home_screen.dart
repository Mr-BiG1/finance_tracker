import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:finance_tracker/theme/home_page/home_screen_theme.dart';
import 'package:finance_tracker/data/services/transaction_service.dart';
import 'package:finance_tracker/data/services/category_service.dart';
import 'package:finance_tracker/utils/format_utils.dart';
import 'package:finance_tracker/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TransactionService _transactionService = TransactionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIndicatorKey.currentState?.show();
    });
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _refreshData,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildBalanceCard(),
                const SizedBox(height: 30),
                _buildTransactionsHeader(),
                const SizedBox(height: 10),
                _buildTransactionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.amber[100],
              child: Icon(Icons.person, color: Colors.amber[800], size: 30),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome", style: HomeScreenTheme.welcomeText),
                Text(
                  _auth.currentUser?.displayName ?? "User",
                  style: HomeScreenTheme.userNameText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings, size: 26),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _transactionService.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildBalanceCardSkeleton();
        }

        if (snapshot.hasError) {
          return _buildErrorCard("Error loading balance");
        }

        final docs = snapshot.data?.docs ?? [];
        double income = 0, expense = 0;

        for (var doc in docs) {
          final amount = (doc['amount'] as num?)?.toDouble() ?? 0;
          if (amount >= 0) {
            income += amount;
          } else {
            expense += amount;
          }
        }

        return _buildBalanceCardContent(income - expense, income, expense);
      },
    );
  }

  Widget _buildBalanceCardContent(
    double balance,
    double income,
    double expense,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: HomeScreenTheme.balanceCardDecoration,
      child: Column(
        children: [
          const Text(
            "Total Balance",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            FormatUtils.formatCurrency(balance),
            style: HomeScreenTheme.balanceText,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBalanceMetric("Income", income, true),
              _buildBalanceMetric("Expense", expense, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceMetric(String label, double amount, bool isPositive) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          FormatUtils.formatCurrency(amount, showSign: isPositive),
          style: TextStyle(
            color: isPositive ? Colors.green[200] : Colors.red[200],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: HomeScreenTheme.balanceCardDecoration,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: HomeScreenTheme.balanceCardDecoration,
      child: Text(message, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildTransactionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Recent Transactions", style: HomeScreenTheme.sectionHeaderText),
        TextButton(
          onPressed: () {}, // TODO: Implement View All
          child: Text("View All", style: HomeScreenTheme.viewAllText),
        ),
      ],
    );
  }

  Widget _buildTransactionsList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _transactionService.getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("No transactions found"));
          }

          final transactions = docs.take(5).toList();

          return ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final data = transactions[index].data() as Map<String, dynamic>;
              final category = data['name'] ?? 'Other';
              final amount = (data['amount'] as num?)?.toDouble() ?? 0;
              final date = _parseTransactionDate(data['date']);

              return _buildTransactionItem(category, amount, date);
            },
          );
        },
      ),
    );
  }

  String _parseTransactionDate(dynamic date) {
    try {
      if (date == null) return 'No Date';
      if (date is Timestamp) return _dateFormat.format(date.toDate());
      if (date is String) return _dateFormat.format(DateTime.parse(date));
    } catch (e) {
      debugPrint('Invalid date: $e');
    }
    return 'Invalid Date';
  }

  Widget _buildTransactionItem(String category, double amount, String date) {
    final isIncome = amount >= 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: HomeScreenTheme.transactionBoxDecoration,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CategoryService.getColor(category).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CategoryService.getIcon(category),
              color: CategoryService.getColor(category),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CategoryService.getDisplayName(category),
                  style: HomeScreenTheme.transactionCategoryText,
                ),
                Text(date, style: HomeScreenTheme.transactionDateText),
              ],
            ),
          ),
          Text(
            FormatUtils.formatCurrency(amount, showSign: true),
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _addNewTransaction(BuildContext context) {
    // TODO: Navigation to new transaction screen
  }
}
