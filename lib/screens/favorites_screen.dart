import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          return ListView.builder(
            itemCount: favoritesProvider.bookings.length,
            itemBuilder: (context, index) {
              final cityId = favoritesProvider.bookings.elementAt(index);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('cities')
                    .doc(cityId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Center(child: Text('City not found'));
                  }

                  final cityData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final cityName = cityData['name'];

                  return ListTile(
                    title: Text(cityName),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () async {
                        await favoritesProvider.removeBooking(cityId);
                        await favoritesProvider.updateBookingsInFirestore(
                            cityId, false);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
