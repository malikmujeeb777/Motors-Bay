import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Domain/Services/obd_sample_data.dart';

class OBDSampleDataWidget extends StatefulWidget {
  final String vehicleId;

  const OBDSampleDataWidget({super.key, required this.vehicleId});

  @override
  State<OBDSampleDataWidget> createState() => _OBDSampleDataWidgetState();
}

class _OBDSampleDataWidgetState extends State<OBDSampleDataWidget> {
  final OBDSampleDataService _sampleDataService = OBDSampleDataService();
  bool _isLoading = false;
  String? _message;
  bool _success = false;

  Future<void> _addSampleData() async {
    setState(() {
      _isLoading = true;
      _message = 'Adding sample OBD data...';
      _success = false;
    });

    try {
      final success = await _sampleDataService.addSampleData(widget.vehicleId);

      setState(() {
        _isLoading = false;
        _success = success;
        _message = success
            ? 'Sample OBD data added successfully!'
            : 'Failed to add sample data';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _success = false;
        _message = 'Error: $e';
      });
    }
  }

  Future<void> _deleteSampleData() async {
    setState(() {
      _isLoading = true;
      _message = 'Deleting sample OBD data...';
      _success = false;
    });

    try {
      final success = await _sampleDataService.deleteSampleData();

      setState(() {
        _isLoading = false;
        _success = success;
        _message = success
            ? 'Sample OBD data deleted successfully!'
            : 'Failed to delete sample data';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _success = false;
        _message = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sample OBD Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add sample ELM327 OBD Scanner data to demonstrate functionality.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addSampleData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add Sample Data'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deleteSampleData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Delete Sample Data'),
                    ),
                  ),
                ],
              ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _success ? Colors.green[50] : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _success ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _message!,
                  style: TextStyle(
                    color: _success ? Colors.green[800] : Colors.red[800],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
