import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roamify/screens/login_screen.dart';
import 'package:roamify/screens/welcome_screen.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    print("Inside Wrapper");
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while checking authentication status
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            // User is authenticated
            print("User is authenticated, navigating to WelcomeScreen");
            return WelcomeScreen();
          } else {
            // User is not authenticated
            print("User is not authenticated, navigating to LoginPage");
            return LoginPage();
          }
        },
      ),
    );
  }
}
