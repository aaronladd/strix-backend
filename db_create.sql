CREATE DATABASE nagiUpdates;

use nagiUpdates;

CREATE TABLE accounts_updated(
account_id MEDIUMINT NOT NULL,
change_type CHAR(1) NOT NULL,
contacts BOOLEAN NOT NULL,
contacts_group BOOLEAN NOT NULL,
hosts BOOLEAN NOT NULL,
PRIMARY KEY (account_id)
);

CREATE USER 'nagiTest'@'localhost' IDENTIFIED BY 'hV22buZAVFk22fx';

GRANT ALL ON nagiUpdates.* TO 'nagiTest'@'localhost';
