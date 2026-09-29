"""
Generate test data for the MotorsBay Recommendation System.
This script creates sample car data and user preferences for testing.
"""

import pandas as pd
import os

def generate_test_data():
    """Generate test dataset for sample recommendations"""    print("Generating test data...")
    # Create directory for test data
    os.makedirs("test_data", exist_ok=True)
    
    # Define simplified data for our test
    # Using only the essential parameters:
    # - vehicle_type (Sedan, SUV, etc)
    # - condition (New, Used)
    # - price_range (in PKR)
    # - brand
    # - fuel_type
    # - transmission
    
    # Sample vehicles
    vehicles = [
        {
            "id": f"car_{i}",
            "brand": brand,
            "vehicle_type": v_type,
            "fuel_type": fuel,
            "transmission": trans,
            "price_range": price,
            "condition": cond
        }
        for i, (brand, v_type, fuel, trans, price, cond) in enumerate([
            ("Honda", "Sedan", "Petrol", "Automatic", "1500000-2500000", "Used"),
            ("Toyota", "SUV", "Diesel", "Manual", "2500000-3500000", "Used"),
            ("Suzuki", "Hatchback", "Petrol", "Manual", "1000000-1500000", "New"),
            ("Honda", "Sedan", "Hybrid", "Automatic", "2500000-3500000", "New"),
            ("Toyota", "Sedan", "Petrol", "Automatic", "1500000-2500000", "Used"),
            ("BMW", "SUV", "Diesel", "Automatic", "3500000-5000000", "Used"),
            ("Mercedes", "Sedan", "Petrol", "Automatic", "3500000-5000000", "New"),
            ("Suzuki", "Hatchback", "Petrol", "Manual", "500000-1000000", "Used"),
            ("Honda", "SUV", "Diesel", "Manual", "2500000-3500000", "Used"),
            ("Toyota", "Sedan", "Hybrid", "Automatic", "2500000-3500000", "New"),
            ("Kia", "SUV", "Diesel", "Automatic", "2500000-3500000", "New"),
            ("Hyundai", "Sedan", "Petrol", "Manual", "1500000-2500000", "Used"),
            ("Suzuki", "SUV", "Petrol", "Manual", "1000000-1500000", "Used"),
            ("Kia", "Hatchback", "Petrol", "Automatic", "1500000-2500000", "New"),
            ("Honda", "Sedan", "Petrol", "Manual", "1000000-1500000", "Used")
        ])
    ]
    
    # Create a CSV file with the test data
    df = pd.DataFrame(vehicles)
    df.to_csv("test_data/test_cars.csv", index=False)
    print(f"Created test cars data with {len(df)} entries")
    
    # Create sample users
    users = [
        {
            'user_id': 'user_001',
            'vehicle_type': 'Sedan',
            'condition': 'Used',
            'price_range': '1500000-2500000',
            'preferred_brands': 'Honda,Toyota',
            'fuel_type': 'Petrol',
            'transmission': 'Automatic'
        },
        {
            'user_id': 'user_002',
            'vehicle_type': 'SUV',
            'condition': 'New',
            'price_range': '2500000-3500000',
            'preferred_brands': 'Kia,Hyundai',
            'fuel_type': 'Diesel',
            'transmission': 'Automatic'
        },
        {
            'user_id': 'user_003',
            'vehicle_type': 'Hatchback',
            'condition': 'Used',
            'price_range': '500000-1000000',
            'preferred_brands': 'Suzuki',
            'fuel_type': 'Petrol',
            'transmission': 'Manual'
        }
    ]
    
    # Create a CSV file with user preferences
    users_df = pd.DataFrame(users)
    users_df.to_csv("test_data/test_users.csv", index=False)
    print(f"Created test user preferences with {len(users_df)} entries")
    
    # Create expected recommendations (ground truth) for evaluation
    ground_truth = []
    for user in users:
        # Match the first user with Honda and Toyota sedans
        if user['user_id'] == 'user_001':
            matches = ["car_0", "car_4"]  # Honda and Toyota sedans
        # Match the second user with SUVs from Kia
        elif user['user_id'] == 'user_002':
            matches = ["car_10"]  # Kia SUV
        # Match the third user with Suzuki hatchbacks        else:
            matches = ["car_7"]  # Suzuki hatchback
            
        for vehicle_id in matches:
            ground_truth.append({
                'user_id': user['user_id'],
                'vehicle_id': vehicle_id,
                'is_match': 1
            })
    
    # Create a CSV file with expected recommendations
    ground_truth_df = pd.DataFrame(ground_truth)
    ground_truth_df.to_csv("test_data/ground_truth.csv", index=False)
    print(f"Created ground truth data with {len(ground_truth_df)} expected matches")
    
    print("Test data generation complete!")
    print("Files saved in the test_data directory:")
    print("- test_cars.csv: Sample car listings")
    print("- test_users.csv: Sample user preferences")
    print("- ground_truth.csv: Expected good matches for evaluation")
    
    # Create a simple README file with instructions
    readme_content = """# MotorsBay Recommendation System Test Data

This directory contains test data for the MotorsBay recommendation system.

## Files

- `test_cars.csv`: Sample car listings with essential parameters
- `test_users.csv`: Sample user preferences
- `ground_truth.csv`: Expected matches for evaluation

## How to Use

1. Start the recommendation system API:
   ```
   python ../recommendation_system.py
   ```

2. Test user preference saving:
   ```
   curl -X POST "http://localhost:8000/save_preferences/" -H "Content-Type: application/json" -d @test_users.csv
   ```

3. Get recommendations for a user:
   ```
   curl -X POST "http://localhost:8000/recommend_cars/" -F "user_id=user_001" -F "cars_file=@test_cars.csv"
   ```
"""
    
    with open("test_data/README.md", "w") as f:
        f.write(readme_content)
    print("Created README.md with usage instructions")

