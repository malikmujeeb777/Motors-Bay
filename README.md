# MotorsBay

A Flutter project for vehicle marketplace with a Python-based recommendation system.

## Project Overview

This project consists of:
1. A Flutter mobile application for the MotorsBay marketplace
2. A Python-based recommendation system that runs locally

## Recommendation System

The new Python recommendation system is designed to:

1. Run locally on the developer's PC
2. Follow the same scoring approach as the current Dart implementation
3. Use only essential parameters from user preferences and ad listings
4. Include simplified test data for testing accuracy

### Essential Parameters

The system focuses on these key parameters:

- **User Preferences**:
  - `vehicle_type` (Sedan, SUV, Hatchback, etc.)
  - `condition` (New, Used)
  - `price_range` (Price brackets in PKR)
  - `preferred_brands` (List of car brands)
  - `fuel_type` (Petrol, Diesel, Hybrid, Electric)
  - `transmission` (Automatic, Manual)

### Running the Recommendation System

1. Ensure Python 3.8+ is installed
2. Install dependencies:
   ```bash
   pip install fastapi uvicorn pandas
   ```
3. Start the recommendation system:
   ```bash
   python recommendation_system.py
   ```
4. Access the API documentation at:
   ```
   http://localhost:8000/docs
   ```
5. Generate test data:
   ```
   http://localhost:8000/create_test_data/
   ```

## Flutter Application

For the Flutter application development:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
