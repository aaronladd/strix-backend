use nagidb;

INSERT INTO account_information(
account_type, service, create_date, email
) VALUES (
'web_glance_gander', '1', 'DATE()', 'lucillecfuhrman@inbound.plus'
);

INSERT INTO account_information(
account_type, service, create_date, email
) VALUES (
'web_glance_gaze', '1', 'DATE()', 'johnmminor@inbound.plus'
);

INSERT INTO nagios_contact(
account_id, contact_id, email, phone, contact_group, receive
) VALUES (
'1', '101', 'lucillecfuhrman@inbound.plus', 1112223333, 'group_alpha', '1'
);

INSERT INTO nagios_contact(
account_id, contact_id, email, phone, contact_group, receive
) VALUES (
'1', '102', 'lucillecfuhrman@inbound.plus', 1113334444, 'group_alpha', '1'
);

INSERT INTO nagios_contact(
account_id, contact_id, email, phone, contact_group, receive
) VALUES (
'2', '201','johnmminor@inbound.plus', 3334445555, 'group_alpha', '1'
);

INSERT INTO nagios_host(
account_id, host_id, host_name, alias, address, contact_groups
) VALUES (
'1', '101', 'host.localhost.net', 'junkHost for Testing', '123.123.123.123', 'group_alpha'
);

INSERT INTO nagios_host(
account_id, host_id, host_name, alias, address, contact_groups
) VALUES (
'2', '201', 'host.localhost.net', 'junk_Host for Testing', '127.0.0.1', 'group_beta'
);

INSERT INTO nagios_host_services(
account_id, host_id, service_num, host_name, service_description, check_command
) VALUES (
'1', '101', 1, 'host.localhost.net', 'stupid_desc_here', 'check_ping'
);

INSERT INTO nagios_host_services(
account_id, host_id, service_num, host_name, service_description, check_command
) VALUES (
'2', '201', 1, 'host.localhost.net', 'stupid_desc here', 'check_pop'
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
'1', 'lucille', 'fuhrman', 'web_glance_gander', 1, 'DATE()', 'lucillecfuhrman@inbound.plus', '1112223333', '1445 Prudence Street', 'Dearborn', 'MI', '48124', 'United States'
);

INSERT INTO account_information(
account_id, first_name, last_name, account_type, service, create_date, email, phone, address_one, address_two, city, state, zip, country
) VALUES (
'2', 'john', 'minor', 'web_glance_gaze', '1', 'DATE()', 'johnmminor@inbound.plus', '8174574831', '4026 Waldeck Street', 'Apt 2A', 'Fort Worth', 'TX', '76112', 'United States'
);

INSERT INTO billing_information(
account_id, billing_id, first_name, last_name, email, phone, address_one, city, state, zip, country, pref_payment_type, paypal
) VALUES (
'1', '101', 'Lucille', 'Fuhrman', 'lucillecfuhrman@inbound.plus', '1112223333', '1445 Prudence Street', 'Dearborn', 'MI', '48124', 'United States', '1', '1'
);

INSERT INTO billing_information(
account_id, billing_id, first_name, last_name, email, phone, address_one, city, state, zip, country, pref_payment_type, paypal, cc_num, cc_exp, cc_sec_code
) VALUES (
'1', '102', 'Lucille', 'Fuhrman', 'lucillecfuhrman@inbound.plus', '1112223333', '1445 Prudence Street', 'Dearborn', 'MI', '48124', 'United States', '1', '0', '4485886586914093', '5/2020', '578'
);

INSERT INTO billing_information(
account_id, billing_id, first_name, last_name, email, phone, address_one, address_two, city, state, zip, country, pref_payment_type, paypal, cc_num, cc_exp, cc_sec_code
) VALUES (
'2', '201','John', 'Minor', 'johnmminor@inbound.plus', '8174574831', '4026 Waldeck Street', 'Apt 2A', 'Fort Worth', 'TX', '76112', 'United States', '1', '0', '5445197118256029', '6/2018', '402'
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
