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
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;

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
        onTap: _toggleMenu,
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
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isMenuOpen = false;
    } else {
      _overlayEntry = _buildOverlayMenu();
      Overlay.of(context).insert(_overlayEntry!);
      _isMenuOpen = true;
    }
  }

  OverlayEntry _buildOverlayMenu() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Background tap area
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleMenu,
                child: Container(color: Colors.transparent),
              ),
            ),

            // Menu items above the FAB
            Positioned(
              left: _fabPosition.dx,
              top: _fabPosition.dy - 180,
              child: Column(
                children: [
                  _buildMenuItem(Icons.edit, "Add Manually", _addTransaction),
                  const SizedBox(height: 10),
                  _buildMenuItem(
                    Icons.camera_alt,
                    "Scan Bill",
                    _scanBillAndAdd,
                  ),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.chat_bubble_outline, "Chat", _goToChat),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String text, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _toggleMenu();
          onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddTransactionScreen()),
    );
  }

  void _goToChat() {
    Navigator.pushNamed(context, "/chat");
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
    final lines = text.split('\n').map((l) => l.trim()).toList();
    for (var line in lines) {
      if (line.contains(RegExp(r'[A-Za-z]')) &&
          line.contains(RegExp(r'[\$₹€]'))) {
        return line
            .replaceAll(RegExp(r'[\$₹€]?\s?\d+(\.\d{1,2})?'), '')
            .replaceAll(RegExp(r'[:\-]'), '')
            .trim();
      }
    }
    for (var line in lines) {
      if (line.contains(RegExp(r'[A-Za-z]'))) {
        return line.replaceAll(RegExp(r'[:\-]'), '').trim();
      }
    }
    return "Scanned Bill";
  }

  void _showSnack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
