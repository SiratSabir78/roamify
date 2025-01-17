import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/state.dart';

class ReviewScreen extends StatefulWidget {
  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  double _fontSize = 16.0;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User is not logged in');
      return Scaffold(
        appBar: AppBar(
          title: Text('User Reviews'),
          actions: _buildThemeActions(),
        ),
        body: Center(
          child: Text('You need to be logged in to view your reviews'),
        ),
      );
    }

    print('User ID: ${user.uid}');

    return Scaffold(
      appBar: AppBar(
        title: Text('My Reviews'),
        backgroundColor: settings.darkMode
            ? Colors.black
            : const Color.fromARGB(255, 221, 128, 244),
        actions: _buildThemeActions(),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('userId',
                isEqualTo: user.uid) // Filter reviews by the logged-in user
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Loading reviews...');
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('No reviews found for user');
            return Center(child: Text('No reviews available'));
          }

          print('Reviews data received');

          var reviews = snapshot.data!.docs.map((doc) {
            print('Review data: ${doc.data()}');
            return Review.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          print('Number of reviews: ${reviews.length}');

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];
              print('Review ${index + 1}: ${review.reviewText}');
              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4.0,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text(
                    review.reviewText,
                    style: TextStyle(fontSize: _fontSize),
                  ),
                  subtitle: Text(
                    'Rating: ${review.rating}\nDate: ${review.date.toLocal()}',
                    style: TextStyle(fontSize: _fontSize * 0.8),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          await _showEditReviewDialog(context, review);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          bool confirmed =
                              await _showConfirmationDialog(context);
                          if (confirmed) {
                            print(
                                'Deleting review with ID: ${review.reviewId}');
                            await _deleteReview(
                                review.reviewId, review.cityId, user.uid);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildThemeActions() {
    return [
      IconButton(
        icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
        onPressed: () {
          setState(() {
            _isDarkMode = !_isDarkMode;
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.text_fields),
        onPressed: () async {
          await _showFontSizeDialog();
        },
      ),
    ];
  }

  Future<void> _showFontSizeDialog() async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Adjust Font Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Font Size: ${_fontSize.toStringAsFixed(1)}'),
              Slider(
                value: _fontSize,
                min: 10.0,
                max: 30.0,
                divisions: 20,
                label: _fontSize.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style:
                    TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditReviewDialog(
      BuildContext context, Review review) async {
    final reviewController = TextEditingController(text: review.reviewText);
    final ratingController =
        TextEditingController(text: review.rating.toString());

    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reviewController,
                decoration: InputDecoration(labelText: 'Review'),
                maxLines: 3,
              ),
              TextField(
                controller: ratingController,
                decoration: InputDecoration(labelText: 'Rating'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final newReviewText = reviewController.text.trim();
                final newRating =
                    double.tryParse(ratingController.text.trim()) ??
                        review.rating;

                if (newReviewText.isNotEmpty) {
                  await _updateReview(
                      review.reviewId, newReviewText, newRating);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateReview(
      String reviewId, String newReviewText, double newRating) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print('Updating review with ID: $reviewId');

      // Update the main 'reviews' collection
      await firestore.collection('reviews').doc(reviewId).update({
        'reviewText': newReviewText,
        'rating': newRating,
        'timestamp': Timestamp.fromDate(DateTime.now()), // Update timestamp
      });

      // Update in the 'reviews' sub-collection within the specified city
      var citiesSnapshot = await firestore.collection('cities').get();
      for (var cityDoc in citiesSnapshot.docs) {
        var cityId = cityDoc.id;
        var reviewDocRef = firestore
            .collection('cities')
            .doc(cityId)
            .collection('reviews')
            .doc(reviewId);

        // Check if the document exists before updating
        var docSnapshot = await reviewDocRef.get();
        if (docSnapshot.exists) {
          try {
            await reviewDocRef.update({
              'reviewText': newReviewText,
              'rating': newRating,
              'timestamp':
                  Timestamp.fromDate(DateTime.now()), // Update timestamp
            });
            print('Updated review in city collection for cityId $cityId');
          } catch (e) {
            print(
                'Error updating review in city collection for cityId $cityId: $e');
          }
        } else {
          print('No document to update in city collection for cityId $cityId');
        }
      }

      // Update in the user's 'reviews' sub-collection
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('reviews')
          .doc(reviewId)
          .update({
        'reviewText': newReviewText,
        'rating': newRating,
        'timestamp': Timestamp.fromDate(DateTime.now()), // Update timestamp
      });

      print('Review with ID: $reviewId successfully updated');
    } catch (e) {
      print('Failed to update review: $e');
    }
  }

  Future<void> _deleteReview(
      String reviewId, String cityId, String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      print('Starting delete transaction for reviewId: $reviewId');

      await firestore.runTransaction((transaction) async {
        // Delete from the main 'reviews' collection
        QuerySnapshot reviewSnapshot = await firestore
            .collection('reviews')
            .where('reviewId', isEqualTo: reviewId)
            .limit(1)
            .get();

        if (reviewSnapshot.docs.isNotEmpty) {
          for (var doc in reviewSnapshot.docs) {
            print('Deleting review from main collection: ${doc.id}');
            transaction.delete(doc.reference);
          }
        } else {
          print('No review found in main collection for reviewId: $reviewId');
        }

        // Delete from the 'reviews' sub-collection within the specified city
        QuerySnapshot subCollectionReviewSnapshot = await firestore
            .collection('cities')
            .doc(cityId)
            .collection('reviews')
            .where('reviewId', isEqualTo: reviewId)
            .limit(1)
            .get();

        if (subCollectionReviewSnapshot.docs.isNotEmpty) {
          for (var doc in subCollectionReviewSnapshot.docs) {
            print('Deleting review from city collection: ${doc.id}');
            transaction.delete(doc.reference);
          }
        } else {
          print('No review found in city collection for reviewId: $reviewId');
        }

        // Delete from the user's 'reviews' sub-collection
        QuerySnapshot userReviewSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('reviews')
            .where('reviewId', isEqualTo: reviewId)
            .limit(1)
            .get();

        if (userReviewSnapshot.docs.isNotEmpty) {
          for (var doc in userReviewSnapshot.docs) {
            print('Deleting review from user collection: ${doc.id}');
            transaction.delete(doc.reference);
          }
        } else {
          print('No review found in user collection for reviewId: $reviewId');
        }
      });

      print('Review with ID: $reviewId successfully deleted');
    } catch (e) {
      print("Failed to delete review: $e");
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Confirm Delete"),
            content: const Text("Are you sure you want to delete this review?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class Review {
  final String reviewId;
  final String userId;
  final String cityId;
  final String reviewText; // Ensure this matches the Firestore field name
  final double rating;
  final DateTime date;

  Review({
    required this.reviewId,
    required this.userId,
    required this.cityId,
    required this.reviewText,
    required this.rating,
    required this.date,
  });

  factory Review.fromMap(Map<String, dynamic> data, String reviewId) {
    return Review(
      reviewId: reviewId,
      userId: data['userId'] ?? '',
      cityId: data['cityId'] ?? '',
      reviewText: data['reviewText'] ??
          '', // Ensure this matches the Firestore field name
      rating: data['rating']?.toDouble() ?? 0.0,
      date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
