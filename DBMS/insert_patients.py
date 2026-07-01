from faker import Faker
import csv
import random

fake = Faker()

with open("patients.csv", "w", newline="", encoding="utf-8") as csvfile:
    fieldnames = ["name", "age", "gender", "disease", "doctor", "city", "admission_date", "discharged"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()

    for _ in range(100000):
        writer.writerow({
            "name": fake.name(),
            "age": random.randint(1, 100),
            "gender": random.choice(["Male", "Female", "Other"]),
            "disease": random.choice(["Flu", "Diabetes", "Cancer", "COVID-19", "Asthma"]),
            "doctor": fake.name(),
            "city": fake.city(),
            "admission_date": fake.date_this_decade(),
            "discharged": random.choice([True, False])
        })

print("Generated patients.csv with 100,000 records.")
