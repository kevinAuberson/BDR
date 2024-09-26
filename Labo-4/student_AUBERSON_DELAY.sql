SET search_path = pagila;

--
-- Triggers
---------------------------

-- BEGIN Exercice 01
DROP TRIGGER IF EXISTS major_insert_payment ON payment;
DROP FUNCTION IF EXISTS major_payment();

CREATE OR REPLACE FUNCTION major_payment()
RETURNS TRIGGER AS $$
BEGIN
    NEW.amount:= NEW.amount * 1.08;
    NEW.payment_date:= CURRENT_TIMESTAMP;
    RETURN NEW;
END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER major_insert_payment
    BEFORE INSERT
    ON payment
    FOR EACH ROW
    EXECUTE FUNCTION major_payment();

INSERT INTO payment(customer_id, staff_id, rental_id, amount, payment_date)
VALUES (1,1,1,35,CURRENT_TIMESTAMP)
RETURNING *;
-- END Exercice 01

-- BEGIN Exercice 02
-- END Exercice 02

-- BEGIN Exercice 03
DROP TRIGGER IF EXISTS email_staff ON staff;
DROP FUNCTION IF EXISTS mailAuto();

CREATE FUNCTION mailAuto()
RETURNS TRIGGER AS $$
BEGIN
    NEW.email:= LOWER(CONCAT(NEW.first_name , '.' , NEW.last_name , '@sakilastaff.com'));
    RETURN NEW;
END;
    $$
LANGUAGE plpgsql;

CREATE TRIGGER email_staff
    BEFORE INSERT OR UPDATE
    ON staff
    FOR EACH ROW
    EXECUTE FUNCTION  mailAuto();

INSERT INTO staff(first_name, last_name, address_id, email, store_id,username)
VALUES ('Zinedine','Zidane',1, '',1,'zizou')
RETURNING *;

UPDATE staff
    SET email = ''
WHERE staff_id = 5
RETURNING *;
-- END Exercice 03

--
-- Vues
---------------------------

-- BEGIN Exercice 04
-- END Exercice 04

-- BEGIN Exercice 05
DROP VIEW IF EXISTS send_mail_late;

CREATE VIEW send_mail_late AS
SELECT
	c.email,
	f.title,
	EXTRACT(DAY FROM(CURRENT_TIMESTAMP - r.rental_date)) AS days
FROM
	customer c
JOIN rental r
    ON r.customer_id = c.customer_id
JOIN inventory i
    ON i.inventory_id = r.inventory_id
JOIN film f
    ON f.film_id = i.film_id

WHERE r.return_date IS NULL
    AND r.rental_date + f.rental_duration * INTERVAL '1 day' < CURRENT_DATE;

SELECT *
FROM send_mail_late;
-- END Exercice 05

-- BEGIN Exercice 06
-- END Exercice 06

-- BEGIN Exercice 07
DROP VIEW IF EXISTS customers_with_most_locations;

CREATE VIEW customers_with_most_locations
AS
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(r.rental_id) AS nbLocation
FROM customer AS c
JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY c.first_name, c.customer_id, c.last_name;

SELECT
    *
FROM customers_with_most_locations
ORDER BY nbLocation DESC LIMIT 20;
-- END Exercice 07

-- BEGIN Exercice 08
-- END Exercice 08

--
-- Procédures / Fonctions
---------------------------

-- BEGIN Exercice 09
DROP FUNCTION IF EXISTS film_choice_of_store(id_store INT);

CREATE FUNCTION film_choice_of_store(id_store INT)
RETURNS INT
LANGUAGE plpgsql
AS
$$
DECLARE
	nbFilm integer;
BEGIN
	SELECT count(*)
	INTO nbFilm
	FROM inventory AS i
	WHERE i.store_id = id_store
	GROUP BY i.store_id;
	RETURN nbFilm;
END;
$$;

SELECT film_choice_of_store(1);
SELECT film_choice_of_store(2);

SELECT COUNT(*)
FROM inventory
WHERE store_id = 1;

SELECT COUNT(*)
FROM inventory
WHERE store_id = 2;
-- END Exercice 09

-- BEGIN Exercice 10
-- END Exercice 10

--
-- SQL Avancé
---------------------------

-- BEGIN Exercice 11
WITH RECURSIVE actor_distance AS (
    SELECT
        a.actor_id,
        0 AS distance
    FROM actor AS a
    WHERE first_name = 'ED'
      AND last_name = 'GUINESS'
    UNION
    SELECT DISTINCT
        a.actor_id,
        ad.distance + 1
    FROM actor AS a
    JOIN film_actor AS fa
        ON a.actor_id = fa.actor_id
    JOIN film AS f
        ON fa.film_id = f.film_id
               AND f.length < 50
    JOIN film_actor AS fa2
        ON f.film_id = fa2.film_id
    JOIN actor_distance AS ad
        ON fa2.actor_id = ad.actor_id
    WHERE ad.distance < 3
)

SELECT DISTINCT
    actor_id
FROM actor_distance;
-- END Exercice 11

-- BEGIN Exercice 12
-- END Exercice 12
