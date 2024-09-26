-- Allows to re-run the script without errors as long as there is no data in the table
DROP SCHEMA IF EXISTS company CASCADE;

-- Setup work
CREATE SCHEMA company;

-- Setup the search paths to avoid prefixing
SET SEARCH_PATH TO company;

-- 1.2 Table implementation
CREATE TABLE company.employee (
    fname varchar(15) NOT NULL,
    minit char(1),
    lname varchar(15) NOT NULL,
    ssn char(9) NOT NULL,
    bdate date,
    address varchar(30),
    sex char(1),
    salary decimal(10,2),
    super_ssn char(9),
    dno integer NOT NULL,
    PRIMARY KEY (ssn)
);

CREATE TABLE company.department (
    dname varchar(15) NOT NULL,
    dnumber integer NOT NULL,
    mgr_ssn char(9) NOT NULL,
    mgr_start_date date NOT NULL,
    PRIMARY KEY (dnumber)
);

-- Diagram specifies dept_location but insertion script expects dept_locations
CREATE TABLE company.dept_locations (
    dnumber integer NOT NULL,
    dlocation integer NOT NULL,
    PRIMARY KEY (dnumber, dlocation)
);

CREATE TABLE company.project (
    pname varchar(15) NOT NULL,
    pnumber integer NOT NULL,
    plocation integer,
    dnum integer NOT NULL,
    PRIMARY KEY (pnumber)
);

CREATE TABLE company.works_on (
    essn char(9) NOT NULL,
    pno integer NOT NULL,
    hours decimal(3,1) NOT NULL,
    PRIMARY KEY (essn, pno)
);

CREATE TABLE company.dependent (
    essn char(9) NOT NULL,
    dependent_name varchar(15) NOT NULL,
    sex char(1),
    bdate date,
    relationship varchar(8),
    PRIMARY KEY (essn, dependent_name)
);

CREATE TABLE company.location (
    lnumber integer NOT NULL,
    lname varchar(15) NOT NULL,
    PRIMARY KEY (lnumber)
);

-- Verify our work with:
SELECT * FROM information_schema.tables
WHERE table_schema = 'company';

-- 1.3 Data insertion
INSERT INTO company.works_on VALUES ('123456789', 3, 10);
INSERT INTO company.works_on VALUES ('123456789', 5, 10);
-- Les deux commandes sont exécutées et deux nouveaux projets apparaissent à la fin de la table. Le nombre d'heures est
-- transformé en un chiffre à une décimale. Postgres ne renvoie pas d'erreur même si le projet 5 n'existe pas.
DELETE FROM company.department WHERE dnumber = 5;
-- Puisqu'il n'y a encore aucune relation en place, Postgres nous laisse effacer le tuple sans soulever d'erreur (la DB
-- ne devrait plus être intègre puisque plusieurs projets et employées référencent le département no 5.

-- 1.4 Implémentation des contraintes
-- 1.4.1 Vidange des tables
DELETE FROM company.department; -- Soulève un warning dans Dataspell
DELETE FROM company.dept_locations WHERE dnumber = *; -- Forme complète, un peu longue
TRUNCATE TABLE company.dependent; -- Ne soulève pas de warning
TRUNCATE TABLE company.location;
TRUNCATE TABLE company.works_on;
TRUNCATE TABLE company.employee;
TRUNCATE TABLE company.project;
-- Dans tous les cas, attention à une éventuelle colonne identité qui ne serait pas remise à 0.

-- 1.4.2 Contraintes d'intégrité référentielle
-- Employee
ALTER TABLE company.employee ADD CONSTRAINT super_ssn_ssn FOREIGN KEY (super_ssn) REFERENCES company.employee(ssn);
ALTER TABLE company.employee ADD CONSTRAINT dno_dnumber FOREIGN KEY (dno) REFERENCES company.department(dnumber);
-- Dependant
ALTER TABLE company.dependent ADD CONSTRAINT essn_ssn FOREIGN KEY (essn) REFERENCES company.employee(ssn);
-- Department
ALTER TABLE company.department ADD CONSTRAINT mgr_ssn_ssn FOREIGN KEY (mgr_ssn) REFERENCES company.employee(ssn);
-- Dept Locations
ALTER TABLE company.dept_locations ADD CONSTRAINT dnumber_dnumber FOREIGN KEY (dnumber) REFERENCES company.department(dnumber);
ALTER TABLE company.dept_locations ADD CONSTRAINT dlocation_lnumber FOREIGN KEY (dlocation) REFERENCES company.location(lnumber);
-- Project
ALTER TABLE company.project ADD CONSTRAINT plocation_lnumber FOREIGN KEY (plocation) REFERENCES company.location(lnumber);
ALTER TABLE company.project ADD CONSTRAINT dnum_dnumber FOREIGN KEY (dnum) REFERENCES company.department(dnumber);
-- Works on
ALTER TABLE company.works_on ADD CONSTRAINT pno_pnumber FOREIGN KEY (pno) REFERENCES company.project(pnumber);
ALTER TABLE company.works_on ADD CONSTRAINT essn_ssn FOREIGN KEY (essn) REFERENCES company.employee(ssn);

-- 1.4.3 Population de la base de données
--   a) Cela n'est pas possible. Insérer dans une table violerait les contraintes d'intégrité. P.ex: si on insère d'abord
--      un employé, le département auquel il appartient d'existe pas encore.
--   b) Il faut désactiver temporairement la vérification des contraintes.

-- Problème: l'utilisateur admin (postgres) ne voit pas le schéma "company" de l'utilisateur bdr. Fix :
GRANT CONNECT ON DATABASE bdr TO postgres;
GRANT ALL ON ALL TABLES IN SCHEMA company TO postgres;
-- Avec DataGrip, il faut ensuite ouvrir une nouvelle console qui utilise la DB "bdr" (il faut peut-être aussi afficher
-- la db dans l'explorateur de database en faisant clic droit sur "postgres@localhost" puis Propriétés > Schéma et ticker bdr)
-- puis on peut enfin donner le rôle de réplication et insérer les données.
SET session_replication_role = 'replica';
-- Run le script "insert_values.sql" en s'assurant d'être dans la même console que celle ou on à set le rôle.
SET session_replication_role = 'origin';
-- Workflow alternatif : ajouter les instructions set dans le script et le run contre la db "bdr" avec le superuser.

-- 1.4.4 Insertion d'un nouveau département
-- Difficulté: on ne peut pas insérer un nouveau département et un nouvel employé en même temps à cause des contraintes
-- d'intégrités : si l'on ne spécifie pas de dno ou mgr_ssr, on viol une contrainte non. Si on essaye de renseigner la
-- valeur de dno dans Employee (ou mgr_ssn dans Department), alors on viol une contrainte de clé étrangère.
-- Deux solutions :
WITH first_insert AS (INSERT INTO company.department VALUES ('IT', 10, '555444333', NOW()))
INSERT
INTO company.employee(fname, lname, ssn, dno)
VALUES ('Job', 'Steve', '555444333', 10);
-- Ou alors :
BEGIN;
SET CONSTRAINTS ALL DEFERRED;
INSERT INTO company.department
VALUES ('IT', 10, '555444333', NOW());
INSERT INTO company.employee(fname, lname, ssn, dno)
VALUES ('Job', 'Steve', '555444333', 10);
COMMIT;
