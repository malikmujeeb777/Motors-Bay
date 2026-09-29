import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'dart:async';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _expensesCollection =>
      _firestore.collection('expenses');
  CollectionReference get _maintenanceCollection =>
      _firestore.collection('maintenance_records');
  CollectionReference get _remindersCollection =>
      _firestore.collection('maintenance_reminders');

  // Get current user ID with error handling
  String? get currentUserId {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('MaintenanceService: No user is currently logged in');
      return null;
    }
    return user.uid;
  }

  // Check if user is authenticated
  bool get isUserAuthenticated => _auth.currentUser != null;

  // EXPENSE RECORDS

  // Add a new expense record
  Future<ExpenseRecord> addExpense(ExpenseRecord expense) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message: 'No user is logged in. Please log in to add an expense.',
        );
      }

      final docRef = _expensesCollection.doc();
      final newExpense = ExpenseRecord(
        id: docRef.id,
        vehicleId: expense.vehicleId,
        userId: userId,
        expenseType: expense.expenseType,
        amount: expense.amount,
        date: expense.date,
        description: expense.description,
        receiptImageUrl: expense.receiptImageUrl,
        additionalDetails: expense.additionalDetails,
      );

      await docRef.set(newExpense.toMap());
      return newExpense;
    } catch (e) {
      debugPrint('Error adding expense: $e');
      rethrow;
    }
  }

  // Get all expenses for current user
  Stream<List<ExpenseRecord>> getUserExpenses() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getUserExpenses: No user logged in');
        return Stream.value([]);
      }

      return _expensesCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final expenses = snapshot.docs
            .map((doc) =>
                ExpenseRecord.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort by date in memory
        expenses.sort((a, b) => b.date.compareTo(a.date));
        return expenses;
      });
    } catch (e) {
      debugPrint('Error getting user expenses: $e');
      return Stream.value([]);
    }
  }

  // Get expenses for a specific vehicle
  Stream<List<ExpenseRecord>> getVehicleExpenses(String vehicleId) {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getVehicleExpenses: No user logged in');
        return Stream.value([]);
      }

      return _expensesCollection
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .snapshots()
          .map((snapshot) {
        final expenses = snapshot.docs
            .map((doc) =>
                ExpenseRecord.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort by date in memory
        expenses.sort((a, b) => b.date.compareTo(a.date));
        return expenses;
      });
    } catch (e) {
      debugPrint('Error getting vehicle expenses: $e');
      return Stream.value([]);
    }
  }

  // Update an expense record
  Future<void> updateExpense(ExpenseRecord expense) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message: 'No user is logged in. Please log in to update an expense.',
        );
      }

      await _expensesCollection.doc(expense.id).update(expense.toMap());
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  // Delete an expense record
  Future<void> deleteExpense(String expenseId) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message: 'No user is logged in. Please log in to delete an expense.',
        );
      }

      await _expensesCollection.doc(expenseId).delete();
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  // Get expense summary by category for a date range
  Future<Map<String, double>> getExpenseSummary(
      DateTime startDate, DateTime endDate,
      {String? vehicleId}) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getExpenseSummary: No user logged in');
        return {};
      }

      // Simple query that only filters by userId
      Query query = _expensesCollection.where('userId', isEqualTo: userId);

      // If vehicle ID is provided, add that filter
      if (vehicleId != null) {
        query = query.where('vehicleId', isEqualTo: vehicleId);
      }

      final snapshot = await query.get();
      final allExpenses = snapshot.docs
          .map((doc) =>
              ExpenseRecord.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter by date range in memory
      final filteredExpenses = allExpenses
          .where((expense) =>
              (expense.date.isAfter(startDate) ||
                  expense.date.isAtSameMomentAs(startDate)) &&
              (expense.date.isBefore(endDate) ||
                  expense.date.isAtSameMomentAs(endDate)))
          .toList();

      // Calculate totals by category
      final summary = <String, double>{};
      for (var expense in filteredExpenses) {
        // Map expense type to category
        String category = getExpenseCategory(expense.expenseType);
        summary[category] = (summary[category] ?? 0) + expense.amount;
      }

      return summary;
    } catch (e) {
      debugPrint('Error getting expense summary: $e');
      return {};
    }
  }

  // Helper method to map expense types to categories
  String getExpenseCategory(String expenseType) {
    // Normalize the expense type
    String normalizedType = expenseType.toLowerCase().trim();
    normalizedType = normalizedType.replaceAll(' ', '_');
    
    // Map of expense types to categories
    final Map<String, String> categoryMap = {
      // Maintenance related
      'oil_change': 'Maintenance',
      'oilchange': 'Maintenance',
      'engine_oil': 'Maintenance',
      'engineoil': 'Maintenance',
      'tire_rotation': 'Maintenance',
      'tirerotation': 'Maintenance',
      'brake_service': 'Maintenance',
      'brakeservice': 'Maintenance',
      'air_filter': 'Maintenance',
      'airfilter': 'Maintenance',
      'spark_plugs': 'Maintenance',
      'sparkplugs': 'Maintenance',
      'transmission_fluid': 'Maintenance',
      'transmissionfluid': 'Maintenance',
      'coolant': 'Maintenance',
      'battery': 'Maintenance',
      'general_maintenance': 'Maintenance',
      'generalmaintenance': 'Maintenance',
      'maintenance': 'Maintenance',
      'service': 'Maintenance',
      'regular_service': 'Maintenance',
      'regularservice': 'Maintenance',
      'periodic_service': 'Maintenance',
      'periodicservice': 'Maintenance',
      'scheduled_service': 'Maintenance',
      'scheduledservice': 'Maintenance',
      'routine_service': 'Maintenance',
      'routineservice': 'Maintenance',

      // Fuel related
      'fuel': 'Fuel',
      'gasoline': 'Fuel',
      'diesel': 'Fuel',
      'electric_charging': 'Fuel',
      'electriccharging': 'Fuel',
      'charging': 'Fuel',
      'gas': 'Fuel',

      // Insurance related
      'insurance': 'Insurance',
      'car_insurance': 'Insurance',
      'carinsurance': 'Insurance',
      'liability': 'Insurance',
      'comprehensive': 'Insurance',
      'coverage': 'Insurance',

      // Registration and taxes
      'registration': 'Registration & Taxes',
      'tax': 'Registration & Taxes',
      'taxes': 'Registration & Taxes',
      'license': 'Registration & Taxes',
      'emission_test': 'Registration & Taxes',
      'emissiontest': 'Registration & Taxes',
      'inspection': 'Registration & Taxes',

      // Repairs
      'repair': 'Repairs',
      'repairs': 'Repairs',
      'body_work': 'Repairs',
      'bodywork': 'Repairs',
      'paint': 'Repairs',
      'dent_repair': 'Repairs',
      'dentrepair': 'Repairs',
      'collision': 'Repairs',
      'accident': 'Repairs',

      // Accessories and upgrades
      'accessory': 'Accessories & Upgrades',
      'accessories': 'Accessories & Upgrades',
      'upgrade': 'Accessories & Upgrades',
      'upgrades': 'Accessories & Upgrades',
      'modification': 'Accessories & Upgrades',
      'modifications': 'Accessories & Upgrades',
      'parts': 'Accessories & Upgrades',
      'equipment': 'Accessories & Upgrades',

      // Cleaning and detailing
      'wash': 'Cleaning & Detailing',
      'cleaning': 'Cleaning & Detailing',
      'detailing': 'Cleaning & Detailing',
      'car_wash': 'Cleaning & Detailing',
      'carwash': 'Cleaning & Detailing',
      'polish': 'Cleaning & Detailing',
      'wax': 'Cleaning & Detailing',

      // Other
      'other': 'Other',
      'miscellaneous': 'Other',
      'misc': 'Other',
    };

    // First try exact match
    if (categoryMap.containsKey(normalizedType)) {
      return categoryMap[normalizedType]!;
    }

    // Then try partial matches for maintenance
    if (normalizedType.contains('maintenance') || 
        normalizedType.contains('service') ||
        normalizedType.contains('oil') ||
        normalizedType.contains('filter') ||
        normalizedType.contains('fluid') ||
        normalizedType.contains('tire') ||
        normalizedType.contains('brake') ||
        normalizedType.contains('battery') ||
        normalizedType.contains('coolant')) {
      return 'Maintenance';
    }

    // Then try partial matches for repairs
    if (normalizedType.contains('repair') ||
        normalizedType.contains('fix') ||
        normalizedType.contains('damage') ||
        normalizedType.contains('broken')) {
      return 'Repairs';
    }

    // Then try partial matches for fuel
    if (normalizedType.contains('fuel') ||
        normalizedType.contains('gas') ||
        normalizedType.contains('charge')) {
      return 'Fuel';
    }

    // Default to Other if no match found
    return 'Other';
  }

  // MAINTENANCE RECORDS

  // Add a new maintenance record
  Future<MaintenanceRecord> addMaintenanceRecord(
      MaintenanceRecord record) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message:
              'No user is logged in. Please log in to add a maintenance record.',
        );
      }

      final docRef = _maintenanceCollection.doc();
      final newRecord = MaintenanceRecord(
        id: docRef.id,
        vehicleId: record.vehicleId,
        userId: userId,
        serviceType: record.serviceType,
        date: record.date,
        cost: record.cost,
        description: record.description,
        serviceProvider: record.serviceProvider,
        invoiceImageUrl: record.invoiceImageUrl,
        additionalDetails: record.additionalDetails,
      );

      await docRef.set(newRecord.toMap());
      return newRecord;
    } catch (e) {
      debugPrint('Error adding maintenance record: $e');
      rethrow;
    }
  }

  // Get all maintenance records for current user
  Stream<List<MaintenanceRecord>> getUserMaintenanceRecords() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getUserMaintenanceRecords: No user logged in');
        return Stream.value([]);
      }

      return _maintenanceCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final records = snapshot.docs
            .map((doc) =>
                MaintenanceRecord.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort by date in memory
        records.sort((a, b) => b.date.compareTo(a.date));

        return records;
      });
    } catch (e) {
      debugPrint('Error getting maintenance records: $e');
      return Stream.value([]);
    }
  }

  // Get maintenance records for a specific vehicle
  Stream<List<MaintenanceRecord>> getVehicleMaintenanceRecords(
      String vehicleId) {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getVehicleMaintenanceRecords: No user logged in');
        return Stream.value([]);
      }

      return _maintenanceCollection
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .snapshots()
          .map((snapshot) {
        final records = snapshot.docs
            .map((doc) =>
                MaintenanceRecord.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort by date in memory
        records.sort((a, b) => b.date.compareTo(a.date));

        return records;
      });
    } catch (e) {
      debugPrint('Error getting vehicle maintenance records: $e');
      return Stream.value([]);
    }
  }

  // Update a maintenance record
  Future<void> updateMaintenanceRecord(MaintenanceRecord record) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message:
              'No user is logged in. Please log in to update a maintenance record.',
        );
      }

      await _maintenanceCollection.doc(record.id).update(record.toMap());
    } catch (e) {
      debugPrint('Error updating maintenance record: $e');
      rethrow;
    }
  }

  // Delete a maintenance record
  Future<void> deleteMaintenanceRecord(String recordId) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message:
              'No user is logged in. Please log in to delete a maintenance record.',
        );
      }

      await _maintenanceCollection.doc(recordId).delete();
    } catch (e) {
      debugPrint('Error deleting maintenance record: $e');
      rethrow;
    }
  }

  // REMINDERS MANAGEMENT

  // Add a new reminder
  Future<MaintenanceReminder> addReminder(MaintenanceReminder reminder) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message: 'No user is logged in. Please log in to add a reminder.',
        );
      }

      await _remindersCollection.doc(reminder.id).set(reminder.toMap());
      return reminder;
    } catch (e) {
      debugPrint('Error adding reminder: $e');
      rethrow;
    }
  }

  // Update an existing reminder
  Future<void> updateReminder(MaintenanceReminder reminder) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message: 'No user is logged in. Please log in to update a reminder.',
        );
      }

      await _remindersCollection.doc(reminder.id).update(reminder.toMap());
    } catch (e) {
      debugPrint('Error updating reminder: $e');
      rethrow;
    }
  }

  // Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      if (currentUserId == null) {
        throw FirebaseException(
          plugin: 'maintenance_service',
          code: 'no-user-logged-in',
          message: 'No user is logged in. Please log in to delete a reminder.',
        );
      }

      await _remindersCollection.doc(reminderId).delete();
    } catch (e) {
      debugPrint('Error deleting reminder: $e');
      rethrow;
    }
  }

  // Get all reminders for the current user
  Stream<List<MaintenanceReminder>> getUserReminders() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getUserReminders: No user logged in');
        return Stream.value([]);
      }

      return _remindersCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final reminders = snapshot.docs
            .map((doc) =>
                MaintenanceReminder.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort by due date
        reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return reminders;
      });
    } catch (e) {
      debugPrint('Error getting user reminders: $e');
      return Stream.value([]);
    }
  }

  // Get reminders for a specific vehicle
  Stream<List<MaintenanceReminder>> getVehicleReminders(String vehicleId) {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getVehicleReminders: No user logged in');
        return Stream.value([]);
      }

      return _remindersCollection
          .where('userId', isEqualTo: userId)
          .where('vehicleId', isEqualTo: vehicleId)
          .snapshots()
          .map((snapshot) {
        final reminders = snapshot.docs
            .map((doc) =>
                MaintenanceReminder.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Sort by due date
        reminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        return reminders;
      });
    } catch (e) {
      debugPrint('Error getting vehicle reminders: $e');
      return Stream.value([]);
    }
  }

  // Get upcoming reminders
  Stream<List<MaintenanceReminder>> getUpcomingReminders() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getUpcomingReminders: No user logged in');
        return Stream.value([]);
      }

      // Simple query that only filters by userId and isCompleted
      // Then filter by date in memory to avoid index requirements
      return _remindersCollection
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        final now = DateTime.now();
        final allReminders = snapshot.docs
            .map((doc) => MaintenanceReminder.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Filter upcoming reminders in memory
        final upcomingReminders = allReminders
            .where((reminder) => reminder.dueDate.isAfter(now) || reminder.dueDate.isAtSameMomentAs(now))
            .toList();

        // Sort by due date
        upcomingReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return upcomingReminders;
      });
    } catch (e) {
      debugPrint('Error getting upcoming reminders: $e');
      return Stream.value([]);
    }
  }

  // Get overdue reminders
  Stream<List<MaintenanceReminder>> getOverdueReminders() {
    try {
      final userId = currentUserId;
      if (userId == null) {
        debugPrint('getOverdueReminders: No user logged in');
        return Stream.value([]);
      }

      // Simple query that only filters by userId and isCompleted
      // Then filter by date in memory to avoid index requirements
      return _remindersCollection
          .where('userId', isEqualTo: userId)
          .where('isCompleted', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        final now = DateTime.now();
        final allReminders = snapshot.docs
            .map((doc) => MaintenanceReminder.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        // Filter overdue reminders in memory
        final overdueReminders = allReminders
            .where((reminder) => reminder.dueDate.isBefore(now))
            .toList();

        // Sort by due date
        overdueReminders.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return overdueReminders;
      });
    } catch (e) {
      debugPrint('Error getting overdue reminders: $e');
      return Stream.value([]);
    }
  }
}
