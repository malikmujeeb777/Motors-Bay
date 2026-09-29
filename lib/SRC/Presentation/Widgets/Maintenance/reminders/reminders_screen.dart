import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';
import 'package:motorsbay1/SRC/Domain/Services/auto_reminder_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/reminders/service_reminder_form.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/gear_loading.dart';

class RemindersScreen extends StatefulWidget {
  final String? vehicleId;

  const RemindersScreen({super.key, this.vehicleId});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen>
    with SingleTickerProviderStateMixin {
  final MaintenanceService _maintenanceService = MaintenanceService();
  final AutoReminderService _autoReminderService = AutoReminderService();
  late TabController _tabController;
  bool _isAutoReminderEnabled = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeAutoReminders();
  }

  Future<void> _initializeAutoReminders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (!_maintenanceService.isUserAuthenticated) {
        setState(() {
          _errorMessage = 'Please log in to view maintenance reminders';
          _isLoading = false;
        });
        return;
      }

    // Start listening for new expenses/maintenance records to generate reminders
    _autoReminderService.startAutoReminderGeneration();
      setState(() {
    _isAutoReminderEnabled = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing reminders: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Navigate to the add reminder form
  void _navigateToAddReminderForm(BuildContext context) {
    if (widget.vehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a vehicle first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceReminderForm(
          vehicleId: widget.vehicleId!,
        ),
      ),
    );
  }

  // Navigate to edit a reminder
  void _navigateToEditReminder(
      BuildContext context, MaintenanceReminder reminder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceReminderForm(
          vehicleId: reminder.vehicleId,
          reminderToEdit: reminder,
        ),
      ),
    );
  }

  // Mark a reminder as completed
  Future<void> _markReminderCompleted(MaintenanceReminder reminder) async {
    try {
      final updatedReminder = reminder.copyWith(
        isCompleted: true,
        completedDate: DateTime.now(),
      );

      await _maintenanceService.updateReminder(updatedReminder);
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder marked as completed'),
          duration: Duration(seconds: 2),
        ),
      );
      }
    } catch (e) {
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      }
    }
  }

  // Delete a reminder
  Future<void> _deleteReminder(String reminderId) async {
    try {
      await _maintenanceService.deleteReminder(reminderId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted'),
            backgroundColor: LightColorsPalate.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting reminder: $e'),
            backgroundColor: LightColorsPalate.errorColor,
          ),
        );
      }
    }
  }

  // Toggle auto-reminder functionality
  void _toggleAutoReminder() {
    setState(() {
      _isAutoReminderEnabled = !_isAutoReminderEnabled;
    });

    if (_isAutoReminderEnabled) {
      _autoReminderService.startAutoReminderGeneration();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-reminders enabled'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Auto-reminders disabled'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Reminders'),
        backgroundColor: LightColorsPalate.backgroundColor,
        elevation: 0,
        actions: [
          // Auto-reminder toggle
          IconButton(
            icon: Icon(
              _isAutoReminderEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: _isAutoReminderEnabled ? Colors.green : Colors.grey,
            ),
            onPressed: _toggleAutoReminder,
            tooltip: _isAutoReminderEnabled
                ? 'Auto-reminders enabled'
                : 'Auto-reminders disabled',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: LightColorsPalate.primaryColor,
          labelColor: LightColorsPalate.primaryColor,
          unselectedLabelColor: LightColorsPalate.tertiaryColor,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersList(isOverdue: false),
          _buildRemindersList(isOverdue: true),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddReminderForm(context),
        backgroundColor: LightColorsPalate.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRemindersList({required bool isOverdue}) {
    return StreamBuilder<List<MaintenanceReminder>>(
      stream: isOverdue
          ? _maintenanceService.getOverdueReminders()
          : _maintenanceService.getUpcomingReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GearLoading();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: LightColorsPalate.errorColor),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOverdue ? Icons.check_circle_outline : Icons.calendar_today,
                  size: 64,
                  color: LightColorsPalate.tertiaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  isOverdue ? 'No overdue reminders' : 'No upcoming reminders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  isOverdue
                      ? 'Great job! You\'re up to date on your maintenance'
                      : 'Tap the + button to add a service reminder',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LightColorsPalate.tertiaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (!isOverdue) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAddReminderForm(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Reminder'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LightColorsPalate.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        final reminders = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return _buildReminderCard(reminder);
          },
        );
      },
    );
  }

  Widget _buildReminderCard(MaintenanceReminder reminder) {
    final daysLeft = reminder.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isDueSoon = daysLeft >= 0 && daysLeft <= 7;

    return Dismissible(
      key: Key(reminder.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Reminder'),
                content: const Text('Are you sure you want to delete this reminder?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
        ) ?? false;
      },
      onDismissed: (direction) {
        _deleteReminder(reminder.id);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(reminder.title),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Due Date: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: DateFormat('MMM dd, yyyy').format(reminder.dueDate)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Service Type: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: reminder.serviceType),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Status: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: isOverdue ? 'Overdue' : (isDueSoon ? 'Due Soon' : 'Upcoming'),
                            style: TextStyle(
                              color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (reminder.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            const TextSpan(
                              text: 'Description: ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: reminder.description),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  if (!reminder.isCompleted)
                  TextButton(
                    onPressed: () {
                        Navigator.of(context).pop();
                        _markReminderCompleted(reminder);
                              },
                      child: const Text('Mark as Completed'),
                  ),
                ],
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: (isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.green)).withAlpha((0.1 * 255).round()),
                      child: Icon(
                        reminder.reminderType == 'mileage-based' ? Icons.speed : Icons.build,
                        color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.green),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reminder.serviceType,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: LightColorsPalate.tertiaryColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(reminder.dueDate),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: LightColorsPalate.tertiaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.green)).withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isOverdue ? 'Overdue' : (isDueSoon ? 'Due Soon' : 'Upcoming'),
                        style: TextStyle(
                          color: isOverdue ? Colors.red : (isDueSoon ? Colors.orange : Colors.green),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
