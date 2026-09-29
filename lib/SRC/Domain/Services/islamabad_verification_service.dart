import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:motorsbay1/SRC/Domain/Models/islamabad_verification_model.dart';

class IslamabadVerificationService {
  static const String _serverIp = '192.168.18.52';
  static const String _baseUrl = 'http://$_serverIp:3000/api/verify/isbv';
  static const int _maxRetries = 5;

  Future<IslamabadVerificationResponse> verifyVehicle({
    required String numberPlate,
    required DateTime registrationDate,
  }) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        final formattedDate = '${registrationDate.day.toString().padLeft(2, '0')}-'
            '${registrationDate.month.toString().padLeft(2, '0')}-'
            '${registrationDate.year}';
            
        final response = await http.get(
          Uri.parse('$_baseUrl?numberPlate=$numberPlate&regDate=$formattedDate'),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          return IslamabadVerificationResponse.fromJson(jsonResponse);
        } else {
          throw Exception('Server error: ${response.statusCode}');
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= _maxRetries) {
          throw Exception('Failed after $_maxRetries attempts: $e');
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: 1));
      }
    }
    
    throw Exception('Verification failed after $_maxRetries attempts');
  }
} 