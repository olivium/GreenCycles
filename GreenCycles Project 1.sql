/* Task 1: Create a list of all the different (distinct) replacement costs of the films */

SELECT
DISTINCT replacement_cost
FROM film
ORDER BY replacement_cost ASC;

/* Task 2: Write a query that gives an overview of how many films have 
replacements costs in the following cost ranges: 

low: 9.99 - 19.99 medium: 20.00 - 24.99 high: 25.00 - 29.99 */

SELECT
CASE
	WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low'
	WHEN replacement_cost BETWEEN 20.00 AND 24.99 THEN 'medium'
	ELSE 'high'
END as cost_range,
COUNT(*)
FROM film
GROUP BY cost_range;

/* Task 3: Create a list of the film titles including their title, length, and category name ordered descendingly by length. 
Filter the results to only the movies in the category 'Drama' or 'Sports'*/

SELECT
title,
length,
name
FROM film f 
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
WHERE name IN ('Drama', 'Sports')
ORDER BY length DESC;


/* Task 4: Create an overview of how many movies (titles) there are in each category (name). */

SELECT
name,
COUNT(title)
FROM film f 
LEFT JOIN film_category fc
ON f.film_id = fc.film_id
LEFT JOIN category c
ON fc.category_id = c.category_id
GROUP BY name
ORDER BY COUNT(title) DESC;

/*Task 5: Create an overview of the actors' first and last names and in how many movies they appear in. */

SELECT
first_name,
last_name,
COUNT(*)
FROM actor a
LEFT JOIN film_actor fa
ON a.actor_id = fa.actor_id
LEFT JOIN film f
ON fa.film_id = f.film_id
GROUP BY first_name, last_name
ORDER BY COUNT(*) DESC;


/* Task 6: Create an overview of the addresses that are not associated to any customer.*/

SELECT
*
FROM address a
LEFT JOIN customer c
ON a.address_id = c.address_id
WHERE c.first_name IS NULL;

/*Task 7: Create an overview of the cities and how much sales (sum of amount) have occurred there.*/

SELECT
city,
SUM(amount)
FROM payment p
LEFT JOIN customer c
ON p.customer_id = c.customer_id
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci
ON a.city_id = ci.city_id
GROUP BY city
ORDER BY SUM(amount) DESC;

/* Task 8: Create an overview of the revenue (sum of amount) grouped by a column in the format "country, city".*/
SELECT
CONCAT(country, ',',city),
SUM(amount)
FROM payment p
LEFT JOIN customer c
ON p.customer_id = c.customer_id
LEFT JOIN address a
ON c.address_id = a.address_id
LEFT JOIN city ci
ON a.city_id = ci.city_id
LEFT JOIN country co
ON ci.country_id = co.country_id
GROUP BY CONCAT(country, ',',city)
ORDER BY SUM(amount) ASC;

/*Task 9: Create a list with the average of the sales amount each staff_id has per customer.*/

SELECT 
staff_id,
ROUND(AVG(total),2) as avg_amount 
FROM 
	(SELECT SUM(amount) as total,
	customer_id,
	staff_id
	FROM payment
	GROUP BY customer_id, staff_id) as avg_sales_per_custom
GROUP BY staff_id;

/*Task 10: Create a query that shows average daily revenue of all Sundays.*/

SELECT 
ROUND(AVG(total),2)
FROM 
	(SELECT SUM(amount) as total,
	 DATE(payment_date),
	 EXTRACT(DOW from payment_date ) as weekday	
	 FROM payment
	 WHERE EXTRACT(DOW FROM payment_date ) = 0
	 GROUP BY DATE(payment_date), weekday) as daily; 	

/*Task 11: Create a list of movies - with their length and their replacement cost
that are longer than the average length in each replacement cost group. */

SELECT
title,
length
FROM film f1
WHERE length > (SELECT AVG(length) from film f2
			   WHERE f1.replacement_cost = f2.replacement_cost)
ORDER BY length ASC;

/*Task 12: Create a list that shows the "average customer lifetime value" 
grouped by the different districts.*/

SELECT
district,
ROUND(AVG(total),2) as avg_customer_spent
FROM 
	(SELECT
	 district,
	 c.customer_id,
	 SUM(amount) as total
	 FROM
	 payment p
	 INNER JOIN customer c
	 ON p.customer_id = c.customer_id
	 INNER JOIN address a
	 ON c.address_id = a.address_id
	 GROUP BY district, c.customer_id) as calc_district_total_per_customer
GROUP BY district
ORDER BY avg_customer_spent DESC;

/*Task 13: Create a list that shows all payments including the payment_id, amount, and the film category (name) plus the total amount that was made in this category. 
Order the results ascendingly by the category (name) and as second order criterion by the payment_id ascendingly.*/

SELECT
title,
amount,
name,
payment_id,
	(SELECT
	 SUM(amount)
	 FROM payment p
	 LEFT JOIN rental r
	 ON p.rental_id = r.rental_id
	 LEFT JOIN inventory i
	 ON i.inventory_id = r.inventory_id
	 LEFT JOIN film f
	 ON i.film_id = f.film_id
	 LEFT JOIN film_category fc
	 ON fc.film_id = f.film_id
	 LEFT JOIN category c1
 	 ON c1.category_id = fc.category_id	
	 WHERE c1.name = c.name)
FROM payment p
LEFT JOIN rental r
ON p.rental_id = r.rental_id
LEFT JOIN inventory i
ON i.inventory_id = r.inventory_id
LEFT JOIN film f
ON i.film_id = f.film_id
LEFT JOIN film_category fc
ON fc.film_id = f.film_id
LEFT JOIN category c
ON c.category_id = fc.category_id	
ORDER BY name ASC, payment_id ASC;


/*Task 14: Create a list with the top overall revenue of a film title (sum of amount per title) for each category (name).*/

SELECT
title,
name,
SUM(amount) as total
FROM payment p
LEFT JOIN rental r
ON r.rental_id=p.rental_id
LEFT JOIN inventory i
ON i.inventory_id=r.inventory_id
LEFT JOIN film f
ON f.film_id=i.film_id
LEFT JOIN film_category fc
ON fc.film_id=f.film_id
LEFT JOIN category c
ON c.category_id=fc.category_id
GROUP BY name,title
HAVING SUM(amount) = (SELECT MAX(total)
					 FROM (SELECT
			         title,
                     name,
			         SUM(amount) as total
			         FROM payment p
			         LEFT JOIN rental r
			         ON r.rental_id=p.rental_id
			         LEFT JOIN inventory i
			         ON i.inventory_id=r.inventory_id
				  	 LEFT JOIN film f
				  	 ON f.film_id=i.film_id
				  	 LEFT JOIN film_category fc
				  	 ON fc.film_id=f.film_id
				  	 LEFT JOIN category c
				  	 ON c.category_id=fc.category_id
				  	 GROUP BY name,title) sub
					 WHERE c.name=sub.name)
					 ORDER BY name
