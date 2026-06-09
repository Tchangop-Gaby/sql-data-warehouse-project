'''
===============================================================================
Generate Fake Dataset containing seven Tables
===============================================================================
Description:
    This Script is AI generated and has gone through some human
    modification because of inconsistency at some points of the
    output Data.

Note:
    Fill free to modifiy this Script to your needs
===============================================================================
'''

import pandas as pd
import numpy as np
import random
from faker import Faker
from datetime import datetime, timedelta
from pathlib import Path

fake = Faker()
random.seed(42)
np.random.seed(42)

# -----------------------------
# CONFIG
# -----------------------------
N_USERS = 5000
N_PRODUCTS = 2000
N_ORDERS = 10000
MESSINESS_RATE = 0.1  # 10% corruption

# -----------------------------
# USERS TABLE
# -----------------------------
users_rows = []

names = [fake.name() for _ in range(N_USERS)]

emails = []
for name in names:
    username = (
        name.lower()
        .replace(" ", "")
        .replace("'", "")
    )
    domain = random.choice([
        "gmail.com",
        "yahoo.com",
        "outlook.com",
        "hotmail.com"
    ])
    emails.append(f"{username}@{domain}")

for i in range(N_USERS):
    signup_date = fake.date_between("-3y", "today")

    users_rows.append({
        "customer_id": f"U{100000+i}",
        "name": names,
        "country": fake.country(),
        "signup_date": signup_date,
        "email": emails,
        "updated_at": fake.date_time_between(signup_date, "now")
    })

users = pd.DataFrame(users_rows)

# introduce messiness
for i in random.sample(range(N_USERS), int(N_USERS * MESSINESS_RATE)):
    users.loc[i, "country"] = None

# 5% corrupted emails
for i in random.sample(range(N_USERS), int(N_USERS * 0.05)):
    users.loc[i, "email"] = random.choice([
        "invalid_email",
        "missing_at.com",
        None,
        "test@@gmail.com"
    ])

# duplicate rows (real-world issue)
users = pd.concat([users, users.sample(frac=0.05)], ignore_index=True)

# -----------------------------
# PRODUCTS TABLE
# -----------------------------

#Products for each category
electronics_products = [
    "Wireless Earbuds",
    "Bluetooth Speaker",
    "Gaming Laptop",
    "Mechanical Keyboard",
    "Smartphone",
    "Smart Watch",
    "4K Monitor",
    "USB-C Hub",
    "External SSD",
    "Noise Cancelling Headphones",
    "Webcam",
    "Portable Charger",
    "Smart TV",
    "Wireless Mouse",
    "Tablet"
]

home_products = [
    "Coffee Maker",
    "Air Fryer",
    "Vacuum Cleaner",
    "Blender",
    "Dining Chair",
    "Bookshelf",
    "Floor Lamp",
    "Bed Frame",
    "Kitchen Mixer",
    "Storage Cabinet",
    "Wall Clock",
    "Desk Organizer",
    "Electric Kettle",
    "Sofa Cover",
    "Curtain Set"
]

beauty_products = [
    "Face Cleanser",
    "Moisturizing Cream",
    "Lipstick",
    "Perfume",
    "Shampoo",
    "Conditioner",
    "Sunscreen",
    "Body Lotion",
    "Hair Serum",
    "Foundation",
    "Mascara",
    "Nail Polish",
    "Facial Toner",
    "Beard Oil",
    "Makeup Brush Set"
]

sports_products = [
    "Yoga Mat",
    "Dumbbell Set",
    "Resistance Bands",
    "Basketball",
    "Football",
    "Running Shoes",
    "Tennis Racket",
    "Fitness Tracker",
    "Cycling Helmet",
    "Jump Rope",
    "Protein Shaker",
    "Camping Tent",
    "Hiking Backpack",
    "Swimming Goggles",
    "Exercise Bench"
]

category_products = {
    "electronics": electronics_products,
    "home": home_products,
    "beauty": beauty_products,
    "sports": sports_products
}

categories = list(category_products.keys())

# add brands to increase the variety of products name
brands = {
    "electronics": ["Samsung", "Sony", "Apple", "Logitech", "Dell"],
    "home": ["IKEA", "Philips", "KitchenAid", "Dyson"],
    "beauty": ["L'Oréal", "Nivea", "Maybelline", "Dove"],
    "sports": ["Nike", "Adidas", "Puma", "Under Armour"]
}

product_rows = []

for i in range(N_PRODUCTS):
    category = random.choice(categories)

    product_name = (
        f"{random.choice(brands[category])} "
        f"{random.choice(category_products[category])}"
    )

    product_rows.append({
        "product_id": f"P{100000+i}",
        "product_name": product_name,
        "category": category,
        "price": round(random.uniform(5, 500), 2),
        "updated_at": fake.date_time_between("-3y", "now")
    })

products = pd.DataFrame(product_rows)

# corrupt product names
for i in random.sample(range(N_PRODUCTS), int(N_PRODUCTS * MESSINESS_RATE)):
    products.loc[i, "product_name"] = None

