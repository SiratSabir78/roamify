import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:roamify/screens/home_screen.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _cityController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _bookNow() async {
    if (_cityController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to book')),
      );
      return;
    }

    final booking = Booking(
      id: _firestore.collection('bookings').doc().id,
      userId: user.uid,
      city: _cityController.text,
      date: _selectedDate!,
    );

    await _firestore
        .collection('bookings')
        .doc(booking.id)
        .set(booking.toMap());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking successful')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Now'),
        backgroundColor: const Color.fromARGB(255, 221, 128, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter City',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Date Chosen'
                        : 'Selected Date: ${_selectedDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: Text(
                    'Choose Date',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 221, 128, 244)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: _bookNow,
              child: Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }
}
