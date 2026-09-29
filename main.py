from fastapi import FastAPI, HTTPException, UploadFile, File,Form
from pydantic import BaseModel
import pandas as pd
import os
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder
from typing import List
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

BASE_DIR = "user_data"
os.makedirs(BASE_DIR, exist_ok=True)

#  user signup input model
class SignupData(BaseModel):
    user_id: str
    vehicle_type: str
    condition: str
    price_range: str
    preferred_brands: List[str]
    fuel_type: str
    transmission: str
    size: str
    fuel_economy: str
    must_have_features: List[str]
    usage: str
    customize_interest: str
    parts_interest: str
    dealership_interest: str
    buying_timeframe: str
    service_recommendation: str

#  user activity input model (updated to include user_id)
class ActivityData(BaseModel):
    user_id: str  
    clicked_vehicle_type: str
    clicked_brand: str
    clicked_fuel: str
    clicked_price_range: str

# Helper functions
def prepare_user_folder(user_id):
    user_folder = os.path.join(BASE_DIR, user_id)
    os.makedirs(user_folder, exist_ok=True)
    return user_folder

def train_user_model(user_id):
    user_folder = prepare_user_folder(user_id)
    activity_path = os.path.join(user_folder, "activity.csv")
    signup_path = os.path.join(user_folder, "signup.csv")

    # Initialize LabelEncoders for categorical features
    brand_encoder = LabelEncoder()
    fuel_encoder = LabelEncoder()
    price_range_encoder = LabelEncoder()

    if os.path.exists(activity_path):
        df_activity = pd.read_csv(activity_path)
        if len(df_activity) >= 5:
            # Train model on activity data
            X = df_activity.drop(columns=["clicked_vehicle_type"])
            y = df_activity["clicked_vehicle_type"]
            model = RandomForestClassifier()
            model.fit(X, y)
            joblib.dump(model, os.path.join(user_folder, "model.pkl"))
            return

    if os.path.exists(signup_path):
        df_signup = pd.read_csv(signup_path)

        # Apply Label Encoding to categorical variables
        df_signup["clicked_brand"] = brand_encoder.fit_transform(df_signup['preferred_brands'].apply(str))
        df_signup["clicked_fuel"] = fuel_encoder.fit_transform(df_signup['fuel_type'].apply(str))
        df_signup["clicked_price_range"] = price_range_encoder.fit_transform(df_signup['price_range'].apply(str))

        # Prepare feature matrix
        signup_features = df_signup[["clicked_brand", "clicked_fuel", "clicked_price_range"]]

        # The target variable is 'vehicle_type'
        signup_target = df_signup["vehicle_type"]

        model = RandomForestClassifier()
        model.fit(signup_features, signup_target)
        joblib.dump(model, os.path.join(user_folder, "model.pkl"))

# Endpoints
@app.post("/signup/")
def signup(user_data: SignupData):
    user_id = user_data.user_id  # use passed user_id
    user_folder = prepare_user_folder(user_id)

    signup_path = os.path.join(user_folder, "signup.csv")
    df = pd.DataFrame([user_data.model_dump(exclude={"user_id"})])  # exclude user_id from saving
    df.to_csv(signup_path, index=False)

    train_user_model(user_id)

    return {"message": "Signup saved.", "user_id": user_id}

@app.post("/activity/")
def save_activity(activity: ActivityData):
    user_folder = prepare_user_folder(activity.user_id)  # Use user_id from the activity parameter
    activity_path = os.path.join(user_folder, "activity.csv")

    # Initialize LabelEncoders for categorical features
    brand_encoder = LabelEncoder()
    fuel_encoder = LabelEncoder()
    price_range_encoder = LabelEncoder()

    act = {
        "clicked_brand": brand_encoder.fit_transform([activity.clicked_brand])[0],
        "clicked_fuel": fuel_encoder.fit_transform([activity.clicked_fuel])[0],
        "clicked_price_range": price_range_encoder.fit_transform([activity.clicked_price_range])[0],
        "clicked_vehicle_type": activity.clicked_vehicle_type
    }

    if os.path.exists(activity_path):
        df = pd.read_csv(activity_path)
        df = pd.concat([df, pd.DataFrame([act])], ignore_index=True)
    else:
        df = pd.DataFrame([act])

    df.to_csv(activity_path, index=False)

    train_user_model(activity.user_id)  # Pass user_id from activity

    return {"message": "Activity saved and model updated."}

@app.post("/recommend/")
async def recommend(user_id: str= Form(), ads_file: UploadFile = File(...)):
    user_folder = prepare_user_folder(user_id)
    model_path = os.path.join(user_folder, "model.pkl")

    if not os.path.exists(model_path):
        raise HTTPException(status_code=404, detail="No trained model found for this user.")

    # Load model
    model = joblib.load(model_path)

    # Read uploaded CSV
    ads_df = pd.read_csv(ads_file.file)

    required_columns = ["ad_id", "brand", "fuel_type", "price_range"]
    for col in required_columns:
        if col not in ads_df.columns:
            raise HTTPException(status_code=400, detail=f"Missing required column: {col}")

    # Initialize LabelEncoders for categorical features
    brand_encoder = LabelEncoder()
    fuel_encoder = LabelEncoder()
    price_range_encoder = LabelEncoder()

    # Apply Label Encoding to the ads data
    ads_df["clicked_brand"] = brand_encoder.fit_transform(ads_df["brand"].apply(str))
    ads_df["clicked_fuel"] = fuel_encoder.fit_transform(ads_df["fuel_type"].apply(str))
    ads_df["clicked_price_range"] = price_range_encoder.fit_transform(ads_df["price_range"].apply(str))

    feature_df = ads_df[["clicked_brand", "clicked_fuel", "clicked_price_range"]]

    # Predict probabilities
    if hasattr(model, "predict_proba"):
        probs = model.predict_proba(feature_df)
        scores = probs.max(axis=1)  # Take the max class probability
    else:
        scores = model.predict(feature_df)  # fallback

    ads_df["score"] = scores

    # Select top 5 ads
    top_ads = ads_df.sort_values(by="score", ascending=False).head(5)

    return {"top_ad_ids": top_ads["ad_id"].tolist()}

@app.get("/")
def root():
    return {"message": "Welcome to Motor Vehicle AI Recommendation API!"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