# -----------------------------
# ORDERS TABLE
# -----------------------------
orders = pd.DataFrame({
    "order_id": [f"O{100000+i}" for i in range(N_ORDERS)],
    "customer_id": np.random.choice(users["customer_id"], N_ORDERS),
    "order_date": [fake.date_time_between("-2y", "now") for _ in range(N_ORDERS)],
    "status": np.random.choice(["completed", "pending", "cancelled"], N_ORDERS, p=[0.7, 0.2, 0.1])
})

# messy timestamps (mixed formats)
for i in random.sample(range(N_ORDERS), int(N_ORDERS * MESSINESS_RATE)):
    orders.loc[i, "order_date"] = fake.date()

# broken foreign keys (real-world nightmare)
for i in random.sample(range(N_ORDERS), int(N_ORDERS * 0.03)):
    orders.loc[i, "customer_id"] = "UNKNOWN"

# -----------------------------
# ORDER ITEMS TABLE (MANY-TO-MANY)
# FIX 1: unit_price pulled from products table instead of random
# -----------------------------
product_price_map = dict(zip(products["product_id"], products["price"]))
order_items = []

for _, row in orders.iterrows():
    num_items = random.randint(1, 5)
    for _ in range(num_items):
        pid = random.choice(products["product_id"].tolist())
        order_items.append({
            "order_id": row["order_id"],
            "product_id": pid,
            "quantity": random.randint(1, 3),
            # FIX 1: use actual product price, with small variance to simulate discounts/promotions
            "unit_price": round(product_price_map[pid] * random.uniform(0.9, 1.0), 2)
        })

order_items = pd.DataFrame(order_items)

# introduce duplicates
order_items = pd.concat([order_items, order_items.sample(frac=0.05)], ignore_index=True)

# -----------------------------
# PAYMENTS TABLE
# FIX 2: amount derived from order_items totals per order
# -----------------------------

# Compute true order totals from order_items (before duplicates were added)
# Use only the first occurrence of each order_id + product_id combination
order_totals = (
    order_items.drop_duplicates(subset=["order_id", "product_id", "quantity", "unit_price"])
    .groupby("order_id")
    .apply(lambda df: (df["quantity"] * df["unit_price"]).sum())
    .round(2)
    .reset_index()
)
order_totals.columns = ["order_id", "true_amount"]
order_totals_map = dict(zip(order_totals["order_id"], order_totals["true_amount"]))

payments = pd.DataFrame({
    "payment_id": [f"PAY{100000+i}" for i in range(N_ORDERS)],
    "order_id": orders["order_id"],
    # FIX 2: use true order total, fall back to random if order_id not found
    "amount": [
        round(order_totals_map.get(oid, round(random.uniform(10, 1000), 2)), 2)
        for oid in orders["order_id"]
    ],
    "payment_method": np.random.choice(["card", "paypal", "cash", "crypto"], N_ORDERS)
})

# corrupt amounts (kept intentionally for ETL messiness)
for i in random.sample(range(N_ORDERS), int(N_ORDERS * 0.05)):
    payments.loc[i, "amount"] = None

# -----------------------------
# SHIPMENTS TABLE
# -----------------------------
shipments = pd.DataFrame({
    "shipment_id": [f"S{100000+i}" for i in range(N_ORDERS)],
    "order_id": orders["order_id"],
    "shipped_date": [fake.date_time_between("-2y", "now") for _ in range(N_ORDERS)],
    "delivery_status": np.random.choice(["delivered", "in_transit", "delayed"], N_ORDERS)
})

# -----------------------------
# EVENTS TABLE (CLICKSTREAM)
# -----------------------------
events = []
event_types = ["view", "click", "add_to_cart", "purchase"]

for _ in range(N_ORDERS * 3):
    events.append({
        "event_id": fake.uuid4(),
        "customer_id": random.choice(users["customer_id"].tolist()),
        "product_id": random.choice(products["product_id"].tolist()),
        "event_type": random.choice(event_types),
        "event_time": fake.date_time_between("-1y", "now"),
        "device": random.choice(["mobile", "web", "MOBILE", "Web", "tablet"])
    })

events = pd.DataFrame(events)

# missing values in events
for i in random.sample(range(len(events)), int(len(events) * MESSINESS_RATE)):
    events.loc[i, "customer_id"] = None

# -----------------------------
# SAVE OUTPUTS
# -----------------------------
master_dir = Path("../datasets/master_data")
master_dir.mkdir(parents=True, exist_ok=True)
users.to_csv(master_dir / "customers.csv", index=False)
products.to_csv(master_dir / "products.csv", index=False)

transaction_dir = Path("../datasets//transaction_data")
transaction_dir.mkdir(parents=True, exist_ok=True)
orders.to_csv(transaction_dir / "orders.csv", index=False)
order_items.to_csv(transaction_dir / "order_items.csv", index=False)
payments.to_csv(transaction_dir / "payments.csv", index=False)
shipments.to_csv(transaction_dir / "shipments.csv", index=False)
events.to_csv(transaction_dir / "events.csv", index=False)

print("✅ Messy warehouse datasets generated successfully!")
