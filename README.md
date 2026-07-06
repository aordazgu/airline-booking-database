# Airline Booking Database

A relational database design for an Expedia-style airline booking platform. Built in MySQL for BUS 393 (Database Management Systems) at Cal Poly San Luis Obispo.

The database covers the full booking process: a customer creates a booking, passengers are assigned to flights, seats and luggage are added, and payment is recorded.

## Schema Overview

The database has 13 tables covering customers, airlines, airports, routes, flights, bookings, passengers, payments, luggage, and seat assignments.

Design features:

- **Passenger supertype/subtype hierarchy.** A `passenger` supertype with three disjoint subtypes: `adult_passenger`, `minor_passenger`, and `employee_passenger`. Subtype membership is enforced with a `CHECK` constraint on `passenger_type`, and each subtype's `passenger_id` is both its primary key and a foreign key back to the supertype.
- **Ternary associative entity.** `booking_flight` links exactly one booking, one flight, and one passenger, so the database can answer who flew on which flight under which booking.
- **Unary relationship.** A self-referencing `referred_by` foreign key on `customer` tracks customer referrals.
- **Normalized structure.** Routes are a directional pairing of origin and destination airports, and flights are scheduled trips operated by an airline on a route.

## Sample Data

The `data/` folder contains 14 CSV files with sample data, including 1,000+ customers, 300 flights, and 2,100+ booking-flight records.

`load_database.py` loads the CSVs into MySQL. It:

- creates the schema from `airline_booking.sql`
- loads each CSV in foreign-key dependency order using parameterized `INSERT IGNORE` statements
- converts empty and "NULL" values to real SQL NULLs
- prints row counts for all tables to verify the load

## Analytical Queries

The project includes 5 queries that span multiple tables and use grouping and subqueries:

1. Total revenue by route (GROUP BY + SUM across 7 tables)
2. Pilot who has flown the most flights (GROUP BY + COUNT filtered on employee subtype)
3. Customers with no confirmed booking (NOT EXISTS correlated subquery)
4. Customers who spent above the average payment amount (scalar subquery in HAVING)
5. Average spending by customers with children (derived table + IN subquery)

## How to Run

1. Install MySQL and Python 3.
2. Install the connector:
   ```
   pip3 install mysql-connector-python
   ```
3. Set your MySQL credentials as environment variables (or edit the config section of `load_database.py`):
   ```
   export DB_HOST=localhost
   export DB_USER=root
   export DB_PASSWORD=your_password
   ```
4. Run the loader:
   ```
   python3 load_database.py
   ```
5. Run the queries in `queries.sql` against the `airline_booking` database.

## Repository Structure

```
airline-booking-database/
├── airline_booking.sql     # CREATE TABLE statements for all 13 tables
├── queries.sql             # 5 analytical queries
├── load_database.py        # Python CSV loader
├── data/                   # 14 sample data CSV files
└── docs/                   # ERD and design documentation (optional)
```

## Team

Group project by Arturo Ordaz-Gutiérrez, Christina Balingit, Maya V. Karl, Marshall Moore, and Courtney Yuen.

Arturo's contributions: schema design changes (subtype hierarchy, ternary booking_flight, unary referral FK), the Python CSV loader, and query development.
