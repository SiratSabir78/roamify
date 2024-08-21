import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String> _favorites = {};
  Set<String> _bookings = {};

  Set<String> get favorites => _favorites;
  Set<String> get bookings => _bookings;

  bool isFavorite(String cityId) => _favorites.contains(cityId);
  bool isBooked(String cityId) => _bookings.contains(cityId);

  Future<void> addFavorite(String cityId) async {
    _favorites.add(cityId);
    notifyListeners();
  }

  Future<void> removeFavorite(String cityId) async {
    _favorites.remove(cityId);
    notifyListeners();
  }

  Future<void> addBooking(String cityId) async {
    _bookings.add(cityId);
    notifyListeners();
  }

  Future<void> removeBooking(String cityId) async {
    _bookings.remove(cityId);
    notifyListeners();
  }

  Future<void> updateBookingsInFirestore(String cityId, bool isBooking) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final bookingCollection =
        _firestore.collection('cities').doc(cityId).collection('bookings');
    final bookingDoc = bookingCollection.doc(user.uid);

    if (isBooking) {
      await bookingDoc.set({
        'userId': user.uid,
        'bookedOn': Timestamp.now(),
      });
    } else {
      await bookingDoc.delete();
    }
  }
}
