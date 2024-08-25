import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/home_screen.dart';
import 'package:roamify/screens/state.dart';

class TravelInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false, // Removes all existing routes
            );
          },
        ),
        title: Text('Travel Info'),
        backgroundColor:
            isDarkMode ? Colors.black : const Color.fromRGBO(186, 104, 200, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Welcome to Roamify! Here you can find useful travel information, tips, and guidelines to make your journey more enjoyable.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Travel Guidelines:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              '1. Always check the weather forecast before your trip and pack accordingly.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '2. Make sure to carry essential documents such as ID, passport, and travel tickets.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '3. Stay hydrated and take regular breaks during your travel to avoid fatigue.',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '4. Familiarize yourself with local customs and regulations to ensure a smooth experience.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'About Roamify:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Roamify is your ultimate travel companion. We provide detailed information about cities, allow you to book trips, and help you manage your bookings effortlessly. Enjoy exploring new places with us!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
