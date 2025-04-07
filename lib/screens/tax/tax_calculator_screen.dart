import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TaxCalculatorScreen extends StatefulWidget {
  const TaxCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<TaxCalculatorScreen> createState() => _TaxCalculatorScreenState();
}

class _TaxCalculatorScreenState extends State<TaxCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _deductionController = TextEditingController();
  final _currencyFormat = NumberFormat.currency(symbol: '₹');
  TaxCalculationResult? _calculationResult;

  @override
  void dispose() {
    _incomeController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tax Calculator"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIncomeInput(),
              const SizedBox(height: 16),
              _buildDeductionInput(),
              const SizedBox(height: 24),
              _buildCalculateButton(),
              if (_calculationResult != null) ...[
                const SizedBox(height: 32),
                _buildResultsCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeInput() {
    return TextFormField(
      controller: _incomeController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Gross Annual Income",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your income';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildDeductionInput() {
    return TextFormField(
      controller: _deductionController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: "Total Deductions (80C, HRA, etc.)",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
      validator: (value) {
        if (value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }

  Widget _buildCalculateButton() {
    return ElevatedButton(
      onPressed: _calculateTax,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text("CALCULATE TAX", style: TextStyle(fontSize: 16)),
    );
  }

  Widget _buildResultsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "TAX ESTIMATE",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const Divider(height: 24),
            _buildResultRow(
              "Taxable Income:",
              _currencyFormat.format(_calculationResult!.taxableIncome),
            ),
            const SizedBox(height: 12),
            _buildResultRow(
              "Estimated Tax:",
              _currencyFormat.format(_calculationResult!.taxAmount),
              isHighlighted: true,
            ),
            const SizedBox(height: 8),
            _buildResultRow(
              "Effective Tax Rate:",
              "${_calculationResult!.effectiveTaxRate.toStringAsFixed(2)}%",
            ),
            const SizedBox(height: 16),
            Text(
              "Based on FY 2023-24 tax slabs (New Regime)",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.green.shade700 : Colors.black,
          ),
        ),
      ],
    );
  }

  void _calculateTax() {
    if (!_formKey.currentState!.validate()) return;

    final income = double.parse(_incomeController.text);
    final deduction = double.tryParse(_deductionController.text) ?? 0;
    final taxableIncome = income - deduction;

    if (taxableIncome < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Deductions cannot exceed income"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taxAmount = _calculateTaxAmount(taxableIncome);
    final effectiveTaxRate = (taxAmount / income) * 100;

    setState(() {
      _calculationResult = TaxCalculationResult(
        taxableIncome: taxableIncome,
        taxAmount: taxAmount,
        effectiveTaxRate: effectiveTaxRate,
      );
    });
  }

  double _calculateTaxAmount(double taxableIncome) {
    // India FY 2023-24 new regime tax slabs
    if (taxableIncome <= 250000) return 0;
    if (taxableIncome <= 500000) return (taxableIncome - 250000) * 0.05;
    if (taxableIncome <= 750000) return (taxableIncome - 500000) * 0.1 + 12500;
    if (taxableIncome <= 1000000)
      return (taxableIncome - 750000) * 0.15 + 37500;
    if (taxableIncome <= 1250000)
      return (taxableIncome - 1000000) * 0.2 + 75000;
    if (taxableIncome <= 1500000)
      return (taxableIncome - 1250000) * 0.25 + 125000;
    return (taxableIncome - 1500000) * 0.3 + 187500;
  }
}

class TaxCalculationResult {
  final double taxableIncome;
  final double taxAmount;
  final double effectiveTaxRate;

  TaxCalculationResult({
    required this.taxableIncome,
    required this.taxAmount,
    required this.effectiveTaxRate,
  });
}
