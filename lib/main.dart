import 'package:finance_tracker/screens/Chat/chat_Screen.dart';
import 'package:finance_tracker/screens/Settings_Screen/app_settings_screen.dart';
import 'package:finance_tracker/screens/Settings_Screen/help_support_screen.dart';
import 'package:finance_tracker/screens/Settings_Screen/privacy_settings_screen.dart';
import 'package:finance_tracker/screens/auth/signup_screen.dart';
import 'package:finance_tracker/screens/tax/InvoiceScreen/invoice_screen.dart';
import 'package:finance_tracker/screens/tax/tax_calculator_screen.dart';
import 'package:finance_tracker/screens/tax/tax_dashboard_screen.dart';
import 'package:finance_tracker/screens/tax/tax_notifications_screen.dart';
import 'package:finance_tracker/screens/tax/tax_summary_screen.dart';
import 'package:finance_tracker/screens/tax/tax_upload_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_tracker/screens/auth/login_screen.dart';
import 'package:finance_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:finance_tracker/screens/profile/change_password_screen.dart';
import 'package:finance_tracker/screens/profile/edit_profile_screen.dart';
import 'package:finance_tracker/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      routes: {
        AppRoutes.login: (context) => LoginScreen(),
        AppRoutes.signUp: (context) => SignUpScreen(),
        AppRoutes.dashboard: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int initialTab = args is int ? args : 0;
          return DashboardScreen(initialTab: initialTab);
        },
        AppRoutes.changePassword: (context) => ChangePasswordScreen(),
        AppRoutes.editProfile: (context) => EditProfileScreen(),
        AppRoutes.privacySettings: (context) => PrivacySettingsScreen(),
        AppRoutes.appSettings: (context) => AppSettingsScreen(),
        AppRoutes.helpSupport: (context) => HelpSupportScreen(),
        AppRoutes.chat: (context) => ChatScreen(),
        AppRoutes.taxUpload: (context) => TaxUploadScreen(),
        AppRoutes.taxCalculator: (context) => TaxCalculatorScreen(),
        AppRoutes.taxSummary: (context) => TaxSummaryScreen(),
        AppRoutes.tax: (context) => const TaxDashboardScreen(),
        AppRoutes.taxNotifications: (context) => TaxNotificationsScreen(),
        AppRoutes.invoice: (context) => InvoiceScreen(),
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
