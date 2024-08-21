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
              'Here you can find general travel information including tips, guidelines, and more.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more information as needed
          ],
        ),
      ),
    );
  }
}
