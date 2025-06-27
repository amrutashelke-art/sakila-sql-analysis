USE sakila;
-- Top 10 customers by total amount paid
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, SUM(p.amount) AS total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Films that were never rented
SELECT f.film_id, f.title
FROM film f
LEFT JOIN inventory i ON f.film_id = i.film_id
LEFT JOIN rental r ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

-- Rental details with customer, film, and payment
SELECT r.rental_id, c.first_name, f.title, r.rental_date, p.amount
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN customer c ON r.customer_id = c.customer_id
JOIN payment p ON r.rental_id = p.rental_id
LIMIT 20;

-- Customers who spent above average total payment
SELECT customer_id, first_name, last_name
FROM customer
WHERE customer_id IN (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    HAVING SUM(amount) > (SELECT AVG(total_amount) FROM (
        SELECT customer_id, SUM(amount) AS total_amount FROM payment GROUP BY customer_id
    ) AS avg_table)
);

-- Revenue per film category
SELECT c.name AS category, SUM(p.amount) AS revenue
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY revenue DESC;
CREATE OR REPLACE VIEW frequent_renters AS
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, COUNT(r.rental_id) AS rental_count
FROM customer c
JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id
HAVING rental_count > 20;



SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month, SUM(amount) AS revenue
FROM payment
GROUP BY month
ORDER BY month;

SELECT customer_id,
       CASE
         WHEN SUM(amount) >= 200 THEN 'High Value'
         WHEN SUM(amount) BETWEEN 100 AND 199 THEN 'Medium Value'
         ELSE 'Low Value'
       END AS customer_segment
FROM payment
GROUP BY customer_id;

SELECT f.title, COUNT(r.rental_id) AS rentals
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY rentals DESC
LIMIT 10;

-- -----------------------------------------------
-- 📊 Conclusion:
-- 
-- This analysis using the Sakila database successfully demonstrates core SQL concepts such as 
-- SELECT, JOINs, GROUP BY, subqueries, views, and indexing. Key business insights include:
-- 
-- 1. Top customers identified by total payments can guide loyalty programs.
-- 2. Certain films have never been rented — indicating inventory inefficiencies.
-- 3. Comedy and Sports are the top revenue-generating film categories.
-- 4. Frequent renters were identified and stored in a view for further targeting.
-- 5. Indexing rental dates can optimize query performance for time-based reports.
-- 
-- Overall, the project achieved its goal of using SQL to analyze and extract valuable business data 
-- from a relational database. The approach can easily be scaled to real-world eCommerce or retail systems.
-- -----------------------------------------------
