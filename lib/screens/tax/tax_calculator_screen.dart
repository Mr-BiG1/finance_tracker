import 'package:flutter/material.dart';

class TaxCalculatorScreen extends StatefulWidget {
  @override
  _TaxCalculatorScreenState createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final incomeController = TextEditingController();
  final deductionController = TextEditingController();
  double? result;

  double _calculateTax(double income) {
    // Example slab calculation (for India FY 2023-24 new regime):
    if (income <= 250000) return 0;
    if (income <= 500000) return (income - 250000) * 0.05;
    if (income <= 1000000) return (income - 500000) * 0.2 + 12500;
    return (income - 1000000) * 0.3 + 112500;
  }

  void _onCalculate() {
    if (_formKey.currentState!.validate()) {
      final income = double.parse(incomeController.text);
      final deduction = double.tryParse(deductionController.text) ?? 0;
      final taxableIncome = income - deduction;
      final tax = _calculateTax(taxableIncome);

      setState(() {
        result = tax;
      });
    }
  }

  @override
  void dispose() {
    incomeController.dispose();
    deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tax Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: incomeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Gross Income"),
                validator: (value) => value!.isEmpty ? "Enter income" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: deductionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Deductions"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onCalculate,
                child: const Text("Calculate Tax"),
              ),
              const SizedBox(height: 24),
              if (result != null)
                Text(
                  "Estimated Tax: ₹${result!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
