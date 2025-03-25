import 'package:flutter/material.dart';
import 'package:finance_tracker/screens/home/home_screen.dart';
import 'package:finance_tracker/screens/Stats%20Screen/stats_screen.dart';
import 'package:finance_tracker/screens/profile/profile_screen.dart';
import 'package:finance_tracker/screens/Settings_Screen/settings_screen.dart';
import 'package:finance_tracker/screens/payment/payment_screen.dart';
import 'package:finance_tracker/data/services/add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
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

  Offset _fabPosition = const Offset(300, 600);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _selectedIndex, children: _screens),

          // Draggable FAB
          Positioned(
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
              child: _buildDraggableFAB(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableFAB() {
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
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
        },
      ),
    );
  }
}
