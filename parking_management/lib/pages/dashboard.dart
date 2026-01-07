import 'package:flutter/material.dart';
import 'home.dart';
import 'book.dart';
import 'activity.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 1;

  final List<Widget> _pages = const [
    BookPage(),
    HomeScreen(),
    ActivityPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.grey[900],
          selectedItemColor: Colors.lightGreen,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.local_parking),
              label: 'Book',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'Activity',
            ),
          ],
        ),
      ),
    );
  }
}
