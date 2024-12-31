import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'hospitals_screen.dart';
import 'medications_screen.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    const HomeScreenContent(),
    const ReportsScreen(),
    const HospitalsScreenContent(),
    const MedicationsScreenContent(),
    const ProfileScreenContent(),
  ];

  void _onProfileTap() {
    setState(() {
      _selectedIndex = 4; // Index of the ProfileScreenContent
    });
    _bottomNavigationKey.currentState?.setPage(4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onProfileTap: _onProfileTap),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: Colors.white,
        color: const Color(0xFFB0C4DE), // Light blue background similar to your image
        buttonBackgroundColor: Colors.blue, // Highlight color for selected icon
        height: 60,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.report, size: 30, color: Colors.white),
          Icon(Icons.local_hospital, size: 30, color: Colors.white),
          Icon(Icons.medical_services, size: 30, color: Colors.white),
          Icon(Icons.person, size: 30, color: Colors.white),
        ],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.home, size: 150, color: Colors.blue),
    );
  }
}