import 'package:finance_tracker/screens/profile/widgets/LoadingIndicator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:finance_tracker/utils/constants.dart';
import 'widgets/profile_card.dart';
import 'widgets/profile_option.dart';
import 'widgets/logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _getUserData();
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      return userDoc.data()!
        ..addAll({'email': user.email, 'emailVerified': user.emailVerified});
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _userDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: LoadingIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState();
            }

            if (!snapshot.hasData) {
              return _buildEmptyState();
            }

            return _buildProfileContent(snapshot.data!);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        "Profile",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.secondary],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.1, 0.9],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            "Failed to load profile",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed:
                () => setState(() {
                  _userDataFuture = _getUserData();
                }),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            "User data not found",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(Map<String, dynamic> userData) {
    final formattedJoinDate = _formatTimestamp(userData['joinDate']);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: kToolbarHeight + 40),

            // Profile Card
            ProfileCard(
              userName: userData['name'] ?? "Unknown",
              email: userData['email'] ?? "No Email",
              joinDate: formattedJoinDate,
              isVerified: userData['emailVerified'] ?? false,
            ),
            const SizedBox(height: 30),

            // Profile Options
            _buildProfileOptions(),
            const SizedBox(height: 20),

            // Logout Button
            const LogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        ProfileOption(
          icon: Icons.edit,
          text: "Edit Profile",
          onTap: () => _navigateTo(AppRoutes.editProfile),
        ),
        ProfileOption(
          icon: Icons.lock,
          text: "Change Password",
          onTap: () => _navigateTo(AppRoutes.changePassword),
        ),
        ProfileOption(
          icon: Icons.privacy_tip,
          text: "Privacy Settings",
          onTap: () => _navigateTo(AppRoutes.privacySettings),
        ),
        ProfileOption(
          icon: Icons.settings,
          text: "App Settings",
          onTap: () => _navigateTo(AppRoutes.appSettings),
        ),
        ProfileOption(
          icon: Icons.help_outline,
          text: "Help & Support",
          onTap: () => _navigateTo(AppRoutes.helpSupport),
        ),
      ],
    );
  }

  void _navigateTo(String route) {
    Navigator.pushNamed(context, route).then((_) {
      // Refresh user data when returning from edit screens
      if (route == "/editProfile" || route == "/changePassword") {
        setState(() {
          _userDataFuture = _getUserData();
        });
      }
    });
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Unknown Date";

    try {
      if (timestamp is Timestamp) {
        return DateFormat('MMMM d, y').format(timestamp.toDate());
      }
      if (timestamp is DateTime) {
        return DateFormat('MMMM d, y').format(timestamp);
      }
      return "Unknown Date";
    } catch (e) {
      debugPrint('Error formatting timestamp: $e');
      return "Unknown Date";
    }
  }
}
