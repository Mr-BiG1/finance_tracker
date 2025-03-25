import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:finance_tracker/data/services/add_transaction_screen.dart';
import 'package:finance_tracker/data/services/transaction_service.dart';

class DraggableFAB extends StatefulWidget {
  final Offset initialPosition;

  const DraggableFAB({Key? key, required this.initialPosition})
    : super(key: key);

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> {
  late Offset _fabPosition;

  @override
  void initState() {
    super.initState();
    _fabPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    const fabSize = 56.0;

    final minX = 0.0;
    final minY = padding.top + kToolbarHeight;
    final maxX = screen.width - fabSize;
    final maxY =
        screen.height -
        padding.bottom -
        fabSize -
        kBottomNavigationBarHeight -
        16;

    return Positioned(
      top: _fabPosition.dy,
      left: _fabPosition.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final newOffset = _fabPosition + details.delta;
            _fabPosition = Offset(
              newOffset.dx.clamp(minX, maxX),
              newOffset.dy.clamp(minY, maxY),
            );
          });
        },
        child: _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7F00FF), Color(0xFFE100FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: _showAddOptions,
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Add Manually"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddTransactionScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Scan Bill"),
                onTap: () {
                  Navigator.pop(context);
                  _scanBillAndAdd();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _scanBillAndAdd() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile == null) return;

      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await recognizer.processImage(inputImage);
      await recognizer.close();

      final text = recognizedText.text;
      final double? amount = _extractAmount(text);
      final String category = _extractCategory(text) ?? "Scanned Bill";

      if (amount == null) {
        _showSnack("Could not extract amount from bill.");
        return;
      }

      await TransactionService().addTransaction(
        category,
        amount,
        DateTime.now(),
      );
      _showSnack("Added $category - \$$amount");
    } catch (e) {
      _showSnack("Error while scanning bill: $e");
    }
  }

  double? _extractAmount(String text) {
    final match =
        RegExp(r'[\$₹€]?\s?(\d+(\.\d{1,2})?)').allMatches(text).toList();
    if (match.isEmpty) return null;
    return double.tryParse(match.last.group(1)?.replaceAll(',', '') ?? '');
  }

  String? _extractCategory(String text) {
    final match = RegExp(r'^([A-Za-z ]+)[\:\-]').firstMatch(text);
    return match?.group(1)?.trim();
  }

  void _showSnack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
