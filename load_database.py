import csv
import mysql.connector
import os
import re

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YOUR_ROOT_PASSWORD",
}
DATABASE = "airline_booking"
SQL_FILE = os.path.join(os.path.dirname(__file__), "airline_booking.sql")
DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "Data")

# CSV filename -> table name (only where they differ)
TABLE_MAP = {"seat_assignments.csv": "seat_assignment"}

# CSV column -> table column (only where they differ)
COLUMN_MAP = {"customer.csv": {"email": "gmail"}}

# Order respects FK dependencies
LOAD_ORDER = [
    "customer.csv",
    "airline.csv",
    "airport.csv",
    "route.csv",
    "flight.csv",
    "booking.csv",
    "passenger.csv",
    "adult_passenger.csv",
    "minor_passenger.csv",
    "employee_passenger.csv",
    "booking_flight.csv",
    "payment.csv",
    "luggage.csv",
    "seat_assignments.csv",
]


def extract_create_statements(path):
    with open(path, "r") as f:
        content = f.read()
    idx = content.find("INSERT INTO")
    if idx != -1:
        content = content[:idx]
    stmts = []
    for m in re.finditer(r"CREATE TABLE.*?;", content, re.DOTALL):
        stmts.append(m.group())
    return stmts


def load_csv(cursor, csv_file, table_name, col_map):
    path = os.path.join(DATA_DIR, csv_file)
    with open(path, "r") as f:
        reader = csv.reader(f)
        headers = next(reader)
        columns = [col_map.get(h, h) for h in headers]
        placeholders = ", ".join(["%s"] * len(columns))
        col_str = ", ".join(columns)
        sql = f"INSERT IGNORE INTO {table_name} ({col_str}) VALUES ({placeholders})"
        rows = []
        for row in reader:
            cleaned = []
            for val in row:
                if val.strip() in ("NULL", ""):
                    cleaned.append(None)
                else:
                    cleaned.append(val.strip())
            rows.append(cleaned)
        if rows:
            cursor.executemany(sql, rows)


def main():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute(f"DROP DATABASE IF EXISTS {DATABASE}")
    cursor.execute(f"CREATE DATABASE {DATABASE}")
    cursor.execute(f"USE {DATABASE}")

    for stmt in extract_create_statements(SQL_FILE):
        cursor.execute(stmt)
    print("Schema created.")

    cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
    for csv_file in LOAD_ORDER:
        table = TABLE_MAP.get(csv_file, csv_file.replace(".csv", ""))
        col_map = COLUMN_MAP.get(csv_file, {})
        load_csv(cursor, csv_file, table, col_map)
        conn.commit()
        print(f"  Loaded {csv_file} -> {table}")
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1")

    print("\nRow counts:")
    for csv_file in LOAD_ORDER:
        table = TABLE_MAP.get(csv_file, csv_file.replace(".csv", ""))
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {table}: {count}")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()
