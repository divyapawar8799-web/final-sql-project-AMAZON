-- Single line comment -- 
/* 
Multiline 
comment 
*/

-- CREATE A DATABASE QUERIES -- 
Create Database Amazon;

Use Amazon;

drop database Amazon;

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL,
    dob DATE NOT NULL,
    status ENUM('Active','Suspended','Deleted') DEFAULT 'Active',
    city_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Users (email, phone, first_name, last_name, gender, dob, status, city_id) VALUES
('rahul.sharma@amazon.in','9876543210','Rahul','Sharma','Male','1995-06-01','Active',101),
('priya.patil@amazon.in','9123456780','Priya','Patil','Female','1994-03-15','Active',102),
('amit.kulkarni@amazon.in','9988776655','Amit','Kulkarni','Male','1992-08-20','Suspended',103),
('sneha.jadhav@amazon.in','9823456712','Sneha','Jadhav','Female','1998-12-11','Active',104),
('vishal.desai@amazon.in','9012345678','Vishal','Desai','Male','1990-07-22','Deleted',105),
('anita.more@amazon.in','9765432109','Anita','More','Female','1996-01-17','Active',106),
('sanjay.pawar@amazon.in','9856123478','Sanjay','Pawar','Male','1988-03-05','Active',107),
('neha.kadam@amazon.in','9776543211','Neha','Kadam','Female','1999-09-09','Suspended',108),
('arjun.naik@amazon.in','9887654321','Arjun','Naik','Male','1993-04-13','Active',109),
('komal.bhosale@amazon.in','9812345670','Komal','Bhosale','Female','1997-05-23','Active',110),
('rohit.patil@amazon.in','9865321478','Rohit','Patil','Male','1991-06-18','Deleted',111),
('meena.deshmukh@amazon.in','9723456789','Meena','Deshmukh','Female','1995-08-30','Active',112),
('sachin.kale@amazon.in','9843215678','Sachin','Kale','Male','1989-10-11','Active',113),
('pooja.shinde@amazon.in','9798765432','Pooja','Shinde','Female','1996-02-25','Active',114),
('manoj.gupta@amazon.in','9734567890','Manoj','Gupta','Male','1992-03-21','Suspended',115),
('alka.verma@amazon.in','9890123456','Alka','Verma','Female','1994-04-12','Active',116),
('nilesh.joshi@amazon.in','9821098765','Nilesh','Joshi','Male','1990-07-19','Active',117),
('swati.kulkarni@amazon.in','9876123450','Swati','Kulkarni','Female','1998-08-28','Active',118),
('deepak.yadav@amazon.in','9761092834','Deepak','Yadav','Male','1991-12-14','Deleted',119),
('reshma.gawande@amazon.in','9912345678','Reshma','Gawande','Female','1997-11-01','Active',120);

-- 1. 
 DROP TABLE Users;
 
-- 2. 
SELECT * FROM USERS;

-- 3. 
Truncate table users;



-- ----------------------------  2 Orders ---------------------------------------------------  

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    quantity INT CHECK (quantity > 0),
    price DECIMAL(10,2) CHECK (price > 0),
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (quantity * price) STORED,
    status ENUM('Pending','Shipped','Delivered','Cancelled') DEFAULT 'Pending',
    payment_method ENUM('COD','Credit Card','Debit Card','UPI') NOT NULL,
    order_date DATE DEFAULT (CURRENT_DATE),
    delivery_date DATE

);


INSERT INTO Orders
(user_id, product_name, quantity, price, status, payment_method, order_date, delivery_date)
VALUES
(1, 'Laptop', 5, 55000.00, 'Shipped', 'Credit Card', '2025-08-01', '2025-08-05'),
(2, 'Smartphone', 2, 22000.00, 'Delivered', 'UPI', '2025-08-02', '2025-08-06'),
(3, 'Headphones', 1, 3000.00, 'Delivered', 'UPI', '2025-08-03', '2025-08-07'),
(4, 'Washing Machine', 1, 15000.00, 'Pending', 'COD', '2025-08-04', NULL),
(5, 'Refrigerator', 1, 25000.00, 'Shipped', 'Credit Card', '2025-08-05', '2025-08-10'),
(6, 'Microwave Oven', 2, 8000.00, 'Delivered', 'UPI', '2025-08-06', '2025-08-09'),
(7, 'Air Conditioner', 1, 32000.00, 'Cancelled', 'Debit Card', '2025-08-07', NULL),
(8, 'Jeans', 3, 2000.00, 'Delivered', 'Credit Card', '2025-08-08', '2025-08-11'),
(9, 'T-shirt', 5, 500.00, 'Shipped', 'UPI', '2025-08-09', '2025-08-12'),
(10, 'Shoes', 2, 2500.00, 'Delivered', 'Credit Card', '2025-08-10', '2025-08-14'),
(11, 'Smartwatch', 1, 7000.00, 'Pending', 'Debit Card', '2025-08-11', NULL),
(12, 'Tablet', 1, 18000.00, 'Shipped', 'UPI', '2025-08-12', '2025-08-16'),
(13, 'Bluetooth Speaker', 2, 2500.00, 'Delivered', 'Credit Card', '2025-08-13', '2025-08-18'),
(14, 'Camera', 1, 45000.00, 'Pending', 'Credit Card', '2025-08-14', NULL),
(15, 'Printer', 1, 12000.00, 'Delivered', 'UPI', '2025-08-15', '2025-08-19'),
(16, 'Keyboard', 3, 1500.00, 'Shipped', 'Debit Card', '2025-08-16', '2025-08-20'),
(17, 'Mouse', 4, 800.00, 'Delivered', 'UPI', '2025-08-17', '2025-08-21'),
(18, 'Monitor', 1, 20000.00, 'Delivered', 'Credit Card', '2025-08-18', '2025-08-23'),
(19, 'Router', 2, 4000.00, 'Shipped', 'UPI', '2025-08-19', '2025-08-24'),
(20, 'Power Bank', 3, 1500.00, 'Delivered', 'COD', '2025-08-20', '2025-08-25');

-- 1. 
drop table orders;
 
-- 2. 
select * from orders;

-- 3. 
Truncate table orders;

-- ------------------------------ 3 PRODUCTS---------------------------------------------  

CREATE TABLE Products (
    product_id int primary key,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category_id INT NOT NULL,
    brand VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    stock INT NOT NULL CHECK(stock >= 0),
    rating DECIMAL(3,2) DEFAULT 0.0,
    status ENUM('Available','Out of Stock','Discontinued') DEFAULT 'Available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table products;

-- Insert 20 Records
INSERT INTO Products (product_id, name, description, category_id, brand, price, stock, rating, status) VALUES
(1,'iPhone 14','Apple smartphone with A15 chip',201,'Apple',79999.00,50,4.8,'Available'),
(2,'Samsung Galaxy S23','Latest Samsung flagship',201,'Samsung',74999.00,40,4.6,'Available'),
(3,'OnePlus 11','Premium OnePlus smartphone',201,'OnePlus',59999.00,30,4.5,'Available'),
(4,'Dell Inspiron 15','15-inch laptop with Intel i5',202,'Dell',55000.00,25,4.3,'Available'),
(5,'HP Pavilion x360','Convertible laptop',202,'HP',62000.00,20,4.2,'Available'),
(6,'Sony WH-1000XM4','Noise-cancelling headphones',203,'Sony',25000.00,100,4.7,'Available'),
(7,'Boat Airdopes 141','True wireless earbuds',203,'Boat',1999.00,200,4.1,'Available'),
(8,'Apple Watch Series 8','Smartwatch with health features',204,'Apple',45000.00,60,4.6,'Available'),
(9,'Samsung Galaxy Watch 5','Premium smartwatch',204,'Samsung',30000.00,55,4.4,'Available'),
(10,'Mi Band 7','Affordable fitness tracker',204,'Xiaomi',2999.00,120,4.0,'Available'),
(11,'Canon EOS 1500D','DSLR Camera 24.1 MP',205,'Canon',38000.00,15,4.5,'Available'),
(12,'Nikon D5600','DSLR Camera with 18-55mm lens',205,'Nikon',42000.00,10,4.6,'Available'),
(13,'LG 55-inch 4K TV','Smart TV with HDR',206,'LG',60000.00,12,4.4,'Available'),
(14,'Samsung QLED 55','55-inch QLED Smart TV',206,'Samsung',75000.00,8,4.7,'Available'),
(15,'Whirlpool Refrigerator','Double door 340L',207,'Whirlpool',30000.00,18,4.3,'Available'),
(16,'LG Washing Machine','Fully automatic front load',207,'LG',28000.00,20,4.2,'Available'),
(17,'Prestige Mixer Grinder','750W powerful motor',208,'Prestige',5500.00,70,4.1,'Available'),
(18,'Philips Air Fryer','Rapid air technology',208,'Philips',12000.00,30,4.4,'Available'),
(19,'Lenovo Legion 5','Gaming laptop RTX 3050',202,'Lenovo',85000.00,15,4.6,'Available'),
(20,'Asus ROG Strix','High-end gaming laptop',202,'Asus',120000.00,10,4.8,'Available');


DROP TABLE Products;

SELECT * FROM Products;

truncate table products;

-- ----------------------------------------- CATEGORIES 4. -------------------------------------
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    parent_category_id INT DEFAULT NULL,
    status ENUM('Active','Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    slug VARCHAR(100) NOT NULL UNIQUE,
    image_url VARCHAR(255),
    display_order INT DEFAULT 0,
    is_featured BOOLEAN ,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id)
);
 DROP TABLE CATEGORIES;
