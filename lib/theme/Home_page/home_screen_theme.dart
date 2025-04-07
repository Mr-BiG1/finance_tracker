import 'package:flutter/material.dart';

class HomeScreenTheme {
  // User Info Text Style
  static const TextStyle welcomeText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.grey,
  );

  static const TextStyle userNameText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  // Balance Card Style
  static BoxDecoration balanceCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF64B5F6), Color(0xFFFF4081)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20),
  );

  static const TextStyle balanceText = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Transaction List Item
  static BoxDecoration transactionBoxDecoration = BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.circular(15),
  );

  static const TextStyle transactionCategoryText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle transactionDateText = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static TextStyle transactionAmountText(double amount) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: amount >= 0 ? Colors.green : Colors.red,
  );

  static const TextStyle sectionHeaderText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle viewAllText = TextStyle(
    fontSize: 14,
    color: Colors.blue,
  );

  static const TextStyle emptyStateText = TextStyle(
    fontSize: 16,
    color: Colors.grey,
  );
}
