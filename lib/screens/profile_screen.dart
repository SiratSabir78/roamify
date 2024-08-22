import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:roamify/screens/user_profile_screen/change_password_screen.dart';
import 'package:roamify/screens/user_profile_screen/change_username_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    if (_user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .get();

      setState(() {
        _username = userDoc['username'];
      });
    }
  }

  void _navigateToChangeUsernameScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangeUsernameScreen()),
    );
    _loadUsername(); // Refresh username after returning from ChangeUsernameScreen
  }

  void _navigateToChangePasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
    );
  }

  void _showOptionsMenu(BuildContext context, String title, Widget screen) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              title: Text(title),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    Color textColor = Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        backgroundColor: primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage('images/profile_placeholder.png'),
                  ),
                  SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement profile picture change functionality
                    },
                    child: Text(
                      'Change Profile Picture',
                      style: TextStyle(color: Color.fromARGB(255, 221, 128, 244)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Username Tile
            if (_user != null)
              ListTile(
                title: Text('Username', style: TextStyle(color: textColor)),
                subtitle: Text(_username, style: TextStyle(color: textColor)),
                trailing: Icon(Icons.more_vert, color: primaryColor),
                onTap: _navigateToChangeUsernameScreen,
              ),
            Divider(color: Colors.grey),

            // Password Tile
            if (_user != null)
              ListTile(
                title: Text('Password', style: TextStyle(color: textColor)),
                subtitle: Text('********', style: TextStyle(color: textColor)),
                trailing: Icon(Icons.more_vert, color: primaryColor),
                onTap: _navigateToChangePasswordScreen,
              ),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
