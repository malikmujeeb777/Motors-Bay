import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Presentation/Common/common_button.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Comparison/car_comparison_page.dart';

class CarComparisonSelection extends StatefulWidget {
  const CarComparisonSelection({Key? key}) : super(key: key);

  @override
  State<CarComparisonSelection> createState() => _CarComparisonSelectionState();
}

class _CarComparisonSelectionState extends State<CarComparisonSelection> {
  String? selectedMake1;
  String? selectedModel1;
  String? selectedMake2;
  String? selectedModel2;

  // Car brands and models data
  final Map<String, List<String>> brandModelMap = {
    'Toyota': ['Corolla', 'Camry', 'Yaris', 'Fortuner', 'Hilux', 'Prius', 'Land Cruiser', 'Prado'],
    'Honda': ['Civic', 'City', 'BR-V', 'Vezel', 'Accord', 'HR-V', 'CR-V'],
    'Suzuki': ['Mehran', 'Alto', 'Cultus', 'Swift', 'Wagon R', 'Bolan', 'Every', 'Jimny', 'Vitara'],
    'Hyundai': ['Tucson', 'Elantra', 'Sonata', 'Santa Fe', 'Porter', 'Shehzore'],
    'Kia': ['Sportage', 'Picanto', 'Grand Carnival', 'Sorento', 'Stonic', 'Stinger'],
    'BMW': ['X1', 'X3', 'X5', '3 Series', '5 Series', '7 Series'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE'],
    'Audi': ['A3', 'A4', 'A6', 'Q7', 'Q5', 'Q3', 'e-tron'],
  };

  final List<String> brands = [
    'Toyota', 'Honda', 'Suzuki', 'Hyundai', 'Kia', 
    'BMW', 'Mercedes-Benz', 'Audi'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Comparison'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Two Cars to Compare',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the make and model for each car you want to compare',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // First Car Selection
            _buildCarSelectionCard(
              title: 'First Car',
              selectedMake: selectedMake1,
              selectedModel: selectedModel1,
              onMakeChanged: (make) {
                setState(() {
                  selectedMake1 = make;
                  selectedModel1 = null; // Reset model when make changes
                });
              },
              onModelChanged: (model) {
                setState(() {
                  selectedModel1 = model;
                });
              },
            ),

            const SizedBox(height: 24),

            // Second Car Selection
            _buildCarSelectionCard(
              title: 'Second Car',
              selectedMake: selectedMake2,
              selectedModel: selectedModel2,
              onMakeChanged: (make) {
                setState(() {
                  selectedMake2 = make;
                  selectedModel2 = null; // Reset model when make changes
                });
              },
              onModelChanged: (model) {
                setState(() {
                  selectedModel2 = model;
                });
              },
            ),

            const SizedBox(height: 32),

            // Compare Button
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                onTap: _canCompare() ? _navigateToComparison : null,
                text: 'Compare Cars',
                backgroundColor: _canCompare() 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey,
                textColor: Colors.white,
                height: 56,
                borderRadius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarSelectionCard({
    required String title,
    required String? selectedMake,
    required String? selectedModel,
    required Function(String?) onMakeChanged,
    required Function(String?) onModelChanged,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Make Dropdown
            _buildDropdown(
              label: 'Make',
              value: selectedMake,
              items: brands,
              onChanged: onMakeChanged,
            ),

            const SizedBox(height: 16),

            // Model Dropdown
            if (selectedMake != null)
              _buildDropdown(
                label: 'Model',
                value: selectedModel,
                items: brandModelMap[selectedMake] ?? [],
                onChanged: onModelChanged,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Select $label'),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  bool _canCompare() {
    return selectedMake1 != null && 
           selectedModel1 != null && 
           selectedMake2 != null && 
           selectedModel2 != null;
  }

  void _navigateToComparison() {
    if (_canCompare()) {
      Get.to(() => CarComparisonPage(
        car1: {
          'make': selectedMake1!,
          'model': selectedModel1!,
        },
        car2: {
          'make': selectedMake2!,
          'model': selectedModel2!,
        },
      ));
    }
  }
} 