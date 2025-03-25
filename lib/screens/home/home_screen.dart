import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/theme/Home_page/home_screen_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_tracker/data/services/transaction_service.dart';
import 'package:finance_tracker/screens/profile/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final TransactionService transactionService = TransactionService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // User Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, color: Colors.black, size: 30),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome",
                          style: HomeScreenTheme.welcomeText,
                        ),
                        Text(
                          _auth.currentUser?.displayName ?? "User",
                          style: HomeScreenTheme.userNameText,
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  icon: const Icon(CupertinoIcons.gear_alt, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Balance Card
            StreamBuilder(
              stream: transactionService.getTransactions(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return _buildBalanceCard(0, 0, 0);

                var transactions = snapshot.data!.docs;
                double income = 0;
                double expense = 0;

                for (var transaction in transactions) {
                  double amount = transaction['amount'] ?? 0;
                  if (amount >= 0) {
                    income += amount;
                  } else {
                    expense += amount;
                  }
                }

                return _buildBalanceCard(income - expense, income, expense);
              },
            ),
            const SizedBox(height: 30),

            // Transactions Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Transactions List
            Expanded(
              child: StreamBuilder(
                stream: transactionService.getTransactions(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());

                  var transactions = snapshot.data!.docs;
                  if (transactions.isEmpty)
                    return const Center(child: Text("No transactions found"));

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      var transaction = transactions[index];
                      String category =
                          (transaction.data()
                              as Map<String, dynamic>?)?['name'] ??
                          'Other';

                      double amount = transaction['amount'] ?? 0;
                      String date = transaction['date'] ?? "No Date";

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        decoration: HomeScreenTheme.transactionBoxDecoration,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _getTransactionColor(category),
                              child: Icon(
                                _getTransactionIcon(category),
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category,
                                  style:
                                      HomeScreenTheme.transactionCategoryText,
                                ),
                                Text(
                                  date,
                                  style: HomeScreenTheme.transactionDateText,
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              amount >= 0
                                  ? "+\$${amount.toStringAsFixed(2)}"
                                  : "-\$${(-amount).toStringAsFixed(2)}",
                              style: HomeScreenTheme.transactionAmountText(
                                amount,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Balance Card
  Widget _buildBalanceCard(double balance, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: HomeScreenTheme.balanceCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Total Balance", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 5),
          Text(
            "\$ ${balance.toStringAsFixed(2)}",
            style: HomeScreenTheme.balanceText,
          ),
        ],
      ),
    );
  }

  IconData _getTransactionIcon(String category) => Icons.money;
  Color _getTransactionColor(String category) => Colors.grey;
}
