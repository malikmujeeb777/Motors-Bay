import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class PunjabVerificationResponse {
  final String status;
  final String? text;
  final PunjabVerificationData? data;

  PunjabVerificationResponse({
    required this.status,
    this.text,
    this.data,
  });

  factory PunjabVerificationResponse.fromJson(Map<String, dynamic> json) {
    return PunjabVerificationResponse(
      status: json['status'] ?? 'error',
      text: json['text'],
      data: json['data'] != null ? PunjabVerificationData.fromJson(json['data']) : null,
    );
  }
}

class PunjabVerificationData {
  final PunjabOwnerData? owner;
  final PunjabPaymentData? payment;
  final PunjabVehicleData? vehicle;
  final PunjabTrackingData? tracking;
  final String? textOutput;

  PunjabVerificationData({
    this.owner,
    this.payment,
    this.vehicle,
    this.tracking,
    this.textOutput,
  });

  factory PunjabVerificationData.fromJson(Map<String, dynamic> json) {
    return PunjabVerificationData(
      owner: json['owner'] != null ? PunjabOwnerData.fromJson(json['owner']) : null,
      payment: json['payment'] != null ? PunjabPaymentData.fromJson(json['payment']) : null,
      vehicle: json['vehicle'] != null ? PunjabVehicleData.fromJson(json['vehicle']) : null,
      tracking: json['tracking'] != null ? PunjabTrackingData.fromJson(json['tracking']) : null,
      textOutput: json['textOutput'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner': owner?.toJson(),
      'payment': payment?.toJson(),
      'vehicle': vehicle?.toJson(),
      'tracking': tracking?.toJson(),
      'textOutput': textOutput,
    };
  }
}

class PunjabOwnerData {
  final String? ownerName;
  final String? fatherHusbandName;
  final String? ownerCity;

  PunjabOwnerData({
    this.ownerName,
    this.fatherHusbandName,
    this.ownerCity,
  });

  factory PunjabOwnerData.fromJson(Map<String, dynamic> json) {
    return PunjabOwnerData(
      ownerName: json['ownerName'],
      fatherHusbandName: json['fatherHusbandName'],
      ownerCity: json['ownerCity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerName': ownerName,
      'fatherHusbandName': fatherHusbandName,
      'ownerCity': ownerCity,
    };
  }
}

class PunjabPaymentData {
  final String? date;
  final String? amount;
  final String? paymentType;

  PunjabPaymentData({
    this.date,
    this.amount,
    this.paymentType,
  });

  factory PunjabPaymentData.fromJson(Map<String, dynamic> json) {
    return PunjabPaymentData(
      date: json['date'],
      amount: json['amount'],
      paymentType: json['paymentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'amount': amount,
      'paymentType': paymentType,
    };
  }
}

class PunjabVehicleData {
  final String? registrationNumber;
  final String? engineNumber;
  final String? makeName;
  final String? registrationDate;
  final String? yearOfManufacture;
  final String? vehiclePrice;
  final String? color;
  final String? token;

  PunjabVehicleData({
    this.registrationNumber,
    this.engineNumber,
    this.makeName,
    this.registrationDate,
    this.yearOfManufacture,
    this.vehiclePrice,
    this.color,
    this.token,
  });

  factory PunjabVehicleData.fromJson(Map<String, dynamic> json) {
    return PunjabVehicleData(
      registrationNumber: json['registrationNumber'],
      engineNumber: json['engineNumber'],
      makeName: json['makeName'],
      registrationDate: json['registrationDate'],
      yearOfManufacture: json['yearOfManufacture'],
      vehiclePrice: json['vehiclePrice'],
      color: json['color'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registrationNumber': registrationNumber,
      'engineNumber': engineNumber,
      'makeName': makeName,
      'registrationDate': registrationDate,
      'yearOfManufacture': yearOfManufacture,
      'vehiclePrice': vehiclePrice,
      'color': color,
      'token': token,
    };
  }
}

class PunjabTrackingData {
  final String? applicationType;
  final String? applicationStatus;

  PunjabTrackingData({
    this.applicationType,
    this.applicationStatus,
  });

