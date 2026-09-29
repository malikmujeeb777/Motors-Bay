import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Domain/Models/islamabad_verification_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveVerificationHistory({
    required String numberPlate,
    required DateTime registrationDate,
    required String province,
    required IslamabadVerificationData verificationData,
  }) async {
    try {
      await _firestore.collection('verification_history').add({
        'numberPlate': numberPlate,
        'registrationDate': registrationDate.toIso8601String(),
        'province': province,
        'verificationData': verificationData.toJson(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving verification history: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getVerificationHistory() {
    return _firestore
        .collection('verification_history')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to last 50 entries for performance
        .snapshots();
  }

  Future<void> deleteVerificationHistory(String docId) async {
    try {
      await _firestore.collection('verification_history').doc(docId).delete();
    } catch (e) {
      print('Error deleting verification history: $e');
      rethrow;
    }
  }
} 