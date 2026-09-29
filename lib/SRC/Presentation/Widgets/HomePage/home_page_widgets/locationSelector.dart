import 'package:flutter/material.dart';

class LocationSelector extends StatefulWidget {
  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  String? selectedCity;

  final List<String> cities = [
    "Peshawar",
    "Islamabad",
    "Lahore",
    "Karachi",
    "Quetta",
    "Multan",
    "Faisalabad",
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Location icon
        Icon(Icons.location_on, color: Colors.blue, size: 20),

        // DropdownButton integrated into the Row
        DropdownButton<String>(
          value: selectedCity, // Currently selected value
          hint: Text("Peshawar",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500),), // Hint text when no city is selected
          onChanged: (String? newValue) {
            setState(() {
              selectedCity = newValue; // Update the selected city
            });
          },
          items: cities.map<DropdownMenuItem<String>>((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(city),
            );
          }).toList(),
          underline: Container(), // Remove the default underline
          icon: Icon(Icons.arrow_drop_down_outlined, color: Colors.blue, size: 25), // Custom dropdown icon
        ),
      ],
    );
  }
}

