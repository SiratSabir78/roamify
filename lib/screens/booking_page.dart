import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/state.dart';

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("My Bookings"),
          backgroundColor: settingsProvider.darkMode
              ? Colors.purple[700]
              : Colors.purple[300],
        ),
        body: Center(child: Text("No user signed in")),
      );
    }
    String userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor:
            settingsProvider.darkMode ? Colors.purple[700] : Colors.purple[300],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
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
              var bookingId = booking['bookingId'] ?? 'Unknown';
              var cityId = booking['cityId'] ?? 'Unknown';
              var checkInDate =
                  booking['checkInDate']?.toDate() ?? DateTime.now();
              var checkOutDate =
                  booking['checkOutDate']?.toDate() ?? DateTime.now();
              var numberOfDays = booking['numberOfDays'] ?? 1;
              var price = booking['price'] ?? 0;

              return FutureBuilder<DocumentSnapshot>(
                future: _fetchCityNameAndDetails(cityId),
                builder: (context, citySnapshot) {
                  String cityName = 'Unknown';
                  String tripDescription = 'No description available';
                  int tripPricePerDay = 0;

                  if (citySnapshot.connectionState == ConnectionState.done) {
                    if (citySnapshot.hasData) {
                      cityName = citySnapshot.data?.get('name') ?? 'Unknown';
                      tripDescription = citySnapshot.data?.get('data') ??
                          'No description available';
                      tripPricePerDay = citySnapshot.data?.get('price') ?? 0;
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
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              "Check-In: ${DateFormat('yyyy-MM-dd').format(checkInDate)}\nCheck-Out: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}"),
                          SizedBox(height: 8),
                          Text("Days: $numberOfDays"),
                          Text("Price: \$${price.toStringAsFixed(2)}"),
                          SizedBox(height: 8),
                          Text("Trip Description: $tripDescription"),
                        ],
                      ),
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
                                numberOfDays,
                                price,
                                tripDescription,
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
                                await _deleteBooking(bookingId, cityId, userId);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: settingsProvider.darkMode
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                            ),
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

  Future<DocumentSnapshot> _fetchCityNameAndDetails(String cityId) async {
    return FirebaseFirestore.instance.collection('cities').doc(cityId).get();
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

  void _showDetailsDialog(
    BuildContext context,
    String cityName,
    DateTime checkInDate,
    DateTime checkOutDate,
    int numberOfDays,
    double price,
    String tripDescription,
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
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text(
                'Check-Out Date: ${DateFormat('yyyy-MM-dd').format(checkOutDate)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8),
              Text('Number of Days: $numberOfDays'),
              Text('Price: \$${price.toStringAsFixed(2)}'),
              SizedBox(height: 8),
              Text('Trip Description: $tripDescription'),
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
  int _numberOfUsers = 1;
  double _totalPrice = 0.0;
  bool _isLoading = false;
  String _tripDescription = '';
  double _pricePerDay = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCityDetails();
  }

  Future<void> _fetchCityDetails() async {
    try {
      DocumentSnapshot citySnapshot = await FirebaseFirestore.instance
          .collection('cities')
          .doc(widget.cityId)
          .get();

      if (citySnapshot.exists) {
        setState(() {
          _pricePerDay = citySnapshot['price']?.toDouble() ?? 0.0;
          _tripDescription = citySnapshot['data'] ?? '';
          _updateTotalPrice();
        });
      }
    } catch (e) {
      print('Failed to fetch city details: $e');
    }
  }

  void _updateTotalPrice() {
    int numberOfDays = _checkOutDate.difference(_checkInDate).inDays;
    _totalPrice = _pricePerDay * _numberOfUsers * numberOfDays;
  }

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
              Text("Trip Description: $_tripDescription"),
              SizedBox(height: 10),
              Text("Price per day per person: \$$_pricePerDay"),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Number of Users',
                  suffixIcon: Icon(Icons.person),
                ),
                initialValue: '1',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _numberOfUsers = int.tryParse(value) ?? 1;
                    _updateTotalPrice();
                  });
                },
                validator: (value) {
                  if (_numberOfUsers < 1) {
                    return 'Please enter at least 1 user';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text(
                "Total Price: \$${_totalPrice.toStringAsFixed(2)}",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
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
                        if (_checkOutDate.isBefore(_checkInDate)) {
                          _checkOutDate = _checkInDate.add(Duration(days: 1));
                        }
                        _updateTotalPrice();
                      });
                    }
                  } catch (e) {
                    print('Error selecting date: $e');
                  }
                },
                validator: (value) {
                  if (_checkInDate.isBefore(DateTime.now())) {
                    return 'Please select a valid check-in date';
                  }
                  return null;
                },
              ),
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
                      firstDate: _checkInDate,
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null && picked != _checkOutDate) {
                      setState(() {
                        _checkOutDate = picked;
                        _updateTotalPrice();
                      });
                    }
                  } catch (e) {
                    print('Error selecting date: $e');
                  }
                },
                validator: (value) {
                  if (_checkOutDate.isBefore(_checkInDate)) {
                    return 'Please select a valid check-out date';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (_isLoading) CircularProgressIndicator(),
        if (!_isLoading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel"),
          ),
        if (!_isLoading)
          TextButton(
            onPressed: _saveBooking,
            child: Text("Book Now"),
          ),
      ],
    );
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String bookingId =
          FirebaseFirestore.instance.collection('bookings').doc().id;

      int numberOfDays = _checkOutDate.difference(_checkInDate).inDays;

      var bookingData = {
        'bookingId': bookingId,
        'cityId': widget.cityId,
        'checkInDate': _checkInDate,
        'checkOutDate': _checkOutDate,
        'numberOfDays': numberOfDays,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'numberOfUsers': _numberOfUsers,
        'price': _totalPrice,
      };

      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set(bookingData);
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(widget.cityId)
          .collection('bookings')
          .doc(bookingId)
          .set(bookingData);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('bookings')
          .doc(bookingId)
          .set(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking successfully added!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Failed to save booking: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
