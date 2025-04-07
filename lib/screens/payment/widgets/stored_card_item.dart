import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/data/services/payment_service.dart';

class StoredCardItem extends StatelessWidget {
  final DocumentSnapshot card;
  final PaymentService paymentService;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onDelete;

  const StoredCardItem({
    Key? key,
    required this.card,
    required this.paymentService,
    required this.isSelected,
    required this.onSelect,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = card.data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        print("Card Selected: ${data['cardNumber']}");
        onSelect();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient:
              isSelected
                  ? const LinearGradient(
                    colors: [Colors.blueAccent, Colors.purpleAccent],
                  )
                  : LinearGradient(
                    colors: [Colors.grey.shade900, Colors.grey.shade800],
                  ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.blueAccent.withOpacity(0.4)
                      : Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Card Details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${data['type']} ****${data['cardNumber'].substring(data['cardNumber'].length - 4)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Expires: ${data['expiry']}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            // Card Type Icon + Delete Button
            Row(
              children: [
                _getCardIcon(data['type']),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    print("🗑️ Deleting Card: ${data['cardNumber']}");
                    await paymentService.deleteCard(card.id);
                    if (onDelete != null) onDelete!(); // <-- trigger callback
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCardIcon(String type) {
    String iconPath = "assets/icons/${type.toLowerCase()}.png";
    return Image.asset(
      iconPath,
      height: 24,
      width: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        print(" Missing icon for $type. Using default.");
        return const Icon(Icons.credit_card, color: Colors.white);
      },
    );
  }
}
