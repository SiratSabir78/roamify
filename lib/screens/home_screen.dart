import 'package:flutter/material.dart';
import 'package:roamify/Widgets/home_app_bar.dart';
import 'package:roamify/widgets/home_botton_bar.dart';
import 'package:roamify/screens/booking_page.dart';
import 'package:roamify/screens/post_screen.dart';

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
  final List<String> catagory = [
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
    'Paris is a global center for art, fashion, gastronomy, and culture. The city is home to some of the world\'s most famous landmarks, including the Eiffel Tower, Notre Dame Cathedral, and the Arc de Triomphe. The Louvre Museum, housing the Mona Lisa, is also a major attraction.',
    'Switzerland is renowned for its stunning landscapes, with the Swiss Alps offering some of the most beautiful scenery in the world. The country is also famous for its charming cities, delicious chocolate, and high-quality watches.',
    'Stockholm, the capital of Sweden, boasts an array of enchanting tourism spots. The historic Gamla Stan (Old Town) captivates with its cobblestone streets, colorful buildings, and the Royal Palace. The Vasa Museum showcases a beautifully preserved 17th-century warship, while the Skansen open-air museum offers a glimpse into Swedish history and culture.',
    'Berlin is rich in historical and cultural tourism spots. The iconic Brandenburg Gate stands as a symbol of unity and peace. The impressive Reichstag Building, with its glass dome, provides panoramic views of the city. Additionally, the bustling Alexanderplatz and the serene Tiergarten Park cater to diverse visitor interests, making Berlin a dynamic and captivating destination for tourists.',
    'Amsterdam is famous for its picturesque canals, vibrant cultural scene, and historic architecture. The city offers numerous museums, including the Van Gogh Museum and Anne Frank House, as well as charming neighborhoods like the Jordaan.',
    'Baku, the capital of Azerbaijan, offers a rich tapestry of tourism spots that captivate visitors with its unique blend of ancient and modern attractions. The historical Icherisheher, or Old City, invites exploration with its narrow alleys, Maiden Tower, and the Palace of the Shirvanshahs, reflecting centuries-old architecture. Contrasting this is the contemporary splendor of the Flame Towers, which illuminate the skyline with their distinctive design.'
  ];

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.0),
        child: HomeAppBar(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 200,
                        child: ListView.builder(
                          itemCount: cities.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostScreen(
                                      cityName: cities[index],
                                      imagePath: "images/city${index + 1}.jpeg",
                                      description: descriptions[index],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 160,
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.only(left: 15),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                    image: AssetImage(
                                      "images/city${index + 1}.jpeg",
                                    ),
                                    fit: BoxFit.cover,
                                    opacity: 0.7,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.topRight,
                                      child: const Icon(
                                        Icons.bookmark_border_rounded,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    Spacer(),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        cities[index],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      children: [
                        for (int i = 0; i < catagory.length; i++)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              catagory[i],
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Big detailed and booking cards...
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cities.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PostScreen(
                              cityName: cities[index],
                              imagePath: "images/city${index + 1}.jpeg",
                              description: descriptions[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Image.asset(
                                "images/city${index + 1}.jpeg",
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
                                    cities[index],
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    descriptions[index],
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
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
                                          Text('4.5'),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.bookmark_border,
                                              color: Colors.grey[700],
                                              size: 25),
                                          SizedBox(width: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        BookingPage()),
                                              );
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
                ),
                SizedBox(height: 30),
                HomeBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
