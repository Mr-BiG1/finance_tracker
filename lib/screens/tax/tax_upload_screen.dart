import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxUploadScreen extends StatefulWidget {
  const TaxUploadScreen({Key? key}) : super(key: key);

  @override
  State<TaxUploadScreen> createState() => _TaxUploadScreenState();
}

class _TaxUploadScreenState extends State<TaxUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yearController = TextEditingController();
  final _incomeController = TextEditingController();
  final _deductionController = TextEditingController();
  final _storage = FirebaseStorage.instance;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  File? _selectedFile;
  bool _isLoading = false;
  String? _fileName;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _yearController.dispose();
    _incomeController.dispose();
    _deductionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _fileName = pickedFile.name;
        });
      }
    } catch (e) {
      _showError('Failed to pick file: ${e.toString()}');
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      _showError('User not authenticated');
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      String? fileUrl;
      if (_selectedFile != null) {
        fileUrl = await _uploadFile(user.uid);
      }

      await _saveTaxData(
        userId: user.uid,
        year: _yearController.text.trim(),
        grossIncome: double.parse(_incomeController.text.trim()),
        deductions: double.parse(_deductionController.text.trim()),
        documentUrl: fileUrl,
      );

      _showSuccess('Tax information saved successfully');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Failed to save tax information: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _uploadFile(String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = _selectedFile!.path.split('.').last;
      final ref = _storage.ref('tax_documents/$userId/$timestamp.$extension');

      final uploadTask = ref.putFile(
        _selectedFile!,
        SettableMetadata(contentType: 'image/$extension'),
      );

      uploadTask.snapshotEvents.listen((snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask;
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
    }
  }

  Future<void> _saveTaxData({
    required String userId,
    required String year,
    required double grossIncome,
    required double deductions,
    String? documentUrl,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tax_records')
        .add({
          'year': year,
          'grossIncome': grossIncome,
          'deductions': deductions,
          'documentUrl': documentUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'taxableIncome': grossIncome - deductions,
        });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Tax Details'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? _buildLoadingIndicator()
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildYearField(),
                      const SizedBox(height: 16),
                      _buildIncomeField(),
                      const SizedBox(height: 16),
                      _buildDeductionsField(),
                      const SizedBox(height: 24),
                      _buildFileUploadSection(),
                      const SizedBox(height: 32),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            value: _uploadProgress > 0 ? _uploadProgress : null,
          ),
          const SizedBox(height: 16),
          Text(
            _uploadProgress > 0
                ? 'Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%'
                : 'Processing...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildYearField() {
    return TextFormField(
      controller: _yearController,
      decoration: const InputDecoration(
        labelText: 'Tax Year',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.calendar_today),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter the tax year';
        final year = int.tryParse(value);
        if (year == null || year < 2000 || year > DateTime.now().year + 1) {
          return 'Please enter a valid year';
        }
        return null;
      },
    );
  }

  Widget _buildIncomeField() {
    return TextFormField(
      controller: _incomeController,
      decoration: const InputDecoration(
        labelText: 'Gross Income',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter your income';
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildDeductionsField() {
    return TextFormField(
      controller: _deductionController,
      decoration: const InputDecoration(
        labelText: 'Total Deductions',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.receipt),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final amount = double.tryParse(value);
          if (amount == null || amount < 0) {
            return 'Please enter a valid amount';
          }
        }
        return null;
      },
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload),
          label: Text(
            _selectedFile == null ? 'Select Document' : 'Change Document',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(height: 12),
          Text(
            _fileName ?? 'Selected file',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'File size: ${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(1)} KB',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('SAVE TAX RECORD', style: TextStyle(fontSize: 16)),
    );
  }
}
