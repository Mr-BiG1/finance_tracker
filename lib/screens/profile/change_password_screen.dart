// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'widgets/password_input.dart';
// import 'widgets/save_button.dart';

// class ChangePasswordScreen extends StatefulWidget {
//   @override
//   _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
// }

// class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _currentPasswordController =
//       TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   bool _isLoading = false;

//   /// **Handles Password Change**
//   Future<void> _changePassword() async {
//     setState(() => _isLoading = true);

//     try {
//       User? user = _auth.currentUser;
//       String email = user?.email ?? "";

//       // Re-authenticate the user before changing the password
//       AuthCredential credential = EmailAuthProvider.credential(
//         email: email,
//         password: _currentPasswordController.text.trim(),
//       );
//       await user?.reauthenticateWithCredential(credential);

//       // Update the password
//       await user?.updatePassword(_newPasswordController.text.trim());

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text(" Password updated successfully!")),
//       );
//       Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(" Error: ${e.toString()}")));
//     }

//     setState(() => _isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Change Password"),
//         backgroundColor: Colors.black,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFF00C9FF),
//               Color(0xFFB721FF),
//             ], // Background gradient
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             children: [
//               const SizedBox(height: 50),
//               PasswordInput(
//                 controller: _currentPasswordController,
//                 hintText: "Current Password",
//               ),
//               const SizedBox(height: 20),
//               PasswordInput(
//                 controller: _newPasswordController,
//                 hintText: "New Password",
//               ),
//               const SizedBox(height: 40),
//               SaveButton(onPressed: _changePassword, isLoading: _isLoading),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/password_input.dart';
import 'widgets/save_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/change-password';

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Validates the new password meets complexity requirements
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Handles password change with proper validation and error handling
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not authenticated',
        );
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(_newPasswordController.text.trim());

      // Success - navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Maps Firebase errors to user-friendly messages
  void _handleFirebaseError(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'wrong-password':
        message = 'The current password is incorrect';
        break;
      case 'weak-password':
        message = 'The new password is too weak';
        break;
      case 'requires-recent-login':
        message =
            'This operation requires recent authentication. Please log in again';
        break;
      default:
        message = 'An error occurred: ${e.message}';
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Change Password",
          style: TextStyle(color: Colors.white), // Ensure visible text
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // ← back arrow
        systemOverlayStyle: SystemUiOverlayStyle.light, // ← status bar icons
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFFB721FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500, // optional max width
                minHeight:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 50),
                      PasswordInput(
                        controller: _currentPasswordController,
                        hintText: "Current Password",
                        labelText: "Current Password",
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please enter your current password'
                                    : null,
                        obscureText: !_currentPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _currentPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed:
                              () => setState(
                                () =>
                                    _currentPasswordVisible =
                                        !_currentPasswordVisible,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PasswordInput(
                        controller: _newPasswordController,
                        hintText: "New Password",
                        labelText: "New Password",
                        validator: _validatePassword,
                        obscureText: !_newPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _newPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed:
                              () => setState(
                                () =>
                                    _newPasswordVisible = !_newPasswordVisible,
                              ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      PasswordInput(
                        controller: _confirmPasswordController,
                        hintText: "Confirm New Password",
                        labelText: "Confirm New Password",
                        validator:
                            (value) =>
                                value != _newPasswordController.text
                                    ? 'Passwords do not match'
                                    : null,
                        obscureText: !_confirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed:
                              () => setState(
                                () =>
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible,
                              ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SaveButton(
                        onPressed: _isLoading ? null : _changePassword,
                        isLoading: _isLoading,
                        text: 'Update Password',
                      ),
                      if (_isLoading) const SizedBox(height: 20),
                      if (_isLoading) const LinearProgressIndicator(),
                      const SizedBox(height: 10), // slight padding below
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
