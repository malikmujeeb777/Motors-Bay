import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:motorsbay1/SRC/Domain/Models/obd_data_model.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

class OBDSampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _sampleRecordIds = [];

  // Get current user ID with error handling
  String? get _currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('OBDSampleDataService: No user is currently logged in');
      return null;
    }
    return user.uid;
  }

  // Add sample OBD data to Firebase
  Future<bool> addSampleData(String vehicleId) async {
    try {
      if (_currentUserId == null) {
        debugPrint('Cannot add sample data: No user logged in');
        return false;
      }

      // Create sample OBD records
      final records = _createSampleRecords(vehicleId);

      // Save records to Firebase
      for (final record in records) {
        await _firestore
            .collection('obd_data_records')
            .doc(record.id)
            .set(record.toMap());
        _sampleRecordIds.add(record.id);
      }

      debugPrint('Added ${records.length} sample OBD records to Firebase');
      return true;
    } catch (e) {
      debugPrint('Error adding sample OBD data: $e');
      return false;
    }
  }

  // Delete sample data from Firebase
  Future<bool> deleteSampleData() async {
    try {
      if (_sampleRecordIds.isEmpty) {
        debugPrint('No sample records to delete');
        return true;
      }

      // Delete each sample record
      for (final id in _sampleRecordIds) {
        await _firestore.collection('obd_data_records').doc(id).delete();
      }

      debugPrint(
          'Deleted ${_sampleRecordIds.length} sample OBD records from Firebase');
      _sampleRecordIds.clear();
      return true;
    } catch (e) {
      debugPrint('Error deleting sample OBD data: $e');
      return false;
    }
  }

  // Create sample OBD records
  List<OBDDataRecord> _createSampleRecords(String vehicleId) {
    final userId = _currentUserId!;
    final now = DateTime.now();
    final records = <OBDDataRecord>[];

    // Add a record for current time
    records.add(_createSampleRecord(
      userId: userId,
      vehicleId: vehicleId,
      timestamp: now,
      rpm: 1250,
      speed: 45,
      engineLoad: 35.5,
      coolantTemp: 87,
      fuelLevel: 72.5,
      dtcCodes: ['P0171', 'P0300'],
    ));

    // Add a record for 1 hour ago
    records.add(_createSampleRecord(
      userId: userId,
      vehicleId: vehicleId,
      timestamp: now.subtract(const Duration(hours: 1)),
      rpm: 2100,
      speed: 65,
      engineLoad: 45.2,
      coolantTemp: 92,
      fuelLevel: 75.0,
      dtcCodes: [],
    ));

    // Add a record for 1 day ago
    records.add(_createSampleRecord(
      userId: userId,
      vehicleId: vehicleId,
      timestamp: now.subtract(const Duration(days: 1)),
      rpm: 800,
      speed: 0,
      engineLoad: 12.5,
      coolantTemp: 65,
      fuelLevel: 82.3,
      dtcCodes: [],
    ));

    return records;
  }

  // Create a single sample OBD record
  OBDDataRecord _createSampleRecord({
    required String userId,
    required String vehicleId,
    required DateTime timestamp,
    required double rpm,
    required int speed,
    required double engineLoad,
    required int coolantTemp,
    required double fuelLevel,
    required List<String> dtcCodes,
  }) {
    return OBDDataRecord(
      id: const Uuid().v4(),
      userId: userId,
      vehicleId: vehicleId,
      timestamp: timestamp,
      diagnosticData: {
        'dtcCodes': dtcCodes,
        'timestamp': timestamp.toIso8601String(),
      },
      engineData: {
        'rpm': rpm,
        'speed': speed,
        'engineLoad': engineLoad,
        'coolantTemp': coolantTemp,
      },
      fuelData: {
        'fuelLevel': fuelLevel,
      },
      connectionType: 'bluetooth',
      deviceName: 'ELM327 OBD Scanner',
      deviceAddress: '00:11:22:33:44:55',
    );
  }
}

