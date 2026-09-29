import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Presentation/Common/common_loading_dialouge.dart';
import 'package:motorsbay1/exports.dart';
import 'package:url_launcher/url_launcher.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  final Map<String, dynamic> carData;
  final bool showOwnerActions;

  const CarDetailScreen({
    Key? key,
    required this.carId,
    required this.carData,
    this.showOwnerActions = true,
  }) : super(key: key);

  @override
  _CarDetailScreenState createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  bool _isLoading = false;
  bool isFavorite = false;
  Map<String, dynamic>? sellerData;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    fetchSellerDetails();
  }

  Future<void> fetchSellerDetails() async {
    if (widget.carData['userId'] == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.carData['userId'])
          .get();

      if (doc.exists) {
        setState(() {
          sellerData = doc.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      print("Error fetching seller details: $e");
    }
  }

  void _checkIfFavorite() async {
    DocumentSnapshot favDoc = await _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(widget.carData['title'])
        .get();

    setState(() {
      isFavorite = favDoc.exists;
    });
  }

  void _toggleFavorite() async {
    DocumentReference favRef = _firestore
        .collection("users")
        .doc(userId)
        .collection("favorites")
        .doc(widget.carData['title']);

    if (isFavorite) {
      // Remove from favorites
      await favRef.delete();
    } else {
      // Add to favorites
      await favRef.set({
        "status": widget.carData['status'],
        "listingType": widget.carData['listingType'],
        "title": widget.carData['title'],
        "price": widget.carData['price'],
        "description": widget.carData['description'],
        "kmDriven": widget.carData['kmDriven'],
        "transmission": widget.carData['transmission'],
        "assembly": widget.carData['assembly'],
        "fuelType": widget.carData['fuelType'],
        "color": widget.carData['color'],
        "city": widget.carData['city'],
        "registerIn": widget.carData['registerIn'],
        "condition": widget.carData['condition'],
        "brand": widget.carData['brand'],
        "subCategory": widget.carData['subCategory'],
        "contactNumber": widget.carData['contactNumber'],
        "allowWhatsApp": widget.carData['allowWhatsApp'],
        "createdAt": widget.carData['createdAt'],
        "userId": widget.carData['userId'],
        "isSold": widget.carData['isSold'],
        "deviceToken": widget.carData['deviceToken'],
        "modelYear": widget.carData['modelYear'],
        "image": "assets/images/carr.png",
        "timestamp": FieldValue.serverTimestamp(),
      });
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _deleteCar() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Confirmation"),
          content: Text("Are you sure you want to delete this car listing?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });

                try {
                  // Delete the car document
                  await _firestore
                      .collection("cars")
                      .doc(userId)
                      .collection("user_cars")
                      .doc(widget.carId)
                      .delete();

                  // Go back to previous screen after deletion
                  if (mounted) {
                    Navigator.pop(context, true); // Return true to indicate deletion
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Car listing deleted successfully!")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error deleting car: $e")),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _editCar() {
    // Navigate to EditCar page with car data for editing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCarScreen(carId: widget.carId, carData: widget.carData),
      ),
    ).then((updated) {
      if (updated == true) {
        // Refresh the page if car was updated
        setState(() {});
      }
    });
  }
  void callSeller() async {
    final phone = widget.carData['contactNumber']; // Ensure 'phone' exists in Firestore
    if (phone != null && phone.isNotEmpty) {
      final Uri callUri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch phone app")));
      }
    } else {
      // If seller's phone number is not found
      final sellerName = sellerData?['displayName'] ?? 'Seller';
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$sellerName's phone number is private")));
    }
  }

  void whatsappSeller() async {
    final phone = widget.carData['contactNumber'];
    if (phone != null && phone.isNotEmpty) {
      final Uri whatsappUri = Uri.parse("https://wa.me/$phone");
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not launch WhatsApp")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone number not available")));
    }
  }

  Future<void> updateCarSoldStatus(String carId, bool isSold) async {
    try {
      LoadingDialog.show(context);
      carId = carId.trim(); // Trim spaces
      
      await _firestore
          .collection("cars")
          .doc(userId)
          .collection("user_cars")
          .doc(carId)
          .update({"isSold": isSold});
          
      LoadingDialog.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Car status updated successfully!")));
    } catch (e) {
      LoadingDialog.hide(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating car status: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.carData;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Vehicle Details"),
        actions: widget.showOwnerActions ? [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _editCar,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteCar,
          ),
        ] : [],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery with favorite button
                  Stack(
                    children: [
                      // Product Images
                      if (car['imageUrls'] != null && (car['imageUrls'] as List).isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: (car['imageUrls'] as List).length,
                            itemBuilder: (context, index) {
                              String imageUrl = car['imageUrls'][index];
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(15),
                                      topRight: Radius.circular(15)),
                                  child: Image.network(imageUrl, fit: BoxFit.cover),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15)),
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: Image.asset(
                              "assets/images/carr.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                      // Favorite Button 
                      if (!widget.showOwnerActions)
                        Positioned(
                          top: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: _toggleFavorite,
                            child: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 29,
                              color: isFavorite ? Colors.red : Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Car details section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          car['title'] ?? "Unknown Car",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "PKR ${car['price'] ?? '0'}",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        Text(
                          car['description'] ?? "No description available",
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        SizedBox(height: 16),

                        // Car details table
                        _buildDetailsTable(),
                        SizedBox(height: 16),
                        
                        // Owner actions
                        if (widget.showOwnerActions)
                          CommonButton(
                            onTap: () {
                              updateCarSoldStatus(widget.carId, true);
                            },
                            text: (car['isSold'] == true) ? "Marked as Sold" : "Mark Car As Sold",
                            backgroundColor: (car['isSold'] == true) ? Colors.grey : Colors.blue,
                          ),

                        // Seller details and contact options  
                        if (!widget.showOwnerActions)
                          _buildSellerDetails(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Build car details table
  Widget _buildDetailsTable() {
    final car = widget.carData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brand Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          children: [
            _buildTableRow('Make', car['subCategory'] ?? 'N/A'),
            _buildTableRow('Model Year', car['modelYear'] ?? 'N/A'),
            _buildTableRow('Brand', car['brand'] ?? 'N/A'),
            _buildTableRow('Register In', car['registerIn'] ?? 'N/A'),
            _buildTableRow('KM Driven', "${car['kmDriven'] ?? '0'} km"),
            _buildTableRow('Fuel Type', car['fuelType'] ?? 'N/A'),
            _buildTableRow('Transmission', car['transmission'] ?? 'N/A'),
            _buildTableRow('Color', car['color'] ?? 'N/A'),
            _buildTableRow('Assembly', car['assembly'] ?? 'N/A'),
            _buildTableRow('City', car['city'] ?? 'N/A'),
            _buildTableRow('Condition', car['condition'] ?? 'N/A'),
          ],
        ),
      ],
    );
  }

  // Build table row helper
  TableRow _buildTableRow(String title, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(title)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(value)),
      ],
    );
  }

  // Build seller details section
  Widget _buildSellerDetails() {
    if (userId == widget.carData['userId']) return SizedBox();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Seller Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ListTile(
          leading: CircleAvatar(
            backgroundImage: sellerData?['photoUrl'] != null
                ? NetworkImage(sellerData!['photoUrl'])
                : AssetImage('assets/images/profile.png') as ImageProvider,
          ),
          title: Text(sellerData?['displayName'] ?? 'Unknown Seller'),
          subtitle: Text(sellerData?['email'] ?? 'No Email Provided'),
        ),
        const SizedBox(height: 16),
        
        // Contact options
        CommonButton(
            onTap: callSeller,
            text: "Call Seller"),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: CommonButton(
                backgroundColor: Colors.blue.withAlpha(100),
                onTap: () {
                  // Navigate to chat screen
                },
                text: "Chat",
                textColor: Colors.black,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CommonButton(
                backgroundColor: Colors.blue.withAlpha(100),
                onTap: whatsappSeller,
                text: "WhatsApp",
                textColor: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EditCarScreen extends StatefulWidget {
  final String carId;
  final Map<String, dynamic> carData;

  const EditCarScreen({
    Key? key,
    required this.carId,
    required this.carData,
  }) : super(key: key);

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? "";
  bool _isLoading = false;

  // Controllers for each field
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _kmDrivenController;
  late TextEditingController _contactNumberController;
  late TextEditingController _priceController;
  bool _allowWhatsApp = false;

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

  // Dropdown options
  final List<String> _transmissionOptions = ['Automatic', 'Manual'];
  final List<String> _assemblyOptions = ['Local', 'Imported'];
  final List<String> _fuelTypeOptions = ['Petrol', 'Diesel', 'Hybrid', 'Electric'];
  final List<String> _colorOptions = ['Black', 'White', 'Red', 'Blue', 'Silver', 'Gray'];
  final List<String> _cityOptions = ['Islamabad', 'Karachi', 'Lahore', 'Peshawar', 'Quetta'];
  final List<String> _registerInOptions = ['Islamabad', 'Karachi', 'Lahore', 'Peshawar', 'Quetta'];
  final List<String> _conditionOptions = ['New', 'Used'];
  final List<String> _modelYearOptions = List.generate(31, (index) => (1995 + index).toString());
  final List<String> _brandOptions = ['Toyota', 'Honda', 'Suzuki', 'Mercedes', 'BMW', 'Audi', 'Kia', 'Hyundai'];
  final Map<String, List<String>> _brandSubCategoryMap = {
    'Toyota': ['Corolla', 'Camry', 'Land Cruiser', 'Prado'],
    'Honda': ['Civic', 'City', 'Accord', 'CR-V'],
    'Suzuki': ['Alto', 'Cultus', 'Wagon R', 'Swift'],
    'Mercedes': ['C-Class', 'E-Class', 'S-Class', 'GLC'],
    'BMW': ['3 Series', '5 Series', '7 Series', 'X5'],
    'Audi': ['A3', 'A4', 'A6', 'Q5'],
    'Kia': ['Sportage', 'Sorento', 'Carnival', 'Picanto'],
    'Hyundai': ['Tucson', 'Santa Fe', 'Elantra', 'Sonata'],
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Initialize with existing data
    final car = widget.carData;
    
    _titleController = TextEditingController(text: car['title'] ?? '');
    _descriptionController = TextEditingController(text: car['description'] ?? '');
    _kmDrivenController = TextEditingController(text: car['kmDriven']?.toString() ?? '');
    _contactNumberController = TextEditingController(text: car['contactNumber'] ?? '');
    _priceController = TextEditingController(text: car['price']?.toString() ?? '');
    _allowWhatsApp = car['allowWhatsApp'] ?? false;

    // Set dropdown values
    _selectedTransmission = car['transmission'];
    _selectedAssembly = car['assembly'];
    _selectedFuelType = car['fuelType'];
    _selectedColor = car['color'];
    _selectedCity = car['city'];
    _selectedRegisterIn = car['registerIn'];
    _selectedCondition = car['condition'];
    _selectedBrand = car['brand'];
    _selectedSubCategory = car['subCategory'];
    _selectedModelYear = car['modelYear'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _kmDrivenController.dispose();
    _contactNumberController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateCar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Update the car document with new data
      await _firestore
          .collection("cars")
          .doc(userId)
          .collection("user_cars")
          .doc(widget.carId)
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'price': _priceController.text,
        'kmDriven': _kmDrivenController.text,
        'transmission': _selectedTransmission,
        'assembly': _selectedAssembly,
        'fuelType': _selectedFuelType,
        'color': _selectedColor,
        'city': _selectedCity,
        'registerIn': _selectedRegisterIn,
        'condition': _selectedCondition,
        'brand': _selectedBrand,
        'subCategory': _selectedSubCategory,
        'contactNumber': _contactNumberController.text,
        'allowWhatsApp': _allowWhatsApp,
        'modelYear': _selectedModelYear,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return to previous screen after update
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Car listing updated successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating car: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Car"),
        actions: [
          TextButton(
            onPressed: _updateCar,
            child: Text("SAVE", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Car Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price (PKR)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    // Dropdowns for car details
                    _buildDropdown(
                      label: 'Brand',
                      value: _selectedBrand,
                      items: _brandOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedBrand = value;
                          _selectedSubCategory = null; // Reset sub-category when brand changes
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    if (_selectedBrand != null)
                      _buildDropdown(
                        label: 'Model',
                        value: _selectedSubCategory,
                        items: _brandSubCategoryMap[_selectedBrand] ?? [],
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCategory = value;
                          });
                        },
                      ),
                    if (_selectedBrand != null) SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Model Year',
                      value: _selectedModelYear,
                      items: _modelYearOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedModelYear = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Transmission',
                      value: _selectedTransmission,
                      items: _transmissionOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedTransmission = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Assembly',
                      value: _selectedAssembly,
                      items: _assemblyOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedAssembly = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Fuel Type',
                      value: _selectedFuelType,
                      items: _fuelTypeOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedFuelType = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Color',
                      value: _selectedColor,
                      items: _colorOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedColor = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _kmDrivenController,
                      decoration: InputDecoration(
                        labelText: 'Kilometers Driven',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter kilometers driven';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'City',
                      value: _selectedCity,
                      items: _cityOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Registered In',
                      value: _selectedRegisterIn,
                      items: _registerInOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedRegisterIn = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    _buildDropdown(
                      label: 'Condition',
                      value: _selectedCondition,
                      items: _conditionOptions,
                      onChanged: (value) {
                        setState(() {
                          _selectedCondition = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _contactNumberController,
                      decoration: InputDecoration(
                        labelText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a contact number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    SwitchListTile(
                      title: Text('Allow WhatsApp Contact'),
                      value: _allowWhatsApp,
                      onChanged: (value) {
                        setState(() {
                          _allowWhatsApp = value;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    
                    ElevatedButton(
                      onPressed: _updateCar,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'UPDATE CAR',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a $label';
        }
        return null;
      },
    );
  }
}