-- Insert 20 Records
INSERT INTO Categories (category_name, description, parent_category_id, status, slug, image_url, display_order, is_featured) VALUES
('Mobiles','Smartphones of all brands',NULL,'Active','mobiles','/images/mobiles.jpg',1,TRUE),
('Laptops','All types of laptops',NULL,'Active','laptops','/images/laptops.jpg',2,TRUE),
('Headphones','Headphones and Earbuds',NULL,'Active','headphones','/images/headphones.jpg',3,FALSE),
('Watches','Smartwatches and Fitness Bands',NULL,'Active','watches','/images/watches.jpg',4,FALSE),
('Cameras','DSLR and Digital Cameras',NULL,'Active','cameras','/images/cameras.jpg',5,FALSE),
('Televisions','LED, QLED, OLED TVs',NULL,'Active','tvs','/images/tvs.jpg',6,TRUE),
('Home Appliances','Fridge, Washing Machines',NULL,'Active','appliances','/images/appliances.jpg',7,TRUE),
('Kitchen Appliances','Mixers, Air Fryers',7,'Active','kitchen-appliances','/images/kitchen.jpg',8,FALSE),
('Gaming','Consoles and Gaming Accessories',NULL,'Active','gaming','/images/gaming.jpg',9,TRUE),
('Fashion','Clothes and Accessories',NULL,'Active','fashion','/images/fashion.jpg',10,TRUE),
('Shoes','Casual & Formal Shoes',10,'Active','shoes','/images/shoes.jpg',11,FALSE),
('Beauty','Makeup & Grooming',NULL,'Active','beauty','/images/beauty.jpg',12,FALSE),
('Books','Educational & Novels',NULL,'Active','books','/images/books.jpg',13,FALSE),
('Sports','Sports Equipment',NULL,'Active','sports','/images/sports.jpg',14,FALSE),
('Furniture','Home & Office Furniture',NULL,'Active','furniture','/images/furniture.jpg',15,FALSE),
('Toys','Kids Toys and Games',NULL,'Active','toys','/images/toys.jpg',16,FALSE),
('Jewelry','Gold, Silver, Artificial Jewelry',10,'Active','jewelry','/images/jewelry.jpg',17,FALSE),
('Baby Products','Baby care items',NULL,'Active','baby-products','/images/baby.jpg',18,FALSE),
('Groceries','Daily groceries & essentials',NULL,'Active','groceries','/images/groceries.jpg',19,TRUE),
('Stationery','Office & School supplies',NULL,'Active','stationery','/images/stationery.jpg',20,FALSE);


DROP TABLE Categories;

SELECT * FROM Categories;

TRUNCATE TABLE Categories;

-- ========================= 5) Cart Table ==============================

CREATE TABLE Cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK(quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK(price >= 0),
    total DECIMAL(12,2) GENERATED ALWAYS AS (quantity * price) STORED,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('Active','Saved','Ordered') DEFAULT 'Active',
    session_id VARCHAR(100),
    coupon_code VARCHAR(50)
);

-- Insert 20 Records
INSERT INTO Cart (user_id, product_id, quantity, price, status, session_id, coupon_code) VALUES
(1, 1, 2, 119998.00, 'Active', 'sess_001', 'NEW100'),
(2, 5, 1, 15999.00, 'Ordered', 'sess_002', 'DISC200'),
(3, 3, 3, 8997.00, 'Saved', 'sess_003', 'SALE500'),
(4, 2, 1, 19999.00, 'Active', 'sess_004', NULL),
(5, 10, 2, 1998.00, 'Ordered', 'sess_005', 'DISC20'),
(6, 7, 1, 1999.00, 'Saved', 'sess_006', NULL),
(7, 4, 1, 4999.00, 'Active', 'sess_007', 'NEW100'),
(8, 6, 1, 45999.00, 'Active', 'sess_008', NULL),
(9, 8, 2, 17998.00, 'Saved', 'sess_009', 'SALE200'),
(10, 9, 1, 2499.00, 'Active', 'sess_010', NULL),
(11, 11, 1, 3999.00, 'Ordered', 'sess_011', 'DISC100'),
(12, 12, 2, 2998.00, 'Active', 'sess_012', NULL),
(13, 13, 1, 5499.00, 'Active', 'sess_013', 'NEW100'),
(14, 14, 5, 3995.00, 'Saved', 'sess_014', NULL),
(15, 15, 1, 8999.00, 'Active', 'sess_015', NULL),
(16, 16, 1, 12999.00, 'Ordered', 'sess_016', 'DISC300'),
(17, 17, 1, 15999.00, 'Active', 'sess_017', NULL),
(18, 18, 1, 24999.00, 'Saved', 'sess_018', NULL),
(19, 19, 1, 7499.00, 'Active', 'sess_019', 'SALE100'),
(20, 20, 1, 19999.00, 'Active', 'sess_020', NULL);


DROP TABLE Cart;

SELECT * FROM Cart;

TRUNCATE TABLE Cart;

-- ========================= 6) Payments Table ==============================

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL CHECK(amount >= 0),
    payment_date DATE NOT NULL,
    payment_method ENUM('Credit Card','Debit Card','Net Banking','UPI','Wallet','COD') NOT NULL,
    status ENUM('Success','Pending','Failed','Refunded') DEFAULT 'Pending',
    transaction_id VARCHAR(50) UNIQUE,
    currency VARCHAR(10) DEFAULT 'INR',
    remarks VARCHAR(255)

    
);



-- Insert 20 Records
INSERT INTO Payments (order_id, user_id, amount, payment_date, payment_method, status, transaction_id, currency, REMARKS) VALUES
(1, 1, 1599.00, '2025-08-01', 'UPI', 'Success', 'TXN10001', 'INR', 'Paid via UPI'),
(2, 2, 2999.00, '2025-08-01', 'Credit Card', 'Success', 'TXN10002', 'INR', 'Credit Card EMI'),
(3, 3, 499.00, '2025-08-02', 'Wallet', 'Pending', 'TXN10003', 'INR', 'Wallet low balance'),
(4, 4, 899.00, '2025-08-02', 'COD', 'Pending', 'TXN10004', 'INR', 'Cash on delivery'),
(5, 5, 1299.00, '2025-08-03', 'Debit Card', 'Failed', 'TXN10005', 'INR', 'Insufficient funds'),
(6, 6, 2499.00, '2025-08-03', 'UPI', 'Success', 'TXN10006', 'INR', 'UPI Payment done'),
(7, 7, 999.00, '2025-08-04', 'Net Banking', 'Success', 'TXN10007', 'INR', 'NetBank Transfer'),
(8, 8, 499.00, '2025-08-04', 'Wallet', 'Success', 'TXN10008', 'INR', 'Wallet Cashback used'),
(9, 9, 5999.00, '2025-08-05', 'Credit Card', 'Success', 'TXN10009', 'INR', 'OneShot Payment'),
(10, 10, 799.00, '2025-08-05', 'UPI', 'Refunded', 'TXN10010', 'INR', 'Order cancelled'),
(11, 11, 2599.00, '2025-08-06', 'Debit Card', 'Success', 'TXN10011', 'INR', 'Debit Card OTP success'),
(12, 12, 199.00, '2025-08-06', 'UPI', 'Success', 'TXN10012', 'INR', 'Small purchase'),
(13, 13, 1599.00, '2025-08-07', 'Wallet', 'Success', 'TXN10013', 'INR', 'AmazonPay Wallet'),
(14, 14, 499.00, '2025-08-07', 'Net Banking', 'Pending', 'TXN10014', 'INR', 'Bank server delay'),
(15, 15, 1899.00, '2025-08-08', 'UPI', 'Success', 'TXN10015', 'INR', 'Google Pay UPI'),
(16, 16, 249.00, '2025-08-08', 'Credit Card', 'Failed', 'TXN10016', 'INR', 'Wrong CVV'),
(17, 17, 3499.00, '2025-08-09', 'UPI', 'Success', 'TXN10017', 'INR', 'PhonePe UPI'),
(18, 18, 1499.00, '2025-08-09', 'Debit Card', 'Success', 'TXN10018', 'INR', 'VISA debit'),
(19, 19, 1999.00, '2025-08-10', 'Wallet', 'Refunded', 'TXN10019', 'INR', 'Refund processed'),
(20, 20, 2999.00, '2025-08-10', 'UPI', 'Success', 'TXN10020', 'INR', 'Amazon UPI Payment');


DROP TABLE Payments;

SELECT * FROM Payments;

TRUNCATE TABLE Payments;

 -- ========================= 7) Shipments Table ==============================

CREATE TABLE Shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    courier_name VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(50) UNIQUE,
    shipment_date DATE NOT NULL,
    delivery_date DATE,
    status ENUM('Pending','In Transit','Delivered','Returned','Cancelled') DEFAULT 'Pending',
    shipping_address TEXT NOT NULL,
    shipping_cost DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert 20 Records
