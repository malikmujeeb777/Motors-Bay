import 'dart:convert';

class ProfileModel {
  final String? token;
  final int? id;
  final dynamic email;
  final bool? emailVerified;
  final dynamic phone;
  final bool? phoneVerified;
  final dynamic name;
  final dynamic googleId;
  final dynamic profilePic;
  final String? role;
  final dynamic dob;
  final String? gender;
  final DateTime? createdAt;
  final bool? isDeleted;
  final dynamic deletedDate;
  final String? accountStatus;
  final dynamic deactivatedDate;
  final String? mode;
  final String? language;
  final dynamic country;
  final dynamic city;
  final dynamic latitude;
  final dynamic longitude;
  final dynamic area;
  final dynamic address;
  final DateTime? lastLogin;
  final dynamic resetToken;
  final int? tokenVersion;
  final dynamic otp;
  final dynamic otpGeneratedTime;
  final dynamic otpExpirationTime;
  final int? userId;
  final String? message;

  ProfileModel({
    this.token,
    this.id,
    this.email,
    this.emailVerified,
    this.phone,
    this.phoneVerified,
    this.name,
    this.googleId,
    this.profilePic,
    this.role,
    this.dob,
    this.gender,
    this.createdAt,
    this.isDeleted,
    this.deletedDate,
    this.accountStatus,
    this.deactivatedDate,
    this.mode,
    this.language,
    this.country,
    this.city,
    this.latitude,
    this.longitude,
    this.area,
    this.address,
    this.lastLogin,
    this.resetToken,
    this.tokenVersion,
    this.otp,
    this.otpGeneratedTime,
    this.otpExpirationTime,
    this.userId,
    this.message,
  });

  ProfileModel copyWith({
    String? token,
    int? id,
    dynamic email,
    bool? emailVerified,
    dynamic phone,
    bool? phoneVerified,
    dynamic name,
    dynamic googleId,
    dynamic profilePic,
    String? role,
    dynamic dob,
    String? gender,
    DateTime? createdAt,
    bool? isDeleted,
    dynamic deletedDate,
    String? accountStatus,
    dynamic deactivatedDate,
    String? mode,
    String? language,
    dynamic country,
    dynamic city,
    dynamic latitude,
    dynamic longitude,
    dynamic area,
    dynamic address,
    DateTime? lastLogin,
    dynamic resetToken,
    int? tokenVersion,
    dynamic otp,
    dynamic otpGeneratedTime,
    dynamic otpExpirationTime,
    int? userId,
    String? message,
  }) =>
      ProfileModel(
        token: token ?? this.token,
        id: id ?? this.id,
        email: email ?? this.email,
        emailVerified: emailVerified ?? this.emailVerified,
        phone: phone ?? this.phone,
        phoneVerified: phoneVerified ?? this.phoneVerified,
        name: name ?? this.name,
        googleId: googleId ?? this.googleId,
        profilePic: profilePic ?? this.profilePic,
        role: role ?? this.role,
        dob: dob ?? this.dob,
        gender: gender ?? this.gender,
        createdAt: createdAt ?? this.createdAt,
        isDeleted: isDeleted ?? this.isDeleted,
        deletedDate: deletedDate ?? this.deletedDate,
        accountStatus: accountStatus ?? this.accountStatus,
        deactivatedDate: deactivatedDate ?? this.deactivatedDate,
        mode: mode ?? this.mode,
        language: language ?? this.language,
        country: country ?? this.country,
        city: city ?? this.city,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        area: area ?? this.area,
        address: address ?? this.address,
        lastLogin: lastLogin ?? this.lastLogin,
        resetToken: resetToken ?? this.resetToken,
        tokenVersion: tokenVersion ?? this.tokenVersion,
        otp: otp ?? this.otp,
        otpGeneratedTime: otpGeneratedTime ?? this.otpGeneratedTime,
        otpExpirationTime: otpExpirationTime ?? this.otpExpirationTime,
        userId: userId ?? this.userId,
        message: message ?? this.message,
      );
  factory ProfileModel.fromRawJson(String str) {
    try {
      return ProfileModel.fromJson(json.decode(str));
    } catch (e) {
      print("Error parsing ProfileModel.fromRawJson: $e");
      // Return a minimal valid model rather than throwing an exception
      return ProfileModel(
        id: 0,
        userId: 0,
        name: "Guest User",
        email: "",
      );
    }
  }

  String toRawJson() => json.encode(toJson());

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse DateTime
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (e) {
        print("Error parsing DateTime: $e");
        return null;
      }
    }

    // Helper function to safely parse int
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) {
        try {
          return int.parse(value);
        } catch (e) {
          print("Error parsing int from String: $e");
          return null;
        }
      }
      return null;
    }

    // Helper function to safely parse bool
    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase() == 'true';
      }
      return null;
    }

    return ProfileModel(
      token: json["token"]?.toString(),
      id: parseInt(json["id"]),
      email: json["email"],
      emailVerified: parseBool(json["emailVerified"]),
      phone: json["phone"],
      phoneVerified: parseBool(json["phoneVerified"]),
      name: json["name"],
      googleId: json["googleId"],
      profilePic: json["profilePic"],
      role: json["role"]?.toString(),
      dob: json["dob"],
      gender: json["gender"]?.toString(),
      createdAt: parseDateTime(json["created_at"]),
      isDeleted: parseBool(json["isDeleted"]),
      deletedDate: json["deletedDate"],
      accountStatus: json["accountStatus"]?.toString(),
      deactivatedDate: json["deactivatedDate"],
      mode: json["mode"]?.toString(),
      language: json["language"]?.toString(),
      country: json["country"],
      city: json["city"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      area: json["area"],
      address: json["address"],
      lastLogin: parseDateTime(json["lastLogin"]),
      resetToken: json["resetToken"],
      tokenVersion: parseInt(json["tokenVersion"]),
      otp: json["otp"],
      otpGeneratedTime: json["otpGeneratedTime"],
      otpExpirationTime: json["otpExpirationTime"],
      userId: parseInt(json["userId"]),
      message: json["message"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "token": token,
    "id": id,
    "email": email,
    "emailVerified": emailVerified,
    "phone": phone,
    "phoneVerified": phoneVerified,
    "name": name,
    "googleId": googleId,
    "profilePic": profilePic,
    "role": role,
    "dob": dob,
    "gender": gender,
    "created_at": createdAt?.toIso8601String(),
    "isDeleted": isDeleted,
    "deletedDate": deletedDate,
    "accountStatus": accountStatus,
    "deactivatedDate": deactivatedDate,
    "mode": mode,
    "language": language,
    "country": country,
    "city": city,
    "latitude": latitude,
    "longitude": longitude,
    "area": area,
    "address": address,
    "lastLogin": lastLogin?.toIso8601String(),
    "resetToken": resetToken,
    "tokenVersion": tokenVersion,
    "otp": otp,
    "otpGeneratedTime": otpGeneratedTime,
    "otpExpirationTime": otpExpirationTime,
    "userId": userId,
    "message": message,
  };
}
