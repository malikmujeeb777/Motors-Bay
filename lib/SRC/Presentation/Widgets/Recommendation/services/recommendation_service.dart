import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Data/Models/car_recommendation_model.dart';

class RecommendationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get user preferences or create default if not exists
  Future<UserPreference> getUserPreferences() async {
    final currentUser = _auth.currentUser;
    final userId = currentUser?.uid ?? Data.app.token;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    try {
      // Try to get existing user preferences
      DocumentSnapshot userPrefDoc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();
          
      if (userPrefDoc.exists) {
        return UserPreference.fromMap(
          userPrefDoc.data() as Map<String, dynamic>
        );
      } else {        // Create default preferences
        UserPreference defaultPrefs = UserPreference(
          userId: userId,
          budgetMin: 0,
          budgetMax: 10000000,
          preferredBrands: [],
          preferredCarTypes: [],
          preferredFeatures: [],
          preferredStyles: [],
          preferredFuelType: '',
          preferredTransmission: '',
        );
        
        // Save default preferences to Firestore
        await _firestore
            .collection('user_preferences')
            .doc(userId)
            .set(defaultPrefs.toMap());
            
        return defaultPrefs;
      }
    } catch (e) {
      print('Error getting user preferences: $e');      // Return default preferences if error occurs
      return UserPreference(
        userId: userId,
        budgetMin: 0,
        budgetMax: 10000000,
        preferredBrands: [],
        preferredCarTypes: [],
        preferredFeatures: [],
        preferredStyles: [],
        preferredFuelType: '',
        preferredTransmission: '',
      );
    }
  }
  
  // Save user preferences
  Future<void> saveUserPreferences(UserPreference preferences) async {
    await _firestore
        .collection('user_preferences')
        .doc(preferences.userId)
        .set(preferences.toMap());
  }
  
  // Check if user has set meaningful preferences (not just default ones)
  Future<bool> hasSetPreferences() async {
    try {
      final preferences = await getUserPreferences();
      
      // Check if user has set any significant preferences
      bool hasSetBrands = preferences.preferredBrands.isNotEmpty;
      bool hasSetCarTypes = preferences.preferredCarTypes.isNotEmpty;
      bool hasSetStyles = preferences.preferredStyles.isNotEmpty;
      bool hasSetFuelType = preferences.preferredFuelType.isNotEmpty;
      bool hasCustomBudget = preferences.budgetMin > 0 || preferences.budgetMax < 10000000;
      
      // Return true if at least two preference categories have been set
      int preferencesSet = 0;
      if (hasSetBrands) preferencesSet++;
      if (hasSetCarTypes) preferencesSet++;
      if (hasSetStyles) preferencesSet++;
      if (hasSetFuelType) preferencesSet++;
      if (hasCustomBudget) preferencesSet++;
      
      return preferencesSet >= 2;
    } catch (e) {
      print('Error checking preferences: $e');
      return false;
    }
  }
  
  // Get car recommendations based on user preferences
  Future<List<CarRecommendation>> getRecommendations({int limit = 10}) async {
    try {
      UserPreference preferences = await getUserPreferences();
      
      // Query cars from Firestore
      QuerySnapshot carsSnapshot = await _firestore
          .collection('cars')
          .get();
          
      List<CarRecommendation> allCars = [];
      
      // Get all cars from all users
      for (var userDoc in carsSnapshot.docs) {
        QuerySnapshot userCarsSnapshot = await _firestore
            .collection('cars')
            .doc(userDoc.id)
            .collection('user_cars')
            .where('isSold', isEqualTo: false) // Only show cars not sold
            .get();
            
        // Convert to CarRecommendation objects
        for (var carDoc in userCarsSnapshot.docs) {
          Map<String, dynamic> carData = carDoc.data() as Map<String, dynamic>;
          
          // Filter by price range if specified
          double carPrice = double.tryParse(carData['price'] ?? '0') ?? 0;
          if (preferences.budgetMin > 0 && carPrice < preferences.budgetMin) {
            continue;
          }
          
          if (preferences.budgetMax > 0 && carPrice > preferences.budgetMax) {
            continue;
          }
          
          // Filter by preferred brands if specified
          if (preferences.preferredBrands.isNotEmpty && 
              !preferences.preferredBrands.contains(carData['brand'])) {
            continue;
          }
          
          // Filter by car type if specified
          if (preferences.preferredCarTypes.isNotEmpty && 
              !preferences.preferredCarTypes.contains(carData['carType'])) {
            continue;
          }
          
          // Filter by fuel type if specified
          if (preferences.preferredFuelType.isNotEmpty && 
              carData['fuelType'] != preferences.preferredFuelType) {
            continue;
          }
          
          // Filter by transmission if specified
          if (preferences.preferredTransmission.isNotEmpty && 
              carData['transmission'] != preferences.preferredTransmission) {
            continue;
          }
          
          // Calculate score factors based on Pakistani market data
          Map<String, double> scoreFactors = _calculateScoreFactors(
            carData: carData,
            preferences: preferences,
          );
          
          // Add score factors to car data
          carData['scoreFactors'] = scoreFactors;
          
          // Calculate overall rating
          double overallRating = _calculateOverallRating(
            scoreFactors: scoreFactors,
            preferences: preferences,
          );
          
          carData['rating'] = overallRating;
          
          // Add to list
          allCars.add(CarRecommendation.fromMap(carData, carDoc.id));
        }
      }
      
      // Sort by overall rating
      allCars.sort((a, b) => b.rating.compareTo(a.rating));
      
      // Return top 'limit' recommendations
      return allCars.take(limit).toList();
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }
  
  // Calculate score factors for a car based on Pakistani market data
  Map<String, double> _calculateScoreFactors({
    required Map<String, dynamic> carData,
    required UserPreference preferences,
  }) {
    Map<String, double> scores = {};
    
    // Calculate resale value score
    String brand = carData['brand'] ?? '';
    scores['resaleValue'] = PakistaniCarMarketData.brandResaleValues[brand] ?? 5.0;
    
    // Calculate maintenance cost score
    scores['maintenanceCost'] = PakistaniCarMarketData.maintenanceCosts[brand] ?? 5.0;
    
    // Calculate fuel efficiency score
    String carType = carData['carType'] ?? '';
    scores['fuelEfficiency'] = PakistaniCarMarketData.fuelEfficiency[carType] ?? 5.0;
    
    // Calculate spare parts availability score
    scores['sparePartsAvailability'] = PakistaniCarMarketData.sparePartsAvailability[brand] ?? 5.0;
    
    // Calculate price value score (lower price gets higher score)
    double price = double.tryParse(carData['price'] ?? '0') ?? 0;
    double priceRange = preferences.budgetMax - preferences.budgetMin;
    if (priceRange > 0) {
      scores['priceValue'] = 10 - ((price - preferences.budgetMin) / priceRange * 10);
    } else {
      scores['priceValue'] = 5.0;
    }
    
    // Calculate feature match score
    List<String> carFeatures = List<String>.from(carData['features'] ?? []);
    if (preferences.preferredFeatures.isNotEmpty && carFeatures.isNotEmpty) {
      int matchCount = 0;
      for (String feature in preferences.preferredFeatures) {
        if (carFeatures.contains(feature)) {
          matchCount++;
        }
      }
      scores['featureMatch'] = (matchCount / preferences.preferredFeatures.length) * 10;
    } else {
      scores['featureMatch'] = 5.0;
    }
    
    // Calculate style match score
    if (preferences.preferredStyles.isNotEmpty) {
      String carStyle = '';
      // Map car attributes to styles
      if (carData['priceRange']?.toString().contains('Luxury') == true || 
          (double.tryParse(carData['price']?.toString() ?? '0') ?? 0) >= 8000000) {
        carStyle = 'Luxury';
      } else if ((int.tryParse(carData['modelYear']?.toString() ?? '0') ?? 0) <= 1990) {
        carStyle = 'Vintage';
      } else if (carData['carType'] == 'Coupe' || 
                carData['carType'] == 'Sports' || 
                carData['brand'] == 'BMW' || 
                carData['brand'] == 'Audi') {
        carStyle = 'Sport';
      } else if (carData['carType'] == 'SUV' || carData['carType'] == 'Crossover') {
        carStyle = 'SUV';
      } else {
        carStyle = 'Standard';
      }
      
      if (preferences.preferredStyles.contains(carStyle)) {
        scores['styleMatch'] = 10.0;
      } else {
        scores['styleMatch'] = 0.0;
      }
    } else {
      scores['styleMatch'] = 5.0;
    }
    
    return scores;
  }
  
  // Calculate overall rating based on score factors and user preferences
  double _calculateOverallRating({
    required Map<String, double> scoreFactors,
    required UserPreference preferences,
  }) {
    // Define weights for different factors based on Pakistani market
    Map<String, double> weights = {
      'resaleValue': 2.0,           // High weight for resale value
      'maintenanceCost': 1.8,       // Important for long-term ownership
      'fuelEfficiency': 1.5,        // Important due to fuel prices
      'sparePartsAvailability': 2.0, // Critical in Pakistani market
      'priceValue': 1.5,            // Price sensitivity
      'featureMatch': 1.2,          // Features are nice but not critical
      'styleMatch': 1.0,            // Style is subjective
    };
    
    double totalScore = 0.0;
    double totalWeight = 0.0;
    
    // Calculate weighted average
    weights.forEach((factor, weight) {
      if (scoreFactors.containsKey(factor)) {
        totalScore += scoreFactors[factor]! * weight;
        totalWeight += weight;
      }
    });
    
    // Return normalized score (0-10)
    return totalWeight > 0 ? (totalScore / totalWeight) : 0.0;
  }
} 