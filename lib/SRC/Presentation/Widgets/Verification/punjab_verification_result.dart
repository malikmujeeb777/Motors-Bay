import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Services/punjab_verification_service.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class PunjabVerificationResult extends StatelessWidget {
  final PunjabVerificationData verificationData;
  final String numberPlate;
  final String chassisNumber;

  PunjabVerificationResult({
    Key? key,
    required this.verificationData,
    required this.numberPlate,
    required this.chassisNumber,
  }) : super(key: key) {
    // Log constructor data
    developer.log('PunjabVerificationResult initialized with:', name: 'Verification');
    developer.log('Number Plate: $numberPlate', name: 'Verification');
    developer.log('Chassis Number: $chassisNumber', name: 'Verification');
    developer.log('Verification Data:', name: 'Verification');
    developer.log('Owner: ${verificationData.owner?.toJson()}', name: 'Verification');
    developer.log('Payment: ${verificationData.payment?.toJson()}', name: 'Verification');
    developer.log('Vehicle: ${verificationData.vehicle?.toJson()}', name: 'Verification');
    developer.log('Tracking: ${verificationData.tracking?.toJson()}', name: 'Verification');
  }

  void _copyToClipboard(BuildContext context) {
    developer.log('Copying data to clipboard', name: 'Verification');
    final String data = '''
Vehicle Details:
Number Plate: $numberPlate
Chassis Number: $chassisNumber

Owner Details:
Name: ${verificationData.owner?.ownerName ?? 'Not Available'}
Father/Husband: ${verificationData.owner?.fatherHusbandName ?? 'Not Available'}
City: ${verificationData.owner?.ownerCity ?? 'Not Available'}

Payment Details:
Date: ${verificationData.payment?.date ?? 'Not Available'}
Amount: ${verificationData.payment?.amount ?? 'Not Available'}
Type: ${verificationData.payment?.paymentType ?? 'Not Available'}

Vehicle Information:
Engine: ${verificationData.vehicle?.engineNumber ?? 'Not Available'}
Make: ${verificationData.vehicle?.makeName ?? 'Not Available'}
Registration Date: ${verificationData.vehicle?.registrationDate ?? 'Not Available'}
Year: ${verificationData.vehicle?.yearOfManufacture ?? 'Not Available'}
Price: ${verificationData.vehicle?.vehiclePrice ?? 'Not Available'}
Color: ${verificationData.vehicle?.color ?? 'Not Available'}
Token: ${verificationData.vehicle?.token ?? 'Not Available'}

Application Status:
Type: ${verificationData.tracking?.applicationType ?? 'Not Available'}
Status: ${verificationData.tracking?.applicationStatus ?? 'Not Available'}
''';

    Clipboard.setData(ClipboardData(text: data));
    developer.log('Data copied to clipboard', name: 'Verification');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    developer.log('Building PunjabVerificationResult widget', name: 'Verification');
    developer.log('Verification Data:', name: 'Verification');
    developer.log('Owner: ${verificationData.owner?.toJson()}', name: 'Verification');
    developer.log('Payment: ${verificationData.payment?.toJson()}', name: 'Verification');
    developer.log('Vehicle: ${verificationData.vehicle?.toJson()}', name: 'Verification');
    developer.log('Tracking: ${verificationData.tracking?.toJson()}', name: 'Verification');
    
    // Debug print the entire verification data
    print('DEBUG: Full verification data: ${verificationData.toJson()}');
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: LightColorsPalate.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      numberPlate,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy, color: Colors.white),
                      onPressed: () => _copyToClipboard(context),
                      tooltip: 'Copy Details',
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'Owners Details',
                      icon: Icons.person,
                      items: [
                        {'label': 'Owner Name', 'value': verificationData.owner?.ownerName ?? 'Not Available'},
                        {'label': 'Father/Husband Name', 'value': verificationData.owner?.fatherHusbandName ?? 'Not Available'},
                        {'label': 'Owner City', 'value': verificationData.owner?.ownerCity ?? 'Not Available'},
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildSection(
                      title: 'Latest Payment Details',
                      icon: Icons.payment,
                      items: [
                        {'label': 'Date', 'value': verificationData.payment?.date ?? 'Not Available'},
                        {'label': 'Amount', 'value': verificationData.payment?.amount ?? 'Not Available'},
                        {'label': 'Payment Type', 'value': verificationData.payment?.paymentType ?? 'Not Available'},
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildSection(
                      title: 'Vehicle Details',
                      icon: Icons.directions_car,
                      items: [
                        {'label': 'Engine Number', 'value': verificationData.vehicle?.engineNumber ?? 'Not Available'},
                        {'label': 'Make Name', 'value': verificationData.vehicle?.makeName ?? 'Not Available'},
                        {'label': 'Registration Date', 'value': verificationData.vehicle?.registrationDate ?? 'Not Available'},
                        {'label': 'Year of Manufacture', 'value': verificationData.vehicle?.yearOfManufacture ?? 'Not Available'},
                        {'label': 'Vehicle Price', 'value': verificationData.vehicle?.vehiclePrice ?? 'Not Available'},
                        {'label': 'Color', 'value': verificationData.vehicle?.color ?? 'Not Available'},
                        {'label': 'Token', 'value': verificationData.vehicle?.token ?? 'Not Available'},
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildSection(
                      title: 'Vehicle Application Tracking',
                      icon: Icons.track_changes,
                      items: [
                        {'label': 'Application Type', 'value': verificationData.tracking?.applicationType ?? 'Not Available'},
                        {'label': 'Application Current Status', 'value': verificationData.tracking?.applicationStatus ?? 'Not Available'},
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
  }) {
    developer.log('Building section: $title', name: 'Verification');
    developer.log('Items for $title:', name: 'Verification');
    items.forEach((item) {
      developer.log('  ${item['label']}: ${item['value']}', name: 'Verification');
    });
    
    // Debug print the entire items list
    print('DEBUG: Section $title items: $items');
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightColorsPalate.outlineColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LightColorsPalate.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: LightColorsPalate.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LightColorsPalate.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              // Debug print before table construction
              print('DEBUG: Building table for $title with ${items.length} items');
              
              return Container(
                width: double.infinity,
                child: Table(
                  border: TableBorder.all(
                    color: LightColorsPalate.outlineColor,
                    width: 1,
                  ),
                  columnWidths: {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(2),
                  },
                  children: items.map((item) {
                    // Debug print each row
                    print('DEBUG: Building row - Label: ${item['label']}, Value: ${item['value']}');
                    
                    return TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            color: LightColorsPalate.surfaceColor,
                            child: Text(
                              item['label']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: LightColorsPalate.tertiaryColor,
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            child: Text(
                              item['value']!,
                              style: TextStyle(
                                fontSize: 14,
                                color: LightColorsPalate.onBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 