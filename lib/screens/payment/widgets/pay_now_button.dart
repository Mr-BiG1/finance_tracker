import 'package:flutter/material.dart';

class PayNowButton extends StatelessWidget {
  final String? selectedMethod;
  final VoidCallback onPay;
  final bool isLoading;

  const PayNowButton({
    required this.selectedMethod,
    required this.onPay,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = selectedMethod == null || isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPay,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: isDisabled ? Colors.grey[800] : Colors.blueAccent,
          elevation: isDisabled ? 0 : 3,
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  "Pay Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? Colors.white54 : Colors.white,
                  ),
                ),
      ),
    );
  }
}
