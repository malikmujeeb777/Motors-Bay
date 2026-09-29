import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Domain/Models/verification_history_model.dart';
import 'package:motorsbay1/SRC/Domain/Services/verification_service.dart';
import 'package:motorsbay1/SRC/Domain/Services/islamabad_verification_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Verification/islamabad_verification_result.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/custom_loader.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:motorsbay1/SRC/Domain/Services/firebase_service.dart';
import 'package:motorsbay1/SRC/Domain/Services/punjab_verification_service.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Verification/punjab_verification_result.dart';

class VehicleVerificationPage extends StatefulWidget {
  final String provinceCode;
  final String provinceName;

  const VehicleVerificationPage({
    Key? key,
    required this.provinceCode,
    required this.provinceName,
  }) : super(key: key);

  @override
  State<VehicleVerificationPage> createState() => _VehicleVerificationPageState();
}

class _VehicleVerificationPageState extends State<VehicleVerificationPage> with SingleTickerProviderStateMixin {
  // Tab controller for Vehicle and License tabs
  late TabController _tabController;
  
  // Form controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // Common controllers
  final TextEditingController _numberPlateController = TextEditingController();
  
  // Punjab specific controllers
  final TextEditingController _chassisNumberController = TextEditingController();
  
  // Islamabad specific controllers
  DateTime? _regDate;
  
  // Sindh specific controllers
  String _wheelersType = 'four';
  
  // Gilgit Baltistan specific controllers
  String _gbDistrict = 'ASTORE';
  
  // Khyber Pakhtunkhwa specific controllers
  String _kpDistrict = 'Abbottabad';
  String _regType = 'registration';
  
  bool _isVerifying = false;
  bool _showResults = false;

