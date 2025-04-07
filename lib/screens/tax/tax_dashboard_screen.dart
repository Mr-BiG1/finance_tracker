// lib/screens/tax/tax_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'upload_tax_docs_screen.dart';
import 'tax_calculator_screen.dart';
import 'tax_notifications_screen.dart';

class TaxDashboardScreen extends StatelessWidget {
  const TaxDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tax Services')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCard(
              context,
              icon: Icons.upload_file,
              title: "Upload Tax Documents",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UploadTaxDocsScreen()),
                  ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: Icons.calculate,
              title: "Tax Calculator",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaxCalculatorScreen()),
                  ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              icon: Icons.notifications,
              title: "Tax Notifications",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TaxNotificationsScreen()),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.deepPurple),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
