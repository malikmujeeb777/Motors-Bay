import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Domain/models/vehicle_details_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/vehicle_details_page.dart';
import 'package:motorsbay1/exports.dart';

class CarBrandList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: StreamBuilder(
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
            scrollDirection: Axis.horizontal,
            itemCount: ads.length,
            itemBuilder: (context, index) {
              String carId = ads[index].id;
              var ad = ads[index].data() as Map<String, dynamic>;
              final vehicleDetailsModel = VehicleDetailsModel(
                status: ad['status'] ?? '',
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
                modelYear: ad['modelYear'] ?? '',
                imageUrls: ad['imageUrls'] ?? [],
              );

              String imagePath = ad['imageUrls'] != null && ad['imageUrls'].isNotEmpty
                  ? ad['imageUrls'][0] // Assuming the first image in the list
                  : '';

              return vehicleDetailsModel.isSold == true
                  ? SizedBox.shrink()
                  : CarItem(
                carName: ad["title"] ?? "No Title",
                price: ad["price"] ?? "0",
                kmDriven: ad["kmDriven"] ?? "0",
                fuelType: ad["fuelType"] ?? "petroleum",
                color: ad["color"] ?? "",
                modelYear: ad["modelYear"] ?? "",
                city: ad["city"] ?? "Islamabad",
                registerIn: ad["registerIn"] ?? "Islamabad",
                imagePath: imagePath,
              ).onTapped(onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehicleDetailsPage(
                      vehicleDetailsModel: vehicleDetailsModel,
                      carId: carId,
                    ),
                  ),
                );
              });
            },
          );
        },
      ),
    );
  }
}

class CarItem extends StatelessWidget {
  final String carName;
  final String price;
  final String kmDriven;
  final String fuelType;
  final String color;
  final String modelYear;
  final String city;
  final String registerIn;
  final String imagePath;

  CarItem({
    required this.carName,
    required this.price,
    required this.kmDriven,
    required this.fuelType,
    required this.color,
    required this.modelYear,
    required this.city,
    required this.registerIn,
    this.imagePath = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
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
                      topRight: Radius.circular(15)),                  child: Container(
                    width: double.infinity,
                    height: 120,
                    color: Colors.grey.shade200, // Placeholder color
                    child: imagePath.isNotEmpty
                        ? Image.network(
                            imagePath, 
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                "assets/images/carr.png",
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                      "assets/images/carr.png", // Default image if no imagePath is available
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
                        Text(city,
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
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 14,
                          overflow: TextOverflow.ellipsis)),
                  Text("PKR ${price}",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text("${modelYear}  |  ${kmDriven} km  |  ${fuelType}",
                      style: TextStyle(fontSize: 12, color: Colors.black)),
                  Text("0 day ago", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
