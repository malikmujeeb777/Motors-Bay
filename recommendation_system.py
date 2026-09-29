from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict
import pandas as pd
import numpy as np
import os
import uvicorn

app = FastAPI(title="MotorsBay Recommendation System")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Directory for storing user data and models
BASE_DIR = "recommendation_data"
os.makedirs(BASE_DIR, exist_ok=True)

# Define data models
class UserPreference(BaseModel):
    user_id: str
    vehicle_type: str  # Car type (sedan, SUV, etc)
    condition: str
    price_range: str
    preferred_brands: List[str] 
    fuel_type: str
    transmission: str

class ActivityData(BaseModel):
    user_id: str  
    clicked_vehicle_type: str
    clicked_brand: str
    clicked_fuel: str
    clicked_price_range: str

# Weights for scoring - matching the Dart implementation
WEIGHTS = {
    'priceMatch': 3.0,     # Higher weight for price match
    'brandMatch': 2.5,     # Pakistani users often have strong brand preferences
    'fuelType': 2.0,       # Fuel economy is important in Pakistani market
    'carType': 1.8,        # Car type (sedan, SUV, etc)
    'transmission': 1.5,   # Auto vs manual preference
    'condition': 2.2,      # New vs used condition
}

# Helper functions
def prepare_user_folder(user_id):
    """Create and return the directory path for a user"""
    user_folder = os.path.join(BASE_DIR, user_id)
    os.makedirs(user_folder, exist_ok=True)
    return user_folder

def train_user_model(user_id):
    """Train a recommendation model based on user preferences and activity"""
    user_folder = prepare_user_folder(user_id)
    activity_path = os.path.join(user_folder, "activity.csv")
    signup_path = os.path.join(user_folder, "signup.csv")

    # Check if we have enough activity data to train a model
    if os.path.exists(activity_path):
        df_activity = pd.read_csv(activity_path)
        if len(df_activity) >= 5:
            # We have enough activity data to train a model based on it
            return True

    # Otherwise, rely on the initial preferences from signup
    return os.path.exists(signup_path)

def calculate_car_score(car_data, user_preferences):
    """Calculate a score for how well a car matches user preferences"""
    score = 0.0
    
    # Price Range Matching
    if car_data.get('price_range') == user_preferences.get('price_range'):
        score += WEIGHTS['priceMatch']
    
    # Brand Matching
    if car_data.get('brand') in user_preferences.get('preferred_brands', []):
        score += WEIGHTS['brandMatch']
    
    # Car Type (Vehicle Type)
    if car_data.get('vehicle_type') == user_preferences.get('vehicle_type'):
        score += WEIGHTS['carType']
      # Fuel Type
    if car_data.get('fuel_type') == user_preferences.get('fuel_type'):
        score += WEIGHTS['fuelType']
    
    # Transmission
    if car_data.get('transmission') == user_preferences.get('transmission'):
        score += WEIGHTS['transmission']
    
    # Condition (New vs Used)
    if car_data.get('condition') == user_preferences.get('condition'):
        score += WEIGHTS['condition']
    
    return score
    
# API endpoints for the recommendation system will be implemented here

# API Endpoints
@app.post("/save_preferences/")
async def api_save_preferences(preferences: UserPreference):
    """Save user preferences to the system"""
    try:
        user_folder = prepare_user_folder(preferences.user_id)
        
        # Save as CSV for compatibility
        preferences_df = pd.DataFrame([{
            'user_id': preferences.user_id,
            'vehicle_type': preferences.vehicle_type,
            'condition': preferences.condition, 
            'price_range': preferences.price_range,
            'preferred_brands': ','.join(preferences.preferred_brands),
            'fuel_type': preferences.fuel_type,
            'transmission': preferences.transmission
        }])
        
        preferences_df.to_csv(os.path.join(user_folder, "signup.csv"), index=False)
        
        return {"status": "success", "message": "Preferences saved successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save preferences: {str(e)}")

