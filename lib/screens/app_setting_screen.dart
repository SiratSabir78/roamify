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
                  "If you have any questions or concerns about these terms, please contact us at roamify@gmail.com.",
                  style: TextStyle(fontSize: 16),
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
                  "1. Information Collection\n\n"
                  "We collect personal information that you provide to us directly, such as your name, email address, and other contact details.\n\n"
                  "2. Use of Information\n\n"
                  "We use your information to provide, maintain, and improve our services, as well as to communicate with you about updates and offers.\n\n"
                  "3. Data Security\n\n"
                  "We implement reasonable security measures to protect your information from unauthorized access, alteration, or destruction.\n\n"
                  "4. Sharing Information\n\n"
                  "We do not sell or rent your personal information to third parties. We may share your information with partners and service providers only as necessary to fulfill our services.\n\n"
                  "5. User Rights\n\n"
                  "You have the right to access, correct, or delete your personal information. To exercise these rights, please contact us directly.\n\n"
                  "6. Changes to Privacy Policy\n\n"
                  "We may update this Privacy Policy from time to time. Any changes will be posted on this page.\n\n"
                  "7. Contact Us\n\n"
                  "If you have any questions or concerns about our Privacy Policy, please contact us at roamify@gmail.com.",
                  style: TextStyle(fontSize: 16),
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
