import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Login/login_on_board.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome to MotorsBay",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),
          const Text(
            "Select your login type",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          _buildLoginOption(
            context,
            title: "Buyer",
            icon: Icons.shopping_cart,
            color: Colors.blue,
            onTap: () => _navigateToLogin(context, "Buyer"),
          ),
          _buildLoginOption(
            context,
            title: "Seller",
            icon: Icons.store,
            color: Colors.green,
            onTap: () => _navigateToLogin(context, "Seller"),
          ),
          _buildLoginOption(
            context,
            title: "Service Provider",
            icon: Icons.handyman,
            color: Colors.orange,
            onTap: () => _navigateToLogin(context, "Service Provider"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginOption(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin(BuildContext context, String userType) {
    if(userType == "Buyer") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginOnBoard()));
    }
    if(userType == "Seller") {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginOnBoard()));
    }
    if(userType == "Service Provider") {
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginOnBoard()));
    }

  }
}
