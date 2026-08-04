import os
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Get Firebase service account from GitHub Secret
secret = os.environ.get("FIREBASE_SERVICE_ACCOUNT")

if not secret:
    raise Exception("FIREBASE_SERVICE_ACCOUNT secret is missing")

cred = credentials.Certificate(json.loads(secret))

firebase_admin.initialize_app(cred)

db = firestore.client()

# Read restaurant JSON
with open("restaurants.json", "r", encoding="utf-8") as file:
    restaurants = json.load(file)

# Upload restaurants
count = 0

for restaurant in restaurants:
    db.collection("restaurants").add(restaurant)
    count += 1

print(f"Successfully uploaded {count} restaurants!")
