# BUS 393 Final Project: Airline Booking Database

**Team:** Christina Balingit, Maya V. Karl, Marshall Moore, Arturo Ordaz-Gutiérrez, Courtney Yuen

## Overview

This project builds a MySQL database for an airline booking platform. It covers the full booking process: a customer makes a booking, passengers get assigned to flights, seats and luggage get added, and payment gets recorded. The database has 13 tables and includes a passenger supertype/subtype hierarchy, a ternary relationship, and a self-referencing customer table.

## Design Questions

**Primary:** How do you model a booking system where one ticket ties together a specific passenger, a specific flight, and a specific booking, while keeping the data normalized?

**Secondary:** How do you handle passengers who are different types (adult, minor, employee) without repeating a bunch of nullable columns in one table?

## Methods

- **Schema:** 13 tables covering customers, airlines, airports, routes, flights, bookings, passengers, payments, luggage, and seat assignments
- **Passenger hierarchy:** One `passenger` supertype with three disjoint subtypes, `adult_passenger`, `minor_passenger`, `employee_passenger`, enforced with a `CHECK` constraint
- **Ternary relationship:** `booking_flight` links one booking, one flight, and one passenger; each row is one ticket
- **Unary relationship:** a self-referencing `referred_by` foreign key on `customer` tracks referrals
- **Data load:** a Python script reads 14 CSV files and loads them into MySQL in foreign-key order

## Key Design Decisions

- Removed a separate `referral` entity that had no real attributes of its own; collapsed it into the `referred_by` column on `customer`
- Replaced one flat passenger table with 7 mostly-null columns with a proper supertype/subtype split, so every column is always meaningful
- All tables are in third normal form; no partial or transitive dependencies

## Project Structure

| File | Purpose |
|------|---------|
| `airline_booking_schema.sql` | CREATE TABLE statements for all 13 tables |
| `queries.sql` | Analytical queries: 7 final graded queries, plus 15 exploratory ones |
| `load_database.py` | Python script that builds the schema and loads the CSV data |
| `data/` | 14 CSV files, one per table |
| `docs/` | ERD and design notes (optional) |

## Queries

`queries.sql` has two parts.

**Final graded queries (7):** the exact queries submitted for grading, with confirmed output. These cover total revenue by route, the pilot with the most flights, flight occupancy, average passenger age, seat lookups, and ticket price comparisons.

**Exploratory queries (15):** the fuller set drafted while building the project. These include subqueries on customer spending and route revenue.

Example, total revenue by route:

```sql
SELECT orig.airport_code AS origin, dest.airport_code AS destination,
    SUM(p.amount_paid) AS total_revenue
FROM payment p
    JOIN booking b
    JOIN booking_flight bf
    JOIN flight f
    JOIN route r
    JOIN airport orig
    JOIN airport dest
ON p.booking_id = b.booking_id
    AND b.booking_id = bf.booking_id
    AND bf.flight_id = f.flight_id
    AND f.route_id = r.route_id
    AND r.origin_airport_id = orig.airport_id
    AND r.destination_airport_id = dest.airport_id
WHERE p.payment_status = 'Paid'
GROUP BY orig.airport_code, dest.airport_code
ORDER BY total_revenue DESC;
```

## Implementation

- `VARCHAR` and `DATE` for names, emails, and dates
- `DECIMAL(10,2)` for all monetary values: ticket prices, fees, payments
- `AUTO_INCREMENT` on all primary keys
- `CHECK` constraint on `passenger_type` to enforce the disjoint subtype rule
- `DEFAULT NULL` on `referred_by` and `customer_id` for optional foreign keys
- `INSERT IGNORE` in the loader so re-running the script doesn't throw duplicate key errors
- Foreign key checks disabled during load, then re-enabled, so load order is more flexible

## Requirements

- MySQL
- Python 3
- `mysql-connector-python`

## Notes

- Sample data: 1,000+ customers, 300 flights, 2,100+ booking-flight records
- Passenger table has 25 rows split across the three subtypes: 12 adult, 3 minor, 10 employee
- Set your MySQL credentials as environment variables before running the loader:
  ```
  export DB_HOST=localhost
  export DB_USER=root
  export DB_PASSWORD=your_password
  ```
