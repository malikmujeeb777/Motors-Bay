import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motorsbay1/SRC/Data/Models/community_post_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Community/services/community_service.dart';

class CreatePostPage extends StatefulWidget {
  final bool isEditing;
  final CommunityPost? post;

  const CreatePostPage({
    Key? key,
    this.isEditing = false,
    this.post,
  }) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final CommunityService _communityService = CommunityService();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  bool _isLoading = false;
  bool _showPreferenceForm = false;
  
  // Selected preference values - simplified to 5 parameters
  String? _selectedBrand;
  String? _selectedFuelType;
  String? _selectedCity;
  String? _selectedCarStyle;
  bool _has3DModel = false;
  
  // Dropdown options
  final List<String> _brands = [
    'Toyota', 'Honda', 'Suzuki', 'Kia', 'Hyundai', 'Nissan', 
    'Mitsubishi', 'Mercedes', 'BMW', 'Audi', 'MG', 'Changan',
    'Other'
  ];
  
  final List<String> _fuelTypes = [
    'Petrol', 'Diesel', 'Hybrid', 'Electric', 'CNG', 'LPG', 'Other'
  ];
  
  final List<String> _cityOptions = [
    'Islamabad', 'Karachi', 'Lahore', 'Peshawar', 'Quetta', 'Rawalpindi', 'Multan',
    'Faisalabad', 'Gujranwala', 'Sialkot', 'Hyderabad', 'Abbottabad', 'Bahawalpur'
  ];
  
  final List<String> _carStyleOptions = [
    'Luxury', 'Classic', 'Sport', 'Off-Road', 'Family', 'Economy'
  ];
  
  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.post != null) {
      _descriptionController.text = widget.post!.description;
      _selectedBrand = widget.post!.brand;
      _selectedFuelType = widget.post!.fuelType;
      _selectedCity = widget.post!.city;
      _selectedCarStyle = widget.post!.carStyle;
      _has3DModel = widget.post!.has3DModel;
      // TODO: Load existing images
    }
  }

  // Helper method to build dropdown fields
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: InputBorder.none,
        ),
        isExpanded: true,
        icon: Icon(Icons.arrow_drop_down, color: Color(0xFF1976D2)),
        style: TextStyle(color: Colors.black, fontSize: 16),
        onChanged: onChanged,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
  
  // Pick images from gallery
  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: 70,
      );
      
      if (pickedImages.isNotEmpty) {
        // Limit to 5 images max
        final List<XFile> newImages = List<XFile>.from(_selectedImages);
        newImages.addAll(pickedImages);
        if (newImages.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can select up to 5 images')),
          );
          newImages.removeRange(5, newImages.length);
        }
        
        setState(() {
          _selectedImages = newImages;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }
  
  // Take a photo with camera
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (photo != null) {
        if (_selectedImages.length >= 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You can select up to 5 images')),
          );
          return;
        }
        
        setState(() {
          _selectedImages.add(photo);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }
  
  // Remove an image from selection
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
    // Create the post
  Future<void> _createPost() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.isEditing && widget.post != null) {
        // Update existing post
        await _communityService.updatePost(
          widget.post!.id!,
          _descriptionController.text.trim(),
          _selectedBrand,
          _selectedFuelType,
          _selectedCity,
          _selectedCarStyle,
          _has3DModel,
          _selectedImages,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post updated successfully')),
        );
      } else {
        // Create new post
        await _communityService.createPost(
          description: _descriptionController.text.trim(),
          images: _selectedImages,
          brand: _selectedBrand,
          fuelType: _selectedFuelType,
          city: _selectedCity,
          carStyle: _selectedCarStyle,
          has3DModel: _has3DModel,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post created successfully')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Show image selection options
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Pick from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImages();
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Take a photo'),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
        ],
      ),
    );
  }

  // Expandable form fields section (modified)
  Widget _buildPreferenceForm() {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add details to help others find your post',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 16),
          
          // Brand dropdown
          _buildDropdown(
            hint: 'Car Brand',
            value: _selectedBrand,
            items: _brands,
            onChanged: (value) {
              setState(() {
                _selectedBrand = value;
              });
            },
          ),
          SizedBox(height: 12),
          
          // Fuel type dropdown
          _buildDropdown(
            hint: 'Fuel Type',
            value: _selectedFuelType,
            items: _fuelTypes,
            onChanged: (value) {
              setState(() {
                _selectedFuelType = value;
              });
            },
          ),
          SizedBox(height: 12),
          
          // City dropdown
          _buildDropdown(
            hint: 'City',
            value: _selectedCity,
            items: _cityOptions,
            onChanged: (value) {
              setState(() {
                _selectedCity = value;
              });
            },
          ),
          SizedBox(height: 12),
          
          // Car style dropdown
          _buildDropdown(
            hint: 'Car Style',
            value: _selectedCarStyle,
            items: _carStyleOptions,
            onChanged: (value) {
              setState(() {
                _selectedCarStyle = value;
              });
            },
          ),
          SizedBox(height: 12),
          
          // 3D Model availability switch
          SwitchListTile(
            title: Text('3D Model Available'),
            value: _has3DModel,
            onChanged: (value) {
              setState(() {
                _has3DModel = value;
              });
            },
            activeColor: Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Post' : 'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          // Post button
          Container(
            margin: EdgeInsets.only(right: 10),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading ? Colors.grey.shade300 : Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    widget.isEditing ? 'Update' : 'Post',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile section
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(Icons.person, color: Colors.grey.shade700, size: 28),
                    // If user has profile photo:
                    // backgroundImage: NetworkImage(userPhotoUrl),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Name', // Replace with actual user name from Firebase
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Public post',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
              // Description input
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind about cars?',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
                style: TextStyle(
                  fontSize: 18,
                ),
                maxLines: 5,
                maxLength: 500,
              ),
            ),
            
            // Post preferences section
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Clickable header to expand/collapse
                  InkWell(
                    onTap: () {
                      setState(() {
                        _showPreferenceForm = !_showPreferenceForm;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Color(0xFF1976D2),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Categorize your post',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            _showPreferenceForm
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Expandable form fields
                  if (_showPreferenceForm)
                    _buildPreferenceForm(),
                ],
              ),
            ),
            
            // Selected images
            if (_selectedImages.isNotEmpty)
              Container(
                height: 120,
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  padding: EdgeInsets.only(left: 16),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            image: DecorationImage(
                              image: FileImage(File(_selectedImages[index].path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            
            // Add image button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: OutlinedButton.icon(
                onPressed: _showImagePickerOptions,
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: Color(0xFF1976D2),
                ),
                label: Text(
                  'Add Photos',
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF1976D2)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
