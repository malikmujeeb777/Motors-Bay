import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServiceProviderDetail extends StatefulWidget {
  final String serviceCategory;
  final String userId;

  const ServiceProviderDetail({
    super.key,
    required this.serviceCategory,
    required this.userId
  });

  @override
  ServiceProviderDetailState createState() => ServiceProviderDetailState();
}

class ServiceProviderDetailState extends State<ServiceProviderDetail> {
  bool isLoading = false;
  Map<String, dynamic> serviceDetails = {};

  @override
  void initState() {
    super.initState();
    fetchServices();
  }

  Future<void> fetchServices() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
          .collection('users_service')
          .doc(widget.userId)
          .collection('services')
          .doc(widget.serviceCategory)
          .get();

      if (serviceDoc.exists) {
        Map<String, dynamic> data = serviceDoc.data() as Map<String, dynamic>;
        setState(() {
          serviceDetails = data['services'] ?? {};
        });
      }
    } catch (e) {
      Get.snackbar(
          "Error",
          "Failed to fetch services: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void contactProvider() {
    // Implement your contact provider logic here
    Get.snackbar(
        "Contact Provider",
        "Contact functionality will be implemented here",
        backgroundColor: Colors.blue,
        colorText: Colors.white
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Service Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.serviceCategory,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Available Services:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: serviceDetails.entries.map((entry) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "Rs. ${entry.value}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: contactProvider,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  "Contact Provider",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}