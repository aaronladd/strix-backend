CREATE DATABASE nagidb;
CREATE DATABASE strixdb;
CREATE DATABASE strixProducts;

use strixProducts;

CREATE TABLE products(
product_id TINYINT NOT NULL,
product_name TINYTEXT NOT NULL,
product_desc TEXT,
cost DECIMAL(6,2) NOT NULL,
PRIMARY KEY (product_id)
);

use strixdb;

CREATE TABLE account_information(
account_id MEDIUMINT NOT NULL AUTO_INCREMENT,
first_name varchar(10) NOT NULL,
last_name varchar(15) NOT NULL,
account_type SMALLINT NOT NULL,
service BOOLEAN NOT NULL,
create_date DATE NOT NULL,
company varchar(35),
email varchar(25) NOT NULL,
phone varchar(10),
address_one varchar(60) NOT NULL,
address_two varchar(40) NOT NULL,
city varchar(35) NOT NULL,
state varchar(20) NOT NULL,
zip MEDIUMINT NOT NULL,
country varchar(30) NOT NULL,
PRIMARY KEY (account_id),
UNIQUE (email)
);

CREATE TABLE billing_information(
account_id MEDIUMINT NOT NULL,
billing_id INT NOT NULL,
first_name varchar(10),
last_name varchar(15),
address_one varchar(60),
address_two varchar(40),
city varchar(35),
state varchar(20),
zip MEDIUMINT,
country varchar(30),
pref_payment_type BOOLEAN NOT NULL,
paypal BOOLEAN NOT NULL,
cc_num varchar(40),
cc_exp varchar (10),
cc_sec_code INT,
PRIMARY KEY(billing_id),
FOREIGN KEY(account_id) REFERENCES account_information(account_id)
);

CREATE TABLE login(
account_id MEDIUMINT NOT NULL,
username varchar(25) NOT NULL,
password varchar(35) NOT NULL,
email varchar(25) NOT NULL,
PRIMARY KEY(email),
FOREIGN KEY(account_id) REFERENCES account_information(account_id),
FOREIGN KEY(email) REFERENCES account_information(email) ON UPDATE CASCADE,
UNIQUE (username)
);

CREATE TABLE invoices(
account_id MEDIUMINT NOT NULL,
invoice_num MEDIUMINT NOT NULL,
invoice_status varchar(10) NOT NULL,
creation_date DATE NOT NULL,
due_date DATE NOT NULL,
total DECIMAL(6,2) NOT NULL,
PRIMARY KEY(invoice_num),
FOREIGN KEY(account_id) REFERENCES account_information(account_id)
);

CREATE TABLE invoice_items(
account_id MEDIUMINT NOT NULL,
invoice_num MEDIUMINT NOT NULL,
line_num TINYINT NOT NULL,
product_id MEDIUMINT NOT NULL,
product_desc TEXT,
cost DECIMAL(6,2) NOT NULL
);

use nagidb;

CREATE TABLE account_information(
account_id MEDIUMINT NOT NULL,
account_type varchar(30) NOT NULL,
service BOOLEAN NOT NULL,
create_date DATE NOT NULL,
email varchar(25) NOT NULL,
PRIMARY KEY (account_id),
UNIQUE (email)
);

CREATE TABLE nagios_contact(
account_id MEDIUMINT NOT NULL,
contact_id INT NOT NULL,
contact_name varchar(25) NOT NULL,
alias varchar(25) NOT NULL,
account_type varchar(30) NOT NULL,
contact_groups varchar(45) NOT NULL,
email varchar(25) NOT NULL,
phone varchar(10),
misc varchar(25),
receive BOOLEAN NOT NULL,
PRIMARY KEY (contact_id),
FOREIGN KEY(account_id) REFERENCES account_information(account_id)
);

CREATE TABLE nagios_contact_groups(
account_id MEDIUMINT NOT NULL,
group_id INT NOT NULL,
contactgroup_name varchar(40) NOT NULL,
alias varchar(25) NOT NULL,
members varchar(80),
PRIMARY KEY (group_id),
FOREIGN KEY(account_id) REFERENCES account_information(account_id)
);

CREATE TABLE nagios_host(
account_id MEDIUMINT NOT NULL,
host_id INT NOT NULL,
host_name varchar(35) NOT NULL,
alias varchar(25) NOT NULL,
address varchar(45) NOT NULL,
account_type varchar(30) NOT NULL,
contacts varchar(50) NOT NULL,
contact_groups TINYTEXT,
PRIMARY KEY (host_id),
FOREIGN KEY(account_id) REFERENCES account_information(account_id)
);

CREATE TABLE nagios_host_services(
account_id MEDIUMINT NOT NULL,
host_id INT NOT NULL,
service_num SMALLINT NOT NULL,
host_name varchar(35) NOT NULL,
service_description TINYTEXT NOT NULL,
check_command varchar(25),
account_type varchar(30) NOT NULL,
contacts varchar(50),
contact_groups TINYTEXT,
PRIMARY KEY (service_num),
FOREIGN KEY(account_id) REFERENCES account_information(account_id),
FOREIGN KEY(host_id) REFERENCES nagios_host(host_id)
);

CREATE USER 'nagiTest'@'localhost' IDENTIFIED BY 'hV22buZAVFk22fx';
GRANT ALL ON nagidb.* TO 'nagiTest'@'localhost';
GRANT ALL ON strixdb.* TO 'nagiTest'@'localhost';
GRANT ALL ON strixProducts.* TO 'nagiTest'@'localhost';
