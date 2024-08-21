import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewPage extends StatefulWidget {
  final String cityId;
  final String cityName;
  final String cityImageUrl; // City image URL to display

  const ReviewPage({
    super.key,
    required this.cityId,
    required this.cityName,
    required this.cityImageUrl,
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
      final String userId = user!.uid;
      final String review = _reviewController.text.trim();
      final String reviewId =
          FirebaseFirestore.instance.collection('reviews').doc().id;

      final reviewData = {
        'reviewId': reviewId,
        'userId': userId,
        'rating': _rating,
        'review': review,
        'timestamp': FieldValue.serverTimestamp(),
      };

      try {
        // Save to City Database
        await FirebaseFirestore.instance
            .collection('cities')
            .doc(widget.cityId)
            .collection('reviews')
            .doc(reviewId) // Save with specific review ID
            .set(reviewData);

        // Save to User Database
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('reviews')
            .doc(reviewId) // Save with specific review ID
            .set({
          'cityId': widget.cityId,
          'cityName': widget.cityName,
          'cityImageUrl': widget.cityImageUrl,
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
            // Display the city image
            Image.network(
              widget.cityImageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
          ],
        ),
      ),
    );
  }
}
