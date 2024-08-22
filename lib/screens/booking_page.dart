import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for DateFormat

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user ID
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Bookings"),
          backgroundColor: const Color.fromARGB(255, 221, 128, 244),
        ),
        body: Center(child: Text("No user signed in")),
      );
    }
    String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId) // Filter by userId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No bookings found."));
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              var booking = bookings[index].data() as Map<String, dynamic>;
              var bookingId =
                  booking['bookingId'] ?? 'Unknown'; // Handle missing field
              var cityId =
                  booking['cityId'] ?? 'Unknown'; // Handle missing field
              var checkInDate = booking['checkInDate']?.toDate() ??
                  DateTime
                      .now(); // Handle missing field and convert to DateTime
              var checkOutDate = booking['checkOutDate']?.toDate() ??
                  DateTime
                      .now(); // Handle missing field and convert to DateTime

              return FutureBuilder<DocumentSnapshot>(
                future: _fetchCityName(cityId),
                builder: (context, citySnapshot) {
                  String cityName = 'Unknown';
                  if (citySnapshot.connectionState == ConnectionState.done) {
                    if (citySnapshot.hasData) {
                      cityName = citySnapshot.data?.get('name') ?? 'Unknown';
                    }
                  }

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        '$cityName',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      subtitle: Text(
                          "Check-In: ${DateFormat('yyyy-MM-dd').format(checkInDate)}\nCheck-Out: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _showDetailsDialog(
                                context,
                                cityName,
                                checkInDate,
                                checkOutDate,
                              );
                            },
                            child: Text('Details'),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              bool confirmDelete =
                                  await _showConfirmationDialog(context);
                              if (confirmDelete) {
                                // Delete the booking from all relevant locations
                                await _deleteBooking(bookingId, cityId, userId);
                              }
                            },
                            style: ElevatedButton.styleFrom(),
                            child: Text(
                              'Remove',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
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

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this booking?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _deleteBooking(
      String bookingId, String cityId, String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.runTransaction((transaction) async {
        // Delete from the main 'bookings' collection
        QuerySnapshot bookingSnapshot = await firestore
            .collection('bookings')
            .where('bookingId', isEqualTo: bookingId)
            .limit(1)
            .get();

        if (bookingSnapshot.docs.isNotEmpty) {
          for (var doc in bookingSnapshot.docs) {
            transaction.delete(doc.reference);
          }
        }

        // Delete from the 'bookings' sub-collection within the specified city
        QuerySnapshot subCollectionBookingSnapshot = await firestore
            .collection('cities')
            .doc(cityId)
            .collection('bookings')
            .where('bookingId', isEqualTo: bookingId)
            .limit(1)
            .get();

        if (subCollectionBookingSnapshot.docs.isNotEmpty) {
          for (var doc in subCollectionBookingSnapshot.docs) {
            transaction.delete(doc.reference);
          }
        }

        // Delete from the user's 'bookings' sub-collection
        QuerySnapshot userBookingSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('bookings')
            .where('bookingId', isEqualTo: bookingId)
            .limit(1)
            .get();

        if (userBookingSnapshot.docs.isNotEmpty) {
          for (var doc in userBookingSnapshot.docs) {
            transaction.delete(doc.reference);
          }
        }
      });
    } catch (e) {
      print("Failed to delete booking: $e");
    }
  }

  Future<DocumentSnapshot> _fetchCityName(String cityId) async {
    return FirebaseFirestore.instance.collection('cities').doc(cityId).get();
  }

  void _showDetailsDialog(
    BuildContext context,
    String cityName,
    DateTime checkInDate,
    DateTime checkOutDate,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Booking Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City Name: $cityName',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 8),
              Text(
                'Check-In Date: ${DateFormat('yyyy-MM-dd').format(checkInDate)}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 8),
              Text(
                'Check-Out Date: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 8),

              // Include additional details here
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class BookingFormDialog extends StatefulWidget {
  final String cityId;

  BookingFormDialog({required this.cityId});

  @override
  _BookingFormDialogState createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _checkInDate = DateTime.now();
  DateTime _checkOutDate = DateTime.now().add(Duration(days: 1));
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Book a Trip"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Check-in Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_checkInDate),
                ),
                onTap: () async {
                  try {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _checkInDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null && picked != _checkInDate) {
                      setState(() {
                        _checkInDate = picked;
                        // Ensure check-out date is not before check-in date
                        if (_checkOutDate.isBefore(_checkInDate)) {
                          _checkOutDate = _checkInDate.add(Duration(days: 1));
                        }
                      });
                    }
                  } catch (e) {
                    print('Error selecting date: $e');
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a check-in date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Check-out Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_checkOutDate),
                ),
                onTap: () async {
                  try {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _checkOutDate,
                      firstDate: _checkInDate.add(Duration(
                          days: 1)), // Ensure check-out is after check-in
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null && picked != _checkOutDate) {
                      setState(() {
                        _checkOutDate = picked;
                      });
                    }
                  } catch (e) {
                    print('Error selecting date: $e');
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a check-out date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (_isLoading) CircularProgressIndicator(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() {
                _isLoading = true;
              });

              try {
                User? user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  throw Exception('No user signed in');
                }
                String userId = user.uid;

                DocumentReference bookingRef =
                    FirebaseFirestore.instance.collection('bookings').doc();

                await bookingRef.set({
                  'bookingId': bookingRef.id,
                  'cityId': widget.cityId,
                  'userId': userId,
                  'checkInDate': _checkInDate,
                  'checkOutDate': _checkOutDate,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                await FirebaseFirestore.instance
                    .collection('cities')
                    .doc(widget.cityId)
                    .collection('bookings')
                    .doc(bookingRef.id)
                    .set({
                  'bookingId': bookingRef.id,
                  'userId': userId,
                  'checkInDate': _checkInDate,
                  'checkOutDate': _checkOutDate,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('bookings')
                    .doc(bookingRef.id)
                    .set({
                  'bookingId': bookingRef.id,
                  'cityId': widget.cityId,
                  'checkInDate': _checkInDate,
                  'checkOutDate': _checkOutDate,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Booking successful!')),
                );

                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to book the trip')),
                );
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          child: Text('Book'),
        ),
      ],
    );
  }
}
