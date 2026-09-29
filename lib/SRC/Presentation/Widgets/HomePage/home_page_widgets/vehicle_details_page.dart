import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Domain/models/vehicle_details_model.dart';
import 'package:motorsbay1/SRC/Presentation/Common/common_loading_dialouge.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ChatScreen/chat_detail_page.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/review_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/3DModel/view_360_images_assets.dart';
import 'package:motorsbay1/exports.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class VehicleDetailsPage extends StatefulWidget {
  final VehicleDetailsModel? vehicleDetailsModel;
  final String? carId;

  const VehicleDetailsPage({super.key, this.vehicleDetailsModel, this.carId});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  bool isFavorite = false; // Track favorite state
  Map<String, dynamic>? sellerData;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // Check favorite status on load
    fetchSellerDetails();
  }

  Future<void> fetchSellerDetails() async {
    if (widget.vehicleDetailsModel?.userId == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.vehicleDetailsModel?.userId)
          .get();

      if (doc.exists) {
        setState(() {
          sellerData = doc.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print("Error fetching seller details: $e");
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = Data.app.token ?? "";

  void _checkIfFavorite() async {
    if (widget.vehicleDetailsModel == null) return;

    DocumentSnapshot favDoc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(widget
        .vehicleDetailsModel!.title)
        .get();

    setState(() {
      isFavorite = favDoc.exists;
    });
  }

  // Function to toggle favorite status
  void _toggleFavorite() async {
    if (widget.vehicleDetailsModel == null) return;

    DocumentReference favRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(widget.vehicleDetailsModel!.title);

    if (isFavorite) {
      // Remove from favorites
      await favRef.delete();
    } else {
      // Add to favorites
      await favRef.set({
        "status": widget.vehicleDetailsModel!.status,
        "listingType": widget.vehicleDetailsModel!.listingType,
        "title": widget.vehicleDetailsModel!.title,
        "price": widget.vehicleDetailsModel!.price,
        "description": widget.vehicleDetailsModel!.description,
        "kmDriven": widget.vehicleDetailsModel!.kmDriven,
        "transmission": widget.vehicleDetailsModel!.transmission,
        "assembly": widget.vehicleDetailsModel!.assembly,
        "fuelType": widget.vehicleDetailsModel!.fuelType,
        "color": widget.vehicleDetailsModel!.color,
        "city": widget.vehicleDetailsModel!.city,
        "registerIn": widget.vehicleDetailsModel!.registerIn,
        "condition": widget.vehicleDetailsModel!.condition,
        "brand": widget.vehicleDetailsModel!.brand,
        "subCategory": widget.vehicleDetailsModel!.subCategory,
        "contactNumber": widget.vehicleDetailsModel!.contactNumber,
        "allowWhatsApp": widget.vehicleDetailsModel!.allowWhatsApp,
        "createdAt": widget.vehicleDetailsModel!.createdAt,
        "userId": widget.vehicleDetailsModel!.userId,
        "isSold": widget.vehicleDetailsModel!.isSold,
        "deviceToken": widget.vehicleDetailsModel!.deviceToken,
        "modelYear": widget.vehicleDetailsModel!.modelYear,
        "image": "assets/images/carr.png",
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("The Car ID is ${widget.carId}");
    return Scaffold(
      appBar: AppBar(title: Text('Vehicle Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Product Images (Carousel for multiple images)
                if (widget.vehicleDetailsModel?.imageUrls != null &&
                    widget.vehicleDetailsModel!.imageUrls.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.vehicleDetailsModel!.imageUrls.length,
                      itemBuilder: (context, index) {
                        String imageUrl = widget.vehicleDetailsModel!.imageUrls[index];
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15)),
                            child: Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        );
                      },
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey.shade200,
                      child: Image.asset(
                        "assets/images/carr.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                // Favorite Button
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 29,
                      color: isFavorite ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vehicleDetailsModel?.title ?? 'Audi Q7 3.0 Quattro',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.vehicleDetailsModel?.price ?? 'PKR 3,248,000',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    widget.vehicleDetailsModel?.description ??
                        'Audi Q7 3.0 Quattro with automatic transmission in Casual Mine...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  // Details Table
                  _buildDetailsTable(),
                  SizedBox(height: 16),
                  
                  // 3D Model Button
                  _build3DModelButton(),
                  SizedBox(height: 16),
                  
                  // Seller Details
                  _buildSellerDetails(),
                  SizedBox(height: 16),
                  (Data.app.token == widget.vehicleDetailsModel?.userId)
                      ? CommonButton(
                    onTap: () {
                      updateCarSoldStatus(widget.carId!, true);
                    },
                    text: "Mark Car As Sold",
                  )
                      : (widget.vehicleDetailsModel!.isSold == true)
                      ? Center(
                    child: SizedBox(
                      child: Text(
                        "Already Sold",
                        style: TextStyle(
                            color: Colors.red, fontSize: 20),
                      ),
                    ),
                  )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build the details table
  Widget _buildDetailsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brand Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            _buildTableRow(
                'Make', widget.vehicleDetailsModel?.subCategory ?? 'Audi'),
            _buildTableRow(
                'Model Year', widget.vehicleDetailsModel?.modelYear ?? '2023'),
            _buildTableRow(
                'Brand', widget.vehicleDetailsModel?.brand ?? 'Yamaha'),
            _buildTableRow('Register In',
                widget.vehicleDetailsModel?.registerIn ?? 'Islamabad'),
          ],
        ),
      ],
    );
  }

  // Function to create table rows
  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
      ],
    );
  }

  // Function to build seller details
  Widget _buildSellerDetails() {
    if (Data.app.token == widget.vehicleDetailsModel?.userId) return SizedBox();
    final data = FirebaseFirestore.instance
        .collection("users")
        .doc(widget.vehicleDetailsModel?.userId)
        .get();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Seller Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("Add Review").onTapped(onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CarReviewScreen(
                        carId: widget.carId ?? "",
                      )));
            })
          ],
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: sellerData?['photoUrl'] != null
                ? NetworkImage(sellerData!['photoUrl'])
                : AssetImage('assets/profile.png') as ImageProvider,
          ),
          title: Text(sellerData?['displayName'] ?? 'Unknown Seller'),
          subtitle: Text(sellerData?['email'] ?? 'No Email Provided'),
        ),
        const SizedBox(height: 16),
        CommonButton(
            onTap: () {
              callSeller();
            },
            text: "Call Seller"),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: CommonButton(
                backgroundColor: Colors.blue.withAlpha(100),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>                              ConversationScreen(
                                receiverId: sellerData?['uid'] ?? "",
                                receiverName: sellerData?['displayName'] ?? "",
                                receiverImage: sellerData?['photoUrl'] ?? "https://randomuser.me/api/portraits/men/1.jpg",
                              )));
                },
                text: "Chat",
                textColor: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CommonButton(
                backgroundColor: Colors.blue.withAlpha(100),
                onTap: () {
                  whatsappSeller();
                },
                text: "WhatsApp",
                textColor: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void callSeller() async {
    final phone = widget.vehicleDetailsModel?.contactNumber; // Ensure 'phone' exists in Firestore
    if (phone != null && phone.isNotEmpty) {
      final Uri callUri = Uri.parse('tel:$phone');
      try {
        // Force opening the phone app with LaunchMode.externalApplication
        if (await canLaunchUrl(callUri)) {
          await launchUrl(callUri, mode: LaunchMode.externalApplication);
        } else {
          showCustomSnackBar(context, "Could not launch phone app");
          print("Could not launch call");
        }
      } catch (e) {
        showCustomSnackBar(context, "Error launching phone app: $e");
        print("Error launching call: $e");
      }
    } else {
      // If seller's phone number is not found
      final sellerName = sellerData?['displayName'] ?? 'Seller';
      showCustomSnackBar(context, "$sellerName's phone number is private");
      print("Phone number not available");
    }
  }

  void whatsappSeller() async {
    final phone = widget.vehicleDetailsModel?.contactNumber;
    if (phone != null && phone.isNotEmpty) {
      final Uri whatsappUri = Uri.parse("https://wa.me/$phone");
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        showCustomSnackBar(context, "Could not launch WhatsApp");
        print("Could not launch WhatsApp");
      }
    } else {
      showCustomSnackBar(context, "Phone number not available");

      print("Phone number not available");
    }
  }

  Future<void> updateCarSoldStatus(String carId, bool isSold) async {
    try {
      LoadingDialog.show(context);
      carId = carId.trim(); // Trim spaces
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("cars")
          .doc("TVuUCfzrZWYHCmPlDElcYVIhTai1")
          .collection("user_cars")
          .doc(carId)
          .get();
      if (!doc.exists) {
        LoadingDialog.hide(context);
        print("❌ Error: Car ID $carId does not exist!");
        return;
      }

      await FirebaseFirestore.instance
          .collection("cars")
          .doc("TVuUCfzrZWYHCmPlDElcYVIhTai1")
          .collection("user_cars")
          .doc(carId)
          .update({"isSold": isSold});
      LoadingDialog.hide(context);
      print("✅ Car status updated successfully!");
    } catch (e) {
      LoadingDialog.hide(context);
      print("❌ Error updating car status: $e");
    }
  }

  // Function to build 3D Model button
  Widget _build3DModelButton() {
    return CommonButton(
      onTap: () => _open3DModelViewer(),
      text: "View 3D Model",
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      leadingIcon: Icons.view_in_ar,
    );
  }

  // Function to open 3D model viewer
  Future<void> _open3DModelViewer() async {
    try {
      // Navigate directly to View360ImagesAssets page - it will load all images from assets
      Get.to(() => const View360ImagesAssets());
    } catch (e) {
      print('Error opening 3D model viewer: $e');
      // Show error message if navigation fails
      Get.snackbar(
        'Error',
        'Could not open 360° viewer',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
