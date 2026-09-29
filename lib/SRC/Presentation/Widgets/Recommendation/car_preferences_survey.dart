import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/community.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Recommendation/services/car_recommendation_service.dart';

class CarPreferencesSurvey extends StatefulWidget {
  final bool isOnboarding;
  
  const CarPreferencesSurvey({
    Key? key,
    this.isOnboarding = false, 
  }) : super(key: key);

  @override
  _CarPreferencesSurveyState createState() => _CarPreferencesSurveyState();
}

class _CarPreferencesSurveyState extends State<CarPreferencesSurvey> {
  final CarRecommendationService _recommendationService = CarRecommendationService();
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Form values - simplified to only 5 parameters
  List<String> _selectedBrands = [];
  String? _selectedFuelType;
  String? _selectedCity;
  List<String> _selectedStyles = [];
  bool _has3DModel = false;
  
  // Dropdown options
  final List<String> _fuelTypeOptions = ['Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG'];
  
  final List<String> _cityOptions = [
    'Islamabad', 'Karachi', 'Lahore', 'Peshawar', 'Quetta', 'Rawalpindi', 'Multan',
    'Faisalabad', 'Gujranwala', 'Sialkot', 'Hyderabad', 'Abbottabad', 'Bahawalpur'
  ];
  
  final List<String> _brandOptions = [
    'Toyota', 'Honda', 'Suzuki', 'Daihatsu', 'Nissan', 'Mitsubishi', 'Mazda',
    'Hyundai', 'Kia', 'MG', 'Changan', 'Proton', 'FAW', 'BAIC', 'Haval', 'Chery',
    'Audi', 'BMW', 'Mercedes-Benz', 'Volkswagen'
  ];
  
  final List<String> _carStyleOptions = [
    'Luxury', 'Classic', 'Sport', 'Off-Road', 'Family', 'Economy'
  ];
  
  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }
  
  // Load existing preferences
  Future<void> _loadUserPreferences() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final preferences = await _recommendationService.getUserPreferences();
      
      if (preferences != null) {
        setState(() {
          _selectedBrands = List<String>.from(preferences['preferredBrands'] ?? []);
          _selectedFuelType = preferences['preferredFuelType'];
          _selectedCity = preferences['preferredCity'];
          _selectedStyles = List<String>.from(preferences['preferredStyles'] ?? []);
          _has3DModel = preferences['has3DModel'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading preferences: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Save preferences
  Future<void> _savePreferences() async {
    // Validate that at least some preferences are selected
    if (_selectedBrands.isEmpty && 
        _selectedFuelType == null && 
        _selectedCity == null &&
        _selectedStyles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least some preferences')),
      );
      return;
    }
    
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save to Firestore
      await _recommendationService.saveUserPreferences({
        'preferredBrands': _selectedBrands,
        'preferredFuelType': _selectedFuelType,
        'preferredCity': _selectedCity,
        'preferredStyles': _selectedStyles,
        'has3DModel': _has3DModel,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Your preferences have been saved')),
      );
      
      // Navigate based on context
      if (widget.isOnboarding) {
        // If in onboarding mode, navigate to community page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CommunityPage()),
        );
      } else {
        // If user is updating preferences, go back to previous screen then to community
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CommunityPage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving preferences: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
  
  // Toggle item selection in a list
  void _toggleSelection(String item, List<String> list) {
    setState(() {
      if (list.contains(item)) {
        list.remove(item);
      } else {
        list.add(item);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Car Preferences'),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tell us your car preferences',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This will help us recommend cars that match your needs',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Preferred Brands
                  _buildSectionTitle('Preferred Brands'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _brandOptions.map((brand) {
                      final isSelected = _selectedBrands.contains(brand);
                      return FilterChip(
                        label: Text(brand),
                        selected: isSelected,
                        onSelected: (_) => _toggleSelection(brand, _selectedBrands),
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[800],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  
                  // Fuel Type
                  _buildSectionTitle('Preferred Fuel Type'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _fuelTypeOptions.map((fuelType) {
                      final isSelected = _selectedFuelType == fuelType;
                      return FilterChip(
                        label: Text(fuelType),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedFuelType = isSelected ? null : fuelType;
                          });
                        },
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[800],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  
                  // City
                  _buildSectionTitle('Preferred City'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _cityOptions.map((city) {
                      final isSelected = _selectedCity == city;
                      return FilterChip(
                        label: Text(city),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            _selectedCity = isSelected ? null : city;
                          });
                        },
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[800],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  
                  // Car Styles
                  _buildSectionTitle('Car Style Preferences'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _carStyleOptions.map((style) {
                      final isSelected = _selectedStyles.contains(style);
                      return FilterChip(
                        label: Text(style),
                        selected: isSelected,
                        onSelected: (_) => _toggleSelection(style, _selectedStyles),
                        selectedColor: Colors.blue[100],
                        checkmarkColor: Colors.blue[800],
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),
                  
                  // 3D Model Availability
                  _buildSectionTitle('3D Model Availability'),
                  SwitchListTile(
                    title: Text('Show cars with 3D models only'),
                    value: _has3DModel,
                    onChanged: (value) {
                      setState(() {
                        _has3DModel = value;
                      });
                    },
                    activeColor: Colors.blue,
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  ),
                  SizedBox(height: 32),
                  
                  // Save Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Save Preferences',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
  
  // Helper for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