/// Class to provide sample OBD data for demo purposes
class OBDSampleData {
  /// Get a sample data map with OBD values
  static Map<String, String> getSampleData() {
    final random = Random();
    
    return {
      'RPM': (800 + random.nextInt(6000)).toString(),
      'SPEED': (random.nextInt(120)).toString(),
      'ENGINE_TEMP': (80 + random.nextInt(40)).toString(),
      'FUEL_LEVEL': (10 + random.nextInt(90)).toString(),
      'INTAKE_TEMP': (30 + random.nextInt(40)).toString(),
      'THROTTLE_POS': (random.nextInt(100)).toString(),
      'ENGINE_LOAD': (random.nextInt(100)).toString(),
      'MAF': (10 + random.nextInt(90)).toString(),
      'FUEL_PRESSURE': (30 + random.nextInt(70)).toString(),
      'INTAKE_PRESSURE': (random.nextInt(100)).toString(),
      'TIMING_ADVANCE': (random.nextInt(40)).toString(),
      'AMBIENT_TEMP': (15 + random.nextInt(25)).toString(),
      'OXYGEN_SENSOR': ((random.nextDouble() * 5).toStringAsFixed(2)),
      'RUNTIME': (random.nextInt(3600)).toString(),
      'DISTANCE_MIL': (random.nextInt(1000)).toString(),
      'FUEL_RAIL_PRESSURE': (2000 + random.nextInt(2000)).toString(),
      'BAROMETRIC_PRESSURE': (95 + random.nextInt(10)).toString(),
      'CONTROL_MODULE_VOLTAGE': ((12 + random.nextDouble() * 2).toStringAsFixed(1)),
      'RELATIVE_THROTTLE_POS': (random.nextInt(100)).toString(),
      'AMBIENT_AIR_TEMP': (15 + random.nextInt(25)).toString(),
      'FUEL_TYPE': 'Gasoline',
      'ENGINE_OIL_TEMP': (80 + random.nextInt(60)).toString(),
      'FUEL_CONSUMPTION': ((5 + random.nextDouble() * 10).toStringAsFixed(1)),
    };
  }
  
  /// Get a list of OBDII diagnostic trouble codes (DTCs) as samples
  static List<String> getSampleDTCs() {
    final dtcs = [
      'P0100: Mass or Volume Air Flow Circuit Malfunction',
      'P0101: Mass or Volume Air Flow Circuit Range/Performance Problem',
      'P0102: Mass or Volume Air Flow Circuit Low Input',
      'P0103: Mass or Volume Air Flow Circuit High Input',
      'P0104: Mass or Volume Air Flow Circuit Intermittent',
      'P0105: Manifold Absolute Pressure/Barometric Pressure Circuit Malfunction',
      'P0106: Manifold Absolute Pressure/Barometric Pressure Circuit Range/Performance Problem',
      'P0107: Manifold Absolute Pressure/Barometric Pressure Circuit Low Input',
      'P0108: Manifold Absolute Pressure/Barometric Pressure Circuit High Input',
      'P0109: Manifold Absolute Pressure/Barometric Pressure Circuit Intermittent',
      'P0110: Intake Air Temperature Circuit Malfunction',
      'P0111: Intake Air Temperature Circuit Range/Performance Problem',
      'P0112: Intake Air Temperature Circuit Low Input',
      'P0113: Intake Air Temperature Circuit High Input',
      'P0114: Intake Air Temperature Circuit Intermittent',
      'P0115: Engine Coolant Temperature Circuit Malfunction',
      'P0116: Engine Coolant Temperature Circuit Range/Performance Problem',
      'P0117: Engine Coolant Temperature Circuit Low Input',
      'P0118: Engine Coolant Temperature Circuit High Input',
      'P0119: Engine Coolant Temperature Circuit Intermittent',
      'P0120: Throttle/Pedal Position Sensor/Switch A Circuit Malfunction',
      'P0121: Throttle/Pedal Position Sensor/Switch A Circuit Range/Performance Problem',
      'P0122: Throttle/Pedal Position Sensor/Switch A Circuit Low Input',
      'P0123: Throttle/Pedal Position Sensor/Switch A Circuit High Input',
    ];
    
    // Return a random subset of DTCs
    final random = Random();
    final numberOfCodes = random.nextInt(3); // 0 to 2 codes
    
    if (numberOfCodes == 0) {
      return [];
    }
    
    final selectedIndices = <int>{};
    while (selectedIndices.length < numberOfCodes) {
      selectedIndices.add(random.nextInt(dtcs.length));
    }
    
    return selectedIndices.map((index) => dtcs[index]).toList();
  }
}