INSERT INTO Shipments (order_id, user_id, courier_name, tracking_number, shipment_date, delivery_date, status, shipping_address, shipping_cost) VALUES
(1, 1, 'BlueDart', 'TRK10001', '2025-08-01', '2025-08-05', 'Delivered', 'Pune, Maharashtra', 100.00),
(2, 2, 'DTDC', 'TRK10002', '2025-08-02', '2025-08-07', 'Delivered', 'Mumbai, Maharashtra', 120.00),
(3, 3, 'FedEx', 'TRK10003', '2025-08-03', NULL, 'In Transit', 'Delhi, NCR', 150.00),
(4, 4, 'Delhivery', 'TRK10004', '2025-08-04', '2025-08-10', 'Delivered', 'Bangalore, Karnataka', 90.00),
(5, 5, 'EcomExpress', 'TRK10005', '2025-08-05', NULL, 'In Transit', 'Hyderabad, Telangana', 110.00),
(6, 6, 'BlueDart', 'TRK10006', '2025-08-06', NULL, 'Pending', 'Chennai, Tamil Nadu', 80.00),
(7, 7, 'DTDC', 'TRK10007', '2025-08-07', '2025-08-12', 'Delivered', 'Kolkata, West Bengal', 130.00),
(8, 8, 'FedEx', 'TRK10008', '2025-08-08', NULL, 'In Transit', 'Jaipur, Rajasthan', 140.00),
(9, 9, 'Delhivery', 'TRK10009', '2025-08-09', NULL, 'Pending', 'Lucknow, UP', 100.00),
(10, 10, 'EcomExpress', 'TRK10010', '2025-08-10', NULL, 'Pending', 'Bhopal, MP', 95.00),
(11, 11, 'BlueDart', 'TRK10011', '2025-08-11', '2025-08-16', 'Delivered', 'Nagpur, Maharashtra', 115.00),
(12, 12, 'DTDC', 'TRK10012', '2025-08-12', NULL, 'In Transit', 'Patna, Bihar', 125.00),
(13, 13, 'FedEx', 'TRK10013', '2025-08-13', '2025-08-18', 'Delivered', 'Indore, MP', 135.00),
(14, 14, 'Delhivery', 'TRK10014', '2025-08-14', NULL, 'Returned', 'Surat, Gujarat', 85.00),
(15, 15, 'EcomExpress', 'TRK10015', '2025-08-15', NULL, 'Pending', 'Chandigarh', 105.00),
(16, 16, 'BlueDart', 'TRK10016', '2025-08-16', NULL, 'Cancelled', 'Ahmedabad, Gujarat', 120.00),
(17, 17, 'DTDC', 'TRK10017', '2025-08-17', NULL, 'Pending', 'Coimbatore, Tamil Nadu', 100.00),
(18, 18, 'FedEx', 'TRK10018', '2025-08-18', NULL, 'In Transit', 'Visakhapatnam, AP', 145.00),
(19, 19, 'Delhivery', 'TRK10019', '2025-08-19', NULL, 'Pending', 'Guwahati, Assam', 160.00),
(20, 20, 'EcomExpress', 'TRK10020', '2025-08-20', '2025-08-25', 'Delivered', 'Ranchi, Jharkhand', 90.00);

-- Drop table
DROP TABLE Shipments;

-- Show all shipments
SELECT * FROM Shipments;

-- Truncate table 
TRUNCATE TABLE Shipments;

-- ---------------------------------- 8 Delivery_Address Table ------------------------------------------ 

