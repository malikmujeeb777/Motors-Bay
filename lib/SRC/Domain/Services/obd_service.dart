import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:motorsbay1/SRC/Domain/Services/obd_sample_data.dart';

// Temporary class to simulate BluetoothDevice while the actual plugin is commented out
class BluetoothDevice {
  final String address;
  final String? name;
  BluetoothDevice(this.address, this.name);
}

// Temporary class to simulate BluetoothConnection
class BluetoothConnection {
  static Future<BluetoothConnection> toAddress(String address) async {
    return BluetoothConnection();
  }
  
  BluetoothStream? input;
  BluetoothStream? output;
  
  Future<void> close() async {}
}

// Temporary class to simulate Bluetooth streams
class BluetoothStream {
  void listen(void Function(Uint8List) onData, {Function? onDone, Function? onError}) {}
  void add(Uint8List data) {}
  Future<void> get allSent async {}
}

// Temporary class to simulate FlutterBluetoothSerial
class FlutterBluetoothSerialStub {
  static final FlutterBluetoothSerialStub instance = FlutterBluetoothSerialStub();
  Future<bool?> get isEnabled async => true;
  Future<bool?> requestEnable() async => true;
}

class OBDService {
  // Use the stub implementation
  final FlutterBluetoothSerialStub _bluetooth = FlutterBluetoothSerialStub.instance;
  BluetoothConnection? _connection;
  final StreamController<Map<String, String>> _dataStreamController = StreamController<Map<String, String>>.broadcast();
  
  Stream<Map<String, String>> get dataStream => _dataStreamController.stream;
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  
  // Initialize the OBD service
  Future<void> init() async {
    debugPrint('OBD Service initialized (SIMULATION MODE)');
    // No actual Bluetooth operations in simulation mode
  }
  
  // Connect to the OBD device
  Future<bool> connectToDevice(BluetoothDevice device) async {
    debugPrint('Simulating connection to ${device.name ?? "Unknown Device"} at ${device.address}');
    _isConnected = true;
    return true;
  }
  
  // Disconnect from the OBD device
  Future<void> disconnectDevice() async {
    await stopDataMonitoring();
    _isConnected = false;
    debugPrint('Device disconnected (simulation)');
  }
  
  // Send a command to the OBD device
  Future<void> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception('Not connected to OBD device');
    }
    
    debugPrint('Simulating sending command: $command');
  }
  
  // Fetch OBD data once
  Future<Map<String, String>> fetchOBDData() async {
    // Always return sample data in simulation mode
    return OBDSampleData.getSampleData();
  }
  
  // Start continuous data monitoring
  Future<void> startDataMonitoring() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _monitoringTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!_isConnected) {
        stopDataMonitoring();
        return;
      }
      
      try {
        final data = await fetchOBDData();
        _dataStreamController.add(data);
      } catch (e) {
        debugPrint('Error fetching OBD data: $e');
      }
    });
  }
  
  // Stop data monitoring
  Future<void> stopDataMonitoring() async {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _isMonitoring = false;
  }
  
  // Get vehicle OBD records (history)
  Future<List<Map<String, String>>> getVehicleOBDRecords(String vehicleId) async {
    // Return a list of sample data
    return List.generate(
      10, 
      (index) => {
        ...OBDSampleData.getSampleData(),
        'timestamp': DateTime.now().subtract(Duration(days: index)).toIso8601String(),
        'vehicleId': vehicleId,
        'id': 'sample-${index}',
        'userId': 'sample-user',
        'deviceName': 'Sample OBD Device',
        'deviceAddress': '00:11:22:33:44:55',
      }
    );
  }
  
  // Dispose resources
  void dispose() {
    stopDataMonitoring();
    disconnectDevice();
    _dataStreamController.close();
  }
} 