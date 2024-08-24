import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/booking_page.dart';
import 'package:roamify/screens/favorites_provider.dart';
import 'package:roamify/screens/favorites_screen.dart';
import 'package:roamify/screens/profile_screen.dart';
import 'package:roamify/screens/post_screen.dart';
import 'package:roamify/screens/app_setting_screen.dart';
import 'package:roamify/screens/signout.dart';
import 'package:roamify/screens/state.dart';
import 'package:roamify/screens/travel_info_screen.dart';
import 'package:roamify/screens/user_review_Screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Default index for home screen

  final List<Widget> _screens = [
    ProfileScreen(),
    FavoriteScreen(),
    HomeContent(), // Home screen content widget
    BookingPage(), // Updated BookingPage without cityId
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;
    return Scaffold(
      appBar: _currentIndex == 2
          ? AppBar(
              title: Text("Roamify",
                  style: TextStyle(color: settingsProvider.textColor)),
              backgroundColor: settingsProvider.darkMode
                  ? Colors.black
                  : const Color.fromARGB(255, 221, 128, 244),
            )
          : null,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: settingsProvider.darkMode
                    ? Colors.black
                    : const Color.fromARGB(255, 221, 128, 244),
              ),
              child: Text(
                'Roamify',
                style: TextStyle(
                  color: settingsProvider.textColor,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: settingsProvider.iconColor),
              title: Text('Home',
                  style: TextStyle(color: settingsProvider.textColor)),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.app_settings_alt,
                  color: settingsProvider.iconColor),
              title: Text('App Settings',
                  style: TextStyle(color: settingsProvider.textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: settingsProvider.iconColor),
              title: Text('Travel Info',
                  style: TextStyle(color: settingsProvider.textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TravelInfoScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback, color: settingsProvider.iconColor),
              title: Text('Reviews',
                  style: TextStyle(color: settingsProvider.textColor)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReviewScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: settingsProvider.iconColor),
              title: Text('Sign Out',
                  style: TextStyle(color: settingsProvider.textColor)),
              onTap: () async {
                await signOutAndNavigate(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: settingsProvider.iconColor),
              title: Text('Sign Out',
                  style: TextStyle(color: settingsProvider.textColor)),
              onTap: () async {
                await signOutAndNavigate(context);
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        color: isDarkMode
            ? Colors.grey[900]!
            : Colors.grey[200]!, // Color of the bar itself
        index: _currentIndex,
        items: [
          Icon(Icons.person_outline,
              size: 30, color: settingsProvider.iconColor),
          Icon(Icons.favorite_outline_outlined,
              size: 30, color: settingsProvider.iconColor),
          Icon(Icons.home, size: 30, color: settingsProvider.iconColor),
          Icon(Icons.menu_book, size: 30, color: settingsProvider.iconColor),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search for a city...',
                  prefixIcon:
                      Icon(Icons.search, color: settingsProvider.iconColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: settingsProvider.darkMode
                            ? Colors.grey[800]!
                            : Colors.grey[300]!),
                  ),
                  filled: true,
                  fillColor: settingsProvider.darkMode
                      ? Colors.grey[850]
                      : Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('cities').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(
                        child: Text("No data available",
                            style:
                                TextStyle(color: settingsProvider.textColor)));
                  }
                  final cities = snapshot.data!.docs.where((city) {
                    final cityName = city['name'].toLowerCase();
                    return cityName.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      var city = cities[index];
                      final isFavorite = context
                          .watch<FavoritesProvider>()
                          .isFavorite(city['name']);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(
                                cityId: city.id,
                                cityName: city['name'],
                                imagePath: city['imagePath'],
                                description: city['description'],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Image.network(
                                  city['imagePath'],
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey,
                                      child: Icon(Icons.error,
                                          color: settingsProvider.iconColor),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: settingsProvider.darkMode
                                      ? Colors.grey[850]
                                      : Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(20)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city['name'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: settingsProvider.textColor,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      city['description'],
                                      style: TextStyle(
                                          color: settingsProvider.textColor
                                              .withOpacity(0.7)),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.orange, size: 20),
                                            SizedBox(width: 5),
                                            Text(city['rating'].toString(),
                                                style: TextStyle(
                                                    color: settingsProvider
                                                        .textColor)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                  isFavorite
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: settingsProvider
                                                      .textColor),
                                              onPressed: () {
                                                _toggleFavorite(
                                                    context, city['name']);
                                              },
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _showBookingDialog(
                                                    context, city['name']);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    settingsProvider.darkMode
                                                        ? Colors.grey[800]
                                                        : const Color.fromARGB(
                                                            255, 221, 128, 244),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text('Book Now',
                                                  style: TextStyle(
                                                      color: settingsProvider
                                                          .textColor)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, String cityName) async {
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

    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    final isFavorite = context.read<FavoritesProvider>().isFavorite(cityName);

    try {
      if (isFavorite) {
        await userDoc.update({
          'favoriteCities': FieldValue.arrayRemove([cityName])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from your favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await userDoc.update({
          'favoriteCities': FieldValue.arrayUnion([cityName])
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to your favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Update the local favorites state
      context.read<FavoritesProvider>().toggleFavorite(cityName);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showBookingDialog(BuildContext context, String cityId) {
    showDialog(
      context: context,
      builder: (context) {
        return BookingFormDialog(cityId: cityId);
      },
    );
  }
}