CREATE TABLE Delivery_Address (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    country VARCHAR(100) DEFAULT 'India',
    address_type ENUM('Home','Office','Other') DEFAULT 'Home',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert 20 Records
INSERT INTO Delivery_Address (user_id, recipient_name, phone_number, street_address, city, state, postal_code, country, address_type) VALUES
(1, 'Amit Sharma', '9876543210', '12 MG Road', 'Pune', 'Maharashtra', '411001', 'India', 'Home'),
(2, 'Priya Mehta', '9123456789', '45 Park Street', 'Mumbai', 'Maharashtra', '400001', 'India', 'Office'),
(3, 'Rohit Verma', '9988776655', '78 Green Avenue', 'Delhi', 'Delhi', '110001', 'India', 'Home'),
(4, 'Sneha Patil', '9876501234', '22 Lake View', 'Nagpur', 'Maharashtra', '440001', 'India', 'Home'),
(5, 'Arjun Singh', '9090909090', '9 Civil Lines', 'Lucknow', 'Uttar Pradesh', '226001', 'India', 'Office'),
(6, 'Neha Gupta', '9898989898', '3 Neelkanth Tower', 'Indore', 'Madhya Pradesh', '452001', 'India', 'Other'),
(7, 'Vikram Rao', '9765432109', '55 Hill Road', 'Hyderabad', 'Telangana', '500001', 'India', 'Home'),
(8, 'Kavita Joshi', '9123459876', '77 Sunrise Complex', 'Ahmedabad', 'Gujarat', '380001', 'India', 'Home'),
(9, 'Manish Tiwari', '9823456789', '89 Garden Lane', 'Bhopal', 'Madhya Pradesh', '462001', 'India', 'Office'),
(10, 'Ritu Sharma', '9123987654', '14 White House', 'Chennai', 'Tamil Nadu', '600001', 'India', 'Home'),
(11, 'Suresh Kumar', '9871234567', '88 Blue Towers', 'Kolkata', 'West Bengal', '700001', 'India', 'Home'),
(12, 'Pooja Yadav', '9786543210', '33 Silver Park', 'Jaipur', 'Rajasthan', '302001', 'India', 'Office'),
(13, 'Ankit Jain', '9654321876', '19 Pearl Residency', 'Bangalore', 'Karnataka', '560001', 'India', 'Home'),
(14, 'Shweta Nair', '9765412345', '65 Ocean View', 'Kochi', 'Kerala', '682001', 'India', 'Home'),
(15, 'Ramesh Sharma', '9543218765', '7 Rose Villa', 'Patna', 'Bihar', '800001', 'India', 'Other'),
(16, 'Divya Singh', '9789012345', '29 Lotus Apartments', 'Kanpur', 'Uttar Pradesh', '208001', 'India', 'Home'),
(17, 'Karan Kapoor', '9654321987', '40 River View', 'Chandigarh', 'Chandigarh', '160001', 'India', 'Office'),
(18, 'Meena Iyer', '9123567890', '99 Sunflower Tower', 'Thane', 'Maharashtra', '400604', 'India', 'Home'),
(19, 'Rajesh Patel', '9876509876', '12 Horizon Plaza', 'Surat', 'Gujarat', '395001', 'India', 'Home'),
(20, 'Sonali Chawla', '9765432890', '48 Green Park', 'Noida', 'Uttar Pradesh', '201301', 'India', 'Office');


DROP TABLE Delivery_Address;

-- Show all addresses
SELECT * FROM Delivery_Address;

TRUNCATE TABLE Delivery_Address;

-- --------------------------------  9 Cities Table ----------------------------

CREATE TABLE Cities (
    city_id INT PRIMARY KEY AUTO_INCREMENT,
    city_name VARCHAR(100) NOT NULL UNIQUE,
    state_name VARCHAR(100) NOT NULL,
    country_name VARCHAR(100) DEFAULT 'India',
    postal_code_prefix VARCHAR(10),
    population INT CHECK (population >= 0),
    is_metro BOOLEAN DEFAULT FALSE,
    timezone VARCHAR(50) DEFAULT 'IST',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert 20 Records
INSERT INTO Cities (city_name, state_name, country_name, postal_code_prefix, population, is_metro, timezone) VALUES
('Mumbai', 'Maharashtra', 'India', '400', 20000000, TRUE, 'IST'),
('Delhi', 'Delhi', 'India', '110', 18000000, TRUE, 'IST'),
('Bengaluru', 'Karnataka', 'India', '560', 12000000, TRUE, 'IST'),
('Hyderabad', 'Telangana', 'India', '500', 10000000, TRUE, 'IST'),
('Chennai', 'Tamil Nadu', 'India', '600', 9500000, TRUE, 'IST'),
('Kolkata', 'West Bengal', 'India', '700', 15000000, TRUE, 'IST'),
('Pune', 'Maharashtra', 'India', '411', 7000000, TRUE, 'IST'),
('Ahmedabad', 'Gujarat', 'India', '380', 6500000, TRUE, 'IST'),
('Jaipur', 'Rajasthan', 'India', '302', 3500000, FALSE, 'IST'),
('Lucknow', 'Uttar Pradesh', 'India', '226', 3100000, FALSE, 'IST'),
('Kanpur', 'Uttar Pradesh', 'India', '208', 3000000, FALSE, 'IST'),
('Nagpur', 'Maharashtra', 'India', '440', 2400000, FALSE, 'IST'),
('Indore', 'Madhya Pradesh', 'India', '452', 2500000, FALSE, 'IST'),
('Bhopal', 'Madhya Pradesh', 'India', '462', 2300000, FALSE, 'IST'),
('Thane', 'Maharashtra', 'India', '400', 2000000, TRUE, 'IST'),
('Surat', 'Gujarat', 'India', '395', 6000000, TRUE, 'IST'),
('Noida', 'Uttar Pradesh', 'India', '201', 1800000, FALSE, 'IST'),
('Gurgaon', 'Haryana', 'India', '122', 1600000, FALSE, 'IST'),
('Chandigarh', 'Chandigarh', 'India', '160', 1200000, FALSE, 'IST'),
('Patna', 'Bihar', 'India', '800', 2200000, FALSE, 'IST');


DROP TABLE Cities;

-- Show all cities
SELECT * FROM Cities;

TRUNCATE TABLE Cities;

-- ------------------------------------ 10 SELLERS ------------------------------------------------
CREATE TABLE Sellers (
    seller_id INT PRIMARY KEY AUTO_INCREMENT,
    seller_name VARCHAR(150) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    gst_number VARCHAR(20) UNIQUE NOT NULL,
    pan_number VARCHAR(15) UNIQUE NOT NULL,
    address VARCHAR(255) NOT NULL,
    city_id INT NOT NULL,
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    join_date DATE DEFAULT (CURRENT_DATE),
    status ENUM('Active','Inactive','Suspended') DEFAULT 'Active',

    CONSTRAINT fk_seller_city FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

-- Insert 20 Records
INSERT INTO Sellers (seller_name, email, phone, gst_number, pan_number, address, city_id, rating, status) VALUES
('TechMart Pvt Ltd', 'contact@techmart.com', '9876543210', 'GSTIN12345', 'PAN1234A', 'Andheri, Mumbai', 1, 4.5, 'Active'),
('HomeNeeds Ltd', 'sales@homeneeds.com', '9876543211', 'GSTIN12346', 'PAN1234B', 'Connaught Place, Delhi', 2, 4.2, 'Active'),
('FashionHub', 'support@fashionhub.com', '9876543212', 'GSTIN12347', 'PAN1234C', 'Koramangala, Bengaluru', 3, 3.8, 'Active'),
('KitchenWorld', 'help@kitchenworld.com', '9876543213', 'GSTIN12348', 'PAN1234D', 'Banjara Hills, Hyderabad', 4, 4.0, 'Active'),
('TrendyStore', 'info@trendystore.com', '9876543214', 'GSTIN12349', 'PAN1234E', 'T Nagar, Chennai', 5, 3.9, 'Active'),
('BookPlanet', 'hello@bookplanet.com', '9876543215', 'GSTIN12350', 'PAN1234F', 'Park Street, Kolkata', 6, 4.7, 'Active'),
('FreshMart', 'orders@freshmart.com', '9876543216', 'GSTIN12351', 'PAN1234G', 'Shivaji Nagar, Pune', 7, 4.1, 'Active'),
('GadgetPoint', 'help@gadgetpoint.com', '9876543217', 'GSTIN12352', 'PAN1234H', 'CG Road, Ahmedabad', 8, 4.6, 'Active'),
('RoyalDecor', 'royal@decor.com', '9876543218', 'GSTIN12353', 'PAN1234I', 'MI Road, Jaipur', 9, 3.5, 'Inactive'),
('UrbanWear', 'urban@wear.com', '9876543219', 'GSTIN12354', 'PAN1234J', 'Hazratganj, Lucknow', 10, 4.0, 'Active'),
('MegaElectro', 'sales@megaelectro.com', '9876543220', 'GSTIN12355', 'PAN1234K', 'Mall Road, Kanpur', 11, 4.3, 'Active'),
('AutoParts Ltd', 'auto@parts.com', '9876543221', 'GSTIN12356', 'PAN1234L', 'Sitabuldi, Nagpur', 12, 3.6, 'Suspended'),
('SmartHome', 'support@smarthome.com', '9876543222', 'GSTIN12357', 'PAN1234M', 'Vijay Nagar, Indore', 13, 4.4, 'Active'),
('DailyNeeds', 'daily@needs.com', '9876543223', 'GSTIN12358', 'PAN1234N', 'MP Nagar, Bhopal', 14, 3.9, 'Active'),
('GameZone', 'help@gamezone.com', '9876543224', 'GSTIN12359', 'PAN1234O', 'Thane West, Thane', 15, 4.8, 'Active'),
('DiamondJewels', 'contact@diamondjewels.com', '9876543225', 'GSTIN12360', 'PAN1234P', 'Ring Road, Surat', 16, 4.6, 'Active'),
('StylePoint', 'style@point.com', '9876543226', 'GSTIN12361', 'PAN1234Q', 'Sector 18, Noida', 17, 3.7, 'Active'),
('ElectroWorld', 'sales@electroworld.com', '9876543227', 'GSTIN12362', 'PAN1234R', 'Cyber City, Gurgaon', 18, 4.2, 'Active'),
('HandicraftBazaar', 'info@handicraftbazaar.com', '9876543228', 'GSTIN12363', 'PAN1234S', 'Sector 17, Chandigarh', 19, 3.8, 'Inactive'),
('BiharMart', 'contact@biharmart.com', '9876543229', 'GSTIN12364', 'PAN1234T', 'Fraser Road, Patna', 20, 3.9, 'Active');


DROP TABLE Sellers;

-- Show all sellers
SELECT * FROM Sellers;

TRUNCATE TABLE Sellers;

-- ----------------------------------------- 11 INVENTORY---------------------------------------------------

CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    seller_id INT NOT NULL,
    stock_quantity INT NOT NULL CHECK(stock_quantity >= 0),
    reserved_quantity INT DEFAULT 0 CHECK(reserved_quantity >= 0),
    warehouse_location VARCHAR(150) NOT NULL,
    restock_date DATE,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('In Stock','Low Stock','Out of Stock') DEFAULT 'In Stock',
    reorder_level INT DEFAULT 10 CHECK(reorder_level >= 0),

    CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES Products(product_id),
    CONSTRAINT fk_inventory_seller FOREIGN KEY (seller_id) REFERENCES Sellers(seller_id)
);

-- Insert 20 Records
INSERT INTO Inventory (product_id, seller_id, stock_quantity, reserved_quantity, warehouse_location, restock_date, status, reorder_level) VALUES
(1, 1, 50, 5, 'Mumbai Warehouse A', '2025-08-20', 'In Stock', 10),
(2, 2, 10, 2, 'Delhi Warehouse B', '2025-08-22', 'Low Stock', 5),
(3, 3, 0, 0, 'Bengaluru Warehouse C', '2025-08-25', 'Out of Stock', 15),
(4, 4, 200, 20, 'Hyderabad Warehouse D', '2025-08-18', 'In Stock', 30),
(5, 5, 15, 1, 'Chennai Warehouse E', '2025-08-21', 'Low Stock', 5),
(6, 6, 120, 10, 'Kolkata Warehouse F', '2025-08-23', 'In Stock', 20),
(7, 7, 60, 5, 'Pune Warehouse G', '2025-08-19', 'In Stock', 15),
(8, 8, 5, 0, 'Ahmedabad Warehouse H', '2025-08-27', 'Low Stock', 3),
(9, 9, 0, 0, 'Jaipur Warehouse I', '2025-08-30', 'Out of Stock', 8),
(10, 10, 90, 10, 'Lucknow Warehouse J', '2025-08-24', 'In Stock', 20),
(11, 11, 40, 3, 'Kanpur Warehouse K', '2025-08-26', 'In Stock', 10),
(12, 12, 0, 0, 'Nagpur Warehouse L', '2025-08-29', 'Out of Stock', 12),
(13, 13, 25, 5, 'Indore Warehouse M', '2025-08-28', 'Low Stock', 7),
(14, 14, 70, 4, 'Bhopal Warehouse N', '2025-08-22', 'In Stock', 18),
(15, 15, 150, 15, 'Thane Warehouse O', '2025-08-19', 'In Stock', 25),
(16, 16, 0, 0, 'Surat Warehouse P', '2025-08-30', 'Out of Stock', 20),
(17, 17, 8, 1, 'Noida Warehouse Q', '2025-08-21', 'Low Stock', 4),
(18, 18, 95, 8, 'Gurgaon Warehouse R', '2025-08-20', 'In Stock', 22),
(19, 19, 50, 5, 'Chandigarh Warehouse S', '2025-08-25', 'In Stock', 12),
(20, 20, 3, 0, 'Patna Warehouse T', '2025-08-23', 'Low Stock', 5);


DROP TABLE Inventory;

-- Show all inventory
SELECT * FROM Inventory;

TRUNCATE TABLE Inventory;


-- ------------------------------------- 12 Cart_Items Table------------------------------------ 

CREATE TABLE Cart_Items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    discount DECIMAL(5,2) DEFAULT 0 CHECK (discount >= 0),
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status ENUM('Active','Removed','Saved for Later') DEFAULT 'Active'
    
);


INSERT INTO Cart_Items (cart_id, product_id, quantity, price, discount, status) VALUES
(1, 1, 2, 499.99, 10.00, 'Active'),
(1, 3, 1, 1299.00, 5.00, 'Active'),
(2, 2, 1, 799.00, 0.00, 'Active'),
(2, 5, 3, 299.00, 15.00, 'Saved for Later'),
(3, 4, 1, 1599.00, 20.00, 'Active'),
(3, 6, 2, 199.00, 5.00, 'Active'),
(4, 7, 4, 99.00, 0.00, 'Removed'),
(4, 8, 1, 899.00, 10.00, 'Active'),
(5, 9, 2, 699.00, 5.00, 'Active'),
(5, 10, 1, 1499.00, 0.00, 'Saved for Later'),
(6, 11, 3, 249.00, 0.00, 'Active'),
(6, 12, 1, 349.00, 10.00, 'Active'),
(7, 13, 2, 599.00, 0.00, 'Active'),
(7, 14, 1, 999.00, 15.00, 'Active'),
(8, 15, 1, 129.00, 0.00, 'Removed'),
(8, 16, 2, 79.00, 5.00, 'Active'),
(9, 17, 1, 1999.00, 10.00, 'Saved for Later'),
(9, 18, 1, 2999.00, 20.00, 'Active'),
(10, 19, 2, 459.00, 0.00, 'Active'),
(10, 20, 1, 259.00, 0.00, 'Active');


DROP TABLE Cart_Items;

SELECT * FROM Cart_Items;

TRUNCATE TABLE Cart_Items;


-- ------------------------------- 13 Reviews-------------------------------------------------------------------------- 
-- 13 REVIEWS TABLE
CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    order_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text VARCHAR(500) NOT NULL,
    review_date DATE NOT NULL,
    is_verified BOOLEAN DEFAULT TRUE,
    helpful_votes INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

INSERT INTO Reviews (user_id, product_id, order_id, rating, review_text, review_date, is_verified, helpful_votes, status)
VALUES
(1, 101, 5001, 5, 'Excellent quality, worth the price!', '2024-01-05', TRUE, 12, 'Active'),
(2, 102, 5002, 4, 'Good phone, battery backup could be better.', '2024-01-08', TRUE, 5, 'Active'),
(3, 103, 5003, 3, 'Average earphones, sound quality is decent.', '2024-01-10', TRUE, 3, 'Active'),
(4, 104, 5004, 5, 'Loved the kurta design, fabric is soft.', '2024-01-12', TRUE, 8, 'Active'),
(5, 105, 5005, 2, 'Delivery was late, not happy.', '2024-01-15', TRUE, 2, 'Inactive'),
(6, 106, 5006, 4, 'Mixer grinder works fine, useful for daily cooking.', '2024-01-18', TRUE, 6, 'Active'),
(7, 107, 5007, 5, 'Cricket bat is strong and lightweight, perfect for practice.', '2024-01-20', TRUE, 10, 'Active'),
(8, 108, 5008, 3, 'Shoes are stylish but not very comfortable.', '2024-01-21', TRUE, 4, 'Active'),
(9, 109, 5009, 4, 'Mobile cover is durable and fits perfectly.', '2024-01-23', TRUE, 7, 'Active'),
(10, 110, 5010, 5, 'Laptop bag is spacious and good quality.', '2024-01-25', TRUE, 9, 'Active'),
(11, 111, 5011, 1, 'Very poor quality t-shirt, faded after one wash.', '2024-01-26', TRUE, 1, 'Inactive'),
(12, 112, 5012, 4, 'Water bottle keeps water cool, nice design.', '2024-01-28', TRUE, 5, 'Active'),
(13, 113, 5013, 5, 'Headphones have amazing bass, value for money.', '2024-01-30', TRUE, 15, 'Active'),
(14, 114, 5014, 3, 'Book print is small, but content is good.', '2024-02-01', TRUE, 2, 'Active'),
(15, 115, 5015, 5, 'Fan is powerful and runs silently, great purchase.', '2024-02-02', TRUE, 6, 'Active'),
(16, 116, 5016, 4, 'Smartwatch is accurate but strap quality average.', '2024-02-04', TRUE, 8, 'Active'),
(17, 117, 5017, 2, 'Power bank does not charge properly.', '2024-02-05', TRUE, 3, 'Inactive'),
(18, 118, 5018, 5, 'Saree is beautiful, same as shown in picture.', '2024-02-06', TRUE, 11, 'Active'),
(19, 119, 5019, 4, 'TV remote works fine, delivery was quick.', '2024-02-07', TRUE, 5, 'Active'),
(20, 120, 5020, 5, 'Washing machine cover fits perfectly, satisfied.', '2024-02-08', TRUE, 7, 'Active');


-- Select all reviews
SELECT * FROM Reviews;

DROP TABLE Reviews;

TRUNCATE TABLE Reviews;


-- ------------------------------- 14 RATINGS -------------------------------------------------------------------------- 
-- 14 RATINGS TABLE
CREATE TABLE Ratings (
    rating_id INT PRIMARY KEY, 
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    stars INT NOT NULL CHECK (stars BETWEEN 1 AND 5),
    rating_date DATE NOT NULL,
    review_id INT,
    status VARCHAR(20) DEFAULT 'Active',
    UNIQUE(user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id),
    FOREIGN KEY (review_id) REFERENCES Reviews(review_id)
);

-- -------------------------------- INSERT 20 RECORDS ------------------------------------------------------------------

INSERT INTO Ratings (rating_id, user_id, product_id, stars, rating_date, review_id, status) VALUES
(11, 1, 101, 5, '2024-01-10', 1, 'Active'),
(12, 2, 102, 4, '2024-01-12', 2, 'Active'),
(13, 3, 103, 3, '2024-01-14', 3, 'Active'),
(14,4, 104, 5, '2024-01-16', 4, 'Active'),
(15, 5, 105, 4, '2024-01-18', 5, 'Active'),
(16, 6, 101, 2, '2024-01-20', 6, 'Inactive'),
(17, 7, 102, 5, '2024-01-22', 7, 'Active'),
(18, 8, 103, 3, '2024-01-24', 8, 'Active'),
(19,9, 104, 4, '2024-01-26', 9, 'Inactive'),
(20, 10, 105, 5, '2024-01-28', 10, 'Active'),
(21, 11, 101, 4, '2024-01-30', 11, 'Active'),
(22, 12, 102, 5, '2024-02-01', 12, 'Active'),
(23, 13, 103, 3, '2024-02-03', 13, 'Active'),
(24, 14, 104, 2, '2024-02-05', 14, 'Inactive'),
(25, 15, 105, 5, '2024-02-07', 15, 'Active'),
(26, 16, 101, 4, '2024-02-09', 16, 'Active'),
(27, 17, 102, 3, '2024-02-11', 17, 'Active'),
(28, 18, 103, 5, '2024-02-13', 18, 'Active'),
(29, 19, 104, 4, '2024-02-15', 19, 'Active'),
(30, 20, 105, 5, '2024-02-17', 20, 'Active');

DROP TABLE RATINGS; 

SELECT * FROM Ratings;

TRUNCATE TABLE RATINGS; 


-- ------------------------------- 15 WISHLIST TABLE ----------------------------------

-- Create Wishlist Table
CREATE TABLE Wishlist (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    date_added DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- Insert 20 Records
INSERT INTO Wishlist (user_id, product_id, date_added, status) VALUES
(1, 101, '2024-01-05', 'Active'),
(2, 102, '2024-01-06', 'Active'),
(3, 103, '2024-01-07', 'Active'),
(4, 104, '2024-01-08', 'Inactive'),
(5, 105, '2024-01-09', 'Active'),
(6, 106, '2024-01-10', 'Active'),
(7, 107, '2024-01-11', 'Active'),
(8, 108, '2024-01-12', 'Inactive'),
(9, 109, '2024-01-13', 'Active'),
(10, 110, '2024-01-14', 'Active'),
(11, 111, '2024-01-15', 'Inactive'),
(12, 112, '2024-01-16', 'Active'),
(13, 113, '2024-01-17', 'Active'),
(14, 114, '2024-01-18', 'Active'),
(15, 115, '2024-01-19', 'Inactive'),
(16, 116, '2024-01-20', 'Active'),
(17, 117, '2024-01-21', 'Active'),
(18, 118, '2024-01-22', 'Inactive'),
(19, 119, '2024-01-23', 'Active'),
(20, 120, '2024-01-24', 'Active');

SELECT * FROM Wishlist;
 
TRUNCATE TABLE Wishlist;

DROP TABLE Wishlist;


-- ------------------------------- 16 WISHLIST_ITEMS -------------------------------------------------------------------------- 
-- 16 WISHLIST_ITEMS TABLE
CREATE TABLE wishlist_items (
    wishlist_item_id INT PRIMARY KEY AUTO_INCREMENT,
    wishlist_id INT NOT NULL,
    product_id INT NOT NULL,
    added_date DATE NOT NULL,
    quantity INT DEFAULT 1 CHECK (quantity > 0),
    notes VARCHAR(255),
    FOREIGN KEY (wishlist_id) REFERENCES wishlists(wishlist_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- -------------------------------- INSERT 20 RECORDS ------------------------------------------------------------------

INSERT INTO wishlist_items (wishlist_id, product_id, added_date, quantity, notes) VALUES
(1, 101, '2024-01-06', 1, 'Latest mobile phone'),
(1, 102, '2024-01-07', 2, 'Headphones with bass'),
(2, 201, '2024-01-09', 1, 'New dress for party'),
(2, 202, '2024-01-10', 3, 'Shirts pack'),
(3, 301, '2024-01-12', 2, 'Novel set'),
(3, 302, '2024-01-13', 1, 'Educational book'),
(4, 401, '2024-01-15', 1, 'Microwave oven'),
(4, 402, '2024-01-16', 1, 'Mixer grinder'),
(5, 501, '2024-01-17', 2, 'Cricket bat & ball'),
(6, 601, '2024-01-19', 1, 'Sneakers for running'),
(7, 701, '2024-01-21', 2, 'Gift cards'),
(7, 702, '2024-01-22', 1, 'Jewelry gift set'),
(8, 801, '2024-01-24', 1, 'Cooking pan'),
(9, 901, '2024-01-25', 2, 'Mobile covers'),
(9, 902, '2024-01-26', 1, 'Wireless earphones'),
(10, 1001, '2024-01-28', 1, 'Dell laptop'),
(11, 1101, '2024-01-29', 2, 'Baby toys'),
(12, 1201, '2024-01-30', 1, 'Wooden chair'),
(13, 1301, '2024-02-01', 1, 'Cosmetic kit'),
(14, 1401, '2024-02-02', 2, 'Travel bags');


TRUNCATE TABLE wishlist_items;

SELECT * FROM wishlist_items;

DROP TABLE wishlist_items;

-- ------------------------------- 17 OFFERS -------------------------------------------------------------------------- 
-- 17 OFFERS TABLE
CREATE TABLE offers (
    offer_id INT PRIMARY KEY AUTO_INCREMENT,
    offer_code VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255) NOT NULL,
    discount_percentage DECIMAL(5,2) CHECK (discount_percentage BETWEEN 0 AND 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    min_order_value DECIMAL(10,2) DEFAULT 0.00,
    max_discount_amount DECIMAL(10,2),
    usage_limit INT DEFAULT 1 CHECK (usage_limit >= 1),
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------- INSERT 20 RECORDS ------------------------------------------------------------------

INSERT INTO offers (offer_code, description, discount_percentage, start_date, end_date, min_order_value, max_discount_amount, usage_limit, status)
VALUES
('NEWUSER100', 'Flat 100 off for new users', 10.00, '2024-01-01', '2024-03-31', 500.00, 100.00, 1, 'Active'),
('SUMMER50', '50% off summer sale', 50.00, '2024-04-01', '2024-05-31', 1000.00, 500.00, 3, 'Active'),
('FESTIVE20', '20% discount on festive items', 20.00, '2024-08-15', '2024-08-31', 1500.00, 400.00, 5, 'Active'),
('DIWALI25', '25% off on Diwali special', 25.00, '2024-10-15', '2024-11-15', 2000.00, 1000.00, 3, 'Active'),
('HOLI15', '15% discount on Holi products', 15.00, '2024-03-01', '2024-03-20', 800.00, 300.00, 2, 'Expired'),
('WINTER30', '30% off on winter wear', 30.00, '2024-12-01', '2025-01-15', 1200.00, 600.00, 4, 'Active'),
('FLASH10', 'Flat 10% off flash sale', 10.00, '2024-02-01', '2024-02-02', 500.00, 200.00, 1, 'Expired'),
('ELECTRO40', '40% off on electronics', 40.00, '2024-07-01', '2024-07-15', 3000.00, 1500.00, 2, 'Active'),
('BOOKS5', '5% off on all books', 5.00, '2024-05-01', '2024-12-31', 300.00, 50.00, 10, 'Active'),
('KIDS25', '25% discount on kids items', 25.00, '2024-06-01', '2024-06-30', 1000.00, 500.00, 3, 'Active'),
('SPORTS20', '20% off on sports gear', 20.00, '2024-09-01', '2024-09-30', 1500.00, 800.00, 5, 'Active'),
('FASHION35', '35% off on fashion wear', 35.00, '2024-08-01', '2024-08-20', 2000.00, 1000.00, 2, 'Active'),
('BEAUTY10', '10% off on beauty products', 10.00, '2024-11-01', '2024-11-30', 700.00, 250.00, 5, 'Active'),
('TRAVEL50', '50% discount on travel accessories', 50.00, '2024-12-15', '2025-01-15', 2500.00, 1200.00, 3, 'Active'),
('STUDENT15', '15% off for students', 15.00, '2024-01-10', '2024-12-31', 600.00, 300.00, 8, 'Active'),
('LOYALTY30', '30% off for loyal customers', 30.00, '2024-02-15', '2024-09-15', 1800.00, 700.00, 4, 'Active'),
('FLASH20', '20% off midnight sale', 20.00, '2024-07-20', '2024-07-21', 1000.00, 300.00, 1, 'Expired'),
('FOOD15', '15% discount on groceries', 15.00, '2024-06-01', '2024-12-31', 500.00, 200.00, 6, 'Active'),
('NEWYEAR25', '25% discount for New Year', 25.00, '2024-12-30', '2025-01-05', 2000.00, 1000.00, 2, 'Active'),
('REPUBLIC10', '10% off on Republic Day sale', 10.00, '2024-01-20', '2024-01-26', 1000.00, 400.00, 1, 'Expired');



DROP TABLE offers;

SELECT * FROM offers;

TRUNCATE TABLE offers;

-- ------------------------------- 18 COUPONS -------------------------------------------------------------------------- 
-- 18 COUPONS TABLE
CREATE TABLE coupons (
    coupon_id INT PRIMARY KEY AUTO_INCREMENT,
    coupon_code VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255),
    discount_type VARCHAR(20) CHECK (discount_type IN ('Percentage', 'Flat')),
    discount_value DECIMAL(10,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    min_order_value DECIMAL(10,2) DEFAULT 0.00,
    max_discount_amount DECIMAL(10,2),
    usage_limit INT DEFAULT 1 CHECK (usage_limit >= 1),
    status VARCHAR(20) DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------- INSERT 20 RECORDS ------------------------------------------------------------------

INSERT INTO coupons (coupon_code, description, discount_type, discount_value, start_date, end_date, min_order_value, max_discount_amount, usage_limit, status)
VALUES
('WELCOME100', 'Flat 100 off for new customers', 'Flat', 100.00, '2024-01-01', '2024-03-31', 500.00, 100.00, 1, 'Active'),
('SAVE50', '50% discount on selected items', 'Percentage', 50.00, '2024-04-01', '2024-05-31', 800.00, 500.00, 2, 'Active'),
('SHOP20', '20% discount on all categories', 'Percentage', 20.00, '2024-06-01', '2024-06-30', 1000.00, 400.00, 5, 'Active'),
('DIWALI500', 'Flat 500 off on Diwali shopping', 'Flat', 500.00, '2024-10-15', '2024-11-15', 2000.00, 500.00, 3, 'Active'),
('HOLI15', '15% discount during Holi sale', 'Percentage', 15.00, '2024-03-01', '2024-03-15', 700.00, 300.00, 2, 'Expired'),
('WINTER300', 'Flat 300 off on winter wear', 'Flat', 300.00, '2024-12-01', '2025-01-15', 1500.00, 300.00, 4, 'Active'),
('FLASH10', 'Flat 10% discount flash coupon', 'Percentage', 10.00, '2024-02-01', '2024-02-02', 500.00, 200.00, 1, 'Expired'),
('ELECTRO25', '25% discount on electronics', 'Percentage', 25.00, '2024-07-01', '2024-07-31', 2500.00, 1000.00, 2, 'Active'),
('BOOKS50', 'Flat 50 off on books', 'Flat', 50.00, '2024-05-01', '2024-12-31', 300.00, 50.00, 10, 'Active'),
('KIDS100', 'Flat 100 off kids wear', 'Flat', 100.00, '2024-06-01', '2024-06-30', 600.00, 100.00, 3, 'Active'),
('SPORTS30', '30% discount on sports items', 'Percentage', 30.00, '2024-09-01', '2024-09-30', 1200.00, 700.00, 4, 'Active'),
('FASHION40', '40% discount on fashion wear', 'Percentage', 40.00, '2024-08-01', '2024-08-31', 2000.00, 1200.00, 3, 'Active'),
('BEAUTY25', '25% discount on beauty products', 'Percentage', 25.00, '2024-11-01', '2024-11-30', 900.00, 400.00, 5, 'Active'),
('TRAVEL15', '15% off on travel accessories', 'Percentage', 15.00, '2024-12-15', '2025-01-10', 1500.00, 600.00, 2, 'Active'),
('STUDENT5', '5% off for student users', 'Percentage', 5.00, '2024-01-15', '2024-12-31', 300.00, 100.00, 8, 'Active'),
('LOYAL200', 'Flat 200 off for loyal customers', 'Flat', 200.00, '2024-02-01', '2024-09-30', 1200.00, 200.00, 5, 'Active'),
('FOOD20', '20% discount on food orders', 'Percentage', 20.00, '2024-06-15', '2024-12-31', 500.00, 250.00, 6, 'Active'),
('NEWYEAR1000', 'Flat 1000 off on New Year sale', 'Flat', 1000.00, '2024-12-30', '2025-01-05', 5000.00, 1000.00, 2, 'Active'),
('REPUBLIC10', '10% discount on Republic Day', 'Percentage', 10.00, '2024-01-20', '2024-01-26', 700.00, 300.00, 1, 'Expired'),
('MONSOON15', '15% discount on monsoon items', 'Percentage', 15.00, '2024-07-10', '2024-07-25', 800.00, 350.00, 2, 'Active');


DROP TABLE coupons;

TRUNCATE TABLE coupons;

SELECT * FROM coupons;


-- ------------------------------- 19 TRANSACTIONS -------------------------------------------------------------------------- 
-- 19 TRANSACTIONS TABLE
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50) CHECK (payment_method IN ('Credit Card','Debit Card','UPI','Net Banking','Wallet','Cash')),
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) CHECK (status IN ('Success','Pending','Failed','Refunded')) DEFAULT 'Pending',
    reference_no VARCHAR(100) UNIQUE,
    remarks VARCHAR(255)
);

-- -------------------------------- INSERT 20 RECORDS ------------------------------------------------------------------

INSERT INTO transactions (user_id, order_id, amount, payment_method, transaction_date, status, reference_no, remarks)
VALUES
(1, 101, 2500.00, 'Credit Card', '2024-01-15 10:30:00', 'Success', 'TXN1001', 'Order payment'),
(2, 102, 1500.00, 'Debit Card', '2024-01-18 11:10:00', 'Success', 'TXN1002', 'Order payment'),
(3, 103, 3000.00, 'UPI', '2024-01-20 12:00:00', 'Failed', 'TXN1003', 'UPI server error'),
(4, 104, 1200.00, 'Net Banking', '2024-02-01 09:45:00', 'Success', 'TXN1004', 'Paid successfully'),
(5, 105, 500.00, 'Wallet', '2024-02-05 08:20:00', 'Success', 'TXN1005', 'Wallet payment'),
(6, 106, 4500.00, 'Credit Card', '2024-02-07 14:10:00', 'Pending', 'TXN1006', 'Awaiting confirmation'),
(7, 107, 2200.00, 'UPI', '2024-02-10 16:30:00', 'Success', 'TXN1007', 'Order paid'),
(8, 108, 600.00, 'Cash', '2024-02-12 19:00:00', 'Success', 'TXN1008', 'COD collected'),
(9, 109, 3200.00, 'Net Banking', '2024-02-14 20:15:00', 'Refunded', 'TXN1009', 'Refund issued'),
(10, 110, 250.00, 'Wallet', '2024-02-15 21:00:00', 'Success', 'TXN1010', 'Wallet used'),
(11, 111, 1800.00, 'UPI', '2024-03-01 10:15:00', 'Success', 'TXN1011', 'UPI payment'),
(12, 112, 2000.00, 'Credit Card', '2024-03-02 12:25:00', 'Failed', 'TXN1012', 'Insufficient balance'),
(13, 113, 750.00, 'Debit Card', '2024-03-05 13:40:00', 'Success', 'TXN1013', 'Paid successfully'),
(14, 114, 1000.00, 'UPI', '2024-03-07 15:00:00', 'Pending', 'TXN1014', 'Awaiting confirmation'),
(15, 115, 5000.00, 'Credit Card', '2024-03-08 16:10:00', 'Success', 'TXN1015', 'High value order'),
(16, 116, 2800.00, 'Net Banking', '2024-03-10 17:30:00', 'Success', 'TXN1016', 'Order paid'),
(17, 117, 600.00, 'Cash', '2024-03-12 18:20:00', 'Failed', 'TXN1017', 'Customer cancelled'),
(18, 118, 3500.00, 'Wallet', '2024-03-15 20:40:00', 'Refunded', 'TXN1018', 'Refund processed'),
(19, 119, 4200.00, 'Credit Card', '2024-03-18 22:00:00', 'Success', 'TXN1019', 'Successful payment'),
(20, 120, 700.00, 'UPI', '2024-03-20 23:15:00', 'Success', 'TXN1020', 'Order payment successful');


DROP TABLE transactions;

SELECT * FROM transactions;

TRUNCATE TABLE transactions;


-- ------------------------------- 20 RETURNS -------------------------------------------------------------------------- 

CREATE TABLE returns (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    reason VARCHAR(255) NOT NULL,
    return_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Requested','Approved','Rejected','Refunded')) DEFAULT 'Requested',
    refund_amount DECIMAL(10,2) DEFAULT 0.00,
    remarks VARCHAR(255)
);

-- -------------------------------- INSERT 20 RECORDS ------------------------------------------------------------------

INSERT INTO returns (order_id, user_id, product_id, reason, return_date, status, refund_amount, remarks)
VALUES
(101, 1, 201, 'Damaged product', '2024-01-20', 'Approved', 2500.00, 'Refund processed'),
(102, 2, 202, 'Wrong size', '2024-01-22', 'Refunded', 1500.00, 'Amount refunded'),
(103, 3, 203, 'Not satisfied', '2024-01-25', 'Rejected', 0.00, 'Return rejected'),
(104, 4, 204, 'Late delivery', '2024-02-01', 'Approved', 1200.00, 'Accepted for refund'),
(105, 5, 205, 'Received duplicate item', '2024-02-05', 'Refunded', 500.00, 'Refund done'),
(106, 6, 206, 'Color mismatch', '2024-02-08', 'Requested', 0.00, 'Awaiting approval'),
(107, 7, 207, 'Damaged packaging', '2024-02-12', 'Approved', 2200.00, 'Processing refund'),
(108, 8, 208, 'Not as described', '2024-02-15', 'Refunded', 600.00, 'Refund successful'),
(109, 9, 209, 'Product missing parts', '2024-02-17', 'Approved', 3200.00, 'Refund in process'),
(110, 10, 210, 'Expired product', '2024-02-18', 'Refunded', 250.00, 'Refund issued'),
(111, 11, 211, 'Not working', '2024-03-01', 'Approved', 1800.00, 'Under process'),
(112, 12, 212, 'Did not like', '2024-03-03', 'Rejected', 0.00, 'Not eligible'),
(113, 13, 213, 'Late shipment', '2024-03-05', 'Approved', 750.00, 'Refund initiated'),
(114, 14, 214, 'Wrong product sent', '2024-03-07', 'Refunded', 1000.00, 'Refund done'),
(115, 15, 215, 'Different material', '2024-03-09', 'Approved', 5000.00, 'High value refund'),
(116, 16, 216, 'Product defective', '2024-03-10', 'Refunded', 2800.00, 'Refund issued'),
(117, 17, 217, 'Unwanted item', '2024-03-12', 'Rejected', 0.00, 'Return rejected'),
(118, 18, 218, 'Product not compatible', '2024-03-15', 'Approved', 3500.00, 'Refund being processed'),
(119, 19, 219, 'Received used item', '2024-03-17', 'Refunded', 4200.00, 'Refund successful'),
(120, 20, 220, 'Order cancelled', '2024-03-20', 'Refunded', 700.00, 'Amount refunded');

DROP TABLE returns;

SELECT * FROM returns;

TRUNCATE TABLE returns;

-- ------------------------------- 21 REFUNDS TABLE -----------------------------------------------------------------
CREATE TABLE refunds (
    refund_id INT PRIMARY KEY AUTO_INCREMENT,
    return_id INT NOT NULL,
    order_id INT NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    refund_date DATE NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    refund_mode VARCHAR(50) CHECK (refund_mode IN ('Bank Transfer','UPI','Wallet','Card')) NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Initiated','Processing','Completed','Failed')) DEFAULT 'Initiated',
    remarks VARCHAR(255)
);

-- ------------------------------- INSERT 20 RECORDS ------------------------------------------------------------

INSERT INTO refunds (return_id, order_id, user_id, product_id, refund_date, refund_amount, refund_mode, status, remarks)
VALUES
(1, 101, 1, 201, '2024-01-21', 2500.00, 'UPI', 'Completed', 'Refund successful'),
(2, 102, 2, 202, '2024-01-23', 1500.00, 'Bank Transfer', 'Completed', 'Amount transferred'),
(3, 103, 3, 203, '2024-01-26', 0.00, 'Wallet', 'Failed', 'Return rejected'),
(4, 104, 4, 204, '2024-02-02', 1200.00, 'Card', 'Processing', 'Under review'),
(5, 105, 5, 205, '2024-02-06', 500.00, 'UPI', 'Completed', 'Refund credited'),
(6, 106, 6, 206, '2024-02-10', 0.00, 'Wallet', 'Initiated', 'Waiting for approval'),
(7, 107, 7, 207, '2024-02-13', 2200.00, 'Bank Transfer', 'Processing', 'Processing refund'),
(8, 108, 8, 208, '2024-02-16', 600.00, 'Card', 'Completed', 'Refund done'),
(9, 109, 9, 209, '2024-02-18', 3200.00, 'UPI', 'Completed', 'Transferred'),
(10, 110, 10, 210, '2024-02-19', 250.00, 'Wallet', 'Completed', 'Amount added to wallet'),
(11, 111, 11, 211, '2024-03-02', 1800.00, 'Bank Transfer', 'Processing', 'Will credit soon'),
(12, 112, 12, 212, '2024-03-04', 0.00, 'UPI', 'Failed', 'Not eligible'),
(13, 113, 13, 213, '2024-03-06', 750.00, 'Wallet', 'Completed', 'Refund successful'),
(14, 114, 14, 214, '2024-03-08', 1000.00, 'Card', 'Completed', 'Refund processed'),
(15, 115, 15, 215, '2024-03-10', 5000.00, 'UPI', 'Completed', 'High value refund'),
(16, 116, 16, 216, '2024-03-11', 2800.00, 'Bank Transfer', 'Completed', 'Credited'),
(17, 117, 17, 217, '2024-03-13', 0.00, 'Wallet', 'Failed', 'Return rejected'),
(18, 118, 18, 218, '2024-03-16', 3500.00, 'Card', 'Processing', 'Refund in process'),
(19, 119, 19, 219, '2024-03-18', 4200.00, 'UPI', 'Completed', 'Refund successful'),
(20, 120, 20, 220, '2024-03-21', 700.00, 'Bank Transfer', 'Completed', 'Amount credited');


DROP TABLE refunds;

SELECT * FROM refunds;

TRUNCATE TABLE refunds;


-- ------------------------------- 22 SUPPORT_TICKETS TABLE -----------------------------------------------------------------
CREATE TABLE support_tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    subject VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    category VARCHAR(50) CHECK (category IN ('Order Issue','Payment','Refund','Delivery','Product','Other')),
    priority VARCHAR(20) CHECK (priority IN ('Low','Medium','High','Critical')) DEFAULT 'Low',
    status VARCHAR(20) CHECK (status IN ('Open','In Progress','Resolved','Closed')) DEFAULT 'Open',
    created_at DATE NOT NULL,
    updated_at DATE
);

-- ------------------------------- INSERT 20 RECORDS ------------------------------------------------------------

INSERT INTO support_tickets (user_id, order_id, subject, description, category, priority, status, created_at, updated_at)
VALUES
(1, 101, 'Late Delivery', 'Order not delivered on expected date.', 'Delivery', 'High', 'Open', '2024-01-15', NULL),
(2, 102, 'Payment Failed', 'Amount deducted but order not placed.', 'Payment', 'Critical', 'In Progress', '2024-01-18', '2024-01-20'),
(3, 103, 'Refund Delay', 'Refund not credited even after 7 days.', 'Refund', 'Medium', 'Open', '2024-01-21', NULL),
(4, 104, 'Damaged Product', 'Product arrived broken.', 'Product', 'High', 'Resolved', '2024-01-25', '2024-01-28'),
(5, 105, 'Order Cancel Request', 'Want to cancel my order before shipment.', 'Order Issue', 'Medium', 'Closed', '2024-01-30', '2024-02-02'),
(6, 106, 'Duplicate Order', 'Order placed twice by mistake.', 'Order Issue', 'High', 'Resolved', '2024-02-01', '2024-02-04'),
(7, 107, 'Wallet Balance Issue', 'Refund not reflected in wallet.', 'Refund', 'Medium', 'Open', '2024-02-05', NULL),
(8, 108, 'Delivery Boy Behavior', 'Delivery person was rude.', 'Delivery', 'Low', 'Closed', '2024-02-07', '2024-02-08'),
(9, 109, 'Size Issue', 'Ordered size M but received size S.', 'Product', 'High', 'In Progress', '2024-02-10', '2024-02-12'),
(10, 110, 'Return Pickup Delay', 'Courier not scheduled for return pickup.', 'Delivery', 'Medium', 'Open', '2024-02-14', NULL),
(11, 111, 'Order Not Updated', 'Order status stuck at Processing.', 'Order Issue', 'High', 'Open', '2024-02-17', NULL),
(12, 112, 'Payment Gateway Error', 'Unable to pay via UPI.', 'Payment', 'Critical', 'In Progress', '2024-02-19', '2024-02-20'),
(13, 113, 'Wrong Item Delivered', 'Received wrong product.', 'Product', 'Critical', 'Resolved', '2024-02-21', '2024-02-23'),
(14, 114, 'Refund Wrong Amount', 'Refunded amount less than expected.', 'Refund', 'High', 'Closed', '2024-02-24', '2024-02-27'),
(15, 115, 'App Crash', 'App crashes during checkout.', 'Other', 'Medium', 'Open', '2024-03-01', NULL),
(16, 116, 'Exchange Request', 'Want to exchange for different color.', 'Product', 'Medium', 'In Progress', '2024-03-03', '2024-03-04'),
(17, 117, 'Delivery Address Change', 'Need to update address before shipping.', 'Delivery', 'Low', 'Resolved', '2024-03-06', '2024-03-07'),
(18, 118, 'Refund Pending', 'Refund taking longer than usual.', 'Refund', 'High', 'Open', '2024-03-08', NULL),
(19, 119, 'Payment Not Credited', 'Money deducted but not credited.', 'Payment', 'Critical', 'In Progress', '2024-03-10', '2024-03-12'),
(20, 120, 'Customer Service Delay', 'Support not responding quickly.', 'Other', 'Medium', 'Closed', '2024-03-13', '2024-03-15');


DROP TABLE support_tickets;

SELECT * FROM support_tickets;

TRUNCATE TABLE support_tickets;

-- ------------------------------- 23 EMPLOYEES TABLE -----------------------------------------------------------------
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    hire_date DATE NOT NULL,
    job_title VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) CHECK (salary >= 10000),
    department_id INT NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Active','On Leave','Resigned')) DEFAULT 'Active',
    created_at DATE DEFAULT (CURRENT_DATE)
);

