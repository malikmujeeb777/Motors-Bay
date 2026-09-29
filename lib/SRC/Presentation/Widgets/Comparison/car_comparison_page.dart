import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Presentation/Common/common_button.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Comparison/dual_model_viewer_page.dart';

class CarComparisonPage extends StatefulWidget {
  final Map<String, String> car1;
  final Map<String, String> car2;

  const CarComparisonPage({
    Key? key,
    required this.car1,
    required this.car2,
  }) : super(key: key);

  @override
  State<CarComparisonPage> createState() => _CarComparisonPageState();
}

class _CarComparisonPageState extends State<CarComparisonPage> {
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
            // Header
            _buildHeader(),
            const SizedBox(height: 24),

            // 3D Model Comparison Button
            _build3DModelButton(),
            const SizedBox(height: 24),

            // Comparison Table
            _buildComparisonTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: _buildCarHeader(
                make: widget.car1['make']!,
                model: widget.car1['model']!,
                isFirst: true,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'VS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: _buildCarHeader(
                make: widget.car2['make']!,
                model: widget.car2['model']!,
                isFirst: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarHeader({
    required String make,
    required String model,
    required bool isFirst,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isFirst ? Colors.blue.shade100 : Colors.red.shade100,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.directions_car,
            size: 40,
            color: isFirst ? Colors.blue : Colors.red,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          make,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          model,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _build3DModelButton() {
    return SizedBox(
      width: double.infinity,
      child: CommonButton(
        onTap: _navigateTo3DComparison,
        text: 'Compare 3D Models',
        backgroundColor: Theme.of(context).colorScheme.secondary,
        textColor: Colors.white,
        height: 56,
        borderRadius: 12,
        leadingIcon: Icons.view_in_ar,
      ),
    );
  }

  Widget _buildComparisonTable() {
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
            const Text(
              'Detailed Comparison',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonTableContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTableContent() {
    final comparisonData = _getComparisonData();

    return Column(
      children: comparisonData.map((section) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section['title'],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            ...section['items'].map<Widget>((item) {
              return _buildComparisonRow(
                feature: item['feature'],
                value1: item['value1'],
                value2: item['value2'],
                isBetter: item['isBetter'],
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildComparisonRow({
    required String feature,
    required String value1,
    required String value2,
    required int? isBetter, // 1 for car1 better, 2 for car2 better, null for equal
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isBetter == 1 ? Colors.green.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isBetter == 1 
                    ? Border.all(color: Colors.green) 
                    : null,
              ),
              child: Text(
                value1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isBetter == 1 ? FontWeight.bold : FontWeight.normal,
                  color: isBetter == 1 ? Colors.green.shade700 : null,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isBetter == 2 ? Colors.green.shade100 : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isBetter == 2 
                    ? Border.all(color: Colors.green) 
                    : null,
              ),
              child: Text(
                value2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isBetter == 2 ? FontWeight.bold : FontWeight.normal,
                  color: isBetter == 2 ? Colors.green.shade700 : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getComparisonData() {
    // Sample comparison data - in a real app, this would come from a database
    return [
      {
        'title': 'Performance',
        'items': [
          {
            'feature': 'Engine Power',
            'value1': '180 HP',
            'value2': '158 HP',
            'isBetter': 1,
          },
          {
            'feature': 'Torque',
            'value1': '240 Nm',
            'value2': '187 Nm',
            'isBetter': 1,
          },
          {
            'feature': '0-100 km/h',
            'value1': '8.2s',
            'value2': '9.1s',
            'isBetter': 1,
          },
        ],
      },
      {
        'title': 'Fuel Economy',
        'items': [
          {
            'feature': 'City (L/100km)',
            'value1': '8.5',
            'value2': '7.2',
            'isBetter': 2,
          },
          {
            'feature': 'Highway (L/100km)',
            'value1': '6.1',
            'value2': '5.8',
            'isBetter': 2,
          },
          {
            'feature': 'Combined (L/100km)',
            'value1': '7.2',
            'value2': '6.4',
            'isBetter': 2,
          },
        ],
      },
      {
        'title': 'Dimensions',
        'items': [
          {
            'feature': 'Length (mm)',
            'value1': '4630',
            'value2': '4674',
            'isBetter': 2,
          },
          {
            'feature': 'Width (mm)',
            'value1': '1780',
            'value2': '1802',
            'isBetter': 2,
          },
          {
            'feature': 'Height (mm)',
            'value1': '1435',
            'value2': '1415',
            'isBetter': 1,
          },
          {
            'feature': 'Wheelbase (mm)',
            'value1': '2700',
            'value2': '2735',
            'isBetter': 2,
          },
        ],
      },
      {
        'title': 'Features',
        'items': [
          {
            'feature': 'Safety Rating',
            'value1': '5 Stars',
            'value2': '5 Stars',
            'isBetter': null,
          },
          {
            'feature': 'Airbags',
            'value1': '7',
            'value2': '6',
            'isBetter': 1,
          },
          {
            'feature': 'Infotainment',
            'value1': '8" Touchscreen',
            'value2': '7" Touchscreen',
            'isBetter': 1,
          },
        ],
      },
    ];
  }

  void _navigateTo3DComparison() {
    Get.to(() => DualModelViewerPage(
      car1: widget.car1,
      car2: widget.car2,
    ));
  }
} 