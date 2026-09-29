import 'package:cloud_firestore/cloud_firestore.dart';

class OBDDataRecord {
  final String id;
  final String userId;
  final String vehicleId;
  final DateTime timestamp;
  final Map<String, dynamic> diagnosticData;
  final Map<String, dynamic>? engineData;
  final Map<String, dynamic>? fuelData;
  final String? connectionType;
  final String? deviceName;
  final String? deviceAddress;

  OBDDataRecord({
    required this.id,
    required this.userId,
    required this.vehicleId,
    required this.timestamp,
    required this.diagnosticData,
    this.engineData,
    this.fuelData,
    this.connectionType,
    this.deviceName,
    this.deviceAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'vehicleId': vehicleId,
      'timestamp': Timestamp.fromDate(timestamp),
      'diagnosticData': diagnosticData,
      'engineData': engineData,
      'fuelData': fuelData,
      'connectionType': connectionType,
      'deviceName': deviceName,
      'deviceAddress': deviceAddress,
    };
  }

  factory OBDDataRecord.fromMap(Map<String, dynamic> map) {
    return OBDDataRecord(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      diagnosticData: map['diagnosticData'] ?? {},
      engineData: map['engineData'],
      fuelData: map['fuelData'],
      connectionType: map['connectionType'],
      deviceName: map['deviceName'],
      deviceAddress: map['deviceAddress'],
    );
  }
}
