import 'package:flutter/material.dart';

class AppSettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Settings'),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('Change Theme'),
              leading: Icon(Icons.color_lens),
              onTap: () {
                // Handle theme change
              },
            ),
            ListTile(
              title: Text('Manage Notifications'),
              leading: Icon(Icons.notifications),
              onTap: () {
                // Handle notification management
              },
            ),
            ListTile(
              title: Text('Privacy Policy'),
              leading: Icon(Icons.security),
              onTap: () {
                // Handle privacy policy
              },
            ),
            // Add more settings options as needed
          ],
        ),
      ),
    );
  }
}
