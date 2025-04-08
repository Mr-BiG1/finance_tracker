import 'package:flutter/material.dart';
import 'package:finance_tracker/data/services/payment_service.dart';

class AddCardModal extends StatefulWidget {
  final PaymentService paymentService;

  const AddCardModal({Key? key, required this.paymentService})
    : super(key: key);

  @override
  _AddCardModalState createState() => _AddCardModalState();
}

class _AddCardModalState extends State<AddCardModal> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  String _selectedCardType = "Visa";

  void _submitCard() async {
    if (_cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty ||
        _cardHolderController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    await widget.paymentService.addCard(
      cardNumber: _cardNumberController.text,
      expiry: _expiryController.text,
      cardHolder: _cardHolderController.text,
      type: _selectedCardType,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Add New Card",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Card Number"),
              ),
              TextField(
                controller: _expiryController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: "Expiry Date (MM/YY)",
                ),
              ),
              TextField(
                controller: _cardHolderController,
                decoration: const InputDecoration(
                  labelText: "Card Holder Name",
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _selectedCardType,
                items:
                    ["Visa", "MasterCard", "Amex"].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCardType = value!;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _submitCard,
                child: const Text("Save Card"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
