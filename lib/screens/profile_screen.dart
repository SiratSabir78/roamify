import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/home_screen.dart';
import 'package:roamify/screens/state.dart'; // Add this import for using Provider

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String _username = '';
  String _email = '';

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
            .doc(_user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _username = userDoc['username'] ?? '';
            _email = userDoc['email'] ?? '';
            // _lastEmailChangeDate = (userDoc['lastEmailChange'] as Timestamp?)?.toDate();
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
                    String newUsername = usernameController.text.trim();

                    if (newUsername.isEmpty) {
                      setState(() {
                        usernameError = 'Username cannot be empty.';
                      });
                    } else if (newUsername == _username) {
                      setState(() {
                        usernameError =
                            'Username is the same as the current one. Please choose a different username.';
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
                      await _user.reauthenticateWithCredential(credential);
                      await _user.updatePassword(newPasswordController.text);
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

  void _showChangeEmailDialog(Function() onEmailChanged) {
    TextEditingController emailController = TextEditingController();
    String? emailError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Email'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'New Email',
                      errorText: emailError,
                    ),
                    keyboardType: TextInputType.emailAddress,
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
                    String newEmail = emailController.text.trim();

                    if (newEmail.isEmpty) {
                      setState(() {
                        emailError = 'Email cannot be empty.';
                      });
                    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
                        .hasMatch(newEmail)) {
                      setState(() {
                        emailError = 'Please enter a valid Gmail address.';
                      });
                    } else if (newEmail == _email) {
                      setState(() {
                        emailError =
                            'Email is the same as the current one. Please choose a different email.';
                      });
                    } else {
                      try {
                        // Check if the new email already exists
                        QuerySnapshot result = await FirebaseFirestore.instance
                            .collection('users')
                            .where('email', isEqualTo: newEmail)
                            .get();

                        if (result.docs.isNotEmpty) {
                          setState(() {
                            emailError =
                                'This email is already in use. Please choose a different one.';
                          });
                        } else {
                          await _user!.verifyBeforeUpdateEmail(newEmail);
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_user.uid)
                              .update({'email': newEmail});
                          onEmailChanged(); // Call the callback to update the profile page
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Email changed successfully!')));
                        }
                      } catch (e) {
                        setState(() {
                          emailError = 'Failed to change email: $e';
                        });
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

  @override
  Widget build(BuildContext context) {
    // Obtain settings from the SettingsModel
    final settings = Provider.of<SettingsModel>(context);
    Color primaryColor = Theme.of(context).primaryColor;
    Color textColor = settings.darkMode ? Colors.white70 : Colors.black87;
    Color backgroundColor = settings.darkMode ? Colors.black : Colors.white;
    double fontSize = settings.fontSize;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ));
          },
        ),
        title: Text(
          'Profile Settings',
        ),
        backgroundColor: settings.darkMode
            ? Colors.black
            : const Color.fromARGB(255, 221, 128, 244),
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                      style: TextStyle(
                        color: Color.fromARGB(255, 221, 128, 244),
                        fontSize: fontSize,
                      ),
                    ),
                  ),
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
                        style: TextStyle(color: textColor, fontSize: fontSize)),
                    Text(_username,
                        style:
                            TextStyle(color: primaryColor, fontSize: fontSize)),
                  ],
                ),
                trailing: Icon(Icons.edit, color: primaryColor),
                onTap: _showChangeUsernameDialog,
              ),
            Divider(color: Colors.grey),
            // Password Tile
            if (_user != null)
              ListTile(
                title: Row(
                  children: [
                    Text('Password: ',
                        style: TextStyle(color: textColor, fontSize: fontSize)),
                    Text('********',
                        style:
                            TextStyle(color: primaryColor, fontSize: fontSize)),
                  ],
                ),
                trailing: Icon(Icons.edit, color: primaryColor),
                onTap: _showChangePasswordDialog,
              ),
            Divider(color: Colors.grey),
            // Email Tile
            if (_user != null)
              ListTile(
                title: Row(
                  children: [
                    Text('Email: ',
                        style: TextStyle(color: textColor, fontSize: fontSize)),
                    Text(_email,
                        style:
                            TextStyle(color: primaryColor, fontSize: fontSize)),
                  ],
                ),
                trailing: Icon(Icons.edit, color: primaryColor),
                onTap: () => _showChangeEmailDialog(() {
                  _loadUserData(); // Refresh the profile data
                }),
              ),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
