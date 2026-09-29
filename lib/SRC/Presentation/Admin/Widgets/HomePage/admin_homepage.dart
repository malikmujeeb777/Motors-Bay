import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/exports.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collectionGroup("user_cars") // Fetch all ads from all users
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error fetching ads"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No ads available"));
        }

        var ads = snapshot.data!.docs;

        return ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: ads.length,
          itemBuilder: (context, index) {
            var ad = ads[index].data() as Map<String, dynamic>;
            var docId = ads[index].id; // Get the document ID

            if(ad['status'] == 'pending'){
              return CarItem(
                docId: docId, // Pass the document ID to CarItem
                carName: ad["title"] ?? "No Title",
                price: ad["price"] ?? "0",
                kmDriven: ad["kmDriven"] ?? "0",
                fuelType: ad["fuelType"] ?? "petroleum",
                color: ad["color"] ?? "",
                modelYear: ad["modelYear"] ?? "",
                city: ad["city"] ?? "Islamabad",
                registerIn: ad["registerIn"] ?? "Islamabad", userId: ad["userId"] ?? "",
              );
            }else{
              return Container();
            }
          },
        );
      },
    );
  }
}

class CarItem extends StatelessWidget {
  final String docId; // Document ID
  final String userId; // User ID (added)
  final String carName;
  final String price;
  final String kmDriven;
  final String fuelType;
  final String color;
  final String modelYear;
  final String city;
  final String registerIn;

  CarItem({
    required this.docId,
    required this.userId, // Added
    required this.carName,
    required this.price,
    required this.kmDriven,
    required this.fuelType,
    required this.color,
    required this.modelYear,
    required this.city,
    required this.registerIn,
  });

  void _updateStatus(String status, {String? reason}) async {
    try {
      // Ensure userId is correctly passed to the CarItem widget
      if (userId == null || userId.isEmpty) {
        print("Error: userId is null or empty");
        return;
      }

      // Directly reference the document using its full path
      var docRef = FirebaseFirestore.instance
          .collection('cars')
          .doc(userId) // Use the actual userId value
          .collection('user_cars')
          .doc(docId);

      // Prepare the update data
      Map<String, dynamic> updateData = {
        'status': status,
      };

      // Add the rejection reason if provided
      if (reason != null && reason.isNotEmpty) {
        updateData['rejectedReason'] = reason;
      }

      // Update the Firestore document
      await docRef.update(updateData);

      print("Status updated to $status");
      if (reason != null) {
        print("Rejection reason: $reason");
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  void _showRejectionDialog(BuildContext context) async {
    // Controller for the rejection reason text field
    TextEditingController rejectionReasonController = TextEditingController();

    // Show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reject Ad"),
          content: TextField(
            controller: rejectionReasonController,
            decoration: InputDecoration(
              hintText: "Enter rejection reason",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // Get the rejection reason
                String reason = rejectionReasonController.text.trim();

                if (reason.isNotEmpty) {
                   _updateStatus("rejected", reason: reason);

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please provide a rejection reason")),
                  );
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: EdgeInsets.only(right: 10, left: 10),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey.shade200, // Placeholder color
                    child: Image.asset(
                      "assets/images/carr.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.black, size: 14),
                        SizedBox(width: 4),
                        Text(registerIn,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                spacing: 2,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(carName,
                      style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text("PKR ${price}",
                      style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text("${modelYear}  |  ${kmDriven} km  |  ${fuelType}",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  Text("0 day ago",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  CommonButton(
                    backgroundColor: Colors.blue.withAlpha(50),
                    onTap: () {
                      _updateStatus("approved");
                    },
                    text: "Accept",
                    textColor: Colors.black,
                  ),
                  10.x,
                  CommonButton(
                    backgroundColor: Colors.red,
                    onTap: () {
                      _showRejectionDialog(context);
                    },
                    text: "Reject",
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}