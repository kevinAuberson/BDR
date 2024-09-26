SET search_path = pagila;

-- BEGIN Exercice 01
SELECT 
	customer_id, 
	last_name, 
	email 
FROM customer 
WHERE store_id=1 
	AND first_name='PHYLLIS' 
ORDER BY  customer_id DESC;
-- END Exercice 01


-- BEGIN Exercice 02
SELECT
    title,
    release_year
FROM film AS f
WHERE f.rating = 'R'
    AND f.length < 60
    AND f.replacement_cost = 12.99
ORDER BY f.title;
-- END Exercice 02


-- BEGIN Exercice 03
SELECT 
	c.country, 
	ci.city, 
	a.postal_code 
FROM country AS c 
JOIN city AS ci 
	ON ci.country_id = c.country_id 
JOIN address AS a 
	ON a.city_id = ci.city_id 
WHERE c.country='France' 
	OR (c.country_id >= 63 AND c.country_id <= 67) 
ORDER BY c.country, ci.city, a.postal_code;
-- END Exercice 03


-- BEGIN Exercice 04
SELECT
    customer_id,
    last_name,
    first_name
FROM customer
JOIN address AS a
    ON customer.address_id = a.address_id
WHERE store_id = 1
  AND a.city_id = 171
ORDER BY first_name;
-- END Exercice 04


-- BEGIN Exercice 05
SELECT DISTINCT
    c1.first_name AS prenom_1,
    c1.last_name AS nom_1,
    c2.first_name AS prenom_2,
    c2.last_name AS nom_2
FROM rental AS r1
JOIN customer AS c1 
	ON r1.customer_id = c1.customer_id
JOIN inventory AS i1 
	ON r1.inventory_id = i1.inventory_id
JOIN inventory AS i2 
	ON i1.film_id = i2.film_id
JOIN rental AS r2 
	ON i2.inventory_id = r2.inventory_id
JOIN customer AS c2 
	ON r2.customer_id = c2.customer_id 
	AND r1.customer_id < r2.customer_id
WHERE (c1.first_name, c1.last_name) != (c2.first_name, c2.last_name);
-- END Exercice 05


-- BEGIN Exercice 06
SELECT
    first_name,
    last_name
FROM
    actor,
    film,
    film_actor,
    film_category,
    category
WHERE actor.actor_id = film_actor.actor_id
    AND film_actor.film_id = film.film_id
    AND film_category.film_id = film.film_id
    AND film_category.category_id = category.category_id
    AND category.name LIKE 'Horror'
    AND (actor.last_name LIKE 'D%' OR actor.first_name LIKE 'K%');
-- END Exercice 06


-- BEGIN Exercice 07a
SELECT 
	f.film_id, 
	f.title, 
	(f.rental_rate / f.rental_duration) AS prix_location_par_jour 
FROM film AS f
WHERE (f.rental_rate / f.rental_duration) <= 1.00 
	AND f.film_id NOT IN(
		SELECT 
			film_id 
		FROM inventory  
		WHERE inventory_id IN(
			SELECT inventory_id 
			FROM rental
			)
		);
-- END Exercice 07a

-- BEGIN Exercice 07b
SELECT 
	f.film_id, 
	f.title, 
	(f.rental_rate / f.rental_duration) AS prix_location_par_jour 
FROM film AS f
LEFT JOIN inventory AS i 
	ON f.film_id = i.film_id
LEFT JOIN rental AS r 
	ON i.inventory_id = r.inventory_id
WHERE (f.rental_rate / f.rental_duration) <= 1.00 AND i.inventory_id IS NULL;
-- END Exercice 07b


-- BEGIN Exercice 08a
SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name
FROM customer
JOIN address AS a
    ON customer.address_id = a.address_id
JOIN city AS c1
    ON a.city_id = c1.city_id
JOIN country AS c2
    ON c1.country_id = c2.country_id
WHERE c2.country LIKE 'Spain'
    AND EXISTS(
    SELECT *
    FROM rental
    WHERE rental.customer_id = customer.customer_id
      AND rental.return_date IS NULL
    );
-- END Exercice 08a

-- BEGIN Exercice 08b
SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name
FROM customer
JOIN address AS a
    ON customer.address_id = a.address_id
JOIN city AS c1
    ON a.city_id = c1.city_id
JOIN country AS c2
    ON c1.country_id = c2.country_id
WHERE c2.country LIKE 'Spain'
  AND customer.customer_id IN (
        SELECT rental.customer_id
        FROM rental
        WHERE return_date IS NULL
        );
-- END Exercice 08b

-- BEGIN Exercice 08c
SELECT
    customer.customer_id,
    customer.first_name,
    customer.last_name
FROM customer
JOIN address AS a
    ON customer.address_id = a.address_id
JOIN city AS c1
    ON a.city_id = c1.city_id
JOIN country AS c2
    ON c1.country_id = c2.country_id
JOIN rental AS r
    ON customer.customer_id = r.customer_id
WHERE c2.country LIKE 'Spain'
  AND r.return_date IS NULL;
-- END Exercice 08c


-- BEGIN Exercice 09 (Bonus)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name
FROM customer AS c
JOIN rental AS r
    ON c.customer_id = r.customer_id
JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
JOIN film AS f
    ON i.film_id = f.film_id
JOIN film_actor AS fa
    ON f.film_id = fa.film_id
JOIN actor AS a
    ON fa.actor_id = a.actor_id
WHERE a.first_name = 'EMILY'
    AND a.last_name = 'DEE'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT f.film_id) = (
        SELECT COUNT(*)
        FROM film AS films
        JOIN film_actor AS fa
            ON films.film_id = fa.film_id
        JOIN actor AS actors
            ON fa.actor_id = actors.actor_id
        WHERE actors.first_name = 'EMILY'
            AND actors.last_name = 'DEE'
        );
