use nagidb;

INSERT INTO account_information(
account_id, account_type, service, create_date, email
) VALUES (
'1', 'web_glance_gander', '1', 'CURDATE()', 'lucillecfuhrman@inbound.plus'
);

INSERT INTO account_information(
account_id, account_type, service, create_date, email
) VALUES (
'2', 'web_glance_gaze', '1', 'CURDATE()', 'johnmminor@inbound.plus'
);

INSERT INTO nagios_contact(
account_id, contact_id, contact_name, alias, account_type, contact_groups, email, phone, receive
) VALUES (
'1', '101', '101_lucille', 'lucille', 'web_glance_gander', '101_group_alpha', 'lucillecfuhrman@inbound.plus', 1112223333, '1'
);

INSERT INTO nagios_contact(
account_id, contact_id, contact_name, alias, account_type, contact_groups, email, phone, misc, receive
) VALUES (
'1', '102', '102_kevin', 'kevin', 'web_glance_gander', '102_group_beta', 'spacey.space@inbound.plus', 1113334444, 'lucillecfuhrman@inbound.plus', '1'
);

INSERT INTO nagios_contact(
account_id, contact_id, contact_name, alias, account_type, contact_groups, email, phone, misc, receive
) VALUES (
'2', '201', '201_john', 'john', 'web_glance_gaze', '201_group_beta', 'johnmminor@inbound.plus', 3334445555, 6667778888, '1'
);

INSERT INTO nagios_contact_groups(
account_id, group_id, contactgroup_name, alias, members
) VALUES (
'1', '101', '101_group_alpha', 'group_alpha', 'lucille'
);

INSERT INTO nagios_contact_groups(
account_id, group_id, contactgroup_name, alias, members
) VALUES (
'1', '102', '102_group_beta', 'group_beta', 'kevin'
);

INSERT INTO nagios_contact_groups(
account_id, group_id, contactgroup_name, alias, members
) VALUES (
'2', '201', '201_group_beta', 'group_beta', 'john'
);

INSERT INTO nagios_host(
account_id, host_id, host_name, alias, account_type, address, contact_groups
) VALUES (
'1', '101', 'host.localhost.net', 'junkHost for Testing', 'web_glance_gander', '123.123.123.123', '101_group_alpha\, 102_group_beta'
);

INSERT INTO nagios_host(
account_id, host_id, host_name, alias, account_type, address, contacts
) VALUES (
'1', '102', 'host2.localhost.net', 'junkHost2 for Testing', 'web_glance_gander', '111.222.333.444', '101_lucille'
);

INSERT INTO nagios_host(
account_id, host_id, host_name, alias, account_type, address, contact_groups
) VALUES (
'2', '201', 'john.localhost.net', 'johns_Host for Testing', 'web_glance_gaze', '127.0.0.1', '201_group_beta'
);

INSERT INTO nagios_host_services(
account_id, host_id, service_num, host_name, service_description, check_command, account_type, contacts
) VALUES (
'1', '101', '10101', 'host.localhost.net', 'stupid_desc_here', 'check_ping', 'web_glance_gander', '101_lucille'
);

INSERT INTO nagios_host_services(
account_id, host_id, service_num, host_name, service_description, check_command, account_type, contact_groups
) VALUES (
'1', '101', '10102', 'host.localhost.net', 'stupid_desc_here', 'check_pop', 'web_glance_gander', '101_group_alpha'
);

INSERT INTO nagios_host_services(
account_id, host_id, service_num, host_name, service_description, check_command, account_type, contact_groups
) VALUES (
'1', '102', '10202', 'host2.localhost.net', 'stupid_desc_here', 'check_ping', 'web_glance_gaze', '201_group_beta'
);

INSERT INTO nagios_host_services(
account_id, host_id, service_num, host_name, service_description, check_command, account_type, contacts, contact_groups
) VALUES (
'2', '201', '20101', 'john.localhost.net', 'stupid_desc here', 'check_pop', 'web_glance_gaze', '201_john', '201_group_beta'
);

