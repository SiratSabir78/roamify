import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roamify/screens/login_screen.dart'; // Import the login page

Future<void> signOutAndNavigate(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  } catch (e) {
    // Handle sign out error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to sign out')),
    );
  }
}
