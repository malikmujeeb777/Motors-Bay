import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';

class AutoReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _expensesCollection =>
      _firestore.collection('expenses');
  CollectionReference get _maintenanceCollection =>
      _firestore.collection('maintenance_records');
  CollectionReference get _remindersCollection =>
      _firestore.collection('maintenance_reminders');

  // Service intervals in days
  static const Map<String, int> _serviceIntervals = {
    'oil change': 90, // 3 months
    'oil_change': 90,
    'engine oil': 90,
    'engine_oil': 90,
    'tire rotation': 180, // 6 months
    'tire_rotation': 180,
    'air filter': 365, // 12 months
    'air_filter': 365,
    'brake service': 365,
    'brake_service': 365,
    'transmission fluid': 730, // 24 months
    'transmission_fluid': 730,
    'spark plugs': 730,
    'spark_plugs': 730,
    'general maintenance': 180,
    'general_maintenance': 180,
  };

  // Listen to new expense records and create reminders automatically
  void startAutoReminderGeneration() {
    _expensesCollection
        .where('expenseType', isEqualTo: 'maintenance')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _processNewExpenseRecord(
            ExpenseRecord.fromMap(change.doc.data() as Map<String, dynamic>),
          );
        }
      }
    }, onError: (error) {
      debugPrint('Error listening to expense records: $error');
    });

    _maintenanceCollection.snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _processNewMaintenanceRecord(
            MaintenanceRecord.fromMap(
                change.doc.data() as Map<String, dynamic>),
          );
        }
      }
    }, onError: (error) {
      debugPrint('Error listening to maintenance records: $error');
    });
  }

  // Process a new expense record for possible reminder generation
  Future<void> _processNewExpenseRecord(ExpenseRecord expense) async {
    if (expense.expenseType != 'maintenance') return;

    final description = expense.description.toLowerCase();
    int? intervalDays;

    // Check for known service types in the description
    for (final entry in _serviceIntervals.entries) {
      if (description.contains(entry.key)) {
        intervalDays = entry.value;
        break;
      }
    }

    if (intervalDays != null) {
      await _createReminderFromService(
        expense.vehicleId,
        expense.description,
        expense.date,
        intervalDays,
      );
    }
  }

  // Process a new maintenance record for possible reminder generation
  Future<void> _processNewMaintenanceRecord(MaintenanceRecord record) async {
    final serviceType = record.serviceType.toLowerCase();
    int? intervalDays;

    // Check for known service types
    for (final entry in _serviceIntervals.entries) {
      if (serviceType.contains(entry.key)) {
        intervalDays = entry.value;
        break;
      }
    }

    if (intervalDays != null) {
      await _createReminderFromService(
        record.vehicleId,
        record.serviceType,
        record.date,
        intervalDays,
      );
    }
  }

  // Create a reminder based on a service record
  Future<void> _createReminderFromService(
    String vehicleId,
    String serviceDescription,
    DateTime serviceDate,
    int intervalDays,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('Cannot create reminder: No user logged in');
        return;
      }

      // Calculate next service date
      final nextServiceDate = serviceDate.add(Duration(days: intervalDays));

      // Get all reminders for the vehicle and filter in memory
      final existingReminders = await _remindersCollection
          .where('vehicleId', isEqualTo: vehicleId)
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      final now = DateTime.now();
      final activeReminders = existingReminders.docs
          .map((doc) {
            try {
              return MaintenanceReminder.fromMap(doc.data() as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing reminder: $e');
              return null;
            }
          })
          .where((reminder) => reminder != null)
          .where((reminder) => reminder!.dueDate.isAfter(now) || reminder.dueDate.isAtSameMomentAs(now))
          .map((reminder) => reminder!)
          .toList();

      // Don't create duplicate reminders for the same service
      for (var reminder in activeReminders) {
        if (_isSimilarService(reminder.title, serviceDescription) ||
            _isSimilarService(reminder.description, serviceDescription)) {
          debugPrint('Similar reminder already exists, skipping creation');
          return;
        }
      }

      // Create a new reminder
      final reminder = MaintenanceReminder(
        id: const Uuid().v4(),
        vehicleId: vehicleId,
        userId: currentUser.uid,
        title: 'Next ${_capitalizeService(serviceDescription)}',
        description: 'Reminder for next ${serviceDescription.toLowerCase()} '
            'based on service performed on ${_formatDate(serviceDate)}',
        dueDate: nextServiceDate,
        reminderType: 'time-based',
        serviceType: serviceDescription,
      );

      await _remindersCollection.doc(reminder.id).set(reminder.toMap());
      debugPrint('Auto-generated reminder for ${serviceDescription}');
    } catch (e) {
      debugPrint('Error creating auto-reminder: $e');
    }
  }

  // Check if two service descriptions are similar
  bool _isSimilarService(String service1, String service2) {
    final s1 = service1.toLowerCase();
    final s2 = service2.toLowerCase();

    if (s1.contains(s2) || s2.contains(s1)) {
      return true;
    }

    // Check for common terms
    final commonTerms = [
      'oil',
      'filter',
      'brake',
      'tire',
      'transmission',
      'spark',
      'plug',
      'coolant',
      'rotation',
    ];

    for (final term in commonTerms) {
      if (s1.contains(term) && s2.contains(term)) {
        return true;
      }
    }

    return false;
  }

  // Capitalize the first letter of each word in a service description
  String _capitalizeService(String service) {
    return service.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // Format a date as a string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Create a reminder based on a service record (public version)
  Future<MaintenanceReminder> createReminderFromService(
    String vehicleId,
    String serviceDescription,
    DateTime serviceDate,
    int intervalDays,
  ) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Cannot create reminder: No user logged in');
      }

      // Calculate next service date
      final nextServiceDate = serviceDate.add(Duration(days: intervalDays));

      // Create a new reminder without checking for duplicates (let user decide)
      final reminder = MaintenanceReminder(
        id: const Uuid().v4(),
        vehicleId: vehicleId,
        userId: currentUser.uid,
        title: 'Next ${_capitalizeService(serviceDescription)}',
        description: 'Reminder for next ${serviceDescription.toLowerCase()} '
            'based on service performed on ${_formatDate(serviceDate)}',
        dueDate: nextServiceDate,
        reminderType: 'time-based',
        serviceType: serviceDescription,
      );

      // Save to Firestore immediately
      await _remindersCollection.doc(reminder.id).set(reminder.toMap());
      debugPrint('Created reminder for ${serviceDescription}');

      return reminder;
    } catch (e) {
      debugPrint('Error creating reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('maintenance_reminders').doc(reminderId).delete();
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }
}
