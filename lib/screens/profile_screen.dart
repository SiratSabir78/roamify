import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  String _username = '';
  String _gender = 'Male'; // Default to male, change as necessary
  String _profileImagePath = 'images/male_default.png'; // Default profile image

  final picker = ImagePicker();

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
            _profileImagePath = userDoc['profileImagePath'] ??
                (_gender == 'Female'
                    ? 'images/female_default.png'
                    : 'images/male_default.png');
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

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        String fileName = '${_user!.uid}.png';
        print('Uploading image: ${imageFile.path}');

        // Upload the image to Firebase Storage
        UploadTask uploadTask =
            FirebaseStorage.instance.ref().child(fileName).putFile(imageFile);

        // Wait for the upload to complete
        TaskSnapshot snapshot = await uploadTask;
        print('Upload complete. Getting download URL...');

        String downloadUrl = await snapshot.ref.getDownloadURL();
        print('Download URL: $downloadUrl');

        // Update the user's profile image URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({'profileImagePath': downloadUrl});

        setState(() {
          _profileImagePath = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile picture updated successfully!'),
        ));
      } else {
        print('No image selected.');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No image selected.'),
        ));
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error uploading image: $e'),
      ));
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
                    backgroundImage: NetworkImage(_profileImagePath),
                  ),
                  SizedBox(height: 8),
                  //  TextButton(
                  //  onPressed: _pickAndUploadImage,
                  // child: Text(
                  //   'Change Profile Picture',
                  //   style:
                  //       TextStyle(color: Color.fromARGB(255, 221, 128, 244)),
                  // ),
                  //  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Username Tile
            if (_user != null)
              ListTile(
                title: Row(
                  children: [
                    Text('Username: ', style: TextStyle(color: textColor)),
                    Text(_username, style: TextStyle(color: primaryColor)),
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
                    Text('Password: ', style: TextStyle(color: textColor)),
                    Text('********', style: TextStyle(color: primaryColor)),
                  ],
                ),
                trailing: Icon(Icons.edit, color: primaryColor),
                onTap: _showChangePasswordDialog,
              ),
            Divider(color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