if __name__ == "__main__":
    generate_test_data()

# Conditions
conditions = ['New', 'Used']

# Generate car data
def generate_car_data(num_cars=200):
    car_data = []
    
    for i in range(num_cars):
        car_id = f'CAR{i+1:03d}'
        brand = np.random.choice(brands)
        model = np.random.choice(car_models[brand])
        car_type = np.random.choice(brand_to_type.get(brand, car_types))
        fuel_type = np.random.choice(fuel_types, p=[0.70, 0.15, 0.10, 0.05])  # Pakistan market probabilities
        transmission = np.random.choice(transmission_types, p=[0.60, 0.30, 0.10])
        price_range = np.random.choice(brand_price_mapping.get(brand, price_ranges))
        condition = np.random.choice(conditions, p=[0.3, 0.7])  # More used cars
        km_driven = 0 if condition == 'New' else int(np.random.exponential(50000) + 1000)
        city = np.random.choice(cities)
        year = np.random.randint(2012 if condition == 'Used' else 2022, 2025)
        
        features = []
        if np.random.random() > 0.5:
            features.append('Air Conditioning')
        if np.random.random() > 0.7:
            features.append('Alloy Wheels')
        if np.random.random() > 0.6:
            features.append('Power Steering')
        if np.random.random() > 0.5:
            features.append('Power Windows')
        if np.random.random() > 0.7:
            features.append('Navigation')
        if np.random.random() > 0.8:
            features.append('Sunroof')
            
        car_data.append({
            'car_id': car_id,
            'brand': brand,
            'model': model,
            'carType': car_type,
            'fuelType': fuel_type,
            'transmission': transmission,
            'priceRange': price_range,
            'condition': condition,
            'kmDriven': km_driven,
            'city': city,
            'year': year,
            'features': ','.join(features),
        })
    
    return pd.DataFrame(car_data)

# Generate user preferences
def generate_user_preferences(num_users=30):
    user_data = []
    
    for i in range(num_users):
        user_id = f'USER{i+1:03d}'
        preferred_brands = np.random.choice(brands, size=np.random.randint(1, 4), replace=False).tolist()
        preferred_car_types = np.random.choice(car_types, size=np.random.randint(1, 3), replace=False).tolist()
        preferred_fuel_type = np.random.choice(fuel_types)
        preferred_transmission = np.random.choice(transmission_types)
        price_range = np.random.choice(price_ranges)
        condition = np.random.choice(conditions)
        max_km_driven = np.random.choice([50000, 75000, 100000, 150000, None])
        preferred_city = np.random.choice(cities)
        
        features = []
        if np.random.random() > 0.5:
            features.append('Air Conditioning')
        if np.random.random() > 0.6:
            features.append('Alloy Wheels')
        if np.random.random() > 0.7:
            features.append('Navigation')
        
        user_data.append({
            'user_id': user_id,
            'preferredBrands': ','.join(preferred_brands),
            'preferredCarTypes': ','.join(preferred_car_types),
            'preferredFuelType': preferred_fuel_type,
            'preferredTransmission': preferred_transmission,
            'priceRange': price_range,
            'condition': condition,
            'maxKmDriven': max_km_driven if max_km_driven else '',
            'preferredCity': preferred_city,
            'preferredFeatures': ','.join(features)
        })
    
    return pd.DataFrame(user_data)

