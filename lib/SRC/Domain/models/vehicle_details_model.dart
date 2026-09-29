import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleDetailsModel {
  String status;
  String listingType;
  String title;
  String price;
  String description;
  String kmDriven;
  String transmission;
  String assembly;
  String fuelType;
  String color;
  String city;
  String registerIn;
  String condition;
  String brand;
  String subCategory;
  String contactNumber;
  bool allowWhatsApp;
  Timestamp createdAt;
  String userId;
  bool isSold;
  String deviceToken;
  String modelYear;
  List<dynamic> imageUrls = [];

  VehicleDetailsModel({
    required this.status,
    required this.listingType,
    required this.title,
    required this.price,
    required this.description,
    required this.kmDriven,
    required this.transmission,
    required this.assembly,
    required this.fuelType,
    required this.color,
    required this.city,
    required this.registerIn,
    required this.condition,
    required this.brand,
    required this.subCategory,
    required this.contactNumber,
    required this.allowWhatsApp,
    required this.createdAt,
    required this.userId,
    required this.isSold,
    required this.deviceToken,
    required this.modelYear,
    this.imageUrls = const [],
  });

  // Convert Firestore document to VehicleDetails object
  factory VehicleDetailsModel.fromMap(Map<String, dynamic> map) {
    return VehicleDetailsModel(
      status: map['status'] ?? '',
      listingType: map['listingType'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? '0',
      description: map['description'] ?? '',
      kmDriven: map['kmDriven'] ?? '',
      transmission: map['transmission'] ?? '',
      assembly: map['assembly'] ?? '',
      fuelType: map['fuelType'] ?? '',
      color: map['color'] ?? '',
      city: map['city'] ?? '',
      registerIn: map['registerIn'] ?? '',
      condition: map['condition'] ?? '',
      brand: map['brand'] ?? '',
      subCategory: map['subCategory'] ?? '',
      contactNumber: map['contactNumber'] ?? '',
      allowWhatsApp: map['allowWhatsApp'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      userId: map['userId'] ?? '',
      isSold: map['isSold'] ?? false,
      deviceToken: map['deviceToken'] ?? '',
      modelYear: map['modelYear'] ?? '',
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }

  // Convert VehicleDetails object to a Firestore document
  Map<String, dynamic> toMap() {
    return {
      "status": status,
      "listingType": listingType,
      "title": title,
      "price": price,
      "description": description,
      "kmDriven": kmDriven,
      "transmission": transmission,
      "assembly": assembly,
      "fuelType": fuelType,
      "color": color,
      "city": city,
      "registerIn": registerIn,
      "condition": condition,
      "brand": brand,
      "subCategory": subCategory,
      "contactNumber": contactNumber,
      "allowWhatsApp": allowWhatsApp,
      "createdAt": createdAt,
      "userId": userId,
      "isSold": isSold,
      "deviceToken": deviceToken,
      "modelYear": modelYear,
      "imageUrls": imageUrls
    };
  }
}
