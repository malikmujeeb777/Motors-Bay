import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';

class MaintenanceHistoryScreen extends StatefulWidget {
  final String? vehicleId;

  const MaintenanceHistoryScreen({super.key, this.vehicleId});

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Oil Change',
    'Tire Service',
    'Brake Service',
    'Engine',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance History'),
        backgroundColor: LightColorsPalate.backgroundColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) {
              return _filterOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Row(
                    children: [
                      option == _selectedFilter
                          ? const Icon(Icons.check,
                              color: LightColorsPalate.primaryColor)
                          : const SizedBox(width: 24),
                      const SizedBox(width: 8),
                      Text(option),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MaintenanceRecord>>(
        stream: widget.vehicleId != null
            ? _maintenanceService
                .getVehicleMaintenanceRecords(widget.vehicleId!)
            : _maintenanceService.getUserMaintenanceRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                  const Icon(
                    Icons.build_outlined,
                    size: 64,
                    color: LightColorsPalate.tertiaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No maintenance records yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first record',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LightColorsPalate.tertiaryColor,
                        ),
                  ),
                ],
              ),
            );
          }

          // Group records by year and month
          final records = snapshot.data!;
          final filteredRecords = _selectedFilter == 'All'
              ? records
              : records
                  .where((r) => r.serviceType
                      .toLowerCase()
                      .contains(_selectedFilter.toLowerCase()))
                  .toList();

          if (filteredRecords.isEmpty) {
            return Center(
              child: Text(
                'No $_selectedFilter maintenance records found',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          // Group by year and month
          final groupedRecords = <String, List<MaintenanceRecord>>{};
          for (var record in filteredRecords) {
            final yearMonth = DateFormat('MMMM yyyy').format(record.date);
            if (!groupedRecords.containsKey(yearMonth)) {
              groupedRecords[yearMonth] = [];
            }
            groupedRecords[yearMonth]!.add(record);
          }

          // Sort keys by date (newest first)
          final sortedKeys = groupedRecords.keys.toList()
            ..sort((a, b) {
              final dateA = DateFormat('MMMM yyyy').parse(a);
              final dateB = DateFormat('MMMM yyyy').parse(b);
              return dateB.compareTo(dateA);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final yearMonth = sortedKeys[index];
              final monthRecords = groupedRecords[yearMonth]!;

              // Sort records by date (newest first)
              monthRecords.sort((a, b) => b.date.compareTo(a.date));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 8),
                    child: Text(
                      yearMonth,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: LightColorsPalate.primaryColor,
                          ),
                    ),
                  ),
                  ...monthRecords
                      .map((record) => _buildMaintenanceCard(record))
                      .toList(),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add maintenance record screen when implemented
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add Maintenance Record coming soon'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        backgroundColor: LightColorsPalate.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMaintenanceCard(MaintenanceRecord record) {
    final dateFormatter = DateFormat('MMM dd, yyyy');
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    // Define service type icon based on the service
    IconData typeIcon;
    Color typeColor;

    final serviceType = record.serviceType.toLowerCase();
    if (serviceType.contains('oil')) {
      typeIcon = Icons.oil_barrel;
      typeColor = Colors.amber;
    } else if (serviceType.contains('tire') || serviceType.contains('wheel')) {
      typeIcon = Icons.tire_repair;
      typeColor = Colors.blue;
    } else if (serviceType.contains('brake')) {
      typeIcon = Icons.do_not_step;
      typeColor = Colors.red;
    } else if (serviceType.contains('engine')) {
      typeIcon = Icons.engineering;
      typeColor = Colors.orange;
    } else if (serviceType.contains('filter')) {
      typeIcon = Icons.filter_alt;
      typeColor = Colors.green;
    } else if (serviceType.contains('battery')) {
      typeIcon = Icons.battery_full;
      typeColor = Colors.purple;
    } else {
      typeIcon = Icons.build;
      typeColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to maintenance record details when implemented
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maintenance record details coming soon'),
              duration: Duration(seconds: 2),
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
                    backgroundColor: typeColor.withOpacity(0.1),
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.serviceType,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: LightColorsPalate.tertiaryColor,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: LightColorsPalate.tertiaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormatter.format(record.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: LightColorsPalate.tertiaryColor,
                                  ),
                            ),
                            if (record.cost != null) ...[
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.attach_money,
                                size: 14,
                                color: LightColorsPalate.tertiaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatter.format(record.cost),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: LightColorsPalate.tertiaryColor,
                                    ),
                              ),
                            ],
                            if (record.serviceProvider != null &&
                                record.serviceProvider!.isNotEmpty) ...[
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.store,
                                size: 14,
                                color: LightColorsPalate.tertiaryColor,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  record.serviceProvider!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: LightColorsPalate.tertiaryColor,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (record.invoiceImageUrl != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Show invoice image when implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View invoice coming soon'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('View Invoice'),
                      style: TextButton.styleFrom(
                        foregroundColor: LightColorsPalate.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
