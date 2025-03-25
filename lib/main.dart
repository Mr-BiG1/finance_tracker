import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_tracker/screens/auth/login_screen.dart';
import 'package:finance_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:finance_tracker/screens/profile/change_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Disable mouse gesture tracking issue
  GestureBinding.instance.resamplingEnabled = true;

  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(),

      // Register Routes Here
      routes: {
        "/login": (context) => LoginScreen(),
        "/dashboard": (context) => DashboardScreen(),
        "/changePassword": (context) => ChangePasswordScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return DashboardScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
