import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import '../../../../exports.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../3DModel/capture360_view.dart';
import '../3DModel/controller/upload_controller.dart';

class AddCar extends StatefulWidget {
  const AddCar({super.key});

  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _kmDrivenController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  bool _allowWhatsApp = false;
  double _price = 0; // Slider value for price
  // Dropdown values
  String? _selectedTransmission;
  String? _selectedAssembly;
  String? _selectedFuelType;
  String? _selectedColor;
  String? _selectedCity;
  String? _selectedRegisterIn;
  String? _selectedCondition;
  String? _selectedBrand;
  String? _selectedSubCategory;
  String? _selectedModelYear;
  String? _selectedCarType; // Car Type/Category
  String? _selectedPriceRange; // Price Range Category

  // Dropdown options
  final List<String> _transmissionOptions = ['Automatic', 'Manual', 'CVT'];
  final List<String> _assemblyOptions = ['Local', 'Imported'];
  final List<String> _fuelTypeOptions = ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'];
  final List<String> _colorOptions = ['Black', 'White', 'Red', 'Blue', 'Silver', 'Gray', 'Bronze', 'Green', 'Gold', 'Brown'];
  final List<String> _cityOptions = [
    'Islamabad', 'Karachi', 'Lahore', 'Peshawar', 'Quetta', 'Rawalpindi', 'Multan',
    'Faisalabad', 'Gujranwala', 'Sialkot', 'Hyderabad', 'Abbottabad', 'Bahawalpur'
  ];
  final List<String> _registerInOptions = [
    'Islamabad', 'Karachi', 'Lahore', 'Peshawar', 'Quetta', 'Rawalpindi', 'Multan',
    'Faisalabad', 'Gujranwala', 'Sialkot', 'Hyderabad', 'Abbottabad', 'Bahawalpur'
  ];
  final List<String> _conditionOptions = ['New', 'Used'];
  final List<String> _modelYearOptions = List.generate(31, (index) => (1995 + index).toString());
  
  // Car Type Options
  final List<String> _carTypeOptions = [
    'Sedan', 'SUV', 'Hatchback', 'Crossover', 'Pickup', 'Van', 'Coupe', 'Convertible',
    'Minivan', 'Wagon', 'Truck', 'Electric Vehicle (EV)', 'Hybrid'
  ];
  
  // Price Range Categories
  final List<String> _priceRangeOptions = [
    'Budget (Under 20 lakh PKR)', 
    'Mid-range (20-40 lakh PKR)',
    'Premium (40-80 lakh PKR)',
    'Luxury (Above 80 lakh PKR)'
  ];

  // Brand and Sub-Category Data - Expanded for Pakistani market
  final Map<String, List<String>> _brandSubCategoryMap = {
    // Japanese
    'Toyota': ['Corolla', 'Yaris', 'Camry', 'Fortuner', 'Hilux', 'Prius', 'Land Cruiser', 'Prado'],
    'Honda': ['Civic', 'City', 'BR-V', 'Vezel', 'Accord', 'HR-V', 'CR-V'],
    'Suzuki': ['Mehran', 'Alto', 'Cultus', 'Swift', 'Wagon R', 'Bolan', 'Every', 'Jimny', 'Vitara'],
    'Daihatsu': ['Mira', 'Cuore', 'Move', 'Hijet', 'Terios', 'Charade'],
    'Nissan': ['Sunny', 'Dayz', 'Note', 'X-Trail', 'Juke', 'Patrol'],
    'Mitsubishi': ['Lancer', 'Pajero', 'L200', 'Attrage'],
    'Mazda': ['Mazda2', 'Mazda3', 'CX-3', 'CX-5'],
    
    // Korean
    'Hyundai': ['Tucson', 'Elantra', 'Sonata', 'Santa Fe', 'Porter', 'Shehzore'],
    'Kia': ['Sportage', 'Picanto', 'Grand Carnival', 'Sorento', 'Stonic', 'Stinger'],
    
    // Chinese
    'MG': ['HS', 'ZS', 'ZS EV', '5', '3'],
    'Changan': ['Alsvin', 'Karvaan', 'M8', 'M9'],
    'Proton': ['X70', 'Saga', 'X50'],
    'FAW': ['V2', 'X-PV', 'Carrier'],
    'BAIC': ['BJ40', 'D20'],
    'Haval': ['H6', 'Jolion'],
    'Chery': ['Tiggo', 'QQ'],
    
    // European
    'Audi': ['A3', 'A4', 'A6', 'Q7', 'Q5', 'Q3', 'e-tron'],
    'BMW': ['X1', 'X3', 'X5', '3 Series', '5 Series', '7 Series'],
    'Mercedes-Benz': ['C-Class', 'E-Class', 'S-Class', 'GLC', 'GLE'],
    'Volkswagen': ['Polo', 'Golf', 'Tiguan', 'Passat']
  };

