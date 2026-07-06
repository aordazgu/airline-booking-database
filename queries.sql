# Airline Booking Database - Analytical Queries
# Run these against the airline_booking database after loading the
# schema and data.
#
# This file has two sections:
# 1. Final graded queries (7) - the exact queries submitted in the
#    BUS 393 Part B write-up, with confirmed output.
# 2. Exploratory queries (15) - the fuller set of queries drafted
#    while building the project.

USE airline_booking;

# =====================================================
# SECTION 1: FINAL GRADED QUERIES (7)
# =====================================================

# Query 1: Total revenue by route
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

# Query 2: Which pilot has flown the most flights
SELECT p.first_name, p.last_name, ep.employee_number, a.airline_name,
    COUNT(f.flight_id) AS flights_flown
FROM employee_passenger ep
    JOIN passenger p
    JOIN airline a
    JOIN flight f
ON ep.passenger_id = p.passenger_id
    AND ep.airline_id = a.airline_id
    AND f.airline_id = a.airline_id
WHERE ep.job_title = 'Pilot'
GROUP BY ep.passenger_id, p.first_name, p.last_name, ep.employee_number, a.airline_name
ORDER BY flights_flown DESC;

# Query 3: Which flight has the highest occupancy
SELECT f.flight_id, Count(passenger_id)
FROM booking_flight bf JOIN flight f
ON bf.flight_id = f.flight_id
GROUP BY flight_id
ORDER BY count(passenger_id) DESC
LIMIT 1;

# Query 4: Average age of passengers per flight
SELECT f.flight_id, f.departure_time,
    AVG(YEAR(CURDATE()) - YEAR(ap.date_of_birth)) as avg_age
FROM flight f
JOIN booking_flight bf ON f.flight_id = bf.flight_id
JOIN passenger p ON bf.passenger_id = p.passenger_id
JOIN adult_passenger ap ON p.passenger_id = ap.passenger_id
GROUP BY f.flight_id, f.departure_time
ORDER BY f.flight_id
LIMIT 10;

# Query 5: First and last name of passengers who sit in seat 14E
SELECT passenger_id, first_name, last_name
FROM passenger
WHERE passenger_id IN(SELECT passenger_id
FROM booking_flight bf JOIN seat_assignment sa
ON bf.booking_flight_id = sa.booking_flight_id
WHERE seat_number = "14E")
ORDER BY passenger_id;

# Query 6: List passengers alphabetically from flight 27
SELECT p.passenger_id, p.first_name, p.last_name
FROM passenger p JOIN booking_flight bf
ON p.passenger_id = bf.passenger_id
WHERE flight_id = "27"
ORDER BY last_name ASC, first_name ASC;

# Query 7: Flights with a higher average ticket price than the overall average
SELECT f.flight_id, AVG(bf.ticket_price)
FROM flight f JOIN booking_flight bf
ON f.flight_id = bf.flight_id
GROUP BY flight_id
HAVING AVG(ticket_price) > (SELECT AVG(ticket_price)
FROM booking_flight)
ORDER BY AVG(bf.ticket_price)
LIMIT 10;

# =====================================================
# SECTION 2: EXPLORATORY QUERIES (15)
# =====================================================

# SIMPLE BUSINESS QUERIES FOR PROJECT

# 1. Total revenue by route
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

# 2. Average spending per booking by customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(b.booking_id) AS total_bookings,
    AVG(p.amount_paid) AS avg_spending_per_booking
FROM customer c
	JOIN booking b
    JOIN payment p
ON c.customer_id = b.customer_id
	AND b.booking_id = p.booking_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY avg_spending_per_booking DESC;

# 3. Number of passengers by route
SELECT 
    orig.airport_code AS origin,
    dest.airport_code AS destination,
    COUNT(bf.booking_flight_id) AS total_passengers
FROM booking_flight bf
	JOIN booking b
    JOIN flight f
    JOIN route r
    JOIN airport orig
    JOIN airport dest
ON bf.booking_id = b.booking_id
	AND bf.flight_id = f.flight_id
    AND f.route_id = r.route_id
    AND r.origin_airport_id = orig.airport_id
    AND r.destination_airport_id = dest.airport_id
WHERE b.booking_status = 'Confirmed'
GROUP BY orig.airport_code, dest.airport_code
ORDER BY total_passengers DESC;

# 4. Average revenue per route
SELECT 
    orig.airport_code AS origin,
    dest.airport_code AS destination,
    AVG(p.amount_paid) AS average_revenue
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
ORDER BY average_revenue DESC;

# 5. Total luggage fees by route
SELECT 
    orig.airport_code AS origin,
    dest.airport_code AS destination,
    SUM(l.fee) AS total_luggage_fees
FROM luggage l
	JOIN booking_flight bf
    JOIN flight f
    JOIN route r
    JOIN airport orig
    JOIN airport dest
ON l.booking_flight_id = bf.booking_flight_id
	AND bf.flight_id = f.flight_id
    AND f.route_id = r.route_id
    AND r.origin_airport_id = orig.airport_id
    AND r.destination_airport_id = dest.airport_id
GROUP BY orig.airport_code, dest.airport_code
ORDER BY total_luggage_fees DESC;

