-- DROP TABLE df_sales

CREATE TABLE df_sales (
row_id int PRIMARY KEY,
order_id varchar(20),
order_date date,
ship_date date,
ship_mode varchar(20),
customer_id varchar(20),
segment varchar(20),
country varchar(20),
city varchar(20),
state varchar(30),
postal_code varchar(20),
region varchar(20),
product_id varchar(50),
category varchar(20),
sub_category varchar(20),
product_name varchar(130),
sales decimal(7,2),
quantity int,
discount decimal(7,2),
profit decimal(7,2),
cluster int
)