  final VerificationService _verificationService = VerificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _numberPlateController.dispose();
    _chassisNumberController.dispose();
    super.dispose();
  }
  
  // Validation function for number plate
  String? _validateNumberPlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a vehicle number plate';
    }
    
    // Check for dash based on province
    if (!value.contains('-')) {
      return 'Number plate must include a dash (e.g., ABC-123)';
    }
    
    // Check for spaces
    if (value.contains(' ')) {
      return 'Number plate should not contain spaces';
    }
    
    return null;
  }
  
  // Validation for chassis number (Punjab)
  String? _validateChassisNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a chassis number';
    }
    
    if (value.contains(' ') || value.contains('-')) {
      return 'Chassis number should not contain spaces or dashes';
    }
    
    return null;
  }
  
  void _verifyVehicle() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (widget.provinceCode == 'ICT' && _regDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select registration date')),
        );
        return;
      }

      setState(() {
        _isVerifying = true;
      });

      try {
        if (widget.provinceCode == 'PB') {
          final verificationService = PunjabVerificationService();
          final response = await verificationService.verifyVehicle(
            numberPlate: _numberPlateController.text,
            chassisNumber: _chassisNumberController.text,
          );

          if (response.status == 'success' && response.data != null) {
            // Save to Firebase
            final verificationService = VerificationService();
            await verificationService.saveVerificationHistory(
              numberPlate: _numberPlateController.text,
              registrationDate: DateTime.now().toIso8601String(),
              province: 'Punjab',
              verificationData: {
                'bodyType': 'MOTOR CAR',
                'chassisNo': _chassisNumberController.text,
                'color': response.data!.vehicle?.color ?? '',
                'engineNo': response.data!.vehicle?.engineNumber ?? '',
                'engineSize': '',
                'makerMake': response.data!.vehicle?.makeName ?? '',
                'ownerName': response.data!.owner?.ownerName ?? '',
                'purchaseDate': '',
                'purchaseType': '',
                'regDate': response.data!.vehicle?.registrationDate ?? '',
                'regNo': response.data!.vehicle?.registrationNumber ?? '',
                'status': response.data!.tracking?.applicationStatus ?? '',
                'taxPaidUpto': response.data!.vehicle?.token ?? '',
                'textOutput': response.data!.textOutput ?? '',
                'vehicleValue': response.data!.vehicle?.vehiclePrice ?? '',
                'yearOfManufacture': response.data!.vehicle?.yearOfManufacture ?? '',
              },
            );

            // Show verification result in popup
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PunjabVerificationResult(
                verificationData: response.data!,
                numberPlate: _numberPlateController.text,
                chassisNumber: _chassisNumberController.text,
              ),
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.text ?? 'Verification failed')),
            );
          }
        } else if (widget.provinceCode == 'ICT') {
          final verificationService = IslamabadVerificationService();
          final response = await verificationService.verifyVehicle(
            numberPlate: _numberPlateController.text,
            registrationDate: _regDate!,
          );

          if (response.status == 'success' && response.data != null) {
            // Save to Firebase
            final verificationService = VerificationService();
            await verificationService.saveVerificationHistory(
              numberPlate: _numberPlateController.text,
              registrationDate: _regDate!.toIso8601String(),
              province: 'Islamabad',
              verificationData: {
                'bodyType': response.data!.bodyType,
                'chassisNo': response.data!.chassisNo,
                'color': response.data!.color,
                'engineNo': response.data!.engineNo,
                'engineSize': response.data!.engineSize,
                'makerMake': response.data!.makerMake,
                'ownerName': response.data!.ownerName,
                'purchaseDate': response.data!.purchaseDate,
                'purchaseType': response.data!.purchaseType,
                'regDate': response.data!.regDate,
                'regNo': response.data!.regNo,
                'status': response.data!.status,
                'taxPaidUpto': response.data!.taxPaidUpto,
                'textOutput': response.data!.textOutput,
                'vehicleValue': response.data!.vehicleValue,
                'yearOfManufacture': response.data!.yearOfManufacture,
              },
            );

            // Show verification result in popup
            showDialog(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IslamabadVerificationResult(
                  verificationData: response.data!,
                  numberPlate: _numberPlateController.text,
                  registrationDate: _regDate!,
                ),
              ),
            );
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.text ?? 'Verification failed')),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.provinceName} Verification',
          style: TextStyle(
            color: LightColorsPalate.onBackgroundColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: LightColorsPalate.onBackgroundColor),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: LightColorsPalate.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: LightColorsPalate.primaryColor,
          tabs: [
            Tab(
              icon: Icon(Icons.directions_car),
              text: 'Vehicle',
            ),
            Tab(
              icon: Icon(Icons.badge),
              text: 'License',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Vehicle verification tab
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  SizedBox(height: 24),
                  if (!_showResults) _buildVehicleInputForm(),
                  if (_showResults) _buildVerificationResults(),
                ],
              ),
            ),
            // License verification tab
            _buildLicenseTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColorsPalate.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: LightColorsPalate.primaryColor,
              ),
              SizedBox(width: 8),
              Text(
                'Verification Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: LightColorsPalate.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Enter your vehicle registration number to verify its details. '
            'For additional verification, you can also provide the chassis or engine number.',
            style: TextStyle(
              fontSize: 14,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVehicleInputForm() {
    // Each province has different fields to fill in
    switch(widget.provinceCode) {
      case 'PB': // Punjab
        return _buildPunjabForm();
      case 'SD': // Sindh
        return _buildSindhForm();
      case 'KP': // Khyber Pakhtunkhwa
        return _buildKPForm();
      case 'GB': // Gilgit Baltistan
        return _buildGilgitBaltistanForm();
      case 'ICT': // Islamabad
        return _buildIslamabadForm();
      case 'BL': // Balochistan
        return _buildBalochistanForm();
      default:
        return _buildDefaultForm();
    }
  }
  
  // Punjab: numberPlate=AHE-080, chassisNumber (no spaces or dashes)
  Widget _buildPunjabForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Punjab Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _numberPlateController,
            decoration: InputDecoration(
              labelText: 'Number Plate *',
              hintText: 'e.g., AHE-080',
              prefixIcon: Icon(Icons.directions_car),
              helperText: 'Format: ABC-123 (dash is required, no spaces)',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateNumberPlate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _chassisNumberController,
            decoration: InputDecoration(
              labelText: 'Chassis Number *',
              hintText: 'e.g., AB12345CD67890',
              prefixIcon: Icon(Icons.numbers),
              helperText: 'No spaces or dashes allowed',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateChassisNumber,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  // Sindh: wheelersType=four (dropdown), numberPlate=ASQ-258
  Widget _buildSindhForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sindh Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Wheeler Type *',
              prefixIcon: Icon(Icons.two_wheeler),
            ),
            value: _wheelersType,
            items: ['four', 'two'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.capitalize ?? value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _wheelersType = newValue!;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _numberPlateController,
            decoration: InputDecoration(
              labelText: 'Number Plate *',
              hintText: 'e.g., ASQ-258',
              prefixIcon: Icon(Icons.directions_car),
              helperText: 'Format: ABC-123 (dash is required, no spaces)',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateNumberPlate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  // KP: numberPlate=B-9838, district (dropdown), regType (dropdown)
  Widget _buildKPForm() {
    final kpDistricts = [
      'Abbottabad', 'Bannu', 'Battagram', 'Buner', 'Charsadda', 'Chitral', 
      'Dera Ismail Khan', 'Hangu', 'Haripur', 'Karak', 'Kohat', 'Kohistan', 
      'Lakki Marwat', 'Lower Dir', 'Malakand', 'Mansehra', 'Mardan', 
      'Nowshera', 'Peshawar', 'Shangla', 'Swabi', 'Swat', 'Tank', 'Tor Ghar'
    ];
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khyber Pakhtunkhwa Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _numberPlateController,
            decoration: InputDecoration(
              labelText: 'Number Plate *',
              hintText: 'e.g., B-9838',
              prefixIcon: Icon(Icons.directions_car),
              helperText: 'Format: B-9838 (dash is required, no spaces)',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateNumberPlate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'District *',
              prefixIcon: Icon(Icons.location_city),
            ),
            value: _kpDistrict,
            items: kpDistricts.map((String district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(district),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _kpDistrict = newValue!;
              });
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Registration Type *',
              prefixIcon: Icon(Icons.app_registration),
            ),
            value: _regType,
            items: ['registration', 'temporary'].map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type.capitalize ?? type),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _regType = newValue!;
              });
            },
          ),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  // Gilgit Baltistan: numberPlate=AD-00, regDate, district (dropdown)
  Widget _buildGilgitBaltistanForm() {
    final gbDistricts = [
      'ASTORE', 'DIAMER', 'GHANCHE', 'GHIZER', 'GILGIT', 
      'HUNZA', 'KHARMANG', 'NAGAR', 'SHIGAR', 'SKARDU'
    ];
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gilgit Baltistan Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _numberPlateController,
            decoration: InputDecoration(
              labelText: 'Number Plate *',
              hintText: 'e.g., AD-00',
              prefixIcon: Icon(Icons.directions_car),
              helperText: 'Format: AD-00 (dash is required, no spaces)',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateNumberPlate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _regDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText: 'Select Registration Date',
              );
              if (picked != null && picked != _regDate) {
                setState(() {
                  _regDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Registration Date *',
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Text(
                _regDate == null 
                  ? 'Select Date'
                  : '${_regDate!.day.toString().padLeft(2, '0')}-${_regDate!.month.toString().padLeft(2, '0')}-${_regDate!.year}',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'District *',
              prefixIcon: Icon(Icons.location_city),
            ),
            value: _gbDistrict,
            items: gbDistricts.map((String district) {
              return DropdownMenuItem<String>(
                value: district,
                child: Text(district),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _gbDistrict = newValue!;
              });
            },
          ),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  // Islamabad: numberPlate=SV-097, regDate
  Widget _buildIslamabadForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Islamabad Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _numberPlateController,
            decoration: InputDecoration(
              labelText: 'Number Plate *',
              hintText: 'e.g., SV-097',
              prefixIcon: Icon(Icons.directions_car),
              helperText: 'Format: ABC-123 (dash is required, no spaces)',
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateNumberPlate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _regDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                helpText: 'Select Registration Date',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: LightColorsPalate.primaryColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _regDate) {
                setState(() {
                  _regDate = picked;
                });
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Registration Date *',
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'DD/MM/YYYY',
              ),
              child: Text(
                _regDate == null 
                  ? 'Select Date'
                  : '${_regDate!.day.toString().padLeft(2, '0')}/${_regDate!.month.toString().padLeft(2, '0')}/${_regDate!.year}',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  // Balochistan: No verification available
  Widget _buildBalochistanForm() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.browser_not_supported,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 24),
          Text(
            'Vehicle verification is currently not available for Balochistan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The online verification system is not yet implemented by the provincial government.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
  
  // Default form for any unhandled province
  Widget _buildDefaultForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.onBackgroundColor,
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _numberPlateController,
            decoration: InputDecoration(
              labelText: 'Number Plate *',
              hintText: 'e.g., ABC-123',
              prefixIcon: Icon(Icons.directions_car),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: _validateNumberPlate,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }
  
  // Common submit button for all forms
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyVehicle,
        style: ElevatedButton.styleFrom(
          backgroundColor: LightColorsPalate.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isVerifying
            ? Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomLoader(
                      outerSize: 40,
                      innerSize: 20,
                      opacity: 0.7,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fetching vehicle details...',
                      style: TextStyle(
                        fontSize: 14,
                  color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                'Verify Vehicle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
  Widget _buildVerificationResults() {
    // This is just a sample result UI, you'll need to connect to a real API for actual verification
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.verified,
              color: LightColorsPalate.successColor,
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Vehicle Verified',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: LightColorsPalate.successColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        _buildResultCard(
          title: 'Vehicle Information',
          items: [
            ResultItem(label: 'Registration Number', value: _numberPlateController.text),
            ResultItem(label: 'Registration Date', value: _regDate != null
                ? '${_regDate!.day.toString().padLeft(2, '0')}-${_regDate!.month.toString().padLeft(2, '0')}-${_regDate!.year}'
                : '15-Jun-2022'),
            ResultItem(label: 'Vehicle Type', value: widget.provinceCode == 'SD' ? _wheelersType + ' wheeler' : 'Car'),
            ResultItem(label: 'Make', value: 'Toyota'),
            ResultItem(label: 'Model', value: 'Corolla'),
            ResultItem(label: 'Year', value: '2020'),
            ResultItem(label: 'Color', value: 'Silver'),
          ],
        ),
        SizedBox(height: 16),
        _buildResultCard(
          title: 'Owner Information',
          items: [
            ResultItem(label: 'Owner Name', value: 'Muhammad Ali'),
            ResultItem(
              label: 'Registration City', 
              value: widget.provinceCode == 'KP' 
                ? '${widget.provinceName} - $_kpDistrict' 
                : (widget.provinceCode == 'GB' 
                    ? '${widget.provinceName} - $_gbDistrict' 
                    : '${widget.provinceName} - Capital')
            ),
          ],
        ),
        if (widget.provinceCode == 'PB')
        Column(
          children: [
            SizedBox(height: 16),
            _buildResultCard(
              title: 'Additional Information',
              items: [
                ResultItem(label: 'Chassis Number', value: _chassisNumberController.text),
                ResultItem(label: 'Token Status', value: 'Paid'),
                ResultItem(label: 'Token Expiry', value: '15-Dec-2025'),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showResults = false;
                _numberPlateController.clear();
                if (widget.provinceCode == 'PB') {
                  _chassisNumberController.clear();
                }
                if (widget.provinceCode == 'ICT' || widget.provinceCode == 'GB') {
                  _regDate = null;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: LightColorsPalate.primaryContainer,
              foregroundColor: LightColorsPalate.primaryColor,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Check Another Vehicle',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required List<ResultItem> items,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColorsPalate.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightColorsPalate.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: LightColorsPalate.primaryColor,
            ),
          ),
          SizedBox(height: 10),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: LightColorsPalate.tertiaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Text(
                      item.value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: LightColorsPalate.onBackgroundColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLicenseTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cancel_outlined,
            size: 64,
            color: Colors.red[400],
          ),
          SizedBox(height: 16),
          Text(
            'Driver License Verification',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[400],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aborted by Islamabad Police',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultItem {
  final String label;
  final String value;

  ResultItem({required this.label, required this.value});
}
