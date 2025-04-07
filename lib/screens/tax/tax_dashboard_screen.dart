import 'package:finance_tracker/screens/tax/InvoiceScreen/invoice_screen.dart';
import 'package:finance_tracker/screens/tax/tax_notifications_screen.dart';
import 'package:finance_tracker/screens/tax/tax_upload_screen.dart';
import 'package:flutter/material.dart';
import 'tax_calculator_screen.dart';

class TaxDashboardScreen extends StatelessWidget {
  const TaxDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Services'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.upload_file,
              title: "Upload Documents",
              color: Colors.blue.shade50,
              iconColor: Colors.blue,
              onTap: () => _navigateTo(context, TaxUploadScreen()),
            ),
            _buildDashboardCard(
              context,
              icon: Icons.calculate_outlined,
              title: "Tax Calculator",
              color: Colors.green.shade50,
              iconColor: Colors.green,
              onTap: () => _navigateTo(context, TaxCalculatorScreen()),
            ),
            _buildDashboardCard(
              context,
              icon: Icons.notifications_active_outlined,
              title: "Tax Alerts",
              color: Colors.orange.shade50,
              iconColor: Colors.orange,
              onTap: () => _navigateTo(context, TaxNotificationsScreen()),
            ),
            _buildDashboardCard(
              context,
              icon: Icons.receipt_long_outlined,
              title: "Invoice Generator",
              color: Colors.purple.shade50,
              iconColor: Colors.purple,
              onTap: () => _navigateTo(context, InvoiceScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: color.withOpacity(0.3),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
