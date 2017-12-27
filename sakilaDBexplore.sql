-- 1a. Display the first and last names of all actors from the table `actor`
USE sakila;
SELECT first_name,last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
USE sakila;
SELECT CONCAT(first_name,' ',last_name) AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?  	
USE sakila;
SELECT actor_id,first_name,last_name
FROM actor
WHERE first_name='JOE';

-- 2b. Find all actors whose last name contain the letters `GEN`
SELECT *
FROM actor
WHERE last_name LIKE '%GEN%';


-- 2c. Find all actors whose last names contain the letters `LI`. 
-- This time, order the rows by last name and first name, in that order
USE sakila;
SELECT * 
FROM 
(
SELECT *
FROM actor
ORDER BY last_name,first_name
) L 
WHERE last_name LIKE '%LI%';


-- 2d. Using `IN`, display the `country_id` and `country` columns of 
-- the following countries: Afghanistan, Bangladesh, and China
USE sakila;
SELECT country_id,country
FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');


-- 3a. Add a `middle_name` column to the table `actor`. 
-- Position it between `first_name` and `last_name`. 
-- Hint: you will need to specify the data type.
USE sakila;
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(40)
AFTER first_name;
SELECT * 
FROM actor;


-- 3b. You realize that some of these actors have tremendously long last names. 
-- Change the data type of the `middle_name` column to `blobs`.
USE sakila;
ALTER TABLE actor
MODIFY column middle_name BLOB;


-- 3c.Now delete the `middle_name` column.
ALTER TABLE actor
DROP COLUMN middle_name;
SELECT *
FROM actor;


-- 4a. List the last names of actors, as well as how many actors have that last name.
USE  sakila;
SELECT last_name,COUNT(*) as actor_count
FROM actor GROUP BY last_name ORDER BY actor_count DESC;


-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
USE  sakila;
SELECT last_name,COUNT(*) as actor_count
FROM actor 
GROUP BY last_name ORDER BY last_name ASC;