-- END Exercice 09 (Bonus)


-- BEGIN Exercice 10
SELECT
    film.title,
    COUNT(fa.actor_id) AS nb_acteurs
FROM film
JOIN film_category AS fc
    ON film.film_id = fc.film_id
JOIN film_actor AS fa
    ON film.film_id = fa.film_id
JOIN category AS c
    ON fc.category_id = c.category_id
WHERE c.name LIKE 'Drama'
GROUP BY film.title
HAVING count(fa.actor_id) >= 5
ORDER BY nb_acteurs DESC;
-- END Exercice 10


-- BEGIN Exercice 11
SELECT 
	c.category_id, 
	c.name, 
	COUNT(fc.film_id) AS nb_film
FROM category AS c
JOIN film_category AS fc
    ON c.category_id = fc.category_id
GROUP BY c.category_id, c.name
HAVING COUNT(fc.film_id) > 65
ORDER BY nb_film;
-- END Exercice 11


-- BEGIN Exercice 12
SELECT
    film_id AS id,
    title AS titre,
    length AS duree
FROM film
WHERE length = (
        SELECT
            MIN(length)
        FROM film
        );
-- END Exercice 12


-- BEGIN Exercice 13a
SELECT DISTINCT 
	f.film_id, 
	f.title 
FROM film AS f 
JOIN film_actor AS fa 
	ON f.film_id = fa.film_id 
WHERE fa.actor_id IN (
	SELECT 
		a.actor_id 
	FROM actor AS a 
	LEFT JOIN film_actor AS fa 
		ON a.actor_id = fa.actor_id 
	GROUP BY a.actor_id 
	HAVING COUNT(fa.actor_id) > 40
	);
-- END Exercice 13a

-- BEGIN Exercice 13b
SELECT DISTINCT 
	f.film_id, 
	f.title
FROM film AS f
JOIN film_actor AS fa
	ON f.film_id = fa.film_id
JOIN (
    SELECT 
		a.actor_id
    FROM actor AS a
    JOIN film_actor AS fa
		ON a.actor_id = fa.actor_id
    GROUP BY a.actor_id
    HAVING COUNT(fa.actor_id) > 40
	) sub 
		ON fa.actor_id = sub.actor_id 
ORDER BY  f.title;
-- END Exercice 13b


-- BEGIN Exercice 14
SELECT
    CEIL(SUM(length) / 60.0 /8.0) AS nb_jours
FROM film;
-- END Exercice 14


-- BEGIN Exercice 15
SELECT 
	id_customer, 
	nom_customer, 
	email_customer, 
	country_customer, 
	nb_locations, 
	depense_totale, 
	depense_moyenne 
FROM (
	SELECT 
		c.customer_id AS id_customer, 
		c.first_name AS nom_customer, 
		c.email AS email_customer, 
		co.country AS country_customer , 
		COUNT(r.customer_id) AS nb_locations, 
		SUM(p.amount) AS depense_totale, 
		AVG(p.amount) AS depense_moyenne
	FROM customer AS c
	JOIN rental AS r
		ON c.customer_id = r.customer_id
	JOIN address AS a
		ON c.address_id = a.address_id
	JOIN city AS ci
		ON a.city_id = ci.city_id
	JOIN country AS co
		ON ci.country_id = co.country_id
	JOIN payment AS p
		ON c.customer_id = p.customer_id
	GROUP BY c.customer_id, c.first_name, c.email, co.country
	)
WHERE country_customer IN ('Switzerland', 'France', 'Germany')
AND depense_moyenne > 3.0
ORDER BY country_customer, nom_customer;
-- END Exercice 15


-- BEGIN Exercice 16a
SELECT count(*) 
FROM payment
WHERE amount <= 9;
-- END Exercice 16a

-- BEGIN Exercice 16b
DELETE FROM payment 
WHERE amount <= 9
RETURNING *;
-- END Exercice 16b

-- BEGIN Exercice 16c
SELECT count(*) 
FROM payment
WHERE amount <= 9;
-- END Exercice 16c


-- BEGIN Exercice 17
UPDATE payment
SET amount = amount * 1.5,
    payment_date = now()
WHERE amount > 4
RETURNING *;
-- END Exercice 17


-- BEGIN Exercice 18
INSERT INTO
	city (city, country_id)
VALUES ('Nyon', (
		SELECT
			country_id AS C
	FROM country
	WHERE country='Switzerland'))
RETURNING *;
	
INSERT INTO
	address (address,city_id,postal_code,phone,district)
VALUES ('Rue du centre',(
		SELECT city_id FROM city
		WHERE city LIKE 'Nyon'),
			1260,'022 360 00 00','')
RETURNING *;
			
INSERT INTO
	customer (store_id,first_name,last_name,email,address_id,active,create_date)
VALUES (1,'Guillaume','Ransome','gr@bluewin.ch',(
		SELECT
			max(address_id)
		FROM address),true, now())
RETURNING *;
-- END Exercice 18

-- BEGIN Exercice 18d
SELECT
    C.first_name,
	C.last_name,
	A.address,
	A.postal_code,
	CI.city,
	A.phone,
	CO.country,
	C.email,
	C.store_id
FROM customer AS C
JOIN address AS A
	ON C.address_id = A.address_id
JOIN city AS CI
	ON A.city_id = CI.city_id
JOIN country AS CO
	ON CI.country_id = CO.country_id
WHERE first_name = 'Guillaume' AND last_name = 'Ransome';
-- END Exercice 18d
