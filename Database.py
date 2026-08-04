import json
import firebase_admin
from firebase_admin import credentials, firestore
import os

# Get Firebase key from GitHub Secret
service_account_json = os.environ["FIREBASE_SERVICE_ACCOUNT"]

cred = credentials.Certificate(json.loads(service_account_json))
firebase_admin.initialize_app(cred)

db = firestore.client()

# Load your restaurant JSON
with open("restaurants.json", "r", encoding="utf-8") as f:
    restaurants = json.load(f)

# Upload
for restaurant in restaurants:
    db.collection("restaurants").add(restaurant)

print(f"Uploaded {len(restaurants)} restaurants successfully!")
