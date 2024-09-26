SET SEARCH_PATH TO company;

create table employee(
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
    CONSTRAINT employer_PK PRIMARY KEY (ssn)
    );

create table department(
    dname varchar(15) NOT NULL,
    dnumber integer NOT NULL,
    mgr_ssn char(9) NOT NULL,
    mgr_start_date date NOT NULL,
    PRIMARY KEY (dnumber)
);

create table dept_location(
    dnumber integer NOT NULL ,
    dlocation integer NOT NULL
);

create table project(
    pname varchar(15) NOT NULL,
    pnumber integer NOT NULL,
    plocation integer,
    dnum integer NOT NULL,
    PRIMARY KEY (pnumber)
);

create table works_on(
    essn char(9) NOT NULL,
    pno integer NOT NULL,
    hours decimal(3,1) NOT NULL
);

create table dependent(
    essn char(9) NOT NULL,
    dependent_name varchar(15) NOT NULL,
    sex char(1),
    bdate date,
    relationship varchar(8),
    PRIMARY KEY (dependent_name)
);

create table location(
    lnumber integer NOT NULL,
    lname varchar(15) NOT NULL,
    PRIMARY KEY (lnumber)
);

ALTER TABLE company.employee add foreign key (dno) references department(dnumber);
ALTER TABLE company.employee add foreign key (super_ssn) references employee(ssn);
ALTER TABLE company.dependent add foreign key (essn) references employee(ssn);
ALTER TABLE company.department add foreign key (mgr_ssn) references employee(ssn);
ALTER TABLE company.project add foreign key (dnum) references department(dnumber);
ALTER TABLE company.project add foreign key (plocation) references location(lnumber);
ALTER TABLE company.dept_location add foreign key (dnumber) references department(dnumber);
ALTER TABLE company.dept_location add foreign key (dlocation) references location(lnumber);
ALTER TABLE company.works_on add foreign key (essn) references employee(ssn);
ALTER TABLE company.works_on add foreign key (pno) references project(pnumber);

-- Bloc à exécuter en mode superuser
SET SEARCH_PATH TO company;
ALTER TABLE company.project DISABLE TRIGGER ALL;
ALTER TABLE company.dept_location DISABLE TRIGGER ALL;
ALTER TABLE company.department DISABLE TRIGGER ALL;
ALTER TABLE company.dependent DISABLE TRIGGER ALL;
ALTER TABLE company.works_on DISABLE TRIGGER ALL;
ALTER TABLE company.location DISABLE TRIGGER ALL;
ALTER TABLE company.employee DISABLE TRIGGER ALL;


ALTER TABLE company.project ENABLE TRIGGER ALL;
ALTER TABLE company.dept_location ENABLE TRIGGER ALL;
ALTER TABLE company.department ENABLE TRIGGER ALL;
ALTER TABLE company.dependent ENABLE TRIGGER ALL;
ALTER TABLE company.works_on ENABLE TRIGGER ALL;
ALTER TABLE company.location ENABLE TRIGGER ALL;
ALTER TABLE company.employee ENABLE TRIGGER ALL;

