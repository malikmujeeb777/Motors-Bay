import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';

class CarReviewScreen extends StatefulWidget {
  final String carId;
  // final String image;
  // final String userName;

  const CarReviewScreen({Key? key, required this.carId, }) : super(key: key);

  @override
  _CarReviewScreenState createState() => _CarReviewScreenState();
}

class _CarReviewScreenState extends State<CarReviewScreen> {
  double _rating = 3.0; // Default rating
  TextEditingController _commentController = TextEditingController();

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('cars')
        .doc(widget.carId)
        .collection('reviews')
        .add({
      'rating': _rating,
      'comment': _commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'profilePic': (Data.app.user != null && Data.app.user!.profilePic.isNotEmpty) ? Data.app.user!.profilePic : '',
      'name' : (Data.app.user != null && Data.app.user!.name.isNotEmpty) ? Data.app.user!.name : '',
    });

    _commentController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Review Added Successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Car Reviews"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Section to Show Existing Reviews
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cars')
                  .doc(widget.carId)
                  .collection('reviews')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No reviews yet."));
                }

                return ListView(
                  padding: EdgeInsets.all(16),
                  children: snapshot.data!.docs.map((doc) {
                    var review = doc.data() as Map<String, dynamic>;
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(/*
                          backgroundImage: (review['rating'] != null && !review['rating'].toString().isNotEmpty)
                              ? NetworkImage(review['profilePic']??"")
                              : AssetImage('assets/images/carr.png'),*/
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review['name'] ?? "Unknown User",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                if (review['rating'] != null) // Ensures rating exists before using it
                                  Text("⭐ " * review['rating'].toInt(), style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        subtitle: Text(review['comment'] ?? ""), // Prevents null error for comment
                      ),

                    );
                  }).toList(),
                );
              },
            ),
          ),

          // Section to Add a New Review
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rate this car:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: "Write your review...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitReview,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: Text("Submit Review", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
