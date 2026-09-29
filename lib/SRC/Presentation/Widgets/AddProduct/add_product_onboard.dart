import 'package:flutter/material.dart';
import 'package:motorsbay1/exports.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/create_post_page.dart';

class AddProductOnboard extends StatefulWidget {
  const AddProductOnboard({super.key});

  @override
  State<AddProductOnboard> createState() => _AddProductOnboardState();
}

class _AddProductOnboardState extends State<AddProductOnboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            40.y,
            AppText(
              "What would you like to create?", 
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            60.y,
            _buildOptionCard(
              title: "Car Listing", 
              description: "Sell or advertise your vehicle with details and photos",
              icon: Icons.directions_car_rounded,
              backgroundColor: Color(0xFF1976D2),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddCar()));
              },
            ),
            20.y,
            _buildOptionCard(
              title: "Social Post",
              description: "Share your thoughts, photos and connect with community",
              icon: Icons.people_alt_rounded,
              backgroundColor: Color(0xFF4CAF50),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CreatePostPage()));
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundColor,
              backgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 30,
                color: Colors.white,
              ),
            ),
            20.x,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  8.y,
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
