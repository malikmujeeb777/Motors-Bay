import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/reminders/reminders_screen.dart';

class UpcomingRemindersWidget extends StatefulWidget {
  final String vehicleId;
  final int maxItems;
  final bool showViewAll;

  const UpcomingRemindersWidget({
    super.key,
    required this.vehicleId,
    this.maxItems = 3,
    this.showViewAll = true,
  });

  @override
  State<UpcomingRemindersWidget> createState() =>
      _UpcomingRemindersWidgetState();
}

class _UpcomingRemindersWidgetState extends State<UpcomingRemindersWidget> {
  final MaintenanceService _maintenanceService = MaintenanceService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MaintenanceReminder>>(
      stream: _maintenanceService.getVehicleReminders(widget.vehicleId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              'Error loading reminders: ${snapshot.error}',
              style: TextStyle(color: Colors.red.shade800),
            ),
          );
        }

        final reminders = snapshot.data ?? [];

        // Filter only upcoming (not completed) reminders and sort by due date
        final upcomingReminders = reminders
            .where((r) => !r.isCompleted)
            .toList()
          ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

        // Limit to maxItems
        final limitedReminders =
            upcomingReminders.take(widget.maxItems).toList();

        if (limitedReminders.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No upcoming service reminders',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Upcoming Service Reminders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: limitedReminders.length,
              itemBuilder: (context, index) {
                return _buildReminderTile(limitedReminders[index]);
              },
            ),
            if (widget.showViewAll &&
                upcomingReminders.length > widget.maxItems)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RemindersScreen(
                          vehicleId: widget.vehicleId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('View all reminders'),
                  style: TextButton.styleFrom(
                    foregroundColor: LightColorsPalate.primaryColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildReminderTile(MaintenanceReminder reminder) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();
    final difference = reminder.dueDate.difference(now).inDays;

    String dueText;
    Color statusColor;

    if (difference < 0) {
      dueText =
          'Overdue by ${-difference} ${-difference == 1 ? 'day' : 'days'}';
      statusColor = Colors.red;
    } else if (difference == 0) {
      dueText = 'Due today';
      statusColor = Colors.orange;
    } else {
      dueText = 'Due in $difference ${difference == 1 ? 'day' : 'days'}';
      statusColor = difference <= 7 ? Colors.orange : Colors.green;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            reminder.reminderType == 'mileage-based'
                ? Icons.speed
                : Icons.calendar_today,
            color: statusColor,
          ),
        ),
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              dueText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Due date: ${dateFormatter.format(reminder.dueDate)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RemindersScreen(
                vehicleId: widget.vehicleId,
              ),
            ),
          );
        },
      ),
    );
  }
}
