import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_details_model.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';
import 'package:motorsbay1/SRC/Domain/Services/auto_reminder_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/gear_loading.dart';
import 'package:uuid/uuid.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? vehicleId;
  final ExpenseRecord? expenseToEdit;

  const AddExpenseScreen({
    super.key, 
    this.vehicleId,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final MaintenanceService _maintenanceService = MaintenanceService();
  final AutoReminderService _autoReminderService = AutoReminderService();

  // Form data
  String _selectedVehicleId = '';
  String _vehicleName = '';
  String _expenseType = 'fuel';
  String _expenseSubcategory = '';
  final _descriptionController = TextEditingController();
  double _amount = 0.0;
  DateTime _date = DateTime.now();
  int _reminderIntervalDays = 180; // Default 6 months

  // UI state
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoadingVehicles = true;
  List<Map<String, dynamic>> _userVehicles = [];
  bool _createReminder = true; // Default to creating a reminder

  // Expense type options with subcategories
  final Map<String, List<Map<String, dynamic>>> _expenseCategories = {
    'fuel': [
      {'id': 'regular', 'name': 'Regular Unleaded'},
      {'id': 'premium', 'name': 'Premium Unleaded'},
      {'id': 'diesel', 'name': 'Diesel'},
      {'id': 'electric', 'name': 'Electric Charging'},
      {'id': 'other', 'name': 'Other Fuel'},
    ],
    'maintenance': [
      {'id': 'oil_change', 'name': 'Oil Change'},
      {'id': 'filter_replacement', 'name': 'Filter Replacement'},
      {'id': 'tire_service', 'name': 'Tire Service'},
      {'id': 'battery', 'name': 'Battery'},
      {'id': 'fluid_change', 'name': 'Fluid Change'},
      {'id': 'general_service', 'name': 'General Service'},
      {'id': 'other', 'name': 'Other Maintenance'},
    ],
    'repair': [
      {'id': 'engine', 'name': 'Engine Repair'},
      {'id': 'transmission', 'name': 'Transmission'},
      {'id': 'brakes', 'name': 'Brakes'},
      {'id': 'suspension', 'name': 'Suspension'},
      {'id': 'electrical', 'name': 'Electrical'},
      {'id': 'body_work', 'name': 'Body Work'},
      {'id': 'other', 'name': 'Other Repair'},
    ],
    'insurance': [
      {'id': 'premium', 'name': 'Insurance Premium'},
      {'id': 'deductible', 'name': 'Deductible Payment'},
      {'id': 'other', 'name': 'Other Insurance'},
    ],
    'other': [
      {'id': 'registration', 'name': 'Registration'},
      {'id': 'inspection', 'name': 'Inspection'},
      {'id': 'parking', 'name': 'Parking'},
      {'id': 'tolls', 'name': 'Tolls'},
      {'id': 'car_wash', 'name': 'Car Wash'},
      {'id': 'accessories', 'name': 'Accessories'},
      {'id': 'other', 'name': 'Other Expense'},
    ],
  };

  // Expense type options
  final List<Map<String, dynamic>> _expenseTypes = [
    {
      'type': 'fuel',
      'label': 'Fuel',
      'icon': Icons.local_gas_station,
      'color': Colors.red,
    },
    {
      'type': 'maintenance',
      'label': 'Maintenance',
      'icon': Icons.build,
      'color': Colors.blue,
    },
    {
      'type': 'repair',
      'label': 'Repair',
      'icon': Icons.handyman,
      'color': Colors.orange,
    },
    {
      'type': 'insurance',
      'label': 'Insurance',
      'icon': Icons.policy,
      'color': Colors.green,
    },
    {
      'type': 'other',
      'label': 'Other',
      'icon': Icons.receipt_long,
      'color': Colors.purple,
    },
  ];

  // Reminder interval options
  final List<Map<String, dynamic>> _reminderIntervals = [
    {'days': 30, 'label': '1 Month'},
    {'days': 90, 'label': '3 Months'},
    {'days': 180, 'label': '6 Months'},
    {'days': 365, 'label': '1 Year'},
    {'days': 730, 'label': '2 Years'},
  ];

  @override
  void initState() {
    super.initState();
    // Set vehicle ID if provided
    if (widget.vehicleId != null) {
      _selectedVehicleId = widget.vehicleId!;
      _loadVehicleDetails(widget.vehicleId!);
    } else {
      _loadUserVehicles();
    }

    // Initialize form with existing expense data if editing
    if (widget.expenseToEdit != null) {
      final expense = widget.expenseToEdit!;
      _selectedVehicleId = expense.vehicleId;
      _expenseType = expense.expenseType.toLowerCase();
      _descriptionController.text = expense.description;
      _amount = expense.amount;
      _date = expense.date;
      _loadVehicleDetails(expense.vehicleId);
    } else {
      // Set default subcategory for new expense
    _expenseSubcategory = _expenseCategories[_expenseType]![0]['id'];
    }

    // Check if user is authenticated
    if (!_maintenanceService.isUserAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAuthError();
      });
    }
  }

  Future<void> _loadUserVehicles() async {
    setState(() {
      _isLoadingVehicles = true;
    });

    try {
      // This is a placeholder - in a real app, you'd fetch actual vehicles from Firebase
      // For demo purposes, we'll create a few dummy vehicles
      await Future.delayed(
          const Duration(milliseconds: 800)); // Simulate network delay

      final dummyVehicles = [
        {'id': 'vehicle_1', 'name': 'Toyota Camry', 'year': '2018'},
        {'id': 'vehicle_2', 'name': 'Honda Accord', 'year': '2020'},
        {'id': 'vehicle_3', 'name': 'Tesla Model 3', 'year': '2021'},
      ];

      setState(() {
        _userVehicles = dummyVehicles;
        _isLoadingVehicles = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingVehicles = false;
        _errorMessage = 'Error loading vehicles: $e';
      });
    }
  }

  Future<void> _loadVehicleDetails(String vehicleId) async {
    try {
      // This is a placeholder - in a real app, you'd fetch the vehicle details
      await Future.delayed(const Duration(milliseconds: 500));

      // For demo, we'll just assign a name based on ID
      final vehicleName = vehicleId == 'vehicle_1'
          ? 'Toyota Camry (2018)'
          : vehicleId == 'vehicle_2'
              ? 'Honda Accord (2020)'
              : vehicleId == 'vehicle_3'
                  ? 'Tesla Model 3 (2021)'
                  : 'Unknown Vehicle';

      setState(() {
        _vehicleName = vehicleName;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _showAuthError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Authentication Required'),
        content: const Text('You need to be logged in to add expenses.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseToEdit != null ? 'Edit Expense' : 'Add Expense'),
        backgroundColor: LightColorsPalate.backgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const GearLoading()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade800),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _errorMessage = null;
                                  });
                                },
                                color: Colors.red.shade800,
                              ),
                            ],
                          ),
                        ),

                      // Vehicle selection
                      if (widget.vehicleId == null) ...[
                        Text(
                          'Select Vehicle',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (_isLoadingVehicles)
                          const GearLoading()
                        else if (_userVehicles.isEmpty)
                          _buildAddVehicleButton()
                        else
                          Column(
                            children: [
                              ..._userVehicles
                                  .map(
                                      (vehicle) => _buildVehicleOption(vehicle))
                                  .toList(),
                              const SizedBox(height: 8),
                              _buildAddVehicleButton(),
                            ],
                          ),
                        const SizedBox(height: 24),
                      ] else if (_vehicleName.isNotEmpty) ...[
                        Text(
                          'Vehicle',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: LightColorsPalate.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: LightColorsPalate.outlineColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.directions_car,
                                color: LightColorsPalate.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _vehicleName,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Expense type selection
                      Text(
                        'Expense Type',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _expenseTypes.map((type) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _buildExpenseTypeButton(
                                type: type['type'],
                                label: type['label'],
                                icon: type['icon'],
                                color: type['color'],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Subcategory selection
                      Text(
                        'Category',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: LightColorsPalate.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: LightColorsPalate.outlineColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _expenseSubcategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down),
                            style: Theme.of(context).textTheme.bodyLarge,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _expenseSubcategory = newValue;
                                });
                              }
                            },
                            items: _expenseCategories[_expenseType]!
                                .map<DropdownMenuItem<String>>((subcategory) {
                              return DropdownMenuItem<String>(
                                value: subcategory['id'],
                                child: Text(subcategory['name']),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description (optional now that we have categories)
                      Text(
                        'Description (Optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Add additional details if needed',
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount - using a slider and preset buttons
                      Text(
                        'Amount: ${NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ').format(_amount)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),

                      // Amount preset buttons
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildAmountButton(1000),
                            _buildAmountButton(5000),
                            _buildAmountButton(10000),
                            _buildAmountButton(50000),
                            _buildAmountButton(100000),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Amount slider
                      Slider(
                        value: _amount,
                        min: 0,
                        max: 1000000,
                        divisions: 1000,
                        label: NumberFormat.currency(
                                locale: 'en_PK', symbol: 'Rs. ')
                            .format(_amount),
                        onChanged: (double value) {
                          setState(() {
                            _amount = value;
                          });
                        },
                      ),

                      // Custom amount entry option
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showCustomAmountDialog(),
                          icon: const Icon(Icons.edit),
                          label: const Text('Enter Custom Amount'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Date
                      Text(
                        'Date',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: LightColorsPalate.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: LightColorsPalate.outlineColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: LightColorsPalate.tertiaryColor,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                DateFormat('MMM dd, yyyy').format(_date),
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Auto-create reminder option (only for maintenance and repair expenses)
                      if (_expenseType == 'maintenance' ||
                          _expenseType == 'repair') ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _createReminder,
                              onChanged: (value) {
                                setState(() {
                                  _createReminder = value ?? true;
                                });
                              },
                              activeColor: LightColorsPalate.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Create automatic service reminder',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        if (_createReminder) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const SizedBox(width: 32),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reminder Interval',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: LightColorsPalate.surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color:
                                                LightColorsPalate.outlineColor),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: _reminderIntervalDays,
                                          isExpanded: true,
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          onChanged: (int? newValue) {
                                            if (newValue != null) {
                                              setState(() {
                                                _reminderIntervalDays =
                                                    newValue;
                                              });
                                            }
                                          },
                                          items: _reminderIntervals
                                              .map<DropdownMenuItem<int>>(
                                                  (interval) {
                                            return DropdownMenuItem<int>(
                                              value: interval['days'],
                                              child: Text(interval['label']),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LightColorsPalate.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Save Expense',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildVehicleOption(Map<String, dynamic> vehicle) {
    final isSelected = _selectedVehicleId == vehicle['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedVehicleId = vehicle['id'];
            _vehicleName = '${vehicle['name']} (${vehicle['year']})';
          });
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? LightColorsPalate.primaryColor.withAlpha((0.1 * 255).round())
                : LightColorsPalate.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? LightColorsPalate.primaryColor
                  : LightColorsPalate.outlineColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.directions_car,
                color: isSelected
                    ? LightColorsPalate.primaryColor
                    : LightColorsPalate.tertiaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle['name'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                    ),
                    Text(
                      'Year: ${vehicle['year']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: LightColorsPalate.tertiaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: LightColorsPalate.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddVehicleButton() {
    return InkWell(
      onTap: () {
        // Navigate to add vehicle screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add Vehicle functionality coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.green.withAlpha((0.5 * 255).round())),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Text(
              'Add New Vehicle',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountButton(double amount) {
    final isSelected = (_amount == amount);
    final formatter = NumberFormat.currency(locale: 'en_PK', symbol: 'Rs. ');

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _amount = amount;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? LightColorsPalate.primaryColor : Colors.white,
          foregroundColor:
              isSelected ? Colors.white : LightColorsPalate.primaryColor,
          side: BorderSide(
            color: LightColorsPalate.primaryColor,
            width: 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(formatter.format(amount)),
      ),
    );
  }

  void _showCustomAmountDialog() {
    final textController = TextEditingController(
      text: _amount > 0 ? _amount.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Amount (PKR)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.currency_rupee),
                hintText: '1000.00',
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Hint: For 10,000 PKR, enter 10000',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(textController.text);
              if (amount != null && amount > 0) {
                setState(() {
                  _amount = amount;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTypeButton({
    required String type,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _expenseType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _expenseType = type;
          // Reset subcategory when type changes
          _expenseSubcategory = _expenseCategories[type]![0]['id'];
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withAlpha((0.1 * 255).round())
                  : LightColorsPalate.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : LightColorsPalate.outlineColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              icon,
              color: isSelected ? color : LightColorsPalate.tertiaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? color : LightColorsPalate.tertiaryColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: LightColorsPalate.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final expense = ExpenseRecord(
        id: widget.expenseToEdit?.id ?? const Uuid().v4(),
        vehicleId: _selectedVehicleId,
        userId: _maintenanceService.currentUserId!,
        expenseType: _expenseType,
        amount: _amount,
        date: _date,
        description: _descriptionController.text,
        receiptImageUrl: widget.expenseToEdit?.receiptImageUrl,
        additionalDetails: {
          'subcategory': _expenseSubcategory,
          if (widget.expenseToEdit?.additionalDetails != null)
            ...widget.expenseToEdit!.additionalDetails!,
        },
      );

      if (widget.expenseToEdit != null) {
        // Update existing expense
        await _maintenanceService.updateExpense(expense);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully'),
              backgroundColor: LightColorsPalate.successColor,
            ),
          );
        }
      } else {
        // Add new expense
        await _maintenanceService.addExpense(expense);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: LightColorsPalate.successColor,
          ),
        );
        }
      }

      // Create reminder if needed
      if (_createReminder && _expenseType == 'maintenance') {
        final reminder = await _autoReminderService.createReminderFromService(
          _selectedVehicleId,
          _descriptionController.text,
          _date,
          _reminderIntervalDays,
        );

        if (mounted) {
          Navigator.pop(context, {'reminder': reminder});
          return;
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving expense: $e';
        _isLoading = false;
      });
    }
  }
}
