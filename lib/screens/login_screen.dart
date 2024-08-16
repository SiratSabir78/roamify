import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roamify/screens/signup_screen.dart';
import 'package:roamify/screens/wrapper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  Future<void> signIn() async {
    
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // If the user is successfully signed in, navigate to the Wrapper screen
      if (_auth.currentUser != null) {
        Get.offAll(() => const Wrapper());
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication exceptions
      String errorMessage;

      // Add a debug print statement to check the error code
      print("FirebaseAuthException code: ${e.code}");

      switch (e.code) {
        case 'invalid-credential':
          errorMessage =
              'No user found with this email. Please check your email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage =
              'The email address is not valid. Please enter a valid email.';
          break;
        default:
          errorMessage =
              'An unknown error occurred. Please try again.'; // Updated default message
          break;
      }

      // Display the specific error message
      Get.snackbar(
        'Login Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      // Handle any other exceptions
      Get.snackbar(
        'Login Error',
        'An unexpected error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      
      appBar: AppBar(
        
        title: const Text("Login"),
        backgroundColor: const Color.fromARGB(255, 242, 219, 248),
        centerTitle: true,
      ),
      
      body: Padding(
        
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/Roamify.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Enter Email',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: const Color.fromARGB(255, 242, 219, 248),
              ),
              onPressed: _isLoading ? null : signIn,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.to(() => const SignUp()),
              child: const Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: Color.fromARGB(255, 221, 128, 244)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
