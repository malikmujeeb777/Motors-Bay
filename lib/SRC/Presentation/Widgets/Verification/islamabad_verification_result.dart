import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:motorsbay1/SRC/Domain/Models/islamabad_verification_model.dart';

class IslamabadVerificationResult extends StatelessWidget {
  final IslamabadVerificationData verificationData;
  final String numberPlate;
  final DateTime registrationDate;

  const IslamabadVerificationResult({
    Key? key,
    required this.verificationData,
    required this.numberPlate,
    required this.registrationDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.8, // Set height to 80% of screen height
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: verificationData.textOutput,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                tooltip: 'Copy to clipboard',
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded( // Make the container take remaining space
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: _buildInfoTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTable() {
    final fields = [
      'REGISTRATION NO',
      'REGISTRATION DATE',
      'CHASSIS NO',
      'ENGINE NO',
      'BODYTYPE',
      'MAKER-MAKE',
      'COLOR',
      'ENGINE SIZE',
      'PURCHASE DATE',
      'VEHICLE VALUE',
      'YEAR OF MANUFACTURE',
      'PURCHASE TYPE',
      'OWNER NAME',
      'TAX PAID UPTO',
      'VEHICLE STATUS',
    ];

    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      border: TableBorder.all(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      children: fields.map((field) {
        String value = 'N/A';
        
        switch (field) {
          case 'REGISTRATION NO':
            value = numberPlate;
            break;
          case 'REGISTRATION DATE':
            value = verificationData.regDate ?? 'N/A';
            break;
          case 'CHASSIS NO':
            value = verificationData.chassisNo ?? 'N/A';
            break;
          case 'ENGINE NO':
            value = verificationData.engineNo ?? 'N/A';
            break;
          case 'BODYTYPE':
            value = verificationData.bodyType ?? 'N/A';
            break;
          case 'MAKER-MAKE':
            value = verificationData.makerMake ?? 'N/A';
            break;
          case 'COLOR':
            value = verificationData.color ?? 'N/A';
            break;
          case 'ENGINE SIZE':
            value = verificationData.engineSize ?? 'N/A';
            break;
          case 'PURCHASE DATE':
            value = verificationData.purchaseDate ?? 'N/A';
            break;
          case 'VEHICLE VALUE':
            value = verificationData.vehicleValue ?? 'N/A';
            break;
          case 'YEAR OF MANUFACTURE':
            value = verificationData.yearOfManufacture ?? 'N/A';
            break;
          case 'PURCHASE TYPE':
            value = verificationData.purchaseType ?? 'N/A';
            break;
          case 'OWNER NAME':
            value = verificationData.ownerName ?? 'N/A';
            break;
          case 'TAX PAID UPTO':
            value = verificationData.taxPaidUpto ?? 'N/A';
            break;
          case 'VEHICLE STATUS':
            value = verificationData.status ?? 'N/A';
            break;
        }

        return TableRow(
          decoration: BoxDecoration(
            color: fields.indexOf(field) % 2 == 0 
                ? Colors.grey.shade50 
                : Colors.white,
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                field,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(value),
            ),
          ],
        );
      }).toList(),
    );
  }
} 