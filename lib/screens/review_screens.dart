import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ReviewPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const ReviewPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> submitReview() async {
    if (_formKey.currentState!.validate()) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You need to be logged in to submit a review.')),
        );
        return;
      }

      final String userId = user.uid;
      final String review = _reviewController.text.trim();
      final String reviewId =
          FirebaseFirestore.instance.collection('reviews').doc().id;

      final reviewData = {
        'reviewId': reviewId,
        'userId': userId,
        'cityId': widget.cityId,
        'rating': _rating,
        'review': review,
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        // 1. Save to Reviews Collection
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(reviewId)
            .set(reviewData);

        // 2. Reference Review ID in City Database
        await FirebaseFirestore.instance
            .collection('cities')
            .doc(widget.cityId)
            .collection('reviews')
            .doc(reviewId)
            .set(reviewData);

        // 3. Reference Review ID in User Database
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('reviews')
            .doc(reviewId)
            .set({
          'cityId': widget.cityId,
          'cityName': widget.cityName,
          ...reviewData,
        });

        // Clear form after submission
        _reviewController.clear();
        setState(() {
          _rating = 0;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: $e')),
        );
      }
    }
  }

  Future<DocumentSnapshot> _fetchCityName(String cityId) async {
    return FirebaseFirestore.instance.collection('cities').doc(cityId).get();
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this review?"),
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

        // Delete from the 'reviews' sub-collection within the user
        QuerySnapshot userCollectionReviewSnapshot = await firestore
            .collection('users')
            .doc(userId)
            .collection('reviews')
            .where('reviewId', isEqualTo: reviewId)
            .limit(1)
            .get();

        if (userCollectionReviewSnapshot.docs.isNotEmpty) {
          for (var doc in userCollectionReviewSnapshot.docs) {
            transaction.delete(doc.reference);
          }
        }
      });
    } catch (e) {
      print("Failed to delete review: $e");
    }
  }

  void _showDetailsDialog(
      BuildContext context, String cityName, DateTime date) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Review Details'),
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
                'Review Date: ${DateFormat('yyyy-MM-dd').format(date)}',
                style: Theme.of(context).textTheme.subtitle1,
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write a Review'),
        backgroundColor: const Color.fromARGB(255, 242, 219, 248),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Write a review about ${widget.cityName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Star Rating
            Slider(
              value: _rating,
              onChanged: (newRating) {
                setState(() => _rating = newRating);
              },
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating.toString(),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your review',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please write a review';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                backgroundColor: const Color.fromARGB(255, 242, 219, 248),
              ),
              onPressed: submitReview,
              child: const Text('Submit Review'),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cities')
                  .doc(widget.cityId)
                  .collection('reviews')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No reviews found."));
                }

                final reviews = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    var review = reviews[index].data() as Map<String, dynamic>;
                    var reviewId = review['reviewId'] ?? 'Unknown';
                    var userId = review['userId'] ?? 'Unknown';
                    var rating = review['rating'] ?? 0;
                    var reviewText = review['review'] ?? '';
                    var date = review['timestamp']?.toDate() ??
                        DateTime
                            .now(); // Handle missing field and convert to DateTime

                    return FutureBuilder<DocumentSnapshot>(
                      future: _fetchCityName(widget.cityId),
                      builder: (context, citySnapshot) {
                        String cityName = 'Unknown';
                        if (citySnapshot.connectionState ==
                            ConnectionState.done) {
                          if (citySnapshot.hasData &&
                              citySnapshot.data != null) {
                            cityName = citySnapshot.data!['name'] ?? 'Unknown';
                          }
                        }
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          child: ListTile(
                            title: Text('Rating: $rating stars'),
                            subtitle: Text(reviewText),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                bool confirmed =
                                    await _showConfirmationDialog(context);
                                if (confirmed) {
                                  await _deleteReview(
                                      reviewId, widget.cityId, userId);
                                }
                              },
                            ),
                            onTap: () {
                              _showDetailsDialog(context, cityName, date);
                            },
                          ),
                        );
                      },
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
}