  factory PunjabTrackingData.fromJson(Map<String, dynamic> json) {
    return PunjabTrackingData(
      applicationType: json['applicationType'],
      applicationStatus: json['applicationStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'applicationType': applicationType,
      'applicationStatus': applicationStatus,
    };
  }
}

class PunjabVerificationService {
  Future<PunjabVerificationResponse> verifyVehicle({
    required String numberPlate,
    required String chassisNumber,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.18.52:3000/api/verify/punjabv?numberPlate=$numberPlate&chassisNumber=$chassisNumber'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        
        // Parse HTML to extract data
        if (jsonResponse['html'] != null) {
          final document = parser.parse(jsonResponse['html']);
          
          // Get all elements with class sec2-data
          final allElements = document.querySelectorAll('.sec2-data');
          
          // Extract data using array indices since we know the order
          // Owner Details
          final ownerName = allElements[0]?.text.trim() ?? 'Not Available';
          final fatherHusbandName = allElements[1]?.text.trim() ?? 'Not Available';
          final ownerCity = allElements[2]?.text.trim() ?? 'Not Available';

          // Payment Details
          final paymentDate = allElements[3]?.text.trim() ?? 'Not Available';
          final paymentAmount = allElements[4]?.text.trim() ?? 'Not Available';
          final paymentType = allElements[5]?.text.trim() ?? 'Not Available';

          // Vehicle Details
          final engineNumber = allElements[6]?.text.trim() ?? 'Not Available';
          final makeName = allElements[7]?.text.trim() ?? 'Not Available';
          final registrationDate = allElements[8]?.text.trim() ?? 'Not Available';
          final yearOfManufacture = allElements[9]?.text.trim() ?? 'Not Available';
          final vehiclePrice = allElements[10]?.text.trim() ?? 'Not Available';
          final color = allElements[11]?.text.trim() ?? 'Not Available';
          final token = allElements[12]?.text.trim() ?? 'Not Available';

          // Application Tracking
          final applicationType = allElements[13]?.text.trim() ?? 'Not Available';
          final applicationStatus = allElements[14]?.text.trim() ?? 'Not Available';

          // Debug print extracted values
          print('\n=== EXTRACTED VALUES ===\n');
          print('Owner Details:');
          print('  Name: $ownerName');
          print('  Father/Husband: $fatherHusbandName');
          print('  City: $ownerCity\n');
          
          print('Payment Details:');
          print('  Date: $paymentDate');
          print('  Amount: $paymentAmount');
          print('  Type: $paymentType\n');
          
          print('Vehicle Details:');
          print('  Engine: $engineNumber');
          print('  Make: $makeName');
          print('  Reg Date: $registrationDate');
          print('  Year: $yearOfManufacture');
          print('  Price: $vehiclePrice');
          print('  Color: $color');
          print('  Token: $token\n');
          
          print('Application Tracking:');
          print('  Type: $applicationType');
          print('  Status: $applicationStatus');
          print('========================\n');

          // Update the data object with parsed values
          jsonResponse['data'] = {
            'owner': {
              'ownerName': ownerName,
              'fatherHusbandName': fatherHusbandName,
              'ownerCity': ownerCity,
            },
            'payment': {
              'date': paymentDate,
              'amount': paymentAmount,
              'paymentType': paymentType,
            },
            'vehicle': {
              'registrationNumber': numberPlate,
              'engineNumber': engineNumber,
              'makeName': makeName,
              'registrationDate': registrationDate,
              'yearOfManufacture': yearOfManufacture,
              'vehiclePrice': vehiclePrice,
              'color': color,
              'token': token,
            },
            'tracking': {
              'applicationType': applicationType,
              'applicationStatus': applicationStatus,
            },
            'textOutput': jsonResponse['data']?['textOutput'] ?? '',
          };
        }

        return PunjabVerificationResponse.fromJson(jsonResponse);
      } else {
        return PunjabVerificationResponse(
          status: 'error',
          text: 'Failed to verify vehicle. Please try again.',
        );
      }
    } catch (e) {
      print('Error in verifyVehicle: $e');
      return PunjabVerificationResponse(
        status: 'error',
        text: 'Error: ${e.toString()}',
      );
    }
  }
} 