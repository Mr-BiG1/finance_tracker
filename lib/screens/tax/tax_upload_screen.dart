import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxUploadScreen extends StatefulWidget {
  @override
  _TaxUploadScreenState createState() => _TaxUploadScreenState();
}

class _TaxUploadScreenState extends State<TaxUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();
  final TextEditingController _deductionController = TextEditingController();

  File? _selectedFile;
  bool _loading = false;

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String? fileUrl;
    if (_selectedFile != null) {
      final ref = FirebaseStorage.instance.ref(
        'tax_files/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(_selectedFile!);
      fileUrl = await ref.getDownloadURL();
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('taxes')
        .add({
          "year": _yearController.text.trim(),
          "grossIncome": double.parse(_incomeController.text.trim()),
          "deductions": double.parse(_deductionController.text.trim()),
          "documentUrl": fileUrl,
          "createdAt": Timestamp.now(),
        });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Tax info saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Tax Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _loading
                ? Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _yearController,
                        decoration: InputDecoration(labelText: 'Year'),
                        keyboardType: TextInputType.number,
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _incomeController,
                        decoration: InputDecoration(labelText: 'Gross Income'),
                        keyboardType: TextInputType.number,
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _deductionController,
                        decoration: InputDecoration(labelText: 'Deductions'),
                        keyboardType: TextInputType.number,
                        validator:
                            (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: Icon(Icons.upload_file),
                        label: Text(
                          _selectedFile == null
                              ? 'Upload Document'
                              : 'Change File',
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(onPressed: _submit, child: Text('Save')),
                    ],
                  ),
                ),
      ),
    );
  }
}
