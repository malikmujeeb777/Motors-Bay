import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/details_page.dart';
import 'package:motorsbay1/exports.dart';

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
class CarServicesScreen extends StatelessWidget {


  List<Map<String, bool>> selectedServices = [
  {
  "Oil Change ": false,
  "Air Filter Replacement ": false,
  "Fuel Filter Replacement": false,
  "Cabin Air Filter Replacement.": false,
},
    {
      "Coolant Flush": false,
      "Brake Fluid Change": false,
      "Transmission Fluid Change": false,
      "Power Steering Fluid Change": false,
      "Windshield Washer Fluid Refill": false
    },
    {
    "Brake Pads & Rotor Replacement": false,
    "Suspension & Shock Absorber Inspection": false,
    "Wheel Alignment & Balancing": false,
    },
    {
    "Tire Rotation": false,
    "Tire Replacement": false,
    "Wheel Balancing": false,
    },{
    "Battery Check & Replacement": false,
    "Spark Plug Replacement": false,
    "Timing Belt or Chain Replacement": false,
    "Engine Diagnostics (Check Engine Light)": false,
    },{
    "AC Gas Refill & Maintenance": false,
    "Heater Core Check": false,
    },{
"Headlights, Brake Lights & Indicator Bulb Replacement": false,
"Wiper Blade Replacement": false,
"Horn & Electrical System Inspection": false,
},{
      "Car Wash & Wax": false,
      "Interior Cleaning": false,
      "Rust Protection Treatment": false
    }


  ];

   CarServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return FadeInUp(
              duration: Duration(milliseconds: 400 + (index * 100)),
              child: InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ServiceDetailPage(selectedServices: selectedServices[index],index: index,)));
                },
                child: ServiceCard(
                  title: service['title'],
                  icon: service['icon'],
                  color: service['color'],
                ),
              )
          );
        },
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
          SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
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