@app.get("/get_preferences/{user_id}")
async def api_get_preferences(user_id: str):
    """Get user preferences from the system"""
    try:
        user_folder = prepare_user_folder(user_id)
        preferences_path = os.path.join(user_folder, "signup.csv")
        
        if os.path.exists(preferences_path):
            preferences_df = pd.read_csv(preferences_path)
            
            # Convert back to dictionary
            preferences = preferences_df.iloc[0].to_dict()
            
            # Convert string of brands back to list
            if 'preferred_brands' in preferences:
                preferences['preferred_brands'] = preferences['preferred_brands'].split(',')
                
            return preferences
        return {"status": "error", "message": "No preferences found for this user"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get preferences: {str(e)}")

@app.post("/save_activity/")
async def api_save_activity(activity: ActivityData):
    """Save user activity data"""
    try:
        user_folder = prepare_user_folder(activity.user_id)
        activity_path = os.path.join(user_folder, "activity.csv")
        
        # Convert to DataFrame
        activity_df = pd.DataFrame([{
            'user_id': activity.user_id,
            'clicked_vehicle_type': activity.clicked_vehicle_type,
            'clicked_brand': activity.clicked_brand,
            'clicked_fuel': activity.clicked_fuel,
            'clicked_price_range': activity.clicked_price_range
        }])
        
        # Append or create activity file
        if os.path.exists(activity_path):
            existing_df = pd.read_csv(activity_path)
            updated_df = pd.concat([existing_df, activity_df], ignore_index=True)
            updated_df.to_csv(activity_path, index=False)
        else:
            activity_df.to_csv(activity_path, index=False)
            
        return {"status": "success", "message": "Activity saved successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save activity: {str(e)}")

@app.post("/recommend_cars/")
async def recommend_cars(
    user_id: str = Form(...),
    cars_file: UploadFile = File(...)
):
    """
    Recommend cars based on user preferences and activity pattern
    
    Upload a CSV file containing car listings with the following columns:
    - id: unique identifier for the car
    - brand: car brand/make
    - vehicle_type: type of car (sedan, SUV, etc.)
    - fuel_type: fuel type (petrol, diesel, etc.)
    - transmission: transmission type (automatic, manual)
    - price_range: price range category
    - condition: new or used
    """
    try:
        # Read the uploaded cars CSV file
        cars_df = pd.read_csv(cars_file.file)
        
        # Validate required columns
        required_cols = ['id', 'brand', 'vehicle_type', 'fuel_type', 'transmission', 'price_range', 'condition']
        for col in required_cols:
            if col not in cars_df.columns:
                raise HTTPException(status_code=400, detail=f"Missing required column: {col}")
        
        # Get user preferences
        user_folder = prepare_user_folder(user_id)
        preferences_path = os.path.join(user_folder, "signup.csv")
        
        if not os.path.exists(preferences_path):
            raise HTTPException(status_code=404, detail="User preferences not found")
            
        preferences_df = pd.read_csv(preferences_path)
        preferences = preferences_df.iloc[0].to_dict()
        
        # Convert string of brands back to list
        if 'preferred_brands' in preferences:
            preferences['preferred_brands'] = preferences['preferred_brands'].split(',') if preferences['preferred_brands'] else []
        
        # Calculate scores for each car
        scores = []
        for _, car in cars_df.iterrows():
            car_dict = car.to_dict()
            score = calculate_car_score(car_dict, preferences)
            scores.append({'id': car['id'], 'score': score})
        
        # Sort by score descending and get top 10
        scores_df = pd.DataFrame(scores)
        top_cars = scores_df.sort_values('score', ascending=False).head(10)
          # Include car details for recommended cars
        recommended_cars = []
        for _, row in top_cars.iterrows():
            car_id = row['id']
            car_details = cars_df[cars_df['id'] == car_id].iloc[0].to_dict()            
            car_details['score'] = row['score']
            recommended_cars.append(car_details)
        
        return {"recommendations": recommended_cars}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Recommendation failed: {str(e)}")

@app.post("/evaluate_recommendations/")
async def evaluate_recommendations(
    test_file: UploadFile = File(...),
    ground_truth_file: UploadFile = File(...)
):
    """
    Evaluate the quality of recommendations using test data
    
    - test_file: CSV with cars and user preferences
    - ground_truth_file: CSV with known good matches for each user
    
    Returns precision, recall and other metrics
    """
    try:
        # Read test data and ground truth
        test_data = pd.read_csv(test_file.file)
        ground_truth = pd.read_csv(ground_truth_file.file)
        
        # Validate required columns
        if 'user_id' not in test_data.columns or 'user_id' not in ground_truth.columns:
            raise HTTPException(status_code=400, detail="Both files must contain user_id column")
        
        results = []
        
        # Process each user
        for user_id in test_data['user_id'].unique():
            user_prefs = test_data[test_data['user_id'] == user_id].iloc[0].to_dict()
            
            # Get cars to evaluate
            cars = ground_truth[ground_truth['user_id'] == user_id]
            
            if len(cars) == 0:
                continue
                
            # Calculate scores
            car_scores = []
            for _, car in cars.iterrows():
                car_dict = car.to_dict()
                score = calculate_car_score(car_dict, user_prefs)
                car_scores.append({
                    'car_id': car['car_id'], 
                    'score': score,
                    'is_good_match': car.get('is_good_match', 0)
                })
            
            # Sort by score and get top 5
            scored_cars = sorted(car_scores, key=lambda x: x['score'], reverse=True)[:5]
            
            # Calculate precision (how many of recommended cars are good matches)
            recommended_ids = [car['car_id'] for car in scored_cars]
            good_matches = [car for car in car_scores if car['is_good_match'] == 1]
            good_match_ids = [car['car_id'] for car in good_matches]
            
            hits = len([car_id for car_id in recommended_ids if car_id in good_match_ids])
            
            if len(recommended_ids) > 0:
                precision = hits / len(recommended_ids)
            else:
                precision = 0
                
            if len(good_match_ids) > 0:
                recall = hits / len(good_match_ids)
            else:
                recall = 0
            
            results.append({
                'user_id': user_id,
                'precision': precision,
                'recall': recall,
                'recommended_cars': recommended_ids,
                'good_matches': good_match_ids
            })
        
        # Calculate overall metrics
        avg_precision = np.mean([r['precision'] for r in results])
        avg_recall = np.mean([r['recall'] for r in results])
        
        return {
            "overall_precision": avg_precision,
            "overall_recall": avg_recall,
            "user_results": results
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Evaluation failed: {str(e)}")

@app.get("/")
async def root():
    return {
        "message": "MotorsBay Recommendation Engine API",
        "version": "1.0.0",
        "endpoints": [
            "/save_preferences/ - Save user preferences",
            "/get_preferences/{user_id} - Get user preferences",
            "/save_activity/ - Log user interaction with cars",
            "/recommend_cars/ - Get car recommendations for user",
            "/evaluate_recommendations/ - Test recommendation quality"
        ]
    }

@app.get("/create_test_data/")
async def api_create_test_data():
    """Generate sample test data for the recommendation system"""
    try:
        import generate_test_data
        generate_test_data.generate_test_data()
        return {"status": "success", "message": "Test data created successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to create test data: {str(e)}")

if __name__ == "__main__":
    print("Starting MotorsBay Recommendation System...")
    print("Access the API documentation at: http://localhost:8000/docs")
    print("\nEndpoints:")
    print("- POST /save_preferences/ - Save user preferences")
    print("- GET  /get_preferences/{user_id} - Get user preferences")
    print("- POST /save_activity/ - Log user activity")
    print("- POST /recommend_cars/ - Get car recommendations")
    print("- GET  /create_test_data/ - Generate test data")
    print("\nTry generating test data first: http://localhost:8000/create_test_data/")
    uvicorn.run(app, host="127.0.0.1", port=8000)
