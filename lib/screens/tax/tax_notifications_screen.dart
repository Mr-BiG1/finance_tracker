import 'package:flutter/material.dart';

class TaxNotificationsScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Upcoming Filing Deadline",
      "message": "Don’t forget to file your Q1 tax returns before April 30th.",
    },
    {
      "title": "Document Verification",
      "message":
          "Your PAN verification is pending. Please upload the required document.",
    },
    {
      "title": "Tax Deduction Update",
      "message":
          "Section 80C deduction updated based on your recent investment submission.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tax Notifications")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(
                Icons.notifications_active,
                color: Colors.deepPurple,
              ),
              title: Text(
                notification["title"]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(notification["message"]!),
            ),
          );
        },
      ),
    );
  }
}
