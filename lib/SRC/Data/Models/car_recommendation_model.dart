// Car recommendation model for Pakistani market
class CarRecommendation {
  final String id;
  final String brand;
  final String model;
  final String imageUrl;
  final double price;
  final String priceRange;
  final String fuelType;
  final String transmission;
  final String carType;
  final List<String> features;
  final double rating;
  final Map<String, double> scoreFactors;
  final String marketSegment; // e.g., "Budget", "Family", "Luxury", "Performance"

  CarRecommendation({
    required this.id,
    required this.brand,
    required this.model,
    required this.imageUrl,
    required this.price,
    required this.priceRange,
    required this.fuelType,
    required this.transmission,
    required this.carType,
    required this.features,
    required this.rating,
    required this.scoreFactors,
    required this.marketSegment,
  });

  factory CarRecommendation.fromMap(Map<String, dynamic> map, String docId) {
    return CarRecommendation(
      id: docId,
      brand: map['brand'] ?? '',
      model: map['subCategory'] ?? '',
      imageUrl: (map['imageUrls'] as List?)?.isNotEmpty == true ? map['imageUrls'][0] : '',
      price: double.tryParse(map['price'] ?? '0') ?? 0.0,
      priceRange: map['priceRange'] ?? '',
      fuelType: map['fuelType'] ?? '',
      transmission: map['transmission'] ?? '',
      carType: map['carType'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      scoreFactors: Map<String, double>.from(map['scoreFactors'] ?? {}),
      marketSegment: map['marketSegment'] ?? 'General',
    );
  }
}

class UserPreference {
  final String userId;
  double budgetMin;
  double budgetMax;
  List<String> preferredBrands;
  List<String> preferredCarTypes;
  List<String> preferredFeatures;
  String preferredFuelType;
  String preferredTransmission;
  List<String> preferredStyles; // Luxury, Vintage, Sport, Family, etc.
  double fuelEfficiencyImportance; // 0-10 scale
  double resaleValueImportance; // 0-10 scale
  double maintenanceCostImportance; // 0-10 scale
  double performanceImportance; // 0-10 scale
  double comfortImportance; // 0-10 scale
  double safetyImportance; // 0-10 scale
  UserPreference({
    required this.userId,
    required this.budgetMin,
    required this.budgetMax,
    required this.preferredBrands,
    required this.preferredCarTypes,
    required this.preferredFeatures,
    required this.preferredFuelType,
    required this.preferredTransmission,
    required this.preferredStyles,
    this.fuelEfficiencyImportance = 5.0,
    this.resaleValueImportance = 5.0,
    this.maintenanceCostImportance = 5.0,
    this.performanceImportance = 5.0,
    this.comfortImportance = 5.0,
    this.safetyImportance = 5.0,
  });
  factory UserPreference.fromMap(Map<String, dynamic> map) {
    return UserPreference(
      userId: map['userId'] ?? '',
      budgetMin: (map['budgetMin'] ?? 0.0).toDouble(),
      budgetMax: (map['budgetMax'] ?? 10000000.0).toDouble(),
      preferredBrands: List<String>.from(map['preferredBrands'] ?? []),
      preferredCarTypes: List<String>.from(map['preferredCarTypes'] ?? []),
      preferredFeatures: List<String>.from(map['preferredFeatures'] ?? []),
      preferredStyles: List<String>.from(map['preferredStyles'] ?? []),
      preferredFuelType: map['preferredFuelType'] ?? '',
      preferredTransmission: map['preferredTransmission'] ?? '',
      fuelEfficiencyImportance: (map['fuelEfficiencyImportance'] ?? 5.0).toDouble(),
      resaleValueImportance: (map['resaleValueImportance'] ?? 5.0).toDouble(),
      maintenanceCostImportance: (map['maintenanceCostImportance'] ?? 5.0).toDouble(),
      performanceImportance: (map['performanceImportance'] ?? 5.0).toDouble(),
      comfortImportance: (map['comfortImportance'] ?? 5.0).toDouble(),
      safetyImportance: (map['safetyImportance'] ?? 5.0).toDouble(),
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'preferredBrands': preferredBrands,
      'preferredCarTypes': preferredCarTypes,
      'preferredFeatures': preferredFeatures,
      'preferredStyles': preferredStyles,
      'preferredFuelType': preferredFuelType,
      'preferredTransmission': preferredTransmission,
      'fuelEfficiencyImportance': fuelEfficiencyImportance,
      'resaleValueImportance': resaleValueImportance,
      'maintenanceCostImportance': maintenanceCostImportance,
      'performanceImportance': performanceImportance,
      'comfortImportance': comfortImportance,
      'safetyImportance': safetyImportance,
    };
  }
}

// Market data specific to Pakistani car market
class PakistaniCarMarketData {
  // Brand resale value ranking (score out of 10)
  static const Map<String, double> brandResaleValues = {
    'Toyota': 9.5,
    'Honda': 9.0,
    'Suzuki': 8.5,
    'Hyundai': 7.5,
    'Kia': 7.0,
    'Nissan': 7.0,
    'Mitsubishi': 6.5,
    'Daihatsu': 8.0,
    'Mazda': 6.5,
    'MG': 6.0,
    'Changan': 5.5,
    'Proton': 6.0,
    'FAW': 5.0,
    'BAIC': 5.0,
    'Haval': 5.5,
    'Chery': 5.0,
    'Audi': 7.0,
    'BMW': 7.0,
    'Mercedes-Benz': 7.0,
    'Volkswagen': 6.5,
  };

  // Maintenance cost ranking (lower is better)
  static const Map<String, double> maintenanceCosts = {
    'Toyota': 8.5,
    'Honda': 8.0,
    'Suzuki': 9.0,
    'Hyundai': 7.0,
    'Kia': 7.0,
    'Nissan': 7.0,
    'Mitsubishi': 6.5,
    'Daihatsu': 8.5,
    'Mazda': 6.0,
    'MG': 5.5,
    'Changan': 6.0,
    'Proton': 5.5,
    'FAW': 5.0,
    'BAIC': 5.0,
    'Haval': 5.0,
    'Chery': 5.0,
    'Audi': 4.0,
    'BMW': 3.5,
    'Mercedes-Benz': 3.0,
    'Volkswagen': 5.0,
  };

  // Fuel efficiency by car type (lower is better)
  static const Map<String, double> fuelEfficiency = {
    'Hatchback': 8.5,
    'Sedan': 7.5,
    'Crossover': 7.0,
    'SUV': 6.0,
    'Pickup': 5.5,
    'Van': 6.0,
    'Coupe': 6.5,
    'Convertible': 6.0,
    'Minivan': 6.0,
    'Wagon': 7.0,
    'Truck': 5.0,
    'Electric Vehicle (EV)': 10.0,
    'Hybrid': 9.0,
  };

  // Spare parts availability in Pakistani market
  static const Map<String, double> sparePartsAvailability = {
    'Toyota': 9.5,
    'Honda': 9.0,
    'Suzuki': 9.5,
    'Hyundai': 8.0,
    'Kia': 7.5,
    'Nissan': 7.0,
    'Mitsubishi': 6.5,
    'Daihatsu': 8.0,
    'Mazda': 6.0,
    'MG': 5.0,
    'Changan': 5.5,
    'Proton': 5.0,
    'FAW': 6.0,
    'BAIC': 4.5,
    'Haval': 4.5,
    'Chery': 4.5,
    'Audi': 6.0,
    'BMW': 6.0,
    'Mercedes-Benz': 6.0,
    'Volkswagen': 5.5,
  };
}
