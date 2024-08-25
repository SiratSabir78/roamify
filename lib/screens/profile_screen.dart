import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:roamify/screens/state.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String _username = '';
  String _gender = 'Male'; // Default to male, change as necessary
  String _profileImagePath = 'images/male_default.png'; // Default profile image

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    if (_user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'] ?? '';
            _gender =
                userDoc['gender'] ?? 'Male'; // Default to male if not specified

            // Set the profile image based on gender
            _profileImagePath = _gender == 'Female'
                ? 'images/female_default.png'
                : 'images/male_default.png';
          });
        } else {
          print('User document does not exist');
        }
      } catch (e) {
        print('Error loading user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error loading user data: $e'),
        ));
      }
    } else {
      print('User is not authenticated');
    }
  }

  void _showChangeUsernameDialog() {
    TextEditingController usernameController = TextEditingController();
    String? usernameError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Username'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'New Username',
                      errorText: usernameError,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (_user != null) {
                      String newUsername = usernameController.text.trim();

                      if (newUsername == _username) {
                        setState(() {
                          usernameError =
                              'Username is the same as the current one. Please choose a different username.';
                        });
                      } else if (newUsername.isEmpty) {
                        setState(() {
                          usernameError = 'Username cannot be empty.';
                        });
                      } else {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_user!.uid)
                              .update({'username': newUsername});
                          _loadUserData(); // Refresh the username on the profile screen
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Username changed successfully!')));
                        } catch (e) {
                          setState(() {
                            usernameError = 'Failed to change username: $e';
                          });
                        }
                      }
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    String? currentPasswordError;
    String? newPasswordError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Current Password',
                      errorText: currentPasswordError,
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      errorText: newPasswordError,
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      if (value == confirmPasswordController.text) {
                        setState(() {
                          newPasswordError = null;
                        });
                      } else {
                        setState(() {
                          newPasswordError = 'Passwords do not match';
                        });
                      }
                    },
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm New Password',
                      errorText: newPasswordError,
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      if (value == newPasswordController.text) {
                        setState(() {
                          newPasswordError = null;
                        });
                      } else {
                        setState(() {
                          newPasswordError = 'Passwords do not match';
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      setState(() {
                        newPasswordError = 'Passwords do not match';
                      });
                      return;
                    }

                    try {
                      AuthCredential credential = EmailAuthProvider.credential(
                          email: _user!.email!,
                          password: currentPasswordController.text);
                      await _user!.reauthenticateWithCredential(credential);
                      await _user!.updatePassword(newPasswordController.text);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Password changed successfully!')));
                    } catch (e) {
                      setState(() {
                        currentPasswordError = 'Incorrect current password';
                      });
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Access settings from the SettingsModel
    final settings = Provider.of<SettingsModel>(context);
    Color primaryColor = Theme.of(context).primaryColor;
    Color textColor = settings.textColor;
    Color iconColor = settings.iconColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
        backgroundColor: settings.darkMode
            ? Colors.black
            : const Color.fromARGB(255, 221, 128, 244),
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
                        AssetImage(_profileImagePath), // Use AssetImage
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Username Tile
            if (_user != null)
              ListTile(
                title: Row(
                  children: [
                    Text('Username: ',
                        style: TextStyle(
                            color: textColor, fontSize: settings.fontSize)),
                    Text(_username,
                        style: TextStyle(
                            color: textColor, fontSize: settings.fontSize)),
                  ],
                ),
                trailing: Icon(Icons.edit, color: iconColor),
                onTap: _showChangeUsernameDialog,
              ),
            Divider(color: Colors.grey),

            // Password Tile
            if (_user != null)
              ListTile(
                title: Row(
                  children: [
                    Text('Password: ',
                        style: TextStyle(
                            color: textColor, fontSize: settings.fontSize)),
                    Text('',
                        style: TextStyle(
                            color: textColor, fontSize: settings.fontSize)),
                  ],
                ),
                trailing: Icon(Icons.edit, color: iconColor),
                onTap: _showChangePasswordDialog,
              ),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
