import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _changePassword() async {
    if (_user != null && _newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text == _confirmPasswordController.text) {
        try {
          // Reauthenticate the user with the current password
          AuthCredential credential = EmailAuthProvider.credential(
            email: _user!.email!,
            password: _currentPasswordController.text,
          );
          await _user!.reauthenticateWithCredential(credential);

          // Update the password
          await _user!.updatePassword(_newPasswordController.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password changed successfully!')),
          );

          // Clear text fields and navigate back
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
          Navigator.pop(context);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to change password: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('New passwords do not match')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define custom colors to use throughout the app
    Color primaryColor = Theme.of(context).primaryColor;
    //Color accentColor = Theme.of(context).accentColor;
    Color textColor = Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        backgroundColor: Color.fromARGB(255, 242, 219, 248),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Password Field
            Text(
              'Current Password',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // New Password Field
            Text(
              'New Password',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),

            // Confirm New Password Field
            Text(
              'Confirm New Password',
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),

            // Save Changes Button
            Center(
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  //primary: primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
