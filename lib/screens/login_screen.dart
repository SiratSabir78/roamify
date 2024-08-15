import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roamify/screens/signup_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      // If successful, navigate to the next screen or show a success message
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("No Account Found"),
              content: const Text(
                  "It seems like you don't have an account. Would you like to sign up for one?"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(const SignUp());
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            );
          },
        );
      } else if (e.code == 'wrong-password') {
        // Handle wrong password case
        Get.snackbar("Error", "Wrong password provided for that user.",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        // Handle other errors
        Get.snackbar("Error", e.message.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
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
              controller: email,
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
              controller: password,
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
              onPressed: (() => signIn()),
              child: const Text("Login"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.to(const SignUp()),
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
