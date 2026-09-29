import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/home_page.dart';

class ServiceDetailPage extends StatefulWidget {
  final Map<String, bool> selectedServices;
  final int index;

  const ServiceDetailPage({super.key, required this.selectedServices, required this.index});

  @override
  ServiceDetailPageState createState() => ServiceDetailPageState();
}

class ServiceDetailPageState extends State<ServiceDetailPage> {
  bool isLoading = false;
  Map<String, TextEditingController> amountControllers = {};

  @override
  void initState() {
    super.initState();
    for (var service in widget.selectedServices.keys) {
      amountControllers[service] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> saveServices() async {
    setState(() {
      isLoading = true;
    });

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String category = services[widget.index]['title'];

      Map<String, dynamic> selectedServicesWithAmounts = {};

      for (var entry in widget.selectedServices.entries) {
        if (entry.value) {
          String amount = amountControllers[entry.key]?.text.trim() ?? '0';
          selectedServicesWithAmounts[entry.key] = amount;
        }
      }

      if (selectedServicesWithAmounts.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users_service')
            .doc(userId)
            .collection('services')
            .doc(category)
            .set({
          'userId': userId,
          'services': selectedServicesWithAmounts,
          'timestamp': FieldValue.serverTimestamp(),
        });

        Get.snackbar("Success", "Services saved successfully for $category!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Please select at least one service.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save services: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Service Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: widget.selectedServices.keys.map((service) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            title: Text(service, style: TextStyle(fontSize: 16)),
                            value: widget.selectedServices[service],
                            onChanged: (bool? value) {
                              setState(() {
                                widget.selectedServices[service] = value ?? false;
                              });
                            },
                          ),
                          if (widget.selectedServices[service]!) // Show amount field only if service is selected
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: TextField(
                                controller: amountControllers[service],
                                decoration: InputDecoration(
                                  labelText: 'Amount (Rs)',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                ),
                                keyboardType: TextInputType.number,
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
                onPressed: isLoading ? null : saveServices, // Disable button when loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white) // Show loading indicator
                    : Text("Save Services", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}