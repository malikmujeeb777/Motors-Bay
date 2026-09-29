import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/expense_tracking/expense_list.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/obd/obd_scanner_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/reminders/reminders_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/reports/expense_reports.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/custom_loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:async';

class MaintenanceHomeScreen extends StatefulWidget {
  const MaintenanceHomeScreen({super.key});

  @override
  State<MaintenanceHomeScreen> createState() => _MaintenanceHomeScreenState();
}

class _MaintenanceHomeScreenState extends State<MaintenanceHomeScreen> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _overdueRemindersCount = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOverdueReminders();
  }

  Future<void> _loadOverdueReminders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (!_maintenanceService.isUserAuthenticated) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Please log in to view maintenance data";
        });
        return;
      }

      // Set a default value upfront so the UI can load even if we hit errors
      setState(() {
        _overdueRemindersCount = 0;
        _isLoading = false;
      });

      // Then start listening for updates
      _maintenanceService.getOverdueReminders().listen(
        (reminders) {
          if (mounted) {
            setState(() {
              _overdueRemindersCount = reminders.length;
            });
          }
        },
        onError: (error) {
          if (mounted) {
            // Don't show error, just log it - we already have default values
            debugPrint("Error loading reminders: $error");
          }
        },
      );
    } catch (e) {
      if (mounted) {
        // Keep the UI working even with errors
        debugPrint("Error in loadOverdueReminders: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Maintenance'),
        backgroundColor: LightColorsPalate.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CustomLoader(
                outerSize: 100,
                innerSize: 40,
                opacity: 0.7,
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : _buildMainContent(isSmallScreen),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadOverdueReminders,
              style: ElevatedButton.styleFrom(
                backgroundColor: LightColorsPalate.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent([bool isSmallScreen = false]) {
    final screenSize = MediaQuery.of(context).size;
    // Calculate the ideal height for the grid based on available space
    final gridHeight = screenSize.height * 0.45;

    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const SizedBox(height: 8),
              Text(
                'Car Maintenance & Expenses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Track expenses, set reminders, and maintain service history for your vehicles.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: LightColorsPalate.tertiaryColor,
                    ),
              ),
              const SizedBox(height: 16),

              // Reminder alert
              if (_overdueRemindersCount > 0) ...[
                _buildOverdueRemindersAlert(),
                const SizedBox(height: 16),
              ],

              // Main feature cards
              Container(
                constraints: BoxConstraints(
                  maxHeight: gridHeight, // Dynamic height based on screen
                ),
                child: GridView.count(
                  crossAxisCount: isSmallScreen
                      ? 1
                      : 2, // Single column on very small screens
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: isSmallScreen ? 12 : 16,
                  mainAxisSpacing: isSmallScreen ? 12 : 16,
                  childAspectRatio: isSmallScreen
                      ? 3
                      : 1.2, // Different aspect ratio for small screens
                  padding: EdgeInsets.zero,
                  children: [
                    _buildFeatureCard(
                      title: 'Expense Tracking',
                      icon: Icons.monetization_on,
                      color: LightColorsPalate.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ExpenseListScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildFeatureCard(
                      title: 'Service Reminders',
                      icon: Icons.notifications_active,
                      color: Colors.amber,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RemindersScreen()),
                        );
                      },
                      badge: _overdueRemindersCount > 0
                          ? _overdueRemindersCount.toString()
                          : null,
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildFeatureCard(
                      title: 'OBD-II Scanner',
                      icon: Icons.bluetooth_searching,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const OBDScannerScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    _buildFeatureCard(
                      title: 'Expense Reports',
                      icon: Icons.bar_chart,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ExpenseReportsScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverdueRemindersAlert() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RemindersScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha((0.1 * 255).round()),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Overdue Reminders',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_overdueRemindersCount ${_overdueRemindersCount == 1 ? 'service needs' : 'services need'} attention',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade800,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
    bool isSmallScreen = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shadowColor: color.withAlpha((0.3 * 255).round()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withAlpha((0.1 * 255).round()),
                    color.withAlpha((0.05 * 255).round()),
                  ],
                ),
                border: Border.all(
                  color: color.withAlpha((0.2 * 255).round()),
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(
                        icon,
                        size: 36,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
