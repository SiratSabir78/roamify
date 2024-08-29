import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roamify/screens/login_screen.dart';
import 'package:roamify/screens/validation_for_signup.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? usernameError; // Store the error message for the username field
  String? selectedGender; // Store the selected gender
  String? profileImagePath; // Store the profile image URL
  final ImagePicker picker = ImagePicker();

  Future<void> signup() async {
    if (_formKey.currentState!.validate()) {
      // Validate username asynchronously
      String? usernameError =
          await validateUsername(usernameController.text.trim());
      if (usernameError != null) {
        setState(() {
          this.usernameError = usernameError;
        });
        return;
      }

      try {
        // Create user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Store additional user information in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'profilePicture': profileImagePath ??
              'assets/images/default_profile.png', // Set the profile picture URL
          'favoriteCities': [], // Initially empty list
          'phoneNumber': phoneController.text.trim(), // Store phone number
          'gender': selectedGender ?? '', // Store gender
          'userId': userCredential.user!.uid,
        });

        // Create an empty sub-collection for reviews with a placeholder document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .collection('reviews')
            .add({
          'ReviewId': '',
          'userId': '',
          'reviews': '',
        });

        // Navigate to LoginPage
        Get.offAll(() => const LoginPage());
      } catch (e) {
        Get.snackbar(
          'Sign Up Error',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color.fromARGB(255, 221, 128, 244),
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      try {
        // Upload the image to Firebase Storage
        UploadTask uploadTask =
            FirebaseStorage.instance.ref().child(fileName).putFile(imageFile);

        // Wait for the upload to complete
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          profileImagePath = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Profile picture updated successfully!'),
        ));
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error uploading image: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: const Color.fromARGB(255, 242, 219, 248),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: profileImagePath != null
                              ? NetworkImage(profileImagePath!)
                              : AssetImage('assets/images/default_profile.png')
                                  as ImageProvider,
                          child: profileImagePath == null
                              ? const Icon(Icons.camera_alt, size: 40)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          hintText: 'Enter Username',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          errorText:
                              usernameError, // Show error text if username is taken
                        ),
                        validator: (value) {
                          return usernameError; // Apply async validation here
                        },
                        onChanged: (value) async {
                          final error = await validateUsername(value);
                          setState(() {
                            usernameError = error;
                          });
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter Email',
                          prefixIcon: const Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (value) => validateEmail(value),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter Phone Number',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (value) => validatePhoneNumber(value),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter Password',
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        validator: (value) => validatePassword(value),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        hint: const Text('Select Gender'),
                        items: <String>['Male', 'Female']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 242, 219, 248),
                        ),
                        onPressed: signup,
                        child: const Text("Sign Up"),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Get.off(() => LoginPage()),
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(
                              color: Color.fromARGB(255, 221, 128, 244)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