use strixProducts;

INSERT INTO products(
product_id, product_name, cost
) VALUES (
'0521345', 'web_glance_gander', '100'
);

INSERT INTO products(
product_id, product_name, cost
) VALUES (
'55346', 'web_glance_gaze', '100'
);

INSERT INTO products(
product_id, product_name, cost
) VALUES (
'553163', 'consulting', '100'
);

use strixdb;

INSERT INTO account_information(
account_id, first_name, last_name, account_type, service, create_date, email, phone, address_one, city, state, zip, country
) VALUES (
'1', 'lucille', 'fuhrman', 'web_glance_gander', 1, 'CURDATE()', 'lucillecfuhrman@inbound.plus', '1112223333', '1445 Prudence Street', 'Dearborn', 'MI', '48124', 'United States'
);

INSERT INTO account_information(
account_id, first_name, last_name, account_type, service, create_date, email, phone, address_one, address_two, city, state, zip, country
) VALUES (
'2', 'john', 'minor', 'web_glance_gaze', '1', 'CURDATE()', 'johnmminor@inbound.plus', '8174574831', '4026 Waldeck Street', 'Apt 2A', 'Fort Worth', 'TX', '76112', 'United States'
);

INSERT INTO billing_information(
account_id, billing_id, first_name, last_name, email, address_one, city, state, zip, country, pref_payment_type, paypal
) VALUES (
'1', '101', 'Lucille', 'Fuhrman', 'lucillecfuhrman@inbound.plus', '1445 Prudence Street', 'Dearborn', 'MI', '48124', 'United States', '1', '1'
);

INSERT INTO billing_information(
account_id, billing_id, first_name, last_name, email, address_one, city, state, zip, country, pref_payment_type, paypal, cc_num, cc_exp, cc_sec_code
) VALUES (
'1', '102', 'Lucille', 'Fuhrman', 'lucillecfuhrman@inbound.plus', '1445 Prudence Street', 'Dearborn', 'MI', '48124', 'United States', '1', '0', '4485886586914093', '5/2020', '578'
);

INSERT INTO billing_information(
account_id, billing_id, first_name, last_name, email, address_one, address_two, city, state, zip, country, pref_payment_type, paypal, cc_num, cc_exp, cc_sec_code
) VALUES (
'2', '201','John', 'Minor', 'johnmminor@inbound.plus', '4026 Waldeck Street', 'Apt 2A', 'Fort Worth', 'TX', '76112', 'United States', '1', '0', '5445197118256029', '6/2018', '402'
);

INSERT INTO login(
account_id, username, password, email
) VALUES (
'1', 'lucillecfuhrman', 'password', 'lucillecfuhrman@inbound.plus'
);

INSERT INTO login(
account_id, username, password, email
) VALUES (
'2', 'johnmminor', 'password', 'johnmminor@inbound.plus'
);

INSERT INTO invoices(
account_id, invoice_status, creation_date, due_date, total
) VALUES (
'1', 'paid', 'DATE()', 'DATE()', '100.00'
);

INSERT INTO invoices(
account_id, invoice_status, creation_date, due_date, total
) VALUES (
'2', 'unpaid', 'DATE()', 'DATE()', '500.00'
);

INSERT INTO invoice_items(
account_id, invoice_num, line_num, product_id, cost
) VALUES (
'1', '1', '1', '0521345', '100.00'
);

INSERT INTO invoice_items(
account_id, invoice_num, line_num, product_id, cost
) VALUES (
'2', '2', '1', '55346', '200.00'
);

INSERT INTO invoice_items(
account_id, invoice_num, line_num, product_id, cost
) VALUES (
'2', '2', '2', '553163', '300.00'
);

use nagiUpdates;

INSERT INTO nagiUpdates(
account_id, change_type, contacts, contacts_group, hosts
) VALUES (
'1', 'E', '1', '0', '0'
);

INSERT INTO nagiUpdates(
account_id, change_type, contacts, contacts_group, hosts
) VALUES (
'2', 'C', '1', '1', '1'
);