-- ------------------------------- INSERT 20 RECORDS ------------------------------------------------------------

INSERT INTO employees (first_name, last_name, email, phone, hire_date, job_title, salary, department_id, status, created_at)
VALUES
('Amit', 'Sharma', 'amit.sharma@example.com', '9876543210', '2021-05-15', 'Data Analyst', 35000, 1, 'Active', '2021-05-15'),
('Priya', 'Verma', 'priya.verma@example.com', '9876543211', '2020-07-20', 'HR Manager', 45000, 2, 'Active', '2020-07-20'),
('Ravi', 'Kumar', 'ravi.kumar@example.com', '9876543212', '2022-01-10', 'Software Engineer', 60000, 3, 'Active', '2022-01-10'),
('Sneha', 'Patil', 'sneha.patil@example.com', '9876543213', '2019-09-25', 'Team Lead', 75000, 3, 'On Leave', '2019-09-25'),
('Vikas', 'Joshi', 'vikas.joshi@example.com', '9876543214', '2018-04-14', 'Project Manager', 90000, 4, 'Active', '2018-04-14'),
('Anjali', 'Mehta', 'anjali.mehta@example.com', '9876543215', '2020-11-11', 'Marketing Executive', 40000, 5, 'Active', '2020-11-11'),
('Rohit', 'Nair', 'rohit.nair@example.com', '9876543216', '2021-03-18', 'Support Engineer', 30000, 6, 'Resigned', '2021-03-18'),
('Divya', 'Gupta', 'divya.gupta@example.com', '9876543217', '2019-12-30', 'Financial Analyst', 55000, 7, 'Active', '2019-12-30'),
('Suresh', 'Singh', 'suresh.singh@example.com', '9876543218', '2022-02-05', 'Data Engineer', 65000, 1, 'Active', '2022-02-05'),
('Kavita', 'Yadav', 'kavita.yadav@example.com', '9876543219', '2021-08-21', 'Recruiter', 32000, 2, 'Active', '2021-08-21'),
('Neha', 'Reddy', 'neha.reddy@example.com', '9876543220', '2020-06-19', 'Business Analyst', 48000, 7, 'Active', '2020-06-19'),
('Manish', 'Kapoor', 'manish.kapoor@example.com', '9876543221', '2021-04-25', 'Software Tester', 37000, 3, 'On Leave', '2021-04-25'),
('Ritika', 'Bose', 'ritika.bose@example.com', '9876543222', '2018-07-13', 'Senior Developer', 80000, 3, 'Active', '2018-07-13'),
('Alok', 'Das', 'alok.das@example.com', '9876543223', '2019-10-02', 'Operations Manager', 72000, 6, 'Active', '2019-10-02'),
('Sunita', 'Mishra', 'sunita.mishra@example.com', '9876543224', '2022-03-11', 'Content Writer', 28000, 5, 'Active', '2022-03-11'),
('Rajesh', 'Pawar', 'rajesh.pawar@example.com', '9876543225', '2020-01-22', 'System Admin', 42000, 6, 'Active', '2020-01-22'),
('Pooja', 'Kale', 'pooja.kale@example.com', '9876543226', '2021-09-09', 'SEO Specialist', 36000, 5, 'Resigned', '2021-09-09'),
('Arjun', 'Shetty', 'arjun.shetty@example.com', '9876543227', '2019-11-16', 'Business Consultant', 88000, 7, 'Active', '2019-11-16'),
('Meera', 'Chopra', 'meera.chopra@example.com', '9876543228', '2022-05-20', 'Trainee Engineer', 25000, 3, 'Active', '2022-05-20'),
('Karan', 'Gill', 'karan.gill@example.com', '9876543229', '2018-08-05', 'Director', 120000, 4, 'Active', '2018-08-05');


