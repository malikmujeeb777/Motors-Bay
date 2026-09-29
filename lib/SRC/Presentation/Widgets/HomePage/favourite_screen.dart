import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Domain/models/vehicle_details_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/vehicle_details_page.dart';

class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = Data.app.token ?? ""; // Get current user ID

  // Function to remove a vehicle from favorites
  void _removeFromFavorites(String title) async {
    await _firestore.collection("users").doc(userId).collection("favorites").doc(title).delete();
    setState(() {}); // Refresh UI after removal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Favorites", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            // Navigator.push(context, MaterialPageRoute(builder: (context)=>ThreeDImages(title: '',)));
          }, icon: Icon(Icons.image_outlined)),
        ]
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("users").doc(userId).collection("favorites").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading state
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No favorites added yet!",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          var favoriteVehicles = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favoriteVehicles.length,
            itemBuilder: (context, index) {
              String carId = favoriteVehicles[index].id;
              var ad = favoriteVehicles[index].data() as Map<String, dynamic>;
              final vehicleDetailsModel = VehicleDetailsModel(status: ad['status'] ?? '',
                listingType: ad['listingType'] ?? '',
                title: ad['title'] ?? '',
                price: ad['price'] ?? '0',
                description: ad['description'] ?? '',
                kmDriven: ad['kmDriven'] ?? '',
                transmission: ad['transmission'] ?? '',
                assembly: ad['assembly'] ?? '',
                fuelType: ad['fuelType'] ?? '',
                color: ad['color'] ?? '',
                city: ad['city'] ?? '',
                registerIn: ad['registerIn'] ?? '',
                condition: ad['condition'] ?? '',
                brand: ad['brand'] ?? '',
                subCategory: ad['subCategory'] ?? '',
                contactNumber: ad['contactNumber'] ?? '',
                allowWhatsApp: ad['allowWhatsApp'] ?? false,
                createdAt: ad['createdAt'] ?? Timestamp.now(),
                userId: ad['userId'] ?? '',
                isSold: ad['isSold'] ?? false,
                deviceToken: ad['deviceToken'] ?? '',
                modelYear: ad['modelYear'] ?? '',);
              var vehicle = favoriteVehicles[index];
              return _buildFavoriteCard(vehicle, (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>VehicleDetailsPage(
                  vehicleDetailsModel: vehicleDetailsModel,
                  carId: carId,
                )));
              });
            },
          );
        },
      ),
    );
  }

  // Widget to display each favorite item in a stylish card
  Widget _buildFavoriteCard(QueryDocumentSnapshot vehicle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: ListTile(
          contentPadding: EdgeInsets.all(10),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              vehicle["image"] ?? "assets/images/carr.png",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            vehicle["title"] ?? "Unknown Vehicle",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            vehicle["price"] ?? "Price Not Available",
            style: TextStyle(fontSize: 16, color: Colors.green),
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeFromFavorites(vehicle["title"]),
          ),
        ),
      ),
    );
  }
}
