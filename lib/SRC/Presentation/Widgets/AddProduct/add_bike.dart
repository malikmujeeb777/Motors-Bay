import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../exports.dart';

class AddBike extends StatefulWidget {
  const AddBike({super.key});

  @override
  State<AddBike> createState() => _AddBikeState();
}

class _AddBikeState extends State<AddBike> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _kmDrivenController = TextEditingController();
  final TextEditingController _transmissionController = TextEditingController();
  final TextEditingController _assemblyController = TextEditingController();
  final TextEditingController _engineCapacityController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _modelYearController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _registerInController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _featuresController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();

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
                AppTextField(
                  controller: _priceController,
                  textInputType: TextInputType.number,
                  hintText: "Price",
                  validator: (value) => value!.isEmpty ? 'Price is required' : null,
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
                AppTextField(
                  controller: _transmissionController,
                  textInputType: TextInputType.text,
                  hintText: "Transmission",
                  validator: (value) => value!.isEmpty ? 'Transmission is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _assemblyController,
                  textInputType: TextInputType.text,
                  hintText: "Assembly",
                  validator: (value) => value!.isEmpty ? 'Assembly is required' : null,
                ),

                10.y,
                AppTextField(
                  controller: _engineCapacityController,
                  textInputType: TextInputType.text,
                  hintText: "Engine Capacity",
                  validator: (value) => value!.isEmpty ? 'Engine Capacity is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _colorController,
                  textInputType: TextInputType.text,
                  hintText: "Color",
                  validator: (value) => value!.isEmpty ? 'Color is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _modelYearController,
                  textInputType: TextInputType.number,
                  hintText: "Model Year",
                  validator: (value) => value!.isEmpty ? 'Model Year is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _cityController,
                  textInputType: TextInputType.text,
                  hintText: "City",
                  validator: (value) => value!.isEmpty ? 'City is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _registerInController,
                  textInputType: TextInputType.text,
                  hintText: "Register In",
                  validator: (value) => value!.isEmpty ? 'Register In is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _areaController,
                  textInputType: TextInputType.text,
                  hintText: "Area",
                  validator: (value) => value!.isEmpty ? 'Area is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _featuresController,
                  textInputType: TextInputType.text,
                  hintText: "Features",
                  validator: (value) => value!.isEmpty ? 'Features are required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _mileageController,
                  textInputType: TextInputType.text,
                  hintText: "Mileage",
                  validator: (value) => value!.isEmpty ? 'Mileage is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _conditionController,
                  textInputType: TextInputType.text,
                  hintText: "Condition",
                  validator: (value) => value!.isEmpty ? 'Condition is required' : null,
                ),
                10.y,
                AppTextField(
                  controller: _vinController,
                  textInputType: TextInputType.text,
                  hintText: "VIN",
                  validator: (value) => value!.isEmpty ? 'VIN is required' : null,
                ),
                20.y,
                CommonButton(onTap: _uploadCarDetails, text: "Upload Car",),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _uploadCarDetails() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not logged in!")));
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection("bikes")
            .doc(user.uid)
            .collection("user_bikes")
            .add({
          "listingType" : "bike",
          "title": _titleController.text,
          "price": _priceController.text,
          "description": _descriptionController.text,
          "kmDriven": _kmDrivenController.text,
          "transmission": _transmissionController.text,
          "assembly": _assemblyController.text,
          "engineCapacity": _engineCapacityController.text,
          "color": _colorController.text,
          "modelYear": _modelYearController.text,
          "city": _cityController.text,
          "registerIn": _registerInController.text,
          "area": _areaController.text,
          "features": _featuresController.text,
          "mileage": _mileageController.text,
          "condition": _conditionController.text,
          "vin": _vinController.text,
          "createdAt": Timestamp.now(),
          "userId": user.uid,
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
    _priceController.dispose();
    _descriptionController.dispose();
    _kmDrivenController.dispose();
    _transmissionController.dispose();
    _assemblyController.dispose();
    _engineCapacityController.dispose();
    _colorController.dispose();
    _modelYearController.dispose();
    _cityController.dispose();
    _registerInController.dispose();
    _areaController.dispose();
    _featuresController.dispose();
    _mileageController.dispose();
    _conditionController.dispose();
    _vinController.dispose();
    super.dispose();
  }
}