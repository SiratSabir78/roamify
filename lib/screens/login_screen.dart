import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/signup_screen.dart';
import 'package:roamify/screens/state.dart';
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
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true; // For toggling password visibility

  Future<void> signIn() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (_auth.currentUser != null) {
        Get.offAll(() => Wrapper());
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-credential') {
          _passwordError =
              'Invalid credentials. Please check your email and password.';
        } else if (e.code == 'invalid-email') {
          _emailError = 'Please enter a valid email address.';
        } else if (e.code == 'wrong-password') {
          _passwordError = 'Incorrect password. Please try again.';
        } else if (e.code == 'too-many-requests') {
          _emailError = 'Too many requests! Please try again later.';
        } else {
          _emailError = 'An unknown error occurred. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _emailError = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;

    return Scaffold(
      appBar: AppBar(
        title:  Text("Login", style: TextStyle(color: isDarkMode
                            ? Colors.white
                            : Colors.black)),
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
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword, // Obscure or reveal password
              decoration: InputDecoration(
                hintText: 'Enter Password',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                errorText: _passwordError,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
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
                backgroundColor :isDarkMode
                            ? const Color.fromARGB(255, 124, 114, 114)
                            :Color.fromARGB(255, 242, 219, 248),
              ),
              onPressed: _isLoading ? null : signIn,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  :  Text("Login", style: TextStyle(color: isDarkMode
                            ? Colors.white
                            : Colors.black)),
            ),
            const SizedBox(height: 20),
            TextButton(
               style: TextButton.styleFrom(backgroundColor :isDarkMode
                            ? const Color.fromARGB(255, 124, 114, 114)
                            :Color.fromARGB(255, 242, 219, 248),),
              onPressed: () => Get.to(() => const SignUp()),
              child:  Text(
                "Don't have an account? Sign Up",
                style: TextStyle(color: isDarkMode
                            ? Colors.white
                            : Colors.black),
                            
              ),
            ),
          ],
        ),
      ),
    );
  }
}
