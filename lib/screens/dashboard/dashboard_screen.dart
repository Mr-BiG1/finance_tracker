import 'package:flutter/material.dart';
import 'package:finance_tracker/screens/home/home_screen.dart';
import 'package:finance_tracker/screens/Stats%20Screen/stats_screen.dart';
import 'package:finance_tracker/screens/profile/profile_screen.dart';
import 'package:finance_tracker/screens/Settings_Screen/settings_screen.dart';
import 'package:finance_tracker/screens/payment/payment_screen.dart';
import 'package:finance_tracker/widgets/draggable_fab.dart'; // NEW

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    StatsScreen(),
    PaymentScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),
          const DraggableFAB(initialPosition: Offset(300, 600)), // NEW
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Stats"),
        BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }
}
