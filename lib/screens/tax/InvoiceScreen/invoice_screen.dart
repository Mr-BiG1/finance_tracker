import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceScreen extends StatefulWidget {
  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _invoiceNoController = TextEditingController();
  final _companyNameController = TextEditingController(text: 'My Business');
  final _companyAddressController = TextEditingController(
    text: '123 Business St\nCity, State 10001',
  );
  final List<Map<String, dynamic>> _items = [];
  final double _taxPercent = 0.0625;

  void _addItem() {
    setState(() {
      _items.add({'desc': '', 'qty': 1, 'unit': 0.0});
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _generateInvoicePdf() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('MMM dd, yyyy');
      final now = DateTime.now();
      final due = now.add(const Duration(days: 15));

      double subtotal = 0;
      for (var item in _items) {
        subtotal += (item['qty'] as int) * (item['unit'] as double);
      }

      final tax = subtotal * _taxPercent;
      final total = subtotal + tax;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build:
              (context) => [
                _buildHeader(),
                pw.SizedBox(height: 20),
                _buildInvoiceInfo(now, due),
                pw.SizedBox(height: 30),
                _buildItemsTable(),
                pw.SizedBox(height: 20),
                _buildTotals(subtotal, tax, total),
                pw.SizedBox(height: 40),
                _buildFooter(),
              ],
        ),
      );

      await Printing.layoutPdf(onLayout: (format) => pdf.save());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: ${e.toString()}')),
      );
    }
  }

  pw.Widget _buildHeader() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              _companyNameController.text,
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(_companyAddressController.text),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue700,
              ),
            ),
            pw.Text(
              '#${_invoiceNoController.text}',
              style: const pw.TextStyle(fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceInfo(DateTime now, DateTime due) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Bill To:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(_clientNameController.text),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Row(
              children: [
                pw.Text(
                  'Invoice Date: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(dateFormat.format(now)),
              ],
            ),
            pw.Row(
              children: [
                pw.Text(
                  'Due Date: ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(dateFormat.format(due)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable() {
    return pw.TableHelper.fromTextArray(
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue700),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      headers: ['QTY', 'DESCRIPTION', 'UNIT PRICE', 'AMOUNT'],
      data:
          _items.map((item) {
            final qty = item['qty'] as int;
            final unit = item['unit'] as double;
            return [
              qty.toString(),
              item['desc'],
              '\$${unit.toStringAsFixed(2)}',
              '\$${(qty * unit).toStringAsFixed(2)}',
            ];
          }).toList(),
    );
  }

  pw.Widget _buildTotals(double subtotal, double tax, double total) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    'Subtotal:',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text('\$${subtotal.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text(
                    'Tax (${(_taxPercent * 100).toStringAsFixed(2)}%):',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text('\$${tax.toStringAsFixed(2)}'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Thank you for your business!',
          style: const pw.TextStyle(fontSize: 12),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Payment is due within 15 days. Please make checks payable to ${_companyNameController.text}.',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Invoice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Company Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: "Company Name"),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                controller: _companyAddressController,
                decoration: const InputDecoration(labelText: "Company Address"),
                maxLines: 2,
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                'Client Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: "Client Name"),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              TextFormField(
                controller: _invoiceNoController,
                decoration: const InputDecoration(labelText: "Invoice Number"),
                validator: (value) => value!.isEmpty ? 'Required field' : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Invoice Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              ..._items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  key: ValueKey(index),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            initialValue: item['desc'],
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            onChanged: (val) => item['desc'] = val,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Required field' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: item['qty'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Qty'),
                            onChanged:
                                (val) => item['qty'] = int.tryParse(val) ?? 1,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Required field' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            initialValue: item['unit'].toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Unit Price',
                            ),
                            onChanged:
                                (val) =>
                                    item['unit'] = double.tryParse(val) ?? 0.0,
                            validator:
                                (value) =>
                                    value!.isEmpty ? 'Required field' : null,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _removeItem(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                );
              }).toList(),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text("Add Item"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _generateInvoicePdf,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Generate Invoice PDF"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