# 6. Airline with the most confirmed bookings
SELECT 
    a.airline_name,
    COUNT(bf.booking_flight_id) AS total_bookings
FROM airline a
	JOIN flight f
    JOIN booking_flight bf
    JOIN booking b
ON a.airline_id = f.airline_id
	AND f.flight_id = bf.flight_id
    AND bf.booking_id = b.booking_id
WHERE b.booking_status = 'Confirmed'
GROUP BY a.airline_name
ORDER BY total_bookings DESC;

# 7. Total revenue by airline
SELECT 
    a.airline_name,
    SUM(p.amount_paid) AS total_revenue
FROM airline a
	JOIN flight f
    JOIN booking_flight bf
    JOIN booking b
    JOIN payment p
ON a.airline_id = f.airline_id
	AND f.flight_id = bf.flight_id
    AND bf.booking_id = b.booking_id
    AND b.booking_id = p.booking_id
WHERE p.payment_status = 'Paid'
GROUP BY a.airline_name
ORDER BY total_revenue DESC;

# 8. Customers who spent above the average payment amount (subquery)
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount_paid) AS total_spent
FROM customer c
	JOIN booking b
    JOIN payment p
ON c.customer_id = b.customer_id
	AND b.booking_id = p.booking_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_spent > (
    SELECT AVG(amount_paid)
    FROM payment
    WHERE payment_status = 'Paid'
)
ORDER BY total_spent DESC;

# 9. Routes that generated more revenue than the average route revenue (subquery)
SELECT 
    orig.airport_code AS origin,
    dest.airport_code AS destination,
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
GROUP BY r.route_id, orig.airport_code, dest.airport_code
HAVING total_revenue > (
    SELECT AVG(route_revenue)
    FROM (
        SELECT r2.route_id, SUM(p2.amount_paid) AS route_revenue
        FROM payment p2
        	JOIN booking b2
            JOIN booking_flight bf2
            JOIN flight f2
            JOIN route r2
        ON p2.booking_id = b2.booking_id
        	AND b2.booking_id = bf2.booking_id
            AND bf2.flight_id = f2.flight_id
            AND f2.route_id = r2.route_id
        WHERE p2.payment_status = 'Paid'
        GROUP BY r2.route_id
    ) AS route_totals
)
ORDER BY total_revenue DESC;

# 10. Full booking history per customer
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    b.booking_id,
    b.booking_date,
    b.booking_status,
    p.amount_paid
FROM customer c
	JOIN booking b
    JOIN payment p
ON c.customer_id = b.customer_id
	AND b.booking_id = p.booking_id
ORDER BY c.customer_id, b.booking_date;

# 11. Count AVG spending by Curstomers, but only Customers with Kids
SELECT c.customer_id, c.first_name, c.last_name, AVG(tab.total_spent) AS avg_spending
FROM customer c
	JOIN (
		SELECT b.customer_id, b.booking_id, SUM(p.amount_paid) AS total_spent
		FROM booking b
			JOIN payment p
				ON b.booking_id = p.booking_id
		GROUP BY b.customer_id, b.booking_id
	) tab
		ON c.customer_id = tab.customer_id
WHERE c.customer_id IN (
	SELECT p.customer_id
	FROM passenger p
		JOIN minor_passenger mp
			ON p.passenger_id = mp.passenger_id
)
GROUP BY c.customer_id, c.first_name, c.last_name;

# 12. Which pilot has flown the most flights
SELECT p.first_name, p.last_name, ep.employee_number, a.airline_name,
    COUNT(f.flight_id) AS flights_flown
FROM employee_passenger ep
    JOIN passenger p
    JOIN airline a
    JOIN flight f
ON ep.passenger_id = p.passenger_id
    AND ep.airline_id = a.airline_id
    AND f.airline_id = a.airline_id
WHERE ep.job_title = 'Pilot'
GROUP BY ep.passenger_id, p.first_name, p.last_name, ep.employee_number, a.airline_name
ORDER BY flights_flown DESC;

# 13. Total luggage fees by airline
SELECT a.airline_name,
    SUM(l.fee) AS total_luggage_fees
FROM luggage l
    JOIN booking_flight bf
    JOIN flight f
    JOIN airline a
ON l.booking_flight_id = bf.booking_flight_id
    AND bf.flight_id = f.flight_id
    AND f.airline_id = a.airline_id
GROUP BY a.airline_name
ORDER BY total_luggage_fees DESC;

# 14. Customers with no confirmed booking
SELECT c.customer_id, c.first_name, c.last_name, c.gmail
FROM customer c
WHERE NOT EXISTS (
    SELECT 1
    FROM booking b
    WHERE b.customer_id = c.customer_id
        AND b.booking_status = 'Confirmed'
)
ORDER BY c.customer_id;

# 15. Customers who spent above the average payment amount
SELECT c.customer_id, c.first_name, c.last_name,
    SUM(p.amount_paid) AS total_spent
FROM customer c
    JOIN booking b
    JOIN payment p
ON c.customer_id = b.customer_id
    AND b.booking_id = p.booking_id
WHERE p.payment_status = 'Paid'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING total_spent > (
    SELECT AVG(amount_paid)
    FROM payment
    WHERE payment_status = 'Paid'
)
ORDER BY total_spent DESC;
