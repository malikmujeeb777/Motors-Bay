import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Domain/Models/vehicle_maintenance_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/maintenance_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServiceReminderForm extends StatefulWidget {
  final String vehicleId;
  final MaintenanceReminder? reminderToEdit;

  const ServiceReminderForm({
    super.key,
    required this.vehicleId,
    this.reminderToEdit,
  });

  @override
  State<ServiceReminderForm> createState() => _ServiceReminderFormState();
}

class _ServiceReminderFormState extends State<ServiceReminderForm> {
  final MaintenanceService _maintenanceService = MaintenanceService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedType = 'time-based';
  String _selectedServiceType = 'oil_change'; // Default service type
  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _serviceTypes = [
    'oil_change',
    'tire_rotation',
    'brake_service',
    'air_filter',
    'battery_check',
    'coolant_flush',
    'transmission_service',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 30));
    
    if (widget.reminderToEdit != null) {
      _titleController.text = widget.reminderToEdit!.title;
      _descriptionController.text = widget.reminderToEdit!.description;
      _selectedDate = widget.reminderToEdit!.dueDate;
      _selectedType = widget.reminderToEdit!.reminderType;
      _selectedServiceType = widget.reminderToEdit!.serviceType;
      if (widget.reminderToEdit!.dueMileage != null) {
        _mileageController.text = widget.reminderToEdit!.dueMileage.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reminder = MaintenanceReminder(
          id: widget.reminderToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        vehicleId: widget.vehicleId,
          userId: _auth.currentUser?.uid ?? '',
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _selectedDate!,
          reminderType: _selectedType,
          serviceType: _selectedServiceType,
          dueMileage: _selectedType == 'mileage-based' ? int.parse(_mileageController.text) : null,
        isCompleted: widget.reminderToEdit?.isCompleted ?? false,
        completedDate: widget.reminderToEdit?.completedDate,
        createdAt: widget.reminderToEdit?.createdAt ?? DateTime.now(),
      );

        if (widget.reminderToEdit != null) {
          await _maintenanceService.updateReminder(reminder);
        } else {
        await _maintenanceService.addReminder(reminder);
      }

      if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.reminderToEdit != null ? 'Reminder updated' : 'Reminder created'),
              backgroundColor: LightColorsPalate.successColor,
            ),
          );
      }
    } catch (e) {
      setState(() {
          _errorMessage = e.toString();
      });
    } finally {
        if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
      }
    }
  }

  Widget _buildServiceTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedServiceType,
      decoration: const InputDecoration(
        labelText: 'Service Type',
        prefixIcon: Icon(Icons.build),
      ),
      items: _serviceTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.replaceAll('_', ' ').toUpperCase()),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedServiceType = value;
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a service type';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminderToEdit != null ? 'Edit Reminder' : 'Add Reminder'),
        backgroundColor: LightColorsPalate.backgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
        key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                        labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                        if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
                    _buildServiceTypeDropdown(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description),
                  ),
                      maxLines: 3,
                ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Type',
                        prefixIcon: Icon(Icons.notifications),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'time-based',
                          child: Text('Time Based'),
                        ),
                        DropdownMenuItem(
                        value: 'mileage-based',
                          child: Text('Mileage Based'),
                        ),
                      ],
                        onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                          });
                        }
                      },
            ),
            const SizedBox(height: 16),
                    if (_selectedType == 'mileage-based')
              TextFormField(
                controller: _mileageController,
                        keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                          labelText: 'Due Mileage',
                  prefixIcon: Icon(Icons.speed),
                ),
                validator: (value) {
                          if (_selectedType == 'mileage-based' && (value == null || value.isEmpty)) {
                            return 'Please enter the due mileage';
                  }
                          if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Due Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate!,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                          });
                        }
                      },
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
            ),
                    ],
            const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LightColorsPalate.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                      child: Text(
                        widget.reminderToEdit != null ? 'Update Reminder' : 'Create Reminder',
                        style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
                ),
        ),
      ),
    );
  }
}
