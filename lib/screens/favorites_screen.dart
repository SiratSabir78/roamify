import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:roamify/screens/welcome_screen.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<String>> _favoriteCitiesFuture;

  @override
  void initState() {
    super.initState();
    _favoriteCitiesFuture = _fetchFavoriteCities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cities'),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
      ),
      body: FutureBuilder<List<String>>(
        future: _favoriteCitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching favorite cities'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorite cities found'));
          }

          final favoriteCities = snapshot.data!;
          return ListView.builder(
            itemCount: favoriteCities.length,
            itemBuilder: (context, index) {
              final cityName = favoriteCities[index];
              return ListTile(
                title: Text(cityName),
                leading: Icon(Icons.star, color: Colors.amber),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _removeFromFavorites(context, cityName);
                    setState(() {
                      // Refresh the list after removing
                      _favoriteCitiesFuture = _fetchFavoriteCities();
                    });
                  },
                  child: Text('Remove'),
                ),
                onTap: () {
                  WelcomeScreen();
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _fetchFavoriteCities() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }

    final userId = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final userDocSnapshot = await userDoc.get();
      if (!userDocSnapshot.exists) {
        return [];
      }

      final userData = userDocSnapshot.data()!;
      final List<dynamic> favoriteCities = userData['favoriteCities'] ?? [];
      return favoriteCities.map((e) => e.toString()).toList();
    } catch (e) {
      print('Error fetching favorite cities: $e');
      return [];
    }
  }

  Future<void> _removeFromFavorites(
      BuildContext context, String cityName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need to be logged in to remove favorites'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final userId = user.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await userDoc.update({
        'favoriteCities': FieldValue.arrayRemove([cityName])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Removed from your favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing from favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _addToFavorites(BuildContext context, String cityName) async {
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
        // Handle case where user document doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User data not found.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final userData = userDocSnapshot.data()!;
      final List<dynamic> favoriteCities = userData['favoriteCities'] ?? [];

      if (favoriteCities.contains(cityName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('City is already in favorites.'),
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
