import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/state.dart';

class PostBottomBar extends StatelessWidget {
  final String cityName;
  final String cityId;
  final String description;

  PostBottomBar({
    required this.cityName,
    required this.cityId,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;

    return Container(
      height: MediaQuery.of(context).size.height / 2,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : const Color(0xFFED2F6),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$cityName, Pakistan",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Text(
                  description,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15),
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black54
                            : Color.fromARGB(255, 255, 255, 255),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        _showBookingDialog(context, cityId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: settingsProvider.darkMode
                            ? Color.fromARGB(255, 85, 84, 84)
                            : const Color.fromARGB(255, 221, 128, 244),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: TextStyle(color: isDarkMode
                            ? Colors.white
                            : Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, String cityId) {
    showDialog(
      context: context,
      builder: (context) => BookingFormDialog(cityId: cityId),
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
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;
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
            child: Text("Cancel",style: TextStyle(color: isDarkMode
                            ? Colors.white
                            : Colors.black),),
          ),
        if (!_isLoading)
          TextButton(
            onPressed: _saveBooking,
            child: Text("Book Now",  style:TextStyle(color: isDarkMode
                            ? Colors.white
                            : Colors.black)),
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

      // Save the booking data to the Firestore 'bookings' collection
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .set(bookingData);

      // Save the booking data to the 'bookings' subcollection in the 'cities' collection
      await FirebaseFirestore.instance
          .collection('cities')
          .doc(widget.cityId)
          .collection('bookings')
          .doc(bookingId)
          .set(bookingData);

      // Save the booking data to the 'bookings' subcollection in the 'users' collection
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save booking. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
