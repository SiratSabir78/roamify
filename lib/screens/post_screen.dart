import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/post_bottom_bar.dart';
import 'package:roamify/screens/review_screens.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/favorites_provider.dart';
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
    final isFavorite = context.watch<FavoritesProvider>().isFavorite(cityName);

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: MediaQuery.of(context).size.height / 2,
              width: double.infinity,
              fit: BoxFit.fitHeight,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: const Color.fromARGB(255, 242, 219, 248),
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
                  child: const Text('Write a Review'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _toggleFavorite(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    backgroundColor: const Color.fromARGB(255, 242, 219, 248),
                  ),
                  child: Text(isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PostBottomBar(
              cityName: cityName,
              description: description,
            ),
          ],
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
    );
  }

  Future<void> _toggleFavorite(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to be logged in to manage favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final isFavorite = context.read<FavoritesProvider>().isFavorite(cityName);

    try {
      if (isFavorite) {
        await userDoc.update({
          'favoriteCities': FieldValue.arrayRemove([cityName])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from your favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await userDoc.update({
          'favoriteCities': FieldValue.arrayUnion([cityName])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to your favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Notify the provider to update the state globally
      context.read<FavoritesProvider>().toggleFavorite(cityName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
