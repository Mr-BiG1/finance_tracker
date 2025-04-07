import 'package:flutter/material.dart';

class CategoryService {
  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'salary':
        return Colors.green;
      case 'entertainment':
        return Colors.pink;
      case 'utilities':
        return Colors.teal;
      case 'health':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'salary':
        return Icons.attach_money;
      case 'entertainment':
        return Icons.movie;
      case 'utilities':
        return Icons.bolt;
      case 'health':
        return Icons.medical_services;
      default:
        return Icons.money;
    }
  }

  static String getDisplayName(String category) {
    return category
        .splitMapJoin(
          RegExp(r'[A-Z]'),
          onMatch: (m) => ' ${m.group(0)}',
          onNonMatch: (n) => n,
        )
        .trim();
  }
}
