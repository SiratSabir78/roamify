import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('User is not logged in');
      return Scaffold(
        appBar: AppBar(
          title: Text('User Reviews'),
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
                  title:
                      Text(review.reviewText, style: TextStyle(fontSize: 16.0)),
                  subtitle: Text(
                      'Rating: ${review.rating}\nDate: ${review.date.toLocal()}'),
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

      await firestore.collection('reviews').doc(reviewId).update({
        'review': newReviewText,
        'rating': newRating,
        'timestamp': Timestamp.fromDate(DateTime.now()), // Update timestamp
      });

      // Update in the 'reviews' sub-collection within the specified city
      var citiesSnapshot = await firestore.collection('cities').get();
      for (var cityDoc in citiesSnapshot.docs) {
        var cityId = cityDoc.id;
        await firestore
            .collection('cities')
            .doc(cityId)
            .collection('reviews')
            .doc(reviewId)
            .update({
          'review': newReviewText,
          'rating': newRating,
          'timestamp': Timestamp.fromDate(DateTime.now()), // Update timestamp
        });
      }

      // Update in the user's 'reviews' sub-collection
      await firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('reviews')
          .doc(reviewId)
          .update({
        'review': newReviewText,
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
  final String reviewText;
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
      reviewText: data['review'] ?? '',
      rating: data['rating']?.toDouble() ?? 0.0,
      date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
