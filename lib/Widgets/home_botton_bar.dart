import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:roamify/screens/home_screen.dart';
import 'package:roamify/screens/favorites_screen.dart';
import 'package:roamify/screens/profile_screen.dart';
import 'package:roamify/screens/booking_page.dart';
import 'package:roamify/screens/search_screen.dart';

class HomeBottomBar extends StatefulWidget {
  @override
  _HomeBottomBarState createState() => _HomeBottomBarState();
}

class _HomeBottomBarState extends State<HomeBottomBar> {
  int _currentIndex = 1; // Default index for home screen

  final List<Widget> _screens = [
    ProfileScreen(),
    FavoriteScreen(),
    BookingPage(),
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        index: _currentIndex,
        items: const [
          Icon(Icons.person_outline, size: 30),
          Icon(Icons.favorite_outline_outlined, size: 30),
          Icon(Icons.home, size: 30, color: Colors.redAccent),
          Icon(Icons.menu_book, size: 30),
          Icon(Icons.list, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
