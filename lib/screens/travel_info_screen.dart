import 'package:flutter/material.dart';

class TravelInfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Travel Info'),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
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
