import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/sp_all_services.dart';

class ServiceProviders extends StatelessWidget {
  const ServiceProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('dealers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No service providers available"));
          }

          var dealers = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dealers.length > 4 ? 4 : dealers.length,
            itemBuilder: (context, index) {
              var dealer = dealers[index].data() as Map<String, dynamic>;
              return AutoPartItem(dealer: dealer);
            },
          );
        },
      ),
    );
  }
}

class AutoPartItem extends StatelessWidget {
  final Map<String, dynamic> dealer;

  const AutoPartItem({super.key, required this.dealer});

  Future<List<String>> fetchServices(String userId) async {
    try {
      var servicesSnapshot = await FirebaseFirestore.instance
          .collection('users_service')
          .doc(userId)
          .collection('services')
          .get();

      return servicesSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    String shopName = dealer['shopName'] ?? "Unknown Shop";
    String address = dealer['address'] ?? "No Address";
    String userId = dealer['uid'] ?? ""; // Assuming email is used as ID

    return FutureBuilder<List<String>>(
      future: fetchServices(userId),
      builder: (context, servicesSnapshot) {
        List<String> services = servicesSnapshot.data ?? [];

        return InkWell(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => SpAllServices(userID: userId,shopName: shopName,)));
          },
          child: Container(
            width: 220,
            margin: const EdgeInsets.only(right: 10),
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      color: Colors.grey.shade200,
                      child: Image.asset("assets/images/part.png", fit: BoxFit.cover),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(address, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 5),
                        services.isNotEmpty
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: services
                              .map((service) => Text("• $service", style: const TextStyle(fontSize: 12)))
                              .toList(),
                        )
                            : const Text("No services available", style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
