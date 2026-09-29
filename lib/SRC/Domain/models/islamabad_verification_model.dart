class IslamabadVerificationResponse {
  final String status;
  final IslamabadVerificationData? data;
  final String? text;

  IslamabadVerificationResponse({
    required this.status,
    this.data,
    this.text,
  });

  factory IslamabadVerificationResponse.fromJson(Map<String, dynamic> json) {
    return IslamabadVerificationResponse(
      status: json['status'] ?? '',
      data: json['data'] != null ? IslamabadVerificationData.fromJson(json['data']) : null,
      text: json['text'],
    );
  }
}

class IslamabadVerificationData {
  final String? regNo;
  final String? regDate;
  final String? chassisNo;
  final String? engineNo;
  final String? bodyType;
  final String? makerMake;
  final String? color;
  final String? engineSize;
  final String? purchaseDate;
  final String? vehicleValue;
  final String? yearOfManufacture;
  final String? purchaseType;
  final String? ownerName;
  final String? taxPaidUpto;
  final String? status;
  final String textOutput;
  final Map<String, String> parsedData;

  IslamabadVerificationData({
    this.regNo,
    this.regDate,
    this.chassisNo,
    this.engineNo,
    this.bodyType,
    this.makerMake,
    this.color,
    this.engineSize,
    this.purchaseDate,
    this.vehicleValue,
    this.yearOfManufacture,
    this.purchaseType,
    this.ownerName,
    this.taxPaidUpto,
    this.status,
    required this.textOutput,
  }) : parsedData = _parseTextOutput(textOutput);

  factory IslamabadVerificationData.fromJson(Map<String, dynamic> json) {
    final textOutput = json['textOutput'] ?? '';
    final parsedData = _parseTextOutput(textOutput);
    
    return IslamabadVerificationData(
      regNo: parsedData['REGISTRATION NO'] ?? json['regNo'],
      regDate: parsedData['REGISTRATION DATE'] ?? json['regDate'],
      chassisNo: parsedData['CHASSIS NO'] ?? json['chassisNo'],
      engineNo: parsedData['ENGINE NO'] ?? json['engineNo'],
      bodyType: parsedData['BODYTYPE'] ?? json['bodyType'],
      makerMake: parsedData['MAKER-MAKE'] ?? json['makerMake'],
      color: parsedData['COLOR'] ?? json['color'],
      engineSize: parsedData['ENGINE SIZE'] ?? json['engineSize'],
      purchaseDate: parsedData['PURCHASE DATE'] ?? json['purchaseDate'],
      vehicleValue: parsedData['VEHICLE VALUE'] ?? json['vehicleValue'],
      yearOfManufacture: parsedData['YEAR OF MANUFACTURE'] ?? json['yearOfManufacture'],
      purchaseType: parsedData['PURCHASE TYPE'] ?? json['purchaseType'],
      ownerName: parsedData['OWNER NAME'] ?? json['ownerName'],
      taxPaidUpto: parsedData['TAX PAID UPTO'] ?? json['taxPaidUpto'],
      status: parsedData['VEHICLE STATUS'] ?? json['status'],
      textOutput: textOutput,
    );
  }

  static Map<String, String> _parseTextOutput(String textOutput) {
    final Map<String, String> result = {};
    final lines = textOutput.split('\n');
    
    for (var line in lines) {
      if (line.trim().isEmpty) continue;
      
      final parts = line.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        result[key] = value;
      }
    }
    
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'regNo': regNo,
      'regDate': regDate,
      'chassisNo': chassisNo,
      'engineNo': engineNo,
      'bodyType': bodyType,
      'makerMake': makerMake,
      'color': color,
      'engineSize': engineSize,
      'purchaseDate': purchaseDate,
      'vehicleValue': vehicleValue,
      'yearOfManufacture': yearOfManufacture,
      'purchaseType': purchaseType,
      'ownerName': ownerName,
      'taxPaidUpto': taxPaidUpto,
      'status': status,
      'textOutput': textOutput,
    };
  }
} 