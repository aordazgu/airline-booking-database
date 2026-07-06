# Airline Booking Database — Schema
# Defines all 13 tables: primary keys, foreign keys, the disjoint
# passenger supertype/subtype hierarchy, and the ternary booking_flight
# associative entity. Tables are created in foreign-key dependency order.

DROP DATABASE IF EXISTS airline_booking;
CREATE DATABASE airline_booking;
USE airline_booking;

# TABLE 1: CUSTOMER
# Stores customers who use the booking platform
CREATE TABLE customer (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gmail VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    referred_by INT DEFAULT NULL,
    FOREIGN KEY (referred_by) REFERENCES customer(customer_id)
);
# NOTE: referred_by is a UNARY (self-referencing) relationship.
# A customer can refer other customers. referred_by points back to
# the customer_id of whoever made the referral. NULL means no referral.

# TABLE 2: AIRLINE
# Stores airline companies available through the platform
CREATE TABLE airline (
    airline_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_name VARCHAR(100) NOT NULL,
    airline_code VARCHAR(10) NOT NULL UNIQUE
);

# TABLE 3: AIRPORT
# Stores airports used for origins and destinations
CREATE TABLE airport (
    airport_id INT PRIMARY KEY AUTO_INCREMENT,
    airport_code VARCHAR(10) NOT NULL UNIQUE,
    airport_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    state VARCHAR(50) NOT NULL
);

# TABLE 4: ROUTE
# Stores origin and destination airport pairs
CREATE TABLE route (
    route_id INT PRIMARY KEY AUTO_INCREMENT,
    origin_airport_id INT NOT NULL,
    destination_airport_id INT NOT NULL,
    distance_miles INT NOT NULL,
    FOREIGN KEY (origin_airport_id) REFERENCES airport(airport_id),
    FOREIGN KEY (destination_airport_id) REFERENCES airport(airport_id),
    CHECK (origin_airport_id <> destination_airport_id)
);

# TABLE 5: FLIGHT
# Stores specific scheduled flights sold by the platform
CREATE TABLE flight (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    airline_id INT NOT NULL,
    route_id INT NOT NULL,
    flight_number VARCHAR(20) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    base_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id),
    FOREIGN KEY (route_id) REFERENCES route(route_id)
);

# TABLE 6: BOOKING
# Stores the reservation transaction made by a customer
CREATE TABLE booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

# TABLE 7a: PASSENGER (Supertype)
# Represents any traveler on a booking.
# Has three DISJOINT subtypes: adult_passenger, minor_passenger, employee_passenger.
# A passenger must be exactly one subtype, never more than one (disjoint, total).
# customer_id is NULL for employees since they are not customers.
CREATE TABLE passenger (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT DEFAULT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    passport_number VARCHAR(30),
    passenger_type VARCHAR(10) NOT NULL CHECK (passenger_type IN ('adult', 'minor', 'employee')),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);

# TABLE 7b: ADULT_PASSENGER (Subtype of passenger # disjoint)
# Only exists for passengers where passenger_type = 'adult'.
# Captures adult-only attributes.
CREATE TABLE adult_passenger (
    passenger_id INT PRIMARY KEY,
    date_of_birth DATE NOT NULL,
    frequent_flyer_number VARCHAR(30),
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id)
);

# TABLE 7c: MINOR_PASSENGER (Subtype of passenger # disjoint)
# Only exists for passengers where passenger_type = 'minor'.
# A minor must have a guardian listed.
CREATE TABLE minor_passenger (
    passenger_id INT PRIMARY KEY,
    date_of_birth DATE NOT NULL,
    guardian_passenger_id INT NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id),
    FOREIGN KEY (guardian_passenger_id) REFERENCES adult_passenger(passenger_id)
);

# TABLE 7d: EMPLOYEE_PASSENGER (Subtype of passenger # disjoint)
# Only exists for passengers where passenger_type = 'employee'.
# Employees are crew members (pilots, flight attendants, etc.)
# They are on the plane but are NOT customers # customer_id is NULL.
CREATE TABLE employee_passenger (
    passenger_id INT PRIMARY KEY,
    employee_number VARCHAR(20) NOT NULL UNIQUE,
    job_title VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL,
    airline_id INT NOT NULL,
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id),
    FOREIGN KEY (airline_id) REFERENCES airline(airline_id)
);

# TABLE 7e: BOOKING_FLIGHT (Ternary Associative Entity)
# Links BOOKING + FLIGHT + PASSENGER # a true 3-way relationship.
# Records that a specific passenger is on a specific flight
# under a specific booking. Each row = one ticket.
CREATE TABLE booking_flight (
    booking_flight_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    flight_id INT NOT NULL,
    passenger_id INT NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id),
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passenger(passenger_id)
);
# NOTE: This is a TERNARY relationship # three entities participate:
# booking, flight, and passenger. Each row = one passenger on one
# flight under one booking.

# TABLE 8: PAYMENT
# Stores payment information for a booking
CREATE TABLE payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
);

# TABLE 9: LUGGAGE
# Stores luggage or carry-on add-ons for each booking flight
CREATE TABLE luggage (
    luggage_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_flight_id INT NOT NULL,
    luggage_type VARCHAR(30) NOT NULL,
    quantity INT NOT NULL,
    fee DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (booking_flight_id) REFERENCES booking_flight(booking_flight_id)
);

# TABLE 10: SEAT_ASSIGNMENT
# Stores seat assignment for a booking flight
CREATE TABLE seat_assignment (
    seat_assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_flight_id INT NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    cabin_class VARCHAR(30) NOT NULL,
    seat_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (booking_flight_id) REFERENCES booking_flight(booking_flight_id)
);