# Generate user activity data
def generate_user_activity(users_df, cars_df, num_activities=300):
    activity_data = []
    
    for _ in range(num_activities):
        user = users_df.sample(1).iloc[0]
        car = cars_df.sample(1).iloc[0]
        
        # Define the likelihood of different interaction types
        # (Users are more likely to view cars matching their preferences)
        brand_match = car['brand'] in user['preferredBrands'].split(',')
        car_type_match = car['carType'] in user['preferredCarTypes'].split(',')
        
        action_types = ['view', 'inquire', 'favorite', 'test_drive']
        action_probs = [0.7, 0.15, 0.1, 0.05]  # Default probabilities
        
        # Adjust probabilities based on preferences
        if brand_match and car_type_match:
            action_probs = [0.4, 0.3, 0.2, 0.1]  # More likely to engage deeply
        
        action_type = np.random.choice(action_types, p=action_probs)
        
        activity_data.append({
            'userId': user['user_id'],
            'carId': car['car_id'],
            'brand': car['brand'],
            'model': car['model'],
            'carType': car['carType'],
            'fuelType': car['fuelType'],
            'transmission': car['transmission'],
            'priceRange': car['priceRange'],
            'condition': car['condition'],
            'kmDriven': car['kmDriven'],
            'city': car['city'],
            'actionType': action_type,
            'timestamp': pd.Timestamp.now() - pd.Timedelta(days=np.random.randint(1, 30))
        })
    
    return pd.DataFrame(activity_data)

# Generate ground truth data for evaluation
def generate_ground_truth(users_df, cars_df):
    ground_truth_data = []
    
    for _, user in users_df.iterrows():
        user_id = user['user_id']
        preferred_brands = user['preferredBrands'].split(',')
        preferred_car_types = user['preferredCarTypes'].split(',')
        
        # Generate some "perfect match" cars
        perfect_matches = cars_df[
            (cars_df['brand'].isin(preferred_brands)) & 
            (cars_df['carType'].isin(preferred_car_types)) &
            (cars_df['fuelType'] == user['preferredFuelType'])
        ]
        
        # Select up to 5 perfect matches
        if len(perfect_matches) > 0:
            perfect_matches = perfect_matches.sample(min(5, len(perfect_matches)))
            
            for _, car in perfect_matches.iterrows():
                ground_truth_data.append({
                    'user_id': user_id,
                    'car_id': car['car_id'],
                    'brand': car['brand'],
                    'model': car['model'],
                    'carType': car['carType'],
                    'fuelType': car['fuelType'],
                    'is_good_match': 1  # This is a good match
                })
        
        # Add some random cars that aren't good matches
        non_matches = cars_df[
            ~(cars_df['brand'].isin(preferred_brands)) | 
            ~(cars_df['carType'].isin(preferred_car_types))
        ]
        
        if len(non_matches) > 0:
            non_matches = non_matches.sample(min(5, len(non_matches)))
            
            for _, car in non_matches.iterrows():
                ground_truth_data.append({
                    'user_id': user_id,
                    'car_id': car['car_id'],
                    'brand': car['brand'],
                    'model': car['model'],
                    'carType': car['carType'],
                    'fuelType': car['fuelType'],
                    'is_good_match': 0  # Not a good match
                })
    
    return pd.DataFrame(ground_truth_data)

# Generate all datasets
print("Generating car dataset...")
cars_df = generate_car_data(200)
print(f"Generated {len(cars_df)} cars")

print("Generating user preferences...")
users_df = generate_user_preferences(30)
print(f"Generated {len(users_df)} user profiles")

print("Generating user activity data...")
activity_df = generate_user_activity(users_df, cars_df, 300)
print(f"Generated {len(activity_df)} user activities")

print("Generating ground truth evaluation data...")
ground_truth_df = generate_ground_truth(users_df, cars_df)
print(f"Generated {len(ground_truth_df)} evaluation entries")

# Save datasets to Excel files
print("Saving datasets to Excel files...")

# Save cars dataset
cars_df.to_excel('test_data/cars.xlsx', index=False)

# Save user preferences
users_df.to_excel('test_data/user_preferences.xlsx', index=False)

# Save user activity
activity_df.to_excel('test_data/user_activity.xlsx', index=False)

# Save ground truth for evaluation
ground_truth_df.to_excel('test_data/ground_truth.xlsx', index=False)

# Also save as CSV for API testing
cars_df.to_csv('test_data/cars.csv', index=False)
users_df.to_csv('test_data/user_preferences.csv', index=False)
activity_df.to_csv('test_data/user_activity.csv', index=False)
ground_truth_df.to_csv('test_data/ground_truth.csv', index=False)

print("Done! Files saved in the test_data directory.")
