import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/expense_tracking/add_expense.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/maintenance/reminders/reminders_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/gear_loading.dart';

class ExpenseListScreen extends StatefulWidget {
  final String? vehicleId;

  const ExpenseListScreen({super.key, this.vehicleId});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Fuel',
    'Maintenance',
    'Repair',
    'Insurance',
    'Other'
  ];

  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    if (!_maintenanceService.isUserAuthenticated) {
      setState(() {
        _errorMessage = "Please log in to view expenses";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracking'),
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
      body: _errorMessage != null
          ? _buildErrorView()
          : StreamBuilder<List<ExpenseRecord>>(
              stream: widget.vehicleId != null
                  ? _maintenanceService.getVehicleExpenses(widget.vehicleId!)
                  : _maintenanceService.getUserExpenses(),
              builder: (context, snapshot) {
                // Handle stream connection states
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const GearLoading();
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {});
                            },
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

                final expenses = snapshot.data ?? [];

                // Filter expenses based on selection
                final filteredExpenses = _selectedFilter == 'All'
                    ? expenses
                    : expenses
                        .where((e) =>
                            e.expenseType.toLowerCase() ==
                            _selectedFilter.toLowerCase())
                        .toList();

                // Show empty state if no expenses
                if (expenses.isEmpty) {
                  return _buildEmptyState();
                }

                // Show "no results" state if filtered list is empty
                if (filteredExpenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.filter_list,
                          size: 48,
                          color: LightColorsPalate.tertiaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No $_selectedFilter expenses found',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try selecting a different filter',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: LightColorsPalate.tertiaryColor,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All';
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: LightColorsPalate.primaryColor,
                          ),
                          child: const Text('Show All Expenses'),
                        ),
                      ],
                    ),
                  );
                }

                // Show expense list
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddExpenseScreen(vehicleId: widget.vehicleId),
            ),
          );

          // Refresh the list if we got a result back (new expense added)
          if (result != null) {
            // Force refresh to show the new expense
            setState(() {});

            // Check if a reminder was created and show a more detailed message
            if (result is Map && result['reminder'] != null) {
              final reminder = result['reminder'] as MaintenanceReminder;
              final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Service reminder set for ${dateFormat.format(reminder.dueDate)}',
                  ),
                  backgroundColor: Colors.blue,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'VIEW',
                    textColor: Colors.white,
                    onPressed: () {
                      // Navigate to reminders screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RemindersScreen(),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          }
        },
        backgroundColor: LightColorsPalate.primaryColor,
        child: const Icon(Icons.add),
      ),
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
              _errorMessage ?? 'An unknown error occurred',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                  _checkAuthentication();
                });
              },
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.monetization_on_outlined,
            size: 64,
            color: LightColorsPalate.tertiaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses recorded yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first expense',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: LightColorsPalate.tertiaryColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseRecord expense) {
    final formatter = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ');
    final dateFormatter = DateFormat('MMM dd, yyyy');

    // Define expense type icon
    IconData typeIcon;
    Color typeColor;

    switch (expense.expenseType.toLowerCase()) {
      case 'fuel':
        typeIcon = Icons.local_gas_station;
        typeColor = Colors.red;
        break;
      case 'maintenance':
        typeIcon = Icons.build;
        typeColor = Colors.blue;
        break;
      case 'repair':
        typeIcon = Icons.handyman;
        typeColor = Colors.orange;
        break;
      case 'insurance':
        typeIcon = Icons.policy;
        typeColor = Colors.green;
        break;
      default:
        typeIcon = Icons.receipt_long;
        typeColor = Colors.purple;
    }

    return Dismissible(
      key: Key(expense.id),
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
        // Show confirmation dialog
        return await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Expense'),
                content: const Text('Are you sure you want to delete this expense?'),
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
            ) ??
            false;
      },
      onDismissed: (direction) {
        // Delete the expense
        _maintenanceService.deleteExpense(expense.id).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted'),
              backgroundColor: LightColorsPalate.successColor,
            ),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting expense: $error'),
              backgroundColor: LightColorsPalate.errorColor,
            ),
          );
          // Refresh to show the expense again since deletion failed
          setState(() {});
        });
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
            // Show expense details in a dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(expense.description),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Amount: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: formatter.format(expense.amount)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Date: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: dateFormatter.format(expense.date)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87),
                        children: [
                          const TextSpan(
                            text: 'Category: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: expense.expenseType.substring(0, 1).toUpperCase() +
                                expense.expenseType.substring(1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the details dialog
                      // Navigate to edit screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(
                            vehicleId: widget.vehicleId,
                            expenseToEdit: expense,
                          ),
                        ),
                      ).then((result) {
                        if (result != null) {
                          setState(() {}); // Refresh the list
                        }
                      });
                    },
                    child: const Text('Edit'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the details dialog
                      // Show delete confirmation
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Expense'),
                          content: const Text('Are you sure you want to delete this expense?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close confirmation dialog
                                _maintenanceService.deleteExpense(expense.id).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Expense deleted'),
                                      backgroundColor: LightColorsPalate.successColor,
                                    ),
                                  );
                                  setState(() {}); // Refresh the list
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error deleting expense: $error'),
                                      backgroundColor: LightColorsPalate.errorColor,
                                    ),
                                  );
                                });
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
                      backgroundColor: typeColor.withAlpha((0.1 * 255).round()),
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
                            expense.description,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormatter.format(expense.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: LightColorsPalate.tertiaryColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                        Text(
                          formatter.format(expense.amount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: LightColorsPalate.primaryColor,
                            fontWeight: FontWeight.bold,
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
