CREATE database ecommerce_db;
Use ecommerce_db;
-- ----------Create Customer Table -----------------
CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE,
    city          VARCHAR(80),
    state         VARCHAR(80),
    gender        VARCHAR(10),
    age           INT,
    join_date     DATE
);
-- ----------Create products Table ---------
CREATE TABLE products (
	product_id    INT PRIMARY KEY auto_increment,
    product_namr  VARCHAR(150) NOT NULL,
    category      VARCHAR(80),
    sub_category  VARCHAR(80),
    brand         VARCHAR(80),
    price         DECIMAL(10,2),
    cost_price    DECIMAL(10,2)
);
-- ---------Create Orders Table ------------
CREATE TABLE Orders (
	order_id	INT PRIMARY KEY AUTO_INCREMENT,
    customer_id	INT,
    order_date	DATE,
    ship_date	DATE,
    status	    VARCHAR(30),
    payment_mode VARCHAR(30),
	city		VARCHAR(80),
	state		VARCHAR(80),
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) 
);
- ----------- Create Order Items table ------------------------
CREATE TABLE order_items (
    item_id       INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(10,2),
    discount      DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
