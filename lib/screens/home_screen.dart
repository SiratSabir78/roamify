import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:roamify/screens/booking_page.dart';
import 'package:roamify/screens/favorites_provider.dart';
import 'package:roamify/screens/favorites_screen.dart';
import 'package:roamify/screens/profile_screen.dart';
import 'package:roamify/screens/search_screen.dart';
import 'package:roamify/screens/post_screen.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Default index for home screen

  final List<Widget> _screens = [
    ProfileScreen(),
    FavoritesPage(),
    HomeContent(), // Home screen content widget
    BookingPage(), // Updated BookingPage without cityId
    SearchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 2
          ? AppBar(
              title: Text("Roamify"),
              backgroundColor: const Color.fromARGB(255, 221, 128, 244),
            )
          : null,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 221, 128, 244),
              ),
              child: Text(
                'Roamify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            // Other Drawer items...
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        index: _currentIndex,
        items: const [
          Icon(Icons.person_outline, size: 30),
          Icon(Icons.favorite_outline_outlined, size: 30),
          Icon(Icons.home, size: 30, color: Colors.redAccent),
          Icon(Icons.menu_book, size: 30),
          Icon(Icons.list, size: 30),
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

class HomeContent extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('cities').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return Center(child: Text("No data available"));
                  }
                  final cities = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cities.length,
                    itemBuilder: (context, index) {
                      var city = cities[index];
                      final isFavorite = context
                          .watch<FavoritesProvider>()
                          .isFavorite(city.id);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostScreen(
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
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      city['description'],
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.orange, size: 20),
                                            SizedBox(width: 5),
                                            Text(city['rating'].toString()),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                  isFavorite
                                                      ? Icons.bookmark
                                                      : Icons.bookmark_border,
                                                  color: Colors.grey[700]),
                                              onPressed: () {
                                                if (isFavorite) {
                                                  context
                                                      .read<FavoritesProvider>()
                                                      .removeFavorite(city.id);
                                                } else {
                                                  context
                                                      .read<FavoritesProvider>()
                                                      .addFavorite(city.id);
                                                }
                                              },
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _showBookingDialog(
                                                    context, city.id);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text('Book Now'),
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
            ],
          ),
        ),
      ),
    );
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