DROP TABLE employees;

SELECT * FROM employees;

TRUNCATE TABLE employees;

-- ------------------------------- 24 DEPARTMENTS TABLE -----------------------------------------------------
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    manager_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    created_at DATE DEFAULT (CURRENT_DATE)
);

-- ------------------------------- INSERT 20 RECORDS -----------------------------------------------------

INSERT INTO departments (department_name, manager_name, location, created_at) VALUES
('Human Resources', 'Priya Verma', 'Mumbai', '2020-05-10'),
('Finance', 'Divya Gupta', 'Delhi', '2019-11-20'),
('IT', 'Ravi Kumar', 'Bangalore', '2021-03-15'),
('Operations', 'Alok Das', 'Hyderabad', '2018-09-12'),
('Marketing', 'Anjali Mehta', 'Pune', '2020-01-18'),
('Sales', 'Rahul Malhotra', 'Chennai', '2019-07-07'),
('Customer Support', 'Rohit Nair', 'Kolkata', '2021-04-22'),
('Logistics', 'Amit Sharma', 'Jaipur', '2020-12-03'),
('Administration', 'Vikas Joshi', 'Delhi', '2018-06-25'),
('Product Development', 'Ritika Bose', 'Bangalore', '2019-02-14'),
('Quality Assurance', 'Manish Kapoor', 'Hyderabad', '2021-07-10'),
('Legal', 'Sunita Mishra', 'Mumbai', '2019-10-01'),
('Procurement', 'Suresh Singh', 'Pune', '2022-01-11'),
('Business Strategy', 'Arjun Shetty', 'Delhi', '2018-03-17'),
('Content & Media', 'Sneha Patil', 'Mumbai', '2020-08-30'),
('Training', 'Kavita Yadav', 'Ahmedabad', '2021-11-21'),
('Security', 'Rajesh Pawar', 'Bangalore', '2022-02-19'),
('Data Science', 'Tanvi Kulkarni', 'Hyderabad', '2021-05-06'),
('Research', 'Neha Reddy', 'Chennai', '2019-09-27'),
('Corporate Affairs', 'Karan Gill', 'Delhi', '2018-04-04');


