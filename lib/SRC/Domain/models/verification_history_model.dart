import 'package:cloud_firestore/cloud_firestore.dart';

class VerificationHistory {
  final String id;
  final String userId;
  final String numberPlate;
  final String province;
  final DateTime registrationDate;
  final DateTime timestamp;
  final Map<String, dynamic> verificationData;

  VerificationHistory({
    required this.id,
    required this.userId,
    required this.numberPlate,
    required this.province,
    required this.registrationDate,
    required this.timestamp,
    required this.verificationData,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'numberPlate': numberPlate,
      'province': province,
      'registrationDate': registrationDate.toIso8601String(),
      'timestamp': Timestamp.fromDate(timestamp),
      'verificationData': verificationData,
    };
  }

  factory VerificationHistory.fromMap(Map<String, dynamic> map) {
    return VerificationHistory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      numberPlate: map['numberPlate'] ?? '',
      province: map['province'] ?? '',
      registrationDate: DateTime.parse(map['registrationDate']),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      verificationData: Map<String, dynamic>.from(map['verificationData'] ?? {}),
    );
  }
} 