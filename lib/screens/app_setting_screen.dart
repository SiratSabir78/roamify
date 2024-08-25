import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/profile_screen.dart';
import 'package:roamify/screens/state.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
         
        ),
        backgroundColor: settings.darkMode
            ? Colors.black
            : const Color.fromARGB(255, 221, 128, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Dark Mode',
                  style: TextStyle(fontSize: settings.fontSize)),
              value: settings.darkMode,
              onChanged: (value) {
                settings.toggleDarkMode(value);
              },
            ),
            ListTile(
              title: Text('Font Size',
                  style: TextStyle(fontSize: settings.fontSize)),
              subtitle: Slider(
                value: settings.fontSize,
                min: 10.0,
                max: 24.0,
                onChanged: (value) {
                  settings.setFontSize(value);
                },
              ),
            ),
            SwitchListTile(
              title: Text('Enable Notifications',
                  style: TextStyle(fontSize: settings.fontSize)),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                settings.toggleNotifications(value);
              },
            ),
            ListTile(
              title: Text('Privacy Policy',
                  style: TextStyle(fontSize: settings.fontSize)),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                _showPrivacyPolicyDialog(context, settings.fontSize);
              },
            ),
            ListTile(
              title: Text('Terms of Service',
                  style: TextStyle(fontSize: settings.fontSize)),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                _showTermsAndServicesDialog(context, settings.fontSize);
              },
            ),
            ListTile(
              title: Text('Account Management',
                  style: TextStyle(fontSize: settings.fontSize)),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: settings.darkMode ? Colors.black : Colors.white,
    );
  }

  void _showTermsAndServicesDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms of Service', style: TextStyle(fontSize: fontSize)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1. Acceptance of Terms\n\n"
                  "By accessing and using this app, you agree to be bound by the terms and conditions outlined in this document.\n\n"
                  "2. Changes to Terms\n\n"
                  "We reserve the right to update or modify these terms at any time. Any changes will be posted on this page.\n\n"
                  "3. User Responsibilities\n\n"
                  "You agree to use the app responsibly and in accordance with all applicable laws.\n\n"
                  "4. Privacy Policy\n\n"
                  "Please review our Privacy Policy to understand how we collect, use, and protect your personal information.\n\n"
                  "5. Termination\n\n"
                  "We may terminate your access to the app if you breach any of these terms.\n\n"
                  "6. Contact Us\n\n"
                  "If you have any questions or concerns about these terms, please contact us at support@example.com.",
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(fontSize: fontSize)),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, double fontSize) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy', style: TextStyle(fontSize: fontSize)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "1. Information We Collect\n\n"
                  "We collect information such as your name, email address, and other personal details when you register.\n\n"
                  "2. How We Use Your Information\n\n"
                  "We use the information we collect to provide you with a personalized experience and to improve our app.\n\n"
                  "3. Sharing Your Information\n\n"
                  "We do not share your personal information with third parties except as required by law.\n\n"
                  "4. Data Security\n\n"
                  "We implement industry-standard security measures to protect your data.\n\n"
                  "5. Changes to Privacy Policy\n\n"
                  "We may update our privacy policy from time to time. Changes will be posted on this page.\n\n"
                  "6. Contact Us\n\n"
                  "If you have any questions or concerns about this privacy policy, please contact us at support@example.com.",
                  style: TextStyle(fontSize: fontSize),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(fontSize: fontSize)),
            ),
          ],
        );
      },
    );
  }
}
