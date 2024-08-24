import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Set<String> _favorites = {};
  Set<String> _bookings = {};

  Set<String> get favorites => _favorites;
  Set<String> get bookings => _bookings;

  bool isFavorite(String cityName) => _favorites.contains(cityName);
  bool isBooked(String cityName) => _bookings.contains(cityName);

  Future<void> addFavorite(String cityName) async {
    _favorites.add(cityName);
    notifyListeners();
    await _updateFavoritesInFirestore();
  }

  void toggleFavorite(String cityName) async {
    if (isFavorite(cityName)) {
      _favorites.remove(cityName);
    } else {
      _favorites.add(cityName);
    }
    notifyListeners();
    await _updateFavoritesInFirestore();
  }

  Future<void> removeFavorite(String cityName) async {
    _favorites.remove(cityName);
    notifyListeners();
    await _updateFavoritesInFirestore();
  }

  Future<void> addBooking(String cityName) async {
    _bookings.add(cityName);
    notifyListeners();
    await updateBookingsInFirestore(cityName, true);
  }

  Future<void> removeBooking(String cityName) async {
    _bookings.remove(cityName);
    notifyListeners();
    await updateBookingsInFirestore(cityName, false);
  }

  Future<void> updateBookingsInFirestore(
      String cityName, bool isBooking) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final bookingCollection =
        _firestore.collection('cities').doc(cityName).collection('bookings');
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

  Future<void> loadFavorites() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('favoriteCities')) {
          _favorites = Set<String>.from(data['favoriteCities']);
        }
      }
    }
    notifyListeners();
  }

  Future<void> _updateFavoritesInFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).update({
      'favoriteCities': _favorites.toList(),
    });
  }
}
