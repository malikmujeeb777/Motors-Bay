import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseRecord {
  final String id;
  final String vehicleId;
  final String userId;
  final String expenseType; // fuel, maintenance, repair, insurance, other
  final double amount;
  final DateTime date;
  final String description;
  final String? receiptImageUrl;
  final Map<String, dynamic>? additionalDetails;

  ExpenseRecord({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.expenseType,
    required this.amount,
    required this.date,
    required this.description,
    this.receiptImageUrl,
    this.additionalDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'expenseType': expenseType,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'description': description,
      'receiptImageUrl': receiptImageUrl,
      'additionalDetails': additionalDetails,
    };
  }

  factory ExpenseRecord.fromMap(Map<String, dynamic> map) {
    return ExpenseRecord(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      userId: map['userId'] ?? '',
      expenseType: map['expenseType'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      date: (map['date'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      receiptImageUrl: map['receiptImageUrl'],
      additionalDetails: map['additionalDetails'],
    );
  }
}

class MaintenanceRecord {
  final String id;
  final String vehicleId;
  final String userId;
  final String serviceType; // oil change, tire rotation, brake service, etc.
  final DateTime date;
  final double? cost;
  final String description;
  final String? serviceProvider;
  final String? invoiceImageUrl;
  final Map<String, dynamic>? additionalDetails;

  MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.serviceType,
    required this.date,
    this.cost,
    required this.description,
    this.serviceProvider,
    this.invoiceImageUrl,
    this.additionalDetails,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'serviceType': serviceType,
      'date': Timestamp.fromDate(date),
      'cost': cost,
      'description': description,
      'serviceProvider': serviceProvider,
      'invoiceImageUrl': invoiceImageUrl,
      'additionalDetails': additionalDetails,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'] ?? '',
      vehicleId: map['vehicleId'] ?? '',
      userId: map['userId'] ?? '',
      serviceType: map['serviceType'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      cost: map['cost']?.toDouble(),
      description: map['description'] ?? '',
      serviceProvider: map['serviceProvider'],
      invoiceImageUrl: map['invoiceImageUrl'],
      additionalDetails: map['additionalDetails'],
    );
  }
}

class MaintenanceReminder {
  final String id;
  final String vehicleId;
  final String userId;
  final String title;
  final String description;
  final DateTime dueDate;
  final String reminderType; // 'date-based' or 'mileage-based'
  final int? dueMileage;
  final String serviceType;
  final bool isCompleted;
  final DateTime? completedDate;
  final DateTime createdAt;

  MaintenanceReminder({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.reminderType,
    required this.serviceType,
    this.dueMileage,
    this.isCompleted = false,
    this.completedDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'reminderType': reminderType,
      'dueMileage': dueMileage,
      'serviceType': serviceType,
      'isCompleted': isCompleted,
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MaintenanceReminder.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is String) {
        return DateTime.parse(date);
      } else {
        return DateTime.now();
      }
    }

    return MaintenanceReminder(
      id: map['id']?.toString() ?? '',
      vehicleId: map['vehicleId']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      dueDate: parseDate(map['dueDate']),
      reminderType: map['reminderType']?.toString() ?? 'time-based',
      serviceType: map['serviceType']?.toString() ?? '',
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedDate: map['completedDate'] != null ? parseDate(map['completedDate']) : null,
      dueMileage: map['dueMileage'] != null ? int.tryParse(map['dueMileage'].toString()) : null,
      createdAt: parseDate(map['createdAt']),
    );
  }

  MaintenanceReminder copyWith({
    String? id,
    String? vehicleId,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? reminderType,
    String? serviceType,
    int? dueMileage,
    bool? isCompleted,
    DateTime? completedDate,
    DateTime? createdAt,
  }) {
    return MaintenanceReminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderType: reminderType ?? this.reminderType,
      serviceType: serviceType ?? this.serviceType,
      dueMileage: dueMileage ?? this.dueMileage,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
