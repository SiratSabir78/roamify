import 'package:flutter/material.dart';
import 'package:roamify/screens/login_screen.dart';
import 'package:roamify/screens/signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bgwelcomeScreen.jpeg"),
                fit: BoxFit.cover,
                opacity: 0.7)),
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 65, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Roamify",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "The world is right here at your phone",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 35,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Unlock hidden gems, ditch tourist traps - Travel like a local, not a lemming.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 30),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //           builder: (context) => HomePage(),
                  //         ));
                  //   },
                  //   child: Ink(
                  //     padding: EdgeInsets.all(15),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(12),
                  //     ),
                  //     child: Icon(
                  //       Icons.arrow_forward_ios,
                  //       color: Colors.black,
                  //       size: 20,
                  //     ),
                  //   ),
                  // ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.how_to_reg,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8), // Spacing between icon and text
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Ink(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.account_circle,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8), // Spacing between icon and text
                          Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
