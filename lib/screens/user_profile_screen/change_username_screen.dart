import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChangeUsernameScreen extends StatefulWidget {
  @override
  _ChangeUsernameScreenState createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final User? _user = FirebaseAuth.instance.currentUser;

  void _changeUsername() async {
    if (_user != null) {
      String newUsername = _usernameController.text.trim();
      if (newUsername.isNotEmpty) {
        // Update username in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user.uid)
            .update({
          'username': newUsername,
        });
        Navigator.pop(context); // Go back after successful update
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Username'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'New Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changeUsername,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
