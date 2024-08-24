import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/post_bottom_bar.dart';
import 'package:roamify/screens/review_screens.dart';
import 'package:roamify/screens/state.dart';

class PostScreen extends StatelessWidget {
  final String cityName;
  final String description;
  final String imagePath;
  final String cityId;

  PostScreen({
    required this.cityName,
    required this.description,
    required this.imagePath,
    required this.cityId,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode; // Determine dark mode

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cityName,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Image.asset(
                imagePath,
                height: MediaQuery.of(context).size.height / 2,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20), // Add spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : const Color.fromARGB(255, 242, 219, 248),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewPage(
                        cityId: cityId,
                        cityName: cityName,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Write a Review',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add spacing
              ElevatedButton(
                onPressed: () async {
                  await _addToFavorites(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  backgroundColor: isDarkMode
                      ? Colors.grey[800]
                      : const Color.fromARGB(255, 242, 219, 248),
                ),
                child: Text(
                  'Add to Favorites',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add spacing
              Expanded(
                child: PostBottomBar(),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }

  Future<void> _addToFavorites(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need to be logged in to add favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final userId = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final userDocSnapshot = await userDoc.get();
      if (!userDocSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User data not found.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final userData = userDocSnapshot.data()!;
      final List<dynamic> favorites = userData['favoriteCities'] ?? [];

      if (favorites.contains(cityName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('City already in favorites.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      await userDoc.update({
        'favoriteCities': FieldValue.arrayUnion([cityName])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to your favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
