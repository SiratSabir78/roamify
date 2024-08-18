import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color.fromARGB(255, 242, 219, 248), // Light purple
              Color.fromARGB(245, 232, 209, 238), // Light pink
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Icon(
            Icons.location_on,
            color: Colors.white,
          ),
          SizedBox(width: 8), // Add spacing between icon and text
          Text(
            "Islamabad, Pakistan", // Replace with your location
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open drawer on menu icon tap
          },
        ),
      ],
    );
  }
}
