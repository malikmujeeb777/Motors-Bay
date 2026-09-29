import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Domain/Models/verification_history_model.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';

class VerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new verification record
  Future<void> addVerificationHistory(VerificationHistory history) async {
    try {
      await _firestore
          .collection('verification_history')
          .doc(history.id)
          .set(history.toMap());
    } catch (e) {
      print('Error adding verification history: $e');
      rethrow;
    }
  }

  // Get verification history for a user
  Stream<List<VerificationHistory>> getUserVerificationHistory(String userId) {
    return _firestore
        .collection('verification_history')
        .where('userId', isEqualTo: userId)
        .orderBy('verifiedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => VerificationHistory.fromMap(doc.data()))
          .toList();
    });
  }

  // Get a single verification record
  Future<VerificationHistory?> getVerificationRecord(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('verification_history')
          .doc(id)
          .get();
      
      if (doc.exists) {
        return VerificationHistory.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting verification record: $e');
      rethrow;
    }
  }

  // Update verification status
  Future<void> updateVerificationStatus(String id, String status) async {
    try {
      await _firestore
          .collection('verification_history')
          .doc(id)
          .update({'status': status});
    } catch (e) {
      print('Error updating verification status: $e');
      rethrow;
    }
  }

  Future<void> saveVerificationHistory({
    required String numberPlate,
    required String province,
    required String registrationDate,
    required Map<String, dynamic> verificationData,
  }) async {
    try {
      if (Data.app.token == null) {
        throw Exception('User not logged in');
      }

      final verification = {
        'uid': Data.app.token.toString(),
        'numberPlate': numberPlate,
        'province': province,
        'registrationDate': registrationDate,
        'timestamp': FieldValue.serverTimestamp(),
        'verificationData': {
          'bodyType': verificationData['bodyType'] ?? '',
          'chassisNo': verificationData['chassisNo'] ?? '',
          'color': verificationData['color'] ?? '',
          'engineNo': verificationData['engineNo'] ?? '',
          'engineSize': verificationData['engineSize'] ?? '',
          'makerMake': verificationData['makerMake'] ?? '',
          'ownerName': verificationData['ownerName'] ?? '',
          'purchaseDate': verificationData['purchaseDate'] ?? '',
          'purchaseType': verificationData['purchaseType'] ?? '',
          'regDate': verificationData['regDate'] ?? '',
          'regNo': verificationData['regNo'] ?? '',
          'status': verificationData['status'] ?? '',
          'taxPaidUpto': verificationData['taxPaidUpto'] ?? '',
          'textOutput': verificationData['textOutput'] ?? '',
          'vehicleValue': verificationData['vehicleValue'] ?? '',
          'yearOfManufacture': verificationData['yearOfManufacture'] ?? '',
        }
      };

      await _firestore
          .collection('verification_history')
          .add(verification);
    } catch (e) {
      print('Error saving verification history: $e');
      rethrow;
    }
  }

  Future<void> deleteVerificationHistory(String docId) async {
    try {
      await _firestore
          .collection('verification_history')
          .doc(docId)
          .delete();
    } catch (e) {
      print('Error deleting verification history: $e');
      rethrow;
    }
  }
} 