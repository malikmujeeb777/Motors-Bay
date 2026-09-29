import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CarRecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // These weights determine how much each factor contributes to the recommendation score
  final Map<String, double> _weights = {
    'priceMatch': 3.0,     // Higher weight for price match
    'brandMatch': 2.5,     // Pakistani users often have strong brand preferences
    'fuelType': 2.0,       // Fuel economy is important in Pakistani market
    'carType': 1.8,        // Car type (sedan, SUV, etc)
    'transmission': 1.5,   // Auto vs manual preference
    'mileage': 1.2,        // Lower mileage cars are generally preferred
    'condition': 2.2,      // New vs used condition
    'city': 1.0,           // Location match
  };
  
  // Get user preferences from Firestore
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('car_preferences')
          .get();
          
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting user preferences: $e');
    }
    
    return null;
  }
  
  // Save user preferences to Firestore
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final String? userId = _auth.currentUser?.uid;
    if (userId == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('car_preferences')
          .set(preferences, SetOptions(merge: true));
    } catch (e) {
      print('Error saving user preferences: $e');
    }
  }
  
  // Get recommended cars based on user preferences
  Stream<List<QueryDocumentSnapshot>> getRecommendedCars({int limit = 10}) async* {
    final preferences = await getUserPreferences();
    final String? userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      // If user is not logged in, just return latest cars
      yield* _firestore
          .collectionGroup('user_cars')
          .where('status', isEqualTo: 'approved')
          .where('isSold', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs);
      return;
    }
    
    // If we have user preferences, fetch cars and score them client-side
    // (Firestore doesn't support complex scoring algorithms)
    yield* _firestore
        .collectionGroup('user_cars')
        .where('status', isEqualTo: 'approved')
        .where('isSold', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(30) // Fetch more than we need to allow for scoring/filtering
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs;
          
          if (preferences != null) {
            // Score each car based on preferences
            final scoredCars = docs.map((doc) {
              final car = doc.data();
              double score = _calculateCarScore(car, preferences);
              return {'doc': doc, 'score': score};
            }).toList();
              // Sort by score (descending)
            scoredCars.sort((a, b) => (b['score'] as double).compareTo(a['score'] as double));
            
            // Return top results up to the limit
            return scoredCars
                .take(limit)
                .map((scoredCar) => scoredCar['doc'] as QueryDocumentSnapshot)
                .toList();
          } else {
            // If no preferences, just return the original results
            return docs.take(limit).toList();
          }
        });
  }
  
  // Calculate a score for how well a car matches user preferences
  double _calculateCarScore(Map<String, dynamic> car, Map<String, dynamic> preferences) {
    double score = 0.0;
    
    // Price Range Matching
    if (preferences['priceRange'] != null && car['priceRange'] != null) {
      if (preferences['priceRange'] == car['priceRange']) {
        score += _weights['priceMatch']!;
      }
    }
    
    // Brand Matching
    if (preferences['preferredBrands'] != null && car['brand'] != null) {
      List<String> preferredBrands = List<String>.from(preferences['preferredBrands']);
      if (preferredBrands.contains(car['brand'])) {
        score += _weights['brandMatch']!;
      }
    }
    
    // Fuel Type
    if (preferences['preferredFuelType'] != null && car['fuelType'] != null) {
      if (preferences['preferredFuelType'] == car['fuelType']) {
        score += _weights['fuelType']!;
      }
    }
    
    // Car Type
    if (preferences['preferredCarType'] != null && car['carType'] != null) {
      if (preferences['preferredCarType'] == car['carType']) {
        score += _weights['carType']!;
      }
    }
    
    // Transmission
    if (preferences['preferredTransmission'] != null && car['transmission'] != null) {
      if (preferences['preferredTransmission'] == car['transmission']) {
        score += _weights['transmission']!;
      }
    }
    
    // Condition (New vs Used)
    if (preferences['preferredCondition'] != null && car['condition'] != null) {
      if (preferences['preferredCondition'] == car['condition']) {
        score += _weights['condition']!;
      }
    }
    
    // City/Location
    if (preferences['preferredCity'] != null && car['city'] != null) {
      if (preferences['preferredCity'] == car['city']) {
        score += _weights['city']!;
      }
    }
    
    // Mileage/KM Driven
    if (preferences['maxKmDriven'] != null && car['kmDriven'] != null) {
      int maxKm = int.tryParse(preferences['maxKmDriven'].toString()) ?? 0;
      int carKm = int.tryParse(car['kmDriven'].toString()) ?? 0;
      
      if (carKm <= maxKm) {
        // Lower mileage gets higher score
        double mileageRatio = 1.0 - (carKm / maxKm);
        score += _weights['mileage']! * mileageRatio;
      }
    }
    
    return score;
  }
} 