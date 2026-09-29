import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/sp_detail_page.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/my_service_details.dart';

class SpAllServices extends StatefulWidget {
  final String userID;
  final String shopName;
  final bool? isDealer;
  const SpAllServices({super.key, required this.userID, required this.shopName, this.isDealer = false});

  @override
  SpAllServicesState createState() => SpAllServicesState();
}

class SpAllServicesState extends State<SpAllServices> {
  List<Map<String, dynamic>> userServices = []; 

  @override
  void initState() {
    super.initState();
    fetchServicesFromFirebase();
  }

  Future<void> fetchServicesFromFirebase() async {
    try {
      String userId = widget.userID; // ✅ Use the correct dealer's ID
      QuerySnapshot servicesSnapshot = await FirebaseFirestore.instance
          .collection('users_service')
          .doc(userId)
          .collection('services')
          .get();

      List<Map<String, dynamic>> fetchedServices = [];

      for (var doc in servicesSnapshot.docs) {
        String category = doc.id;
        var serviceData = doc.data() as Map<String, dynamic>;
        if (serviceData.isNotEmpty) {
          var matchingService = services.firstWhere(
                (s) => s['title'] == category,
            orElse: () => {},
          );
          if (matchingService.isNotEmpty) {
            fetchedServices.add(matchingService);
          }
        }
      }

      setState(() {
        userServices = fetchedServices;
      });
    } catch (e) {
      print("Error fetching services: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shopName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: userServices.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: userServices.length,
          itemBuilder: (context, index) {
            final service = userServices[index];
            return FadeInUp(
              duration: Duration(milliseconds: 400 + (index * 100)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProviderDetail(
                        serviceCategory: service['title'], userId: widget.userID,
                      ),
                    ),
                  );
                },
                child: ServiceCard(
                  title: service['title'],
                  icon: service['icon'],
                  color: service['color'],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const ServiceCard({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      color: color.withOpacity(0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 30,
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

final List<Map<String, dynamic>> services = [
  {'title': 'Routine Maintenance', 'icon': Icons.build, 'color': Colors.blue},
  {'title': 'Fluid Checks', 'icon': Icons.opacity, 'color': Colors.teal},
  {'title': 'Brakes & Suspension', 'icon': Icons.car_repair, 'color': Colors.red},
  {'title': 'Tires & Wheels', 'icon': Icons.directions_car, 'color': Colors.orange},
  {'title': 'Engine & Battery', 'icon': FontAwesomeIcons.carBattery, 'color': Colors.green},
  {'title': 'AC & Heating', 'icon': Icons.ac_unit, 'color': Colors.cyan},
  {'title': 'Safety & Electrical', 'icon': Icons.electrical_services, 'color': Colors.purple},
  {'title': 'Cleaning & Detailing', 'icon': Icons.cleaning_services, 'color': Colors.brown},
];
