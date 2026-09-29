import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyServicesDetails extends StatefulWidget {
  final String serviceCategory;

  const MyServicesDetails({super.key, required this.serviceCategory});

  @override
  MyServicesDetailsState createState() => MyServicesDetailsState();
}

class MyServicesDetailsState extends State<MyServicesDetails> {
  bool isLoading = false;
  Map<String, bool> selectedServices = {};
  Map<String, TextEditingController> amountControllers = {};

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
      String userId = FirebaseAuth.instance.currentUser!.uid;
      // String category = services[widget.index]['title'];

      DocumentSnapshot serviceDoc = await FirebaseFirestore.instance
          .collection('users_service')
          .doc(userId)
          .collection('services')
          .doc(widget.serviceCategory)
          .get();

      if (serviceDoc.exists) {
        Map<String, dynamic> data = serviceDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> servicesData = data['services'] ?? {};

        setState(() {
          selectedServices = servicesData.map((key, value) => MapEntry(key, true));
          servicesData.forEach((key, value) {
            amountControllers[key] = TextEditingController(text: value.toString());
          });
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch services: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveServices() async {
    setState(() {
      isLoading = true;
    });

    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String category = widget.serviceCategory;

      Map<String, dynamic> updatedServices = {};
      selectedServices.forEach((key, value) {
        if (value) {
          updatedServices[key] = amountControllers[key]?.text.trim() ?? "0";
        }
      });

      if (updatedServices.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users_service')
            .doc(userId)
            .collection('services')
            .doc(category)
            .set({
          'userId': userId,
          'services': updatedServices,
          'timestamp': FieldValue.serverTimestamp(),
        });

        Get.snackbar("Success", "Services updated successfully for $category!",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        Get.snackbar("Error", "Please select at least one service.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to update services: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    for (var controller in amountControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
            Expanded(
              child: ListView(
                children: selectedServices.keys.map((service) {
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
                            value: selectedServices[service],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedServices[service] = value ?? false;
                              });
                            },
                          ),
                          if (selectedServices[service]!)
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
                onPressed: isLoading ? null : saveServices,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Update Services", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

