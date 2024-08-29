import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roamify/screens/state.dart';

class ReviewPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  ReviewPage({required this.cityId, required this.cityName});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();
  double _rating = 3.0;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> submitReview() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      String userId = user.uid;
      String reviewId =
          FirebaseFirestore.instance.collection('reviews').doc().id;
      String cityId = widget.cityId;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final reviewData = {
          'reviewId': reviewId,
          'userId': userId,
          'cityId': cityId,
          'rating': _rating,
          'reviewText': _reviewController.text,
          'timestamp': FieldValue.serverTimestamp(),
        };

        // Add review to 'reviews' collection
        transaction.set(
          FirebaseFirestore.instance.collection('reviews').doc(reviewId),
          reviewData,
        );

        // Add review to 'cities' sub-collection
        transaction.set(
          FirebaseFirestore.instance
              .collection('cities')
              .doc(cityId)
              .collection('reviews')
              .doc(reviewId),
          reviewData,
        );

        // Add review to user's 'reviews' sub-collection
        transaction.set(
          FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('reviews')
              .doc(reviewId),
          reviewData,
        );
      });

      // Clear the form
      _reviewController.clear();
      setState(() {
        _rating = 3.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Review submitted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsModel>(context);
    final isDarkMode = settingsProvider.darkMode;
    final fontSize = settingsProvider.fontSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review', style: TextStyle(fontSize: fontSize)),
        backgroundColor: isDarkMode
            ? Colors.grey[850]
            : const Color.fromRGBO(186, 104, 200, 1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a review about ${widget.cityName}',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _rating,
              onChanged: (newRating) {
                setState(() => _rating = newRating);
              },
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
              activeColor: isDarkMode
                  ? const Color.fromARGB(255, 221, 128, 244)
                  : const Color.fromARGB(255, 221, 128, 244),
              inactiveColor: isDarkMode ? Colors.grey[700] : Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _reviewController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your review',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                ),
                style: TextStyle(
                    fontSize: fontSize,
                    color: isDarkMode ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please write a review';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: isDarkMode
                    ? Color.fromRGBO(77, 76, 74, 0.047)
                    : const Color.fromRGBO(186, 104, 200, 1),
              ),
              onPressed: submitReview,
              child: Text('Submit Review',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('cityId', isEqualTo: widget.cityId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No reviews found."));
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var review = reviews[index].data() as Map<String, dynamic>;
                    var reviewId = review['reviewId'] ?? 'Unknown';
                    var userId = review['userId'] ?? 'Unknown';
                    var rating = review['rating'] ?? 0;
                    var reviewText = review['reviewText'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      child: ListTile(
                        title: Text('Rating: $rating stars',
                            style: TextStyle(
                                fontSize: fontSize,
                                color:
                                    isDarkMode ? Colors.white : Colors.black)),
                        subtitle: Text(reviewText,
                            style: TextStyle(
                                fontSize: fontSize,
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black87)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete,
                              color:
                                  isDarkMode ? Colors.redAccent : Colors.red),
                          onPressed: () async {
                            bool confirmed =
                                await _showConfirmationDialog(context);
                            if (confirmed) {
                              await _deleteReview(
                                  reviewId, widget.cityId, userId);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteReview(
      String reviewId, String cityId, String userId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.runTransaction((transaction) async {
        // Delete from the main 'reviews' collection
        QuerySnapshot reviewSnapshot = await firestore
            .collection('reviews')
            .where('reviewId', isEqualTo: reviewId)
            .limit(1)
            .get();

        if (reviewSnapshot.docs.isNotEmpty) {
          for (var doc in reviewSnapshot.docs) {
            transaction.delete(doc.reference);
          }
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
            transaction.delete(doc.reference);
          }
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
            transaction.delete(doc.reference);
          }
        }
      });
    } catch (e) {
      print("Failed to delete review: $e");
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Delete",
                style: TextStyle(
                    fontSize: Provider.of<SettingsModel>(context).fontSize)),
            content: Text("Are you sure you want to delete this review?",
                style: TextStyle(
                    fontSize: Provider.of<SettingsModel>(context).fontSize)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("Cancel",
                    style: TextStyle(
                        fontSize:
                            Provider.of<SettingsModel>(context).fontSize)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Delete",
                    style: TextStyle(
                        fontSize:
                            Provider.of<SettingsModel>(context).fontSize)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