  List<String> _subCategoryOptions = [];
  List<File> _selectedImages = []; // Store selected images as files




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                50.y,
                AppText("Enter Car Details", style: Theme.of(context).textTheme.headlineMedium),
                20.y,
                AppTextField(
                  controller: _titleController,
                  textInputType: TextInputType.text,
                  hintText: "Title",
                  validator: (value) => value!.isEmpty ? 'Title is required' : null,
                ),
                10.y,
                // Brand Dropdown
                _buildDropdown(
                  value: _selectedBrand,
                  hint: 'Select Brand',
                  items: _brandSubCategoryMap.keys.toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                      _selectedSubCategory = null; // Reset sub-category when brand changes
                      _subCategoryOptions = _brandSubCategoryMap[value] ?? [];
                    });
                  },
                  validator: (value) => value == null ? 'Brand is required' : null,
                ),
                10.y,
                // Sub-Category Dropdown
                _buildDropdown(
                  value: _selectedSubCategory,
                  hint: 'Select Sub Category',
                  items: _subCategoryOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedSubCategory = value;
                    });
                  },
                  validator: (value) => value == null ? 'Sub Category is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _descriptionController,
                  textInputType: TextInputType.text,
                  hintText: "Description",
                  validator: (value) => value!.isEmpty ? 'Description is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _kmDrivenController,
                  textInputType: TextInputType.number,
                  hintText: "KM Driven",
                  validator: (value) => value!.isEmpty ? 'KM Driven is required' : null,
                ),
                10.y,
                // Price Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Price: PKR ${_price.toStringAsFixed(0)}"),
                    Slider(
                      value: _price,
                      min: 0,
                      max: 100000000,
                      divisions: 100,
                      label: _price.toStringAsFixed(0),
                      onChanged: (value) {
                        setState(() {
                          _price = value;
                        });
                      },
                    ),
                  ],
                ),
                10.y,
                // Other Dropdowns
                _buildDropdown(
                  value: _selectedModelYear,
                  hint: 'Select Model Year',
                  items: _modelYearOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedModelYear = value;
                    });
                  },
                  validator: (value) => value == null ? 'Model Year is required' : null,
                ),10.y,
                // Car Type Dropdown
                _buildDropdown(
                  value: _selectedCarType,
                  hint: 'Select Car Type',
                  items: _carTypeOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedCarType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Car Type is required' : null,
                ),
                10.y,
                // Price Range Category Dropdown
                _buildDropdown(
                  value: _selectedPriceRange,
                  hint: 'Select Price Range',
                  items: _priceRangeOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedPriceRange = value;
                    });
                  },
                  validator: (value) => value == null ? 'Price Range is required' : null,
                ),
                10.y,
                // Other Dropdowns
                _buildDropdown(
                  value: _selectedTransmission,
                  hint: 'Select Transmission',
                  items: _transmissionOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedTransmission = value;
                    });
                  },
                  validator: (value) => value == null ? 'Transmission is required' : null,
                ),
                10.y,
                _buildDropdown(
                  value: _selectedAssembly,
                  hint: 'Select Assembly',
                  items: _assemblyOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedAssembly = value;
                    });
                  },
                  validator: (value) => value == null ? 'Assembly is required' : null,
                ),
                10.y,
                _buildDropdown(
                  value: _selectedFuelType,
                  hint: 'Select Fuel Type',
                  items: _fuelTypeOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedFuelType = value;
                    });
                  },
                  validator: (value) => value == null ? 'Fuel Type is required' : null,
                ),
                10.y,
                _buildDropdown(
                  value: _selectedColor,
                  hint: 'Select Color',
                  items: _colorOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedColor = value;
                    });
                  },
                  validator: (value) => value == null ? 'Color is required' : null,
                ),
                10.y,
                _buildDropdown(
                  value: _selectedCity,
                  hint: 'Select City',
                  items: _cityOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                  validator: (value) => value == null ? 'City is required' : null,
                ),
                10.y,
                _buildDropdown(
                  value: _selectedRegisterIn,
                  hint: 'Select Register In',
                  items: _registerInOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedRegisterIn = value;
                    });
                  },
                  validator: (value) => value == null ? 'Register In is required' : null,
                ),
                10.y,
                _buildDropdown(
                  value: _selectedCondition,
                  hint: 'Select Condition',
                  items: _conditionOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  },
                  validator: (value) => value == null ? 'Condition is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _contactNumberController,
                  textInputType: TextInputType.phone,
                  hintText: "Contact Number",
                  validator: (value) => value!.isEmpty ? 'Contact Number is required' : null,
                ),
                10.y,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Allow WhatsApp Contact'),
                    Switch(
                      value: _allowWhatsApp,
                      onChanged: (value) {
                        setState(() {
                          _allowWhatsApp = value;
                        });
                      },
                    ),
                  ],
                ),
                20.y,
                // Image Upload Button
                ElevatedButton(
                  onPressed: _selectImages,
                  child: Text("Select Images"),
                ),
                10.y,
                // Display selected images
                _selectedImages.isNotEmpty
                    ? Wrap(
                  spacing: 10,
                  children: _selectedImages.map((image) {
                    return Container(
                      width: 100,  // Fixed width
                      height: 100, // Fixed height
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8), // Optional: for rounded corners
                        child: Image.file(
                          image,
                          fit: BoxFit.cover, // Ensures the image covers the fixed size without distortion
                        ),
                      ),
                    );
                  }).toList(),
                )
                    : SizedBox(),

                20.y,
                // Add 3D Model Button
                ElevatedButton.icon(
                  onPressed: _startCapture360,
                  icon: Icon(Icons.view_in_ar),
                  label: Text("Add 3D Model"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                20.y,

                CommonButton(onTap: _uploadCarDetails, text: "Upload Car"),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // Helper method to create dropdowns with borders
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(), // Add border to dropdown
      ),
    );
  }
  
  // Function to select multiple images
  Future<void> _selectImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  // Function to start 360° capture
  Future<void> _startCapture360() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    
    if (cameraStatus.isGranted) {
      Get.put(UploadController());
      Get.to(() => const Capture360View());
    } else if (cameraStatus.isDenied) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission is required for 360° capture.',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } else if (cameraStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  // Function to upload car details including images
  Future<void> _uploadCarDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        List<String> imageUrls = [];
        // Upload images to Firebase Storage
        for (var image in _selectedImages) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('car_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
          UploadTask uploadTask = ref.putFile(image);
          TaskSnapshot snapshot = await uploadTask;
          String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        }

        // Save car details to Firestore along with image URLs
        await FirebaseFirestore.instance
            .collection("cars")
            .doc(user.uid)
            .collection("user_cars")
            .add({
          "status": "pending",
          "listingType": "car",
          "title": _titleController.text,
          "price": _price.toStringAsFixed(0), // Use slider value for price
          "description": _descriptionController.text,
          "kmDriven": _kmDrivenController.text,
          "transmission": _selectedTransmission ?? '',
          "assembly": _selectedAssembly ?? '',
          "fuelType": _selectedFuelType ?? '',
          "color": _selectedColor ?? '',
          "city": _selectedCity ?? '',
          "registerIn": _selectedRegisterIn ?? '',
          "condition": _selectedCondition ?? '',
          "brand": _selectedBrand ?? '',
          "subCategory": _selectedSubCategory ?? '',
          "contactNumber": _contactNumberController.text,
          "allowWhatsApp": _allowWhatsApp,
          "createdAt": Timestamp.now(),
          "userId": user.uid,
          "isSold": false,
          "deviceToken": Data.app.token,
          "modelYear": _selectedModelYear ?? '',
          "imageUrls": imageUrls, // Store image URLs
          "carType": _selectedCarType ?? '', // Add car type
          "priceRange": _selectedPriceRange ?? '', // Add price range
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Car details uploaded successfully!")));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }



  @override
  void dispose() {
    // Dispose all controllers
    _titleController.dispose();
    _descriptionController.dispose();
    _kmDrivenController.dispose();
    _contactNumberController.dispose();
    super.dispose();
  }
}