-- 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`,
-- the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
USE  sakila;
SELECT last_name,COUNT(*) as actor_count
FROM actor 
GROUP BY last_name HAVING actor_count>1 ORDER BY last_name ASC;


-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. 
-- Otherwise, change the first name to `MUCHO GROUCHO`, 
-- as that is exactly what the actor will be with the grievous error. 
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
-- (Hint: update the record using a unique identifier.)
USE sakila;
UPDATE actor
SET first_name = REPLACE(first_name, 'GROUCHO', 'HARPO') 
WHERE INSTR(first_name, 'GROUCHO') > 0 ;

USE sakila;
ROLLBACK;


-- 5a. You cannot locate the schema of the `address` table. 
-- Which query would you use to re-create it?
SELECT * FROM sakila.address;


-- 6a. Use `JOIN` to display the first and last names, 
-- as well as the address, of each staff member. 
-- Use the tables `staff` and `address`
USE sakila;
SELECT first_name,last_name,aa.address
FROM staff s
INNER JOIN address aa
ON s.address_id=aa.address_id;


-- 6b. Use `JOIN` to display the total amount rung up 
-- by each staff member in August of 2005. 
-- Use tables `staff` and `payment`. 
USE sakila;
SELECT na.staff_id,COUNT(amount),na.payment_date
FROM 
(SELECT s.staff_id,np.amount,np.payment_date
FROM staff s
INNER JOIN 
(SELECT staff_id,amount,payment_date
FROM payment
WHERE EXTRACT(YEAR FROM payment_date) = 2005
AND EXTRACT(MONTH FROM payment_date)  =  08
) np
) na
GROUP BY na.staff_id
ORDER BY na.staff_id;


-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. 
-- Use inner join.
USE sakila;
SELECT fa.film_id, COUNT(actor_id)
FROM film_actor fa
INNER JOIN film f
ON  fa.film_id=f.film_id;
SELECT * FROM sakila.film;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
USE sakila;
SELECT film_id,title
FROM film
WHERE title= "Hunchback Impossible";
USE sakila;
SELECT a.film_id,COUNT(*) as copies
FROM
(SELECT *
FROM inventory
WHERE film_id='439'
) as a;


-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, 
-- list the total paid by each customer. 
-- List the customers alphabetically by last name
USE sakila;
SELECT c.first_name,c.last_name,SUM(c.amount) as total_paid
FROM
(SELECT a.customer_id,a.first_name,a.last_name,b.amount
FROM customer as a
INNER JOIN payment as b
ON a.customer_id=b.customer_id
) as c
GROUP BY c.last_name
ORDER BY c.last_name;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 
USE sakila;
SELECT title,language_id
FROM film
WHERE (title LIKE "Q%") OR (title LIKE "K%") AND 
language_id=
(SELECT language_id
FROM language
WHERE name='English');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
USE sakila;
SELECT actor.first_name,actor.last_name
FROM 
(SELECT actor_id,film_id
FROM film_actor
WHERE film_id=
(SELECT film_id 
FROM film
WHERE title='Alone Trip'
)
) b
INNER JOIN actor
ON b.actor_id=actor.actor_id;


-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
USE sakila;
SELECT c.first_name,c.last_name,c.email,c.address_id
FROM
(SELECT address_id
FROM 
(
SELECT city_id
FROM city
WHERE country_id=(SELECT country_id
FROM country
WHERE country='Canada'
)
) b
INNER JOIN address a
ON b.city_id=a.city_id
) m
INNER JOIN customer c
ON m.address_id=c.address_id;

-- 7d. Sales have been lagging among young families, 
-- and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as famiy films.
USE sakila;
SELECT b.title as Family_Movies,a.film_id
FROM 
(SELECT film_id
FROM film_category
WHERE category_id=
(SELECT category_id
FROM category
WHERE name='Family'
)
) a
INNER JOIN film b
ON a.film_id=b.film_id;

-- 7e. Display the most frequently rented movies in descending order.
USE sakila;
(SELECT f.title,l.times_rented,l.film_id
FROM
(SELECT m.film_id,COUNT(film_id) as times_rented
FROM
(SELECT a.inventory_id,b.film_id
FROM rental a
INNER JOIN inventory b
ON a.inventory_id=b.inventory_id
) m
GROUP BY m.film_id
ORDER BY times_rented DESC) l
INNER JOIN film f
ON f.film_id=l.film_id
) 
ORDER BY l.times_rented DESC;


-- 7f. Write a query to display how much business, in dollars, each store brought in.
USE sakila;
SELECT j.manager_staff_id as store,SUM(j.amount) as Total_Revenue
FROM
(SELECT manager_staff_id,p.amount
FROM payment p
INNER JOIN store s
ON p.staff_id=s.manager_staff_id
) j
GROUP BY j.manager_staff_id
ORDER BY j.manager_staff_id;


-- 7g. Write a query to display for each store its store ID, city, and country.
USE sakila;
SELECT f.store_id,f.city,g.country
FROM
(SELECT l.store_id,l.city_id,m.city,m.country_id
FROM
(SELECT  s.store_id,s.address_id,a.city_id
FROM store s
INNER JOIN address a
ON s.address_id=a.address_id
) l
INNER JOIN city m
ON l.city_id=m.city_id
) f
INNER JOIN country g
ON f.country_id=g.country_id
;


-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)
USE SAKILA;
CREATE VIEW top_genre AS
(SELECT SUM(amount) as Total_Revenue,j.name as Genre
FROM
(SELECT g.amount,h.name
FROM
(SELECT e.amount,e.film_id,f.category_id
FROM
(SELECT c.amount,c.inventory_id,d.film_id
FROM
(SELECT a.amount,a.rental_id,b.inventory_id
FROM
(SELECT amount,rental_id
FROM payment
) a
INNER JOIN rental b
ON a.rental_id=b.rental_id
) c
INNER JOIN inventory d
ON c.inventory_id=d.inventory_id
) e
INNER JOIN film_category f
ON e.film_id=f.film_id
) g
INNER JOIN category h
ON g.category_id=h.category_id
) j
GROUP BY j.name
ORDER BY Total_Revenue DESC
LIMIT 5
);


-- 8a. In your new role as an executive, 
-- you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
USE sakila;
SELECT * FROM top_genre;


-- 8b. How would you display the view that you created in 8a?
USE sakila;
DROP VIEW top_genre;


