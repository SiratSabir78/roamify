import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:roamify/Widgets/home_app_bar.dart';
import 'package:roamify/Widgets/home_botton_bar.dart';
import 'booking_page.dart';
import 'post_screen.dart';

class Booking {
  String id;
  String userId;
  String city;
  DateTime date;

  Booking(
      {required this.id,
      required this.userId,
      required this.city,
      required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'city': city,
      'date': date.toIso8601String(),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['userId'],
      city: map['city'],
      date: DateTime.parse(map['date']),
    );
  }
}
class HomePage extends StatelessWidget {
  final List<String> category = [
    'Best Places',
    'Most Visited',
    'Favourites',
    'New Added',
    'Hotels',
    'Restaurants'
  ];



  final List<String> cities = [
    'Paris, France',
    'Swiss Alps, Switzerland',
    'Stockholm, Sweden',
    'Berlin, Germany',
    'Amsterdam, Netherlands',
    'Baku, Azerbaijan'
  ];

  final List<String> descriptions = [
    'Paris is a global center for art, fashion, gastronomy, and culture...',
    'Switzerland is renowned for its stunning landscapes...',
    'Stockholm, the capital of Sweden, boasts an array of enchanting tourism spots...',
    'Berlin is rich in historical and cultural tourism spots...',
    'Amsterdam is famous for its picturesque canals...',
    'Baku, the capital of Azerbaijan, offers a rich tapestry of tourism spots...'
  ];

  HomePage({super.key});

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
            ListTile(
              leading: Icon(Icons.app_settings_alt),
              title: Text('App Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppSettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('Travel Info'),
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
              leading: Icon(Icons.feedback),
              title: Text('Reviews'),
              onTap: () {
                
                // Handle reviews tap
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