DROP TABLE departments;

SELECT * FROM departments;

TRUNCATE TABLE departments;

-- ------------------------------- 25 NOTIFICATIONS TABLE -----------------------------------------------------
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Order', 'Payment', 'Shipment', 'Offer', 'General')),
    status VARCHAR(20) DEFAULT 'Unread' CHECK (status IN ('Unread','Read')),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    read_at DATETIME NULL,
    priority VARCHAR(20) DEFAULT 'Normal' CHECK (priority IN ('Low','Normal','High')),
    channel VARCHAR(20) DEFAULT 'Email' CHECK (channel IN ('Email','SMS','App')),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- ------------------------------- INSERT 20 RECORDS -----------------------------------------------------

INSERT INTO notifications (user_id, message, type, status, priority, channel, created_at) VALUES
(1, 'Your order #101 has been placed successfully.', 'Order', 'Unread', 'High', 'Email', '2023-12-01 10:15:00'),
(2, 'Your payment of ₹2500 has been confirmed.', 'Payment', 'Read', 'Normal', 'App', '2023-12-01 11:00:00'),
(3, 'Your shipment for order #104 is out for delivery.', 'Shipment', 'Unread', 'High', 'SMS', '2023-12-02 08:30:00'),
(4, 'Special offer: 20% off on electronics.', 'Offer', 'Unread', 'Normal', 'App', '2023-12-03 09:45:00'),
(5, 'Your return request #205 has been approved.', 'General', 'Read', 'Low', 'Email', '2023-12-04 12:00:00'),
(6, 'Your refund for order #110 has been processed.', 'Payment', 'Unread', 'Normal', 'App', '2023-12-04 14:20:00'),
(7, 'Order #120 has been cancelled as per your request.', 'Order', 'Read', 'Normal', 'Email', '2023-12-05 10:10:00'),
(8, 'Your shipment for order #115 has been delayed.', 'Shipment', 'Unread', 'High', 'SMS', '2023-12-05 18:40:00'),
(9, 'Mega Sale: Upto 50% off on fashion.', 'Offer', 'Unread', 'High', 'App', '2023-12-06 09:00:00'),
(10, 'Your order #125 has been successfully delivered.', 'Order', 'Read', 'Normal', 'Email', '2023-12-07 11:25:00'),
(11, 'Your payment of ₹1200 has failed.', 'Payment', 'Unread', 'High', 'SMS', '2023-12-07 12:15:00'),
(12, 'Your shipment for order #130 is packed.', 'Shipment', 'Unread', 'Normal', 'App', '2023-12-08 10:05:00'),
(13, 'Your account password has been changed.', 'General', 'Read', 'Normal', 'Email', '2023-12-08 15:45:00'),
(14, 'Flash Deal: Buy 1 Get 1 Free!', 'Offer', 'Unread', 'High', 'App', '2023-12-09 09:15:00'),
(15, 'Order #140 is under processing.', 'Order', 'Unread', 'Normal', 'App', '2023-12-09 10:30:00'),
(16, 'Your payment of ₹899 is pending.', 'Payment', 'Unread', 'High', 'SMS', '2023-12-10 11:00:00'),
(17, 'Shipment for order #150 has been dispatched.', 'Shipment', 'Read', 'Normal', 'Email', '2023-12-10 17:25:00'),
(18, 'New Year Offer: Flat ₹500 off.', 'Offer', 'Unread', 'High', 'App', '2023-12-11 08:30:00'),
(19, 'Your return request #210 is under review.', 'General', 'Unread', 'Low', 'App', '2023-12-11 14:00:00'),
(20, 'Your order #160 has been confirmed.', 'Order', 'Read', 'Normal', 'Email', '2023-12-12 10:00:00');


DROP TABLE notifications;

TRUNCATE TABLE notifications;

SELECT * FROM notifications;



