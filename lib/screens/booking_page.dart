import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for DateFormat

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
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
              var date = booking['date']?.toDate() ??
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

                  return ListTile(
                    title: Text(
                      '$cityName',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    subtitle: Text(
                        "Booking Date: ${DateFormat('yyyy-MM-dd').format(date)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showDetailsDialog(context, cityName, date);
                          },
                          child: Text('Details'),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            bool confirmDelete =
                                await _showConfirmationDialog(context);
                            if (confirmDelete) {
                              // Delete the booking from both the main collection and the sub-collection
                              await _deleteBooking(bookingId, cityId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: Text('Remove'),
                        ),
                      ],
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

  Future<void> _deleteBooking(String bookingId, String cityId) async {
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
      });
    } catch (e) {
      print("Failed to delete booking: $e");
    }
  }

  Future<DocumentSnapshot> _fetchCityName(String cityId) async {
    return FirebaseFirestore.instance.collection('cities').doc(cityId).get();
  }
}

void _showDetailsDialog(BuildContext context, String cityName, DateTime date) {
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
              'Booking Date: ${DateFormat('yyyy-MM-dd').format(date)}',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            // Add more details as needed
            // For example:
            SizedBox(height: 8),
            Text(
              'Additional Information:',
              style: Theme.of(context).textTheme.subtitle1,
            ),
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
                decoration: InputDecoration(labelText: 'Check-in Date'),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_checkInDate),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _checkInDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null && picked != _checkInDate) {
                    setState(() {
                      _checkInDate = picked;
                      if (_checkOutDate.isBefore(_checkInDate)) {
                        _checkOutDate = _checkInDate.add(Duration(days: 1));
                      }
                    });
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
                decoration: InputDecoration(labelText: 'Check-out Date'),
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_checkOutDate),
                ),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _checkOutDate,
                    firstDate: _checkInDate.add(Duration(days: 1)),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (picked != null && picked != _checkOutDate) {
                    setState(() {
                      _checkOutDate = picked;
                    });
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
                // Generate a unique ID for the booking
                DocumentReference bookingRef = FirebaseFirestore.instance
                    .collection('bookings')
                    .doc(); // Generate a new document reference with a unique ID

                // Save to main bookings collection
                await bookingRef.set({
                  'bookingId': bookingRef.id, // Include unique booking ID
                  'cityId': widget.cityId,
                  'userId': 'userId', // Replace with actual user ID
                  'checkInDate': _checkInDate,
                  'checkOutDate': _checkOutDate,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                // Save to subcollection of the selected city
                await FirebaseFirestore.instance
                    .collection('cities')
                    .doc(widget.cityId)
                    .collection('bookings')
                    .doc(
                        bookingRef.id) // Use the same unique ID for consistency
                    .set({
                  'bookingId': bookingRef.id, // Include unique booking ID
                  'userId': 'userId', // Replace with actual user ID
                  'checkInDate': _checkInDate,
                  'checkOutDate': _checkOutDate,
                  'timestamp': FieldValue.serverTimestamp(),
                });

                Navigator.of(context).pop();
              } catch (e) {
                // Handle errors
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
