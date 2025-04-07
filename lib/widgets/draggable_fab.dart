import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:finance_tracker/data/services/add_transaction_screen.dart';
import 'package:finance_tracker/data/services/transaction_service.dart';
import 'package:finance_tracker/utils/app_routes.dart';

class DraggableFAB extends StatefulWidget {
  final Offset initialPosition;

  const DraggableFAB({Key? key, required this.initialPosition})
    : super(key: key);

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB>
    with SingleTickerProviderStateMixin {
  late Offset _fabPosition;
  bool _isMenuOpen = false;
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fabPosition = widget.initialPosition;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
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
        child: ScaleTransition(scale: _scaleAnimation, child: _buildFAB()),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isMenuOpen = false;
    } else {
      _overlayEntry = _buildOverlayMenu();
      Overlay.of(context).insert(_overlayEntry!);
      _animationController.forward();
      _isMenuOpen = true;
    }
  }

  OverlayEntry _buildOverlayMenu() {
    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Background dim and tap area
            Positioned.fill(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: _toggleMenu,
                  child: Container(color: Colors.black.withOpacity(0.3)),
                ),
              ),
            ),

            // Menu items
            Positioned(
              left: _fabPosition.dx - 100,
              top: _fabPosition.dy - 240,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            Icons.account_balance,
                            "Tax Dashboard",
                            _goToTaxDashboard,
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          _buildMenuItem(
                            Icons.edit,
                            "Add Manually",
                            _addTransaction,
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          _buildMenuItem(
                            Icons.camera_alt,
                            "Scan Bill",
                            _scanBillAndAdd,
                          ),
                          const Divider(height: 16, thickness: 0.5),
                          _buildMenuItem(
                            Icons.chat_bubble_outline,
                            "Chat with AI",
                            _goToChat,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        _toggleMenu();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.deepPurple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _goToTaxDashboard() {
    Navigator.pushNamed(context, AppRoutes.tax);
  }

  void _addTransaction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _goToChat() {
    Navigator.pushNamed(context, AppRoutes.chat);
  }

  Future<void> _scanBillAndAdd() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1200,
        imageQuality: 90,
      );

      if (pickedFile == null) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final inputImage = InputImage.fromFile(File(pickedFile.path));
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognizedText = await recognizer.processImage(inputImage);
      await recognizer.close();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      final text = recognizedText.text;
      final double? amount = _extractAmount(text);
      final String category = _extractCategory(text) ?? "Scanned Bill";

      if (amount == null) {
        _showSnack("Could not extract amount from bill");
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Confirm Transaction"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category: $category"),
                  const SizedBox(height: 8),
                  Text("Amount: \$${amount.toStringAsFixed(2)}"),
                  const SizedBox(height: 16),
                  const Text("Is this information correct?"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Confirm"),
                ),
              ],
            ),
      );

      if (confirmed == true) {
        await TransactionService().addTransaction(
          category,
          amount,
          DateTime.now(),
        );
        _showSnack("Added $category - \$${amount.toStringAsFixed(2)}");
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showSnack("Error while scanning bill: ${e.toString()}");
    }
  }

  double? _extractAmount(String text) {
    // Improved amount extraction with better pattern matching
    final matches = RegExp(
      r'(?:[\$₹€]|USD|EUR|INR)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{1,2})?)',
    ).allMatches(text);

    if (matches.isEmpty) return null;

    // Get the largest amount found (likely the total)
    double? maxAmount;
    for (final match in matches) {
      final amountStr = match.group(1)?.replaceAll(',', '');
      final amount = double.tryParse(amountStr ?? '');
      if (amount != null && (maxAmount == null || amount > maxAmount)) {
        maxAmount = amount;
      }
    }

    return maxAmount;
  }

  String? _extractCategory(String text) {
    // Improved category extraction logic
    final lines =
        text
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

    // Look for common receipt patterns
    for (var line in lines) {
      // Skip lines that are just numbers or amounts
      if (RegExp(r'^[\$₹€]?\s?\d+').hasMatch(line)) continue;

      // Look for lines that might contain category info
      if (line.length > 3 &&
          line.length < 30 &&
          !line.contains(RegExp(r'[0-9]'))) {
        // Clean up the line
        return line
            .replaceAll(RegExp(r'[\*\-+#]'), '')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
      }
    }

    // Fallback to first non-empty line that doesn't look like an amount
    for (var line in lines) {
      if (!RegExp(r'[\$₹€]?\s?\d+').hasMatch(line) && line.length > 3) {
        return line
            .replaceAll(RegExp(r'[\*\-+#]'), '')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
      }
    }

    return "Scanned Bill";
  }

  void _showSnack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
