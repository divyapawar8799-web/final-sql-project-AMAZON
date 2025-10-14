Create Database Amazon;

Use Amazon;

-- ---------------------- 1 USERS TABLE ------------------------------------- 


-- 1️ DDL: Add a new column for membership level
ALTER TABLE Users ADD COLUMN membership_level ENUM('Silver','Gold','Platinum') DEFAULT 'Silver';

-- 2️ DDL: Add a CHECK constraint on phone length
ALTER TABLE Users ADD CONSTRAINT chk_phone_length CHECK (LENGTH(phone) = 10);

-- 3️ DDL: Create an index on email for faster lookup
CREATE INDEX idx_users_email ON Users(email);

-- 4️ DDL: Rename column 'status' to 'account_status'
ALTER TABLE Users CHANGE COLUMN status account_status ENUM('Active','Suspended','Deleted') DEFAULT 'Active';

-- 5️ DDL: Add ON DELETE CASCADE to city_id foreign key (demonstration)
ALTER TABLE Users DROP FOREIGN KEY fk_city_id;
ALTER TABLE Users
  ADD CONSTRAINT fk_city_id FOREIGN KEY (city_id)
  REFERENCES City(city_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 6️ DML: Insert sample users
INSERT INTO Users (first_name, last_name, email, phone, gender, dob, account_status, city_id)
VALUES ('Riya','Sharma','riya.sharma@gmail.com','9876543210','Female','1999-06-10','Active',101),
       ('Amit','Verma','amitv@gmail.com','9988776655','Male','1998-02-15','Active',102);

-- 7️ DML: Update membership level based on order count (sample logic)
UPDATE Users
SET membership_level = 'Gold'
WHERE user_id IN (SELECT user_id FROM Orders GROUP BY user_id HAVING COUNT(order_id) > 5);

-- 8️ DML: Delete suspended users older than 2 years (cleanup)
DELETE FROM Users
WHERE account_status = 'Suspended'
  AND last_login < DATE_SUB(CURRENT_DATE, INTERVAL 2 YEAR);

-- 9 ️DML: Set all NULL last_login to current timestamp
UPDATE Users
SET last_login = CURRENT_TIMESTAMP
WHERE last_login IS NULL;

-- 10 DML: Change membership for female users in Mumbai
UPDATE Users
SET membership_level = 'Platinum'
WHERE gender='Female' AND city_id=(SELECT city_id FROM City WHERE city_name='Mumbai');

-- 11️ DQL: Display all active users ordered by newest login
SELECT user_id, CONCAT(first_name,' ',last_name) AS FullName, last_login
FROM Users
WHERE account_status='Active'
ORDER BY last_login DESC;

-- 12️ DQL: Count total users by gender
SELECT gender, COUNT(*) AS total_users
FROM Users
GROUP BY gender;

-- 13️ DQL: Find users who have not placed any orders
SELECT u.user_id, u.first_name, u.email
FROM Users u
LEFT JOIN Orders o ON u.user_id=o.user_id
WHERE o.order_id IS NULL;

-- 14️ DQL: Top 5 most recent signups
SELECT user_id, first_name, email, created_at
FROM Users
ORDER BY created_at DESC
LIMIT 5;

-- 15 DQL: Users aged between 20 and 30 years
SELECT user_id, first_name, dob,
       TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age
FROM Users
WHERE TIMESTAMPDIFF(YEAR, dob, CURDATE()) BETWEEN 20 AND 30;

-- 16️ DQL: Find duplicate emails if any
SELECT email, COUNT(*) AS occurrences
FROM Users
GROUP BY email
HAVING COUNT(*) > 1;

-- 17️ DQL: List top cities by number of users
SELECT c.city_name, COUNT(u.user_id) AS total_users
FROM Users u
JOIN City c ON u.city_id=c.city_id
GROUP BY c.city_name
ORDER BY total_users DESC
LIMIT 10;

-- 18️ DQL: Count users by membership level
SELECT membership_level, COUNT(*) AS user_count
FROM Users
GROUP BY membership_level
ORDER BY user_count DESC;

-- 19️ DQL: Users whose name starts with 'A'
SELECT user_id, CONCAT(first_name,' ',last_name) AS Name
FROM Users
WHERE first_name LIKE 'A%';

-- 20️ DQL: Check cascade behavior (test user deletion)
ALTER TABLE Users DROP FOREIGN KEY fk_city_id;
ALTER TABLE Users
  ADD CONSTRAINT fk_city_id FOREIGN KEY (city_id)
  REFERENCES City(city_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;




-- ----------------------------  2 Orders ---------------------------------------------------  

USE Amazon;

-- 1️ DDL: Add a new column for delivery_type (Comparison + default)
ALTER TABLE Orders
ADD COLUMN delivery_type ENUM('Standard','Express','Same-Day') DEFAULT 'Standard';

-- 2️ DDL: Add CHECK constraint to ensure positive quantity (Comparison operator)
ALTER TABLE Orders
ADD CONSTRAINT chk_quantity_positive CHECK (quantity > 0);

-- 3️ DDL: Create index on order_date for faster lookups
CREATE INDEX idx_orders_date ON Orders(order_date);

-- 4️ DDL: Add ON DELETE / ON UPDATE CASCADE for user_id foreign key
ALTER TABLE Orders DROP FOREIGN KEY fk_user;
ALTER TABLE Orders
  ADD CONSTRAINT fk_user FOREIGN KEY (user_id)
  REFERENCES Users(user_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 5️ DDL: Rename column 'payment_method' to 'pay_method'
ALTER TABLE Orders CHANGE COLUMN payment_method pay_method VARCHAR(50);

-- 6️ DML: Insert sample orders (Comparison + values)
INSERT INTO Orders (user_id, product_id, quantity, grand_total, pay_method, order_status, order_date)
VALUES
(1,3,2,1599.00,'UPI','Pending','2025-10-10'),
(2,4,1,2499.00,'Credit Card','Delivered','2025-10-11');

-- 7️ DML: Update order status (Logical operator: AND)
UPDATE Orders
SET order_status = 'Shipped'
WHERE order_status = 'Pending'
  AND grand_total > 1000;

-- 8️ DML: Cancel unpaid orders older than 5 days (Arithmetic + Comparison)
UPDATE Orders
SET order_status = 'Cancelled'
WHERE pay_status = 'Unpaid'
  AND DATEDIFF(CURDATE(), order_date) > 5;

-- 9️ DML: Delete all cancelled orders older than 2024 (Logical + Comparison)
DELETE FROM Orders
WHERE order_status = 'Cancelled'
  AND order_date < '2024-01-01';

-- 10 DML: Apply promo to festival orders (Special IN)
UPDATE Orders
SET promo_id = (SELECT promo_id FROM Promotions WHERE promo_code='FESTIVE25' LIMIT 1)
WHERE order_id IN (1,2,3,4);

-- 11️ DQL: List all orders with user and product (Aliases + JOIN)
SELECT o.order_id, u.full_name AS Customer, p.product_name, o.grand_total, o.order_status
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
JOIN Products p ON o.product_id = p.product_id
ORDER BY o.order_date DESC;

-- 12️ DQL: Total revenue per payment method (GROUP BY + Aggregate + Alias)
SELECT pay_method AS PaymentType, SUM(grand_total) AS TotalRevenue
FROM Orders
GROUP BY pay_method
ORDER BY TotalRevenue DESC;

-- 13️ DQL: Count monthly orders for 2025 (Arithmetic + GROUP BY)
SELECT MONTH(order_date) AS MonthNumber, COUNT(order_id) AS OrdersCount
FROM Orders
WHERE YEAR(order_date)=2025
GROUP BY MONTH(order_date)
ORDER BY MonthNumber;

-- 14️ DQL: Top 5 users by total spent (Aliases + HAVING)
SELECT u.user_id, u.full_name, SUM(o.grand_total) AS TotalSpent
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
GROUP BY u.user_id
HAVING SUM(o.grand_total) > 1000
ORDER BY TotalSpent DESC
LIMIT 5;

-- 15️ DQL: Find orders without shipments yet (Special NOT IN)
SELECT order_id, user_id, order_status
FROM Orders
WHERE order_id NOT IN (SELECT order_id FROM Shipments);

-- 16️ DQL: Average order amount per city (GROUP BY + JOIN + Alias)
SELECT c.city_name AS City, ROUND(AVG(o.grand_total),2) AS AvgOrderValue
FROM Orders o
JOIN Users u ON o.user_id=u.user_id
JOIN City c ON u.city_id=c.city_id
GROUP BY c.city_name
ORDER BY AvgOrderValue DESC
LIMIT 10;

-- 17️ DQL: Orders using arithmetic operator on totals (price × quantity)
SELECT order_id, quantity, grand_total, (grand_total / quantity) AS PerItemPrice
FROM Orders
WHERE quantity > 0
ORDER BY PerItemPrice DESC
LIMIT 10;

-- 18️ DQL: Orders between price range and not Cancelled (Special BETWEEN + Logical NOT)
SELECT order_id, grand_total, order_status
FROM Orders
WHERE grand_total BETWEEN 1000 AND 5000
  AND NOT order_status = 'Cancelled';

-- 19️ DQL: Count orders by status (GROUP BY + HAVING + Alias)
SELECT order_status AS Status, COUNT(*) AS TotalOrders
FROM Orders
GROUP BY order_status
HAVING COUNT(*) > 1
ORDER BY TotalOrders DESC;

-- 20️ DQL: Verify CASCADE behavior (test deletion)
ALTER TABLE Orders DROP FOREIGN KEY fk_user;
ALTER TABLE Orders
  ADD CONSTRAINT fk_user FOREIGN KEY (user_id)
  REFERENCES Users(user_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;


-- Only show users with more than 2 orders
SELECT user_id, COUNT(*) AS total_orders 
FROM Orders 
GROUP BY user_id 
HAVING COUNT(*) > 2;



-- ------------------------------ 3 PRODUCTS---------------------------------------------  


USE Amazon;

-- 1️ DDL: Add a column for product_brand
ALTER TABLE Products
ADD COLUMN product_brand VARCHAR(100);

-- 2️ DDL: Add CHECK constraint to ensure price > 0  (Comparison operator)
ALTER TABLE Products
ADD CONSTRAINT chk_price_positive CHECK (price > 0);

-- 3️ DDL: Add foreign key to Categories with ON DELETE / ON UPDATE CASCADE
ALTER TABLE Products DROP FOREIGN KEY fk_category_id;
ALTER TABLE Products
  ADD CONSTRAINT fk_category_id FOREIGN KEY (category_id)
  REFERENCES Categories(category_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 4️ DDL: Create index on product_name for faster searching
CREATE INDEX idx_products_name ON Products(product_name);

-- 5️ DDL: Rename column description → product_description
ALTER TABLE Products CHANGE COLUMN description product_description TEXT;

-- 6️ DML: Insert new sample products (Comparison + values)
INSERT INTO Products (product_name, product_brand, category_id, price, stock, rating, status)
VALUES
('Echo Dot 5th Gen','Amazon',2,4499.00,150,4.7,'Active'),
('Noise Smartwatch','Noise',3,2999.00,200,4.5,'Active');

-- 7️ DML: Update product price using Arithmetic operator (+10%)
UPDATE Products
SET price = price + (price * 0.10)
WHERE category_id IN (2,3);

-- 8️ DML: Mark discontinued products when stock = 0 (Comparison)
UPDATE Products
SET status = 'Discontinued'
WHERE stock = 0;

-- 9️ DML: Reduce stock after recent orders (Arithmetic −)
UPDATE Products
SET stock = stock - 5
WHERE product_id IN (1,2,3);

-- 10 DML: Delete duplicate inactive products (Logical operator AND)
DELETE FROM Products
WHERE status='Inactive' AND stock=0;

-- 11️ DQL: List all products with category name (Aliases + JOIN)
SELECT p.product_id, p.product_name, c.category_name, p.price, p.status
FROM Products p
JOIN Categories c ON p.category_id=c.category_id
ORDER BY p.price DESC;

-- 12️ DQL: Show top 5 highest rated products (Comparison + ORDER BY LIMIT)
SELECT product_id, product_name, rating
FROM Products
WHERE rating > 4.0
ORDER BY rating DESC
LIMIT 5;

-- 13️ DQL: Average price per category (GROUP BY + Alias)
SELECT c.category_name AS Category, ROUND(AVG(p.price),2) AS AvgPrice
FROM Products p
JOIN Categories c ON p.category_id=c.category_id
GROUP BY c.category_name
ORDER BY AvgPrice DESC;

-- 14️ DQL: Count products per brand > 1 (HAVING)
SELECT product_brand, COUNT(*) AS TotalProducts
FROM Products
GROUP BY product_brand
HAVING COUNT(*) > 1;

-- 15️ DQL: Products priced BETWEEN 1000 AND 10000 (Special BETWEEN)
SELECT product_id, product_name, price
FROM Products
WHERE price BETWEEN 1000 AND 10000
ORDER BY price ASC;

-- 16️ DQL: Products name starting with ‘N’ (Special LIKE)
SELECT product_id, product_name
FROM Products
WHERE product_name LIKE 'N%';

-- 17️ DQL: Products not discontinued and rating > 3.5 (Logical NOT + Comparison)
SELECT product_id, product_name, rating
FROM Products
WHERE NOT status='Discontinued'
  AND rating>3.5;

-- 18️ DQL: Stock-value calculation (price × stock) (Arithmetic)
SELECT product_id, product_name,
       price, stock,
       (price * stock) AS TotalStockValue
FROM Products
ORDER BY TotalStockValue DESC
LIMIT 10;

-- 19️ DQL: Find brands with total stock > 100 (GROUP BY + HAVING)
SELECT product_brand, SUM(stock) AS TotalStock
FROM Products
GROUP BY product_brand
HAVING SUM(stock) > 100;

-- 20️ DQL: Verify cascade (Category → Products)


-- ----------------------------------------- CATEGORIES 4. -------------------------------------


USE Amazon;

-- 1. Add column for parent_category (self-referencing hierarchy)
ALTER TABLE Categories
ADD COLUMN parent_category_id INT NULL;

-- 2. Add foreign key to self (Category → Category) with CASCADE
ALTER TABLE Categories
  ADD CONSTRAINT fk_parent_category
  FOREIGN KEY (parent_category_id)
  REFERENCES Categories(category_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 3. Add CHECK constraint to ensure category_name not empty
ALTER TABLE Categories
ADD CONSTRAINT chk_category_name CHECK (LENGTH(category_name) > 0);

-- 4. Create index on category_name
CREATE INDEX idx_category_name ON Categories(category_name);

-- 5. Rename column description → category_description
ALTER TABLE Categories CHANGE COLUMN description category_description TEXT;

-- 6. Insert sample categories
INSERT INTO Categories (category_name, category_description, parent_category_id)
VALUES
('Electronics','Devices and gadgets',NULL),
('Mobiles','Smartphones and accessories',1),
('Appliances','Home and kitchen appliances',NULL);

-- 7. Update parent category of Mobiles (Arithmetic / Logical)
UPDATE Categories
SET parent_category_id = 1
WHERE category_name = 'Mobiles' AND parent_category_id IS NULL;

-- 8. Delete categories with no products (Logical + Special IS NULL)
DELETE FROM Categories
WHERE category_id NOT IN (SELECT DISTINCT category_id FROM Products)
  AND parent_category_id IS NULL;

-- 9. Update category description using CONCAT (String fn)
UPDATE Categories
SET category_description = CONCAT(category_description,' (updated ',YEAR(CURDATE()),')')
WHERE category_name LIKE '%Electronics%';

-- 10. Set all NULL parent_category_id to 0
UPDATE Categories
SET parent_category_id = 0
WHERE parent_category_id IS NULL;

-- 11. List all categories and sub-categories (Aliases + Self JOIN)
SELECT c1.category_name AS MainCategory,
       c2.category_name AS SubCategory
FROM Categories c1
LEFT JOIN Categories c2 ON c1.category_id = c2.parent_category_id
ORDER BY MainCategory;

-- 12. Count total products per category (GROUP BY + Alias)
SELECT c.category_name AS Category, COUNT(p.product_id) AS ProductCount
FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_name
ORDER BY ProductCount DESC;

-- 13. Categories having more than 2 products (HAVING + Comparison)
SELECT c.category_name, COUNT(p.product_id) AS TotalProducts
FROM Categories c 
JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_name
HAVING COUNT(p.product_id) > 2;

-- 14. Categories with name starting with ‘A’ (Special LIKE)
SELECT category_id, category_name
FROM Categories
WHERE category_name LIKE 'A%';

-- 15. Categories without sub-categories (Special IS NULL)
SELECT c.category_id, c.category_name
FROM Categories c
LEFT JOIN Categories sub ON c.category_id = sub.parent_category_id
WHERE sub.category_id IS NULL;

-- 16. Categories ordered by name length (Arithmetic + ORDER BY)
SELECT category_id, category_name, LENGTH(category_name) AS NameLength
FROM Categories
ORDER BY NameLength DESC
LIMIT 5;

-- 17. Count categories grouped by first letter (String fn + GROUP BY)
SELECT LEFT(category_name,1) AS FirstLetter, COUNT(*) AS CountByLetter
FROM Categories
GROUP BY LEFT(category_name,1)
ORDER BY FirstLetter;

-- 18. Categories where description NOT LIKE '%old%' (Logical NOT + Special LIKE)
SELECT category_id, category_name
FROM Categories
WHERE NOT category_description LIKE '%old%';

-- 19. Total categories and sub-category count (HAVING)
SELECT parent_category_id, COUNT(*) AS SubCount
FROM Categories
GROUP BY parent_category_id
HAVING COUNT(*) > 1;

-- 20. Add / Delete CASCADE demonstration
-- Step 1: Add temporary main and sub-category
INSERT INTO Categories (category_id,category_name,parent_category_id)
VALUES (999,'Temp Main',NULL);
INSERT INTO Categories (category_name,parent_category_id)
VALUES ('Temp Sub',999);
-- Step 2: Delete main category → sub auto-deletes (ON DELETE CASCADE)
DELETE FROM Categories WHERE category_id = 999;


-- ========================= 5) Cart Table ==============================


-- 1. Add column for cart_status
ALTER TABLE Cart
ADD COLUMN cart_status ENUM('Active','Saved','Expired') DEFAULT 'Active';

-- 2. Add foreign key to Users with ON DELETE / ON UPDATE CASCADE
ALTER TABLE Cart DROP FOREIGN KEY fk_cart_user;
ALTER TABLE Cart
  ADD CONSTRAINT fk_cart_user FOREIGN KEY (user_id)
  REFERENCES Users(user_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 3. Add CHECK constraint for quantity > 0
ALTER TABLE Cart
ADD CONSTRAINT chk_cart_quantity CHECK (quantity > 0);

-- 4. Add column for added_at date if not exists
ALTER TABLE Cart
ADD COLUMN added_at DATETIME DEFAULT CURRENT_TIMESTAMP;

-- 5. Create index on product_id for faster queries
CREATE INDEX idx_cart_product_id ON Cart(product_id);

-- 6. Insert sample cart items (Comparison)
INSERT INTO Cart (user_id, product_id, quantity, price, cart_status)
VALUES
(1,3,2,1599.00,'Active'),
(2,5,1,2499.00,'Saved');

-- 7. Update cart quantity (Arithmetic operator)
UPDATE Cart
SET quantity = quantity + 1
WHERE cart_id = 1;

-- 8. Update price for all items (Arithmetic operator + Logical)
UPDATE Cart
SET price = price * 0.95
WHERE cart_status='Active' AND quantity >= 2;

-- 9. Delete expired cart items (Logical AND + Comparison)
DELETE FROM Cart
WHERE cart_status='Expired' AND added_at < DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- 10. Convert saved carts to active (Special IN)
UPDATE Cart
SET cart_status='Active'
WHERE cart_id IN (SELECT cart_id FROM Cart WHERE cart_status='Saved');

-- 11. Show cart details with user and product (Aliases + JOIN)
SELECT c.cart_id, u.full_name AS Customer, p.product_name, c.quantity, c.price
FROM Cart c
JOIN Users u ON c.user_id=u.user_id
JOIN Products p ON c.product_id=p.product_id
ORDER BY c.added_at DESC;

-- 12. Total cart value per user (GROUP BY + Arithmetic)
SELECT user_id, SUM(price * quantity) AS TotalCartValue
FROM Cart
GROUP BY user_id
ORDER BY TotalCartValue DESC;

-- 13. Average cart quantity (Aggregate + HAVING)
SELECT user_id, AVG(quantity) AS AvgQuantity
FROM Cart
GROUP BY user_id
HAVING AVG(quantity) > 1;

-- 14. Carts with more than 2 items (Comparison)
SELECT cart_id, user_id, quantity
FROM Cart
WHERE quantity > 2
ORDER BY quantity DESC;

-- 15. Users having active carts (Special EXISTS)
SELECT DISTINCT u.user_id, u.full_name
FROM Users u
WHERE EXISTS (SELECT 1 FROM Cart c WHERE c.user_id=u.user_id AND c.cart_status='Active');

-- 16. Products with total quantity in cart (GROUP BY + SUM)
SELECT p.product_name, SUM(c.quantity) AS TotalQty
FROM Cart c
JOIN Products p ON c.product_id=p.product_id
GROUP BY p.product_name
ORDER BY TotalQty DESC
LIMIT 10;

-- 17. Total active vs saved carts (GROUP BY + Alias)
SELECT cart_status AS Status, COUNT(*) AS TotalCarts
FROM Cart
GROUP BY cart_status;

-- 18. Show carts with value BETWEEN 1000 and 5000 (Special BETWEEN)
SELECT cart_id, (price*quantity) AS CartValue
FROM Cart
WHERE (price*quantity) BETWEEN 1000 AND 5000;

-- 19. Carts without users (LEFT JOIN + IS NULL)
SELECT c.cart_id, c.product_id, c.user_id
FROM Cart c
LEFT JOIN Users u ON c.user_id=u.user_id
WHERE u.user_id IS NULL;

-- 20. Add/Delete Cascade test
-- Step 1: Create test user & cart
INSERT INTO Users (email, phone, first_name, last_name, gender, dob, account_status, city_id)
VALUES ('cascade.test@amazon.in','9999999999','Cascade','Test','Other','2000-01-01','Active',101);
SET @uid = LAST_INSERT_ID();
INSERT INTO Cart (user_id, product_id, quantity, price, cart_status)
VALUES (@uid,1,1,499.00,'Active');

-- Step 2: Delete user → Cart auto-deletes (ON DELETE CASCADE)
DELETE FROM Users WHERE user_id = @uid;





-- ========================= 6) Payments Table ==============================

-- 1. Add column for payment_type
ALTER TABLE Payments
ADD COLUMN payment_type ENUM('Online','COD','Wallet') DEFAULT 'Online';

-- 2. Add ON DELETE / ON UPDATE CASCADE for order_id → Orders
ALTER TABLE Payments DROP FOREIGN KEY fk_payment_order;
ALTER TABLE Payments
  ADD CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
  REFERENCES Orders(order_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 3. Add CHECK constraint to ensure amount > 0
ALTER TABLE Payments
ADD CONSTRAINT chk_payment_amount CHECK (amount > 0);

-- 4. Add index on payment_date
CREATE INDEX idx_payment_date ON Payments(payment_date);

-- 5. Rename column payment_method → pay_method
ALTER TABLE Payments CHANGE COLUMN payment_method pay_method VARCHAR(50);

-- 6. Insert sample payments
INSERT INTO Payments (order_id, user_id, amount, payment_date, pay_method, status, transaction_id)
VALUES
(1,1,1599.00,'2025-10-10','UPI','Success','TXN001'),
(2,2,2499.00,'2025-10-11','Credit Card','Success','TXN002');

-- 7. Update payment status for failed ones
UPDATE Payments
SET status='Failed'
WHERE amount > 3000 AND pay_method='Credit Card';

-- 8. Update amount by adding tax (Arithmetic operator)
UPDATE Payments
SET amount = amount + (amount * 0.18)
WHERE status='Success';

-- 9. Delete payments older than 2 years (Comparison + Logical)
DELETE FROM Payments
WHERE payment_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
  AND status='Failed';

-- 10. Insert refund entry for cancelled orders
INSERT INTO Payments (order_id, user_id, amount, payment_date, pay_method, status, transaction_id)
SELECT order_id, user_id, amount, CURDATE(), pay_method, 'Refunded', CONCAT('RFN_',transaction_id)
FROM Payments
WHERE status='Success' AND order_id IN (SELECT order_id FROM Orders WHERE order_status='Cancelled');

-- 11. List all successful payments (Aliases)
SELECT p.payment_id, u.full_name AS Customer, p.amount, p.status, p.pay_method
FROM Payments p
JOIN Users u ON p.user_id=u.user_id
WHERE p.status='Success'
ORDER BY p.amount DESC;

-- 12. Total amount received per payment method
SELECT pay_method AS Method, SUM(amount) AS TotalReceived
FROM Payments
WHERE status='Success'
GROUP BY pay_method
ORDER BY TotalReceived DESC;

-- 13. Average payment value by type (GROUP BY + Alias)
SELECT payment_type AS Type, ROUND(AVG(amount),2) AS AvgValue
FROM Payments
GROUP BY payment_type;

-- 14. Find users with total payment > 5000 (HAVING)
SELECT user_id, SUM(amount) AS TotalPaid
FROM Payments
GROUP BY user_id
HAVING SUM(amount) > 5000;

-- 15. Payments using BETWEEN for amount range
SELECT payment_id, amount, status
FROM Payments
WHERE amount BETWEEN 1000 AND 4000
ORDER BY amount ASC;

-- 16. Payments where status NOT IN (‘Success’, ‘Refunded’)
SELECT payment_id, status
FROM Payments
WHERE status NOT IN ('Success','Refunded');

-- 17. Monthly total collection (Arithmetic + GROUP BY)
SELECT MONTH(payment_date) AS MonthNum, SUM(amount) AS MonthlyCollection
FROM Payments
GROUP BY MONTH(payment_date)
ORDER BY MonthNum;

-- 18. Payment records joined with Orders (JOIN + Aliases)
SELECT p.payment_id, o.order_id, p.amount, o.order_status
FROM Payments p
JOIN Orders o ON p.order_id=o.order_id
WHERE o.order_status IN ('Delivered','Shipped');

-- 19. Find duplicate transaction IDs
SELECT transaction_id, COUNT(*) AS Occurrences
FROM Payments
GROUP BY transaction_id
HAVING COUNT(*) > 1;

-- 20. Cascade test — delete order should delete payment
INSERT INTO Orders (user_id, product_id, quantity, grand_total, pay_method, order_status, order_date)
VALUES (1,3,1,999.00,'UPI','Pending',CURDATE());
SET @oid = LAST_INSERT_ID();
INSERT INTO Payments (order_id, user_id, amount, payment_date, pay_method, status, transaction_id)
VALUES (@oid,1,999.00,CURDATE(),'UPI','Success','CASCADE_TEST');
DELETE FROM Orders WHERE order_id=@oid;  -- should auto-delete payment (ON DELETE CASCADE)




-- ========================= 7) Shipments Table ==============================

-- 1. Add column for delivery_speed
ALTER TABLE Shipments
ADD COLUMN delivery_speed ENUM('Standard','Fast','Express') DEFAULT 'Standard';

-- 2. Add ON DELETE / ON UPDATE CASCADE for order_id → Orders
ALTER TABLE Shipments DROP FOREIGN KEY fk_shipment_order;
ALTER TABLE Shipments
  ADD CONSTRAINT fk_shipment_order FOREIGN KEY (order_id)
  REFERENCES Orders(order_id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

-- 3. Add CHECK constraint for delivery_fee >= 0
ALTER TABLE Shipments
ADD CONSTRAINT chk_delivery_fee CHECK (delivery_fee >= 0);

-- 4. Create index on shipment_date
CREATE INDEX idx_shipment_date ON Shipments(shipment_date);

-- 5. Rename column tracking_no → tracking_number
ALTER TABLE Shipments CHANGE COLUMN tracking_no tracking_number VARCHAR(100);

-- 6. Insert new shipment records
INSERT INTO Shipments (order_id, user_id, shipment_date, delivery_fee, status, tracking_number)
VALUES
(1,1,'2025-10-12',120.00,'In Transit','TRK001'),
(2,2,'2025-10-13',90.00,'Delivered','TRK002');

-- 7. Update shipment fee using arithmetic operator
UPDATE Shipments
SET delivery_fee = delivery_fee + 20
WHERE status='In Transit';

-- 8. Update status for delivered shipments (Comparison)
UPDATE Shipments
SET status='Delivered'
WHERE shipment_date <= CURDATE() AND status!='Delivered';

-- 9. Delete cancelled shipments (Logical AND)
DELETE FROM Shipments
WHERE status='Cancelled' AND delivery_fee=0;

-- 10. Mark high-value shipments as Express (Special IN)
UPDATE Shipments
SET delivery_speed='Express'
WHERE order_id IN (SELECT order_id FROM Orders WHERE grand_total>5000);

-- 11. List shipments with user and order info (Aliases)
SELECT s.shipment_id, u.full_name AS Customer, o.order_id, s.status, s.delivery_fee
FROM Shipments s
JOIN Users u ON s.user_id=u.user_id
JOIN Orders o ON s.order_id=o.order_id
ORDER BY s.shipment_date DESC;

-- 12. Total delivery fees collected per month
SELECT MONTH(shipment_date) AS MonthNum, SUM(delivery_fee) AS TotalFee
FROM Shipments
GROUP BY MONTH(shipment_date)
ORDER BY MonthNum;

-- 13. Average delivery fee by speed (GROUP BY + Alias)
SELECT delivery_speed AS SpeedType, ROUND(AVG(delivery_fee),2) AS AvgFee
FROM Shipments
GROUP BY delivery_speed;

-- 14. Shipments with delivery_fee BETWEEN 100 and 200
SELECT shipment_id, delivery_fee, status
FROM Shipments
WHERE delivery_fee BETWEEN 100 AND 200;

-- 15. Count shipments by status (GROUP BY + HAVING)
SELECT status, COUNT(*) AS Total
FROM Shipments
GROUP BY status
HAVING COUNT(*)>0;

-- 16. Find shipments not yet delivered (Logical NOT)
SELECT shipment_id, order_id, status
FROM Shipments
WHERE NOT status='Delivered';

-- 17. Join shipments with Orders to show total order + fee (Arithmetic)
SELECT s.shipment_id, o.grand_total, (o.grand_total + s.delivery_fee) AS TotalWithFee
FROM Shipments s
JOIN Orders o ON s.order_id=o.order_id
ORDER BY TotalWithFee DESC
LIMIT 10;

-- 18. Cities with most shipments (JOIN + GROUP BY)
SELECT a.city, COUNT(s.shipment_id) AS ShipmentCount
FROM Shipments s
JOIN Delivery_Address a ON s.user_id=a.user_id
GROUP BY a.city
ORDER BY ShipmentCount DESC
LIMIT 5;

-- 19. Users having more than one shipment (HAVING)
SELECT user_id, COUNT(*) AS ShipCount
FROM Shipments
GROUP BY user_id
HAVING COUNT(*)>1;

-- 20. Cascade test — delete order should delete shipment
INSERT INTO Orders (user_id, product_id, quantity, grand_total, pay_method, order_status, order_date)
VALUES (1,4,1,1500.00,'UPI','Pending',CURDATE());
SET @oid2 = LAST_INSERT_ID();
INSERT INTO Shipments (order_id,user_id,shipment_date,delivery_fee,status,tracking_number)
VALUES (@oid2,1,CURDATE(),50.00,'In Transit','CASCADE_TRK');
DELETE FROM Orders WHERE order_id=@oid2;  -- shipment auto-deletes (ON DELETE CASCADE)




-- ---------------------------------- 8  Delivery_Address Table ------------------------------------------ 

-- 1. DDL: RENAME Column
ALTER TABLE Delivery_Address CHANGE COLUMN street_address line1 VARCHAR(500) NOT NULL;

-- 2. DDL: Add ON DELETE / ON UPDATE CASCADE for user_id → Users
ALTER TABLE Delivery_Address DROP FOREIGN KEY fk_delivery_address_user; -- Assuming a default key name
ALTER TABLE Delivery_Address
ADD CONSTRAINT fk_delivery_address_user FOREIGN KEY (user_id)
REFERENCES Users(user_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. DDL: DROP Column
ALTER TABLE Delivery_Address DROP COLUMN created_at;

-- 4. DDL: ADD Column with DEFAULT value
ALTER TABLE Delivery_Address
ADD COLUMN address_type ENUM('Home','Work','Other') DEFAULT 'Home';

-- 5. DDL: ADD CHECK constraint (Comparison)
ALTER TABLE Delivery_Address
ADD CONSTRAINT chk_zip_length CHECK (LENGTH(zip_code) = 6);

-- 6. DDL: CREATE INDEX on two columns for quick lookup
CREATE INDEX idx_city_state ON Delivery_Address(city, state);

-- 7. DDL: MODIFY Column to NOT NULL
ALTER TABLE Delivery_Address MODIFY COLUMN phone_number VARCHAR(15) NOT NULL;

-- 8. DDL: TRUNCATE Table (Used for cleanup/reset)
TRUNCATE TABLE Delivery_Address;

-- DML Queries (Data Manipulation Language)
-- 9. DML: INSERT (Single Record)
INSERT INTO Delivery_Address (user_id, recipient_name, phone_number, line1, city, state, zip_code, is_default)
VALUES (10, 'Komal Bhosale', '9812345670', '15, Valley View Apartments', 'Nashik', 'Maharashtra', '422002', TRUE);

-- 10. DML: INSERT (Multiple Records - Bulk)
INSERT INTO Delivery_Address (user_id, recipient_name, phone_number, line1, city, state, zip_code, address_type)
VALUES
(1, 'Rahul Sharma - Office', '9876543211', 'Tech Park, Hinjewadi', 'Pune', 'Maharashtra', '411057', 'Work'),
(3, 'Amit Kulkarni', '9988776655', 'Plot 45, IT Hub', 'Bangalore', 'Karnataka', '560001', 'Home');

-- 11. DML: UPDATE using Logical AND
UPDATE Delivery_Address
SET is_default = FALSE
WHERE user_id = 1 AND address_type = 'Work';

-- 12. DML: UPDATE using Special Operator IS NULL
UPDATE Delivery_Address
SET order_id = 99 -- Assign a temporary order ID
WHERE order_id IS NULL AND city = 'Nashik';

-- 13. DML: UPDATE using Comparison Operator
UPDATE Delivery_Address
SET recipient_name = CONCAT('Mr. ', recipient_name)
WHERE address_type = 'Work' AND recipient_name NOT LIKE 'Mr.%';

-- 14. DML: DELETE using Logical OR
DELETE FROM Delivery_Address
WHERE city = 'Pune' OR state = 'Karnataka';

-- 15. DML: DELETE using Special Operator LIKE
DELETE FROM Delivery_Address
WHERE line1 LIKE '%Temporary%';

-- 16. DML: ON UPDATE CASCADE Test (Update user_id in Parent)
-- Assumes user_id 1 exists in Users table
UPDATE Users
SET user_id = 101
WHERE user_id = 1;
-- The corresponding user_id in Delivery_Address will automatically update from 1 to 101.

-- DQL Queries (Data Query Language)
-- 17. DQL: Alias, JOIN, ORDER BY
SELECT
a.recipient_name AS Recipient,
u.email AS UserEmail,
a.city,
a.address_type
FROM Delivery_Address a
JOIN Users u ON a.user_id = u.user_id
ORDER BY a.zip_code ASC;

-- 18. DQL: Clauses (GROUP BY, COUNT)
SELECT
city,
COUNT(address_id) AS TotalAddresses
FROM Delivery_Address
GROUP BY city
ORDER BY TotalAddresses DESC
LIMIT 5;

-- 19. DQL: Clauses (HAVING, Comparison)
SELECT
state,
COUNT(address_id) AS AddressCount
FROM Delivery_Address
GROUP BY state
HAVING COUNT(address_id) > 1;

-- 20. DQL: Special Operator (IN)
SELECT recipient_name, line1
FROM Delivery_Address
WHERE address_type IN ('Home', 'Work');

-- 21. DQL: Special Operator (NOT IN)
SELECT recipient_name, city
FROM Delivery_Address
WHERE user_id NOT IN (SELECT user_id FROM Users WHERE status = 'Suspended');

-- 22. DQL: Special Operator (BETWEEN)
SELECT address_id, zip_code
FROM Delivery_Address
WHERE zip_code BETWEEN '400000' AND '500000';

-- 23. DQL: Arithmetic Operator (String Concatenation)
SELECT
address_id,
recipient_name,
CONCAT(city, ' - ', zip_code) AS LocationDetail
FROM Delivery_Address
WHERE is_default = TRUE;

-- 24. DQL: Logical Operator (NOT)
SELECT user_id, recipient_name, line1
FROM Delivery_Address
WHERE NOT is_default = TRUE;

-- 25. Cascade Test — delete user should delete all their addresses (ON DELETE CASCADE)
INSERT INTO Users (user_id, email, phone, first_name, last_name, gender, dob, status, city_id)
VALUES (999, 'test@delete.com', '9999999999', 'Test', 'User', 'Male', '2000-01-01', 'Active', 101);
SET @uid = LAST_INSERT_ID();
INSERT INTO Delivery_Address (user_id, recipient_name, phone_number, line1, city, state, zip_code, is_default)
VALUES (@uid, 'Test Delete Address', '9876543210', 'Test Line', 'Test City', 'Test State', '111111', TRUE);
DELETE FROM Users WHERE user_id = @uid; -- Address auto-deletes (ON DELETE CASCADE)
SELECT * FROM Delivery_Address WHERE user_id = @uid; -- Check to confirm no records are found


-- --------------------------------  9 Cities Table ----------------------------
-- 1. Add a column for region
ALTER TABLE Cities
ADD COLUMN region VARCHAR(50);

-- 2. Add ON DELETE / ON UPDATE CASCADE for country_name → Countries table
-- (Assuming a Countries table exists)
ALTER TABLE Cities DROP FOREIGN KEY fk_cities_country;
ALTER TABLE Cities
ADD CONSTRAINT fk_cities_country FOREIGN KEY (country_name)
REFERENCES Countries(country_name)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add CHECK constraint to ensure population >= 0
ALTER TABLE Cities
ADD CONSTRAINT chk_population_positive CHECK (population >= 0);

-- 4. Add column for mayor_name
ALTER TABLE Cities
ADD COLUMN mayor_name VARCHAR(100);

-- 5. Create index on state_name for faster queries
CREATE INDEX idx_city_state ON Cities(state_name);

-- 6. Insert sample cities
INSERT INTO Cities (city_name, state_name, country_name, postal_code_prefix, population, is_metro, timezone)
VALUES
('Guwahati','Assam','India','781',1000000,FALSE,'IST'),
('Vadodara','Gujarat','India','390',2000000,FALSE,'IST');

-- 7. Update timezone for all cities in Maharashtra
UPDATE Cities
SET timezone='IST+0'
WHERE state_name='Maharashtra';

-- 8. Update population for Thane (Comparison)
UPDATE Cities
SET population=2200000
WHERE city_name='Thane' AND population < 2200000;

-- 9. Delete cities with population < 1 million (Logical AND)
DELETE FROM Cities
WHERE population < 1000000 AND is_metro=FALSE;

-- 10. Change city_name to proper case
UPDATE Cities
SET city_name = CONCAT(UPPER(LEFT(city_name,1)),LOWER(SUBSTRING(city_name,2)));

-- 11. List cities with aliases
SELECT city_id AS ID, city_name AS City, state_name AS State, population AS Pop
FROM Cities
ORDER BY population DESC;

-- 12. Count cities per state (GROUP BY + Alias)
SELECT state_name, COUNT(city_id) AS TotalCities
FROM Cities
GROUP BY state_name
ORDER BY TotalCities DESC;

-- 13. States having more than 3 cities (HAVING)
SELECT state_name, COUNT(city_id) AS TotalCities
FROM Cities
GROUP BY state_name
HAVING COUNT(city_id) > 3;

-- 14. Cities starting with 'B' (LIKE)
SELECT city_id, city_name
FROM Cities
WHERE city_name LIKE 'B%';

-- 15. Metro cities (Logical OR + Comparison)
SELECT city_name, population
FROM Cities
WHERE is_metro=TRUE OR population>10000000;

-- 16. Average population per state (Arithmetic + GROUP BY)
SELECT state_name, AVG(population) AS AvgPop
FROM Cities
GROUP BY state_name
ORDER BY AvgPop DESC;

-- 17. Cities not in Maharashtra (Logical NOT)
SELECT city_name, state_name
FROM Cities
WHERE NOT state_name='Maharashtra';

-- 18. Distinct states (DISTINCT + ORDER BY)
SELECT DISTINCT state_name
FROM Cities
ORDER BY state_name;

-- 19. Count cities by is_metro (GROUP BY)
SELECT is_metro AS MetroStatus, COUNT(*) AS CountCities
FROM Cities
GROUP BY is_metro;

-- 20. Cascade test — delete country should delete cities
INSERT INTO Countries (country_name, continent)
VALUES ('Testland','Asia');
INSERT INTO Cities (city_name,state_name,country_name,population)
VALUES ('TestCity','TestState','Testland',500000);

DELETE FROM Countries WHERE country_name='Testland';  -- City auto-deletes (ON DELETE CASCADE)


-- ------------------------------------ 10 SELLERS ------------------------------------------------

-- 1. Add a column for seller_type
ALTER TABLE Sellers
ADD COLUMN seller_type ENUM('Individual','Company') DEFAULT 'Company';

-- 2. Add ON DELETE / ON UPDATE CASCADE for city_id → Cities
ALTER TABLE Sellers DROP FOREIGN KEY fk_seller_city;
ALTER TABLE Sellers
ADD CONSTRAINT fk_seller_city FOREIGN KEY (city_id)
REFERENCES Cities(city_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add CHECK constraint to ensure rating is between 0 and 5
ALTER TABLE Sellers
ADD CONSTRAINT chk_rating CHECK (rating >= 0 AND rating <= 5);

-- 4. Add column for website URL
ALTER TABLE Sellers
ADD COLUMN website VARCHAR(150);

-- 5. Create index on seller_name
CREATE INDEX idx_seller_name ON Sellers(seller_name);

-- 6. Insert sample sellers
INSERT INTO Sellers (seller_name, email, phone, gst_number, pan_number, address, city_id, rating, status)
VALUES
('EcoStore', 'eco@store.com', '9876543230', 'GSTIN12365', 'PAN1234U', 'Green Street, Mumbai', 1, 4.3, 'Active'),
('QuickShop', 'quick@shop.com', '9876543231', 'GSTIN12366', 'PAN1234V', 'MG Road, Pune', 7, 4.1, 'Active');

-- 7. Update status of inactive sellers
UPDATE Sellers
SET status='Active'
WHERE status='Inactive';

-- 8. Update rating for top sellers (Comparison)
UPDATE Sellers
SET rating=5.0
WHERE seller_name='GameZone' AND rating<5.0;

-- 9. Delete sellers with rating < 3.5 (Logical AND)
DELETE FROM Sellers
WHERE rating < 3.5 AND status='Inactive';

-- 10. Change seller_name to proper case
UPDATE Sellers
SET seller_name = CONCAT(UPPER(LEFT(seller_name,1)),LOWER(SUBSTRING(seller_name,2)));

-- 11. List sellers with city names (Aliases + JOIN)
SELECT s.seller_id AS SellerID, s.seller_name AS Seller, c.city_name AS City, s.rating
FROM Sellers s
JOIN Cities c ON s.city_id = c.city_id
ORDER BY s.rating DESC;

-- 12. Count sellers per city (GROUP BY + Alias)
SELECT city_id, COUNT(seller_id) AS TotalSellers
FROM Sellers
GROUP BY city_id
ORDER BY TotalSellers DESC;

-- 13. Cities having more than 2 sellers (HAVING)
SELECT city_id, COUNT(seller_id) AS TotalSellers
FROM Sellers
GROUP BY city_id
HAVING COUNT(seller_id) > 2;

-- 14. Sellers starting with 'S' (LIKE)
SELECT seller_id, seller_name
FROM Sellers
WHERE seller_name LIKE 'S%';

-- 15. Top rated sellers (Logical OR)
SELECT seller_name, rating
FROM Sellers
WHERE rating >= 4.5 OR status='Active';

-- 16. Average rating per city (Arithmetic + GROUP BY)
SELECT city_id, AVG(rating) AS AvgRating
FROM Sellers
GROUP BY city_id
ORDER BY AvgRating DESC;

-- 17. Sellers not in Maharashtra (Logical NOT)
SELECT seller_name, city_id
FROM Sellers
WHERE NOT city_id IN (SELECT city_id FROM Cities WHERE state_name='Maharashtra');

-- 18. Distinct seller statuses (DISTINCT + ORDER BY)
SELECT DISTINCT status
FROM Sellers
ORDER BY status;

-- 19. Count sellers by status (GROUP BY)
SELECT status AS SellerStatus, COUNT(*) AS CountSellers
FROM Sellers
GROUP BY status;

-- 20. Cascade test — delete city should delete sellers
INSERT INTO Cities (city_name, state_name, country_name, postal_code_prefix, population)
VALUES ('TestCity2','TestState','India','999',50000);

SET @city_id_test = LAST_INSERT_ID();
INSERT INTO Sellers (seller_name,email,phone,gst_number,pan_number,address,city_id,rating,status)
VALUES ('TestSeller','test@seller.com','9876543232','GST12367','PAN1234W','Test Address',@city_id_test,4.0,'Active');

DELETE FROM Cities WHERE city_id=@city_id_test;  -- Seller auto-deletes (ON DELETE CASCADE)


-- ----------------------------------------- 11 INVENTORY---------------------------------------------------

-- 1. Add column for inventory_type
ALTER TABLE Inventory
ADD COLUMN inventory_type ENUM('Regular','Seasonal','Clearance') DEFAULT 'Regular';

-- 2. Add ON DELETE / ON UPDATE CASCADE for seller_id → Sellers
ALTER TABLE Inventory DROP FOREIGN KEY fk_inventory_seller;
ALTER TABLE Inventory
ADD CONSTRAINT fk_inventory_seller FOREIGN KEY (seller_id)
REFERENCES Sellers(seller_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add ON DELETE / ON UPDATE CASCADE for product_id → Products
ALTER TABLE Inventory DROP FOREIGN KEY fk_inventory_product;
ALTER TABLE Inventory
ADD CONSTRAINT fk_inventory_product FOREIGN KEY (product_id)
REFERENCES Products(product_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 4. Add CHECK constraint to ensure reorder_level >= 0
ALTER TABLE Inventory
ADD CONSTRAINT chk_reorder_level CHECK (reorder_level >= 0);

-- 5. Create index on warehouse_location
CREATE INDEX idx_inventory_warehouse ON Inventory(warehouse_location);

-- 6. Insert sample inventory records
INSERT INTO Inventory (product_id, seller_id, stock_quantity, reserved_quantity, warehouse_location, restock_date, status, reorder_level)
VALUES
(21, 1, 30, 2, 'Mumbai Warehouse B', '2025-09-01', 'In Stock', 10),
(22, 2, 5, 1, 'Delhi Warehouse C', '2025-09-03', 'Low Stock', 5);

-- 7. Update stock_quantity after new shipment
UPDATE Inventory
SET stock_quantity = stock_quantity + 50, status='In Stock'
WHERE warehouse_location='Pune Warehouse G';

-- 8. Update reserved_quantity for pending orders
UPDATE Inventory
SET reserved_quantity = reserved_quantity + 5
WHERE product_id=3 AND stock_quantity > 0;

-- 9. Delete inventory entries with 0 stock and 0 reserved (Logical AND)
DELETE FROM Inventory
WHERE stock_quantity=0 AND reserved_quantity=0;

-- 10. Change warehouse_location names to proper case
UPDATE Inventory
SET warehouse_location = CONCAT(UPPER(LEFT(warehouse_location,1)),LOWER(SUBSTRING(warehouse_location,2)));

-- 11. List inventory with seller names (JOIN + Alias)
SELECT i.inventory_id AS InventoryID, s.seller_name AS Seller, i.warehouse_location AS Warehouse, i.stock_quantity AS Stock
FROM Inventory i
JOIN Sellers s ON i.seller_id = s.seller_id
ORDER BY i.stock_quantity DESC;

-- 12. Count products per seller (GROUP BY + Alias)
SELECT seller_id, COUNT(product_id) AS TotalProducts
FROM Inventory
GROUP BY seller_id
ORDER BY TotalProducts DESC;

-- 13. Sellers having more than 3 products (HAVING)
SELECT seller_id, COUNT(product_id) AS TotalProducts
FROM Inventory
GROUP BY seller_id
HAVING COUNT(product_id) > 3;

-- 14. Warehouses starting with 'B' (LIKE)
SELECT inventory_id, warehouse_location
FROM Inventory
WHERE warehouse_location LIKE 'B%';

-- 15. Low or out of stock products (Logical OR)
SELECT inventory_id, product_id, stock_quantity, status
FROM Inventory
WHERE status='Low Stock' OR status='Out of Stock';

-- 16. Average stock per warehouse (Arithmetic + GROUP BY)
SELECT warehouse_location, AVG(stock_quantity) AS AvgStock
FROM Inventory
GROUP BY warehouse_location
ORDER BY AvgStock DESC;

-- 17. Inventory not in 'Maharashtra' cities (Logical NOT + JOIN)
SELECT i.inventory_id, i.warehouse_location, c.state_name
FROM Inventory i
JOIN Cities c ON i.seller_id = c.city_id
WHERE NOT c.state_name='Maharashtra';

-- 18. Distinct inventory statuses (DISTINCT + ORDER BY)
SELECT DISTINCT status
FROM Inventory
ORDER BY status;

-- 19. Count products by status (GROUP BY)
SELECT status AS StockStatus, COUNT(*) AS CountProducts
FROM Inventory
GROUP BY status;

-- 20. Cascade test — delete seller should delete inventory
INSERT INTO Sellers (seller_name,email,phone,gst_number,pan_number,address,city_id,rating,status)
VALUES ('TestSellerInv','testinv@seller.com','9876543233','GST12368','PAN1234X','Test Address','1',4.0,'Active');

SET @seller_test = LAST_INSERT_ID();

INSERT INTO Inventory (product_id,seller_id,stock_quantity,warehouse_location,status)
VALUES (1,@seller_test,50,'Test Warehouse','In Stock');

DELETE FROM Sellers WHERE seller_id=@seller_test;  -- Inventory auto-deletes (ON DELETE CASCADE)


-- ------------------------------------- 12 Cart_Items Table------------------------------------ 

-- 1. Add a column for cart_item_type
ALTER TABLE Cart_Items
ADD COLUMN cart_item_type ENUM('Normal','Gift','Promotional') DEFAULT 'Normal';

-- 2. Add ON DELETE / ON UPDATE CASCADE for cart_id → Carts
ALTER TABLE Cart_Items
ADD CONSTRAINT fk_cart_items_cart FOREIGN KEY (cart_id)
REFERENCES Carts(cart_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add ON DELETE / ON UPDATE CASCADE for product_id → Products
ALTER TABLE Cart_Items
ADD CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id)
REFERENCES Products(product_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 4. Add CHECK constraint to ensure quantity > 0
ALTER TABLE Cart_Items
ADD CONSTRAINT chk_quantity_positive CHECK (quantity > 0);

-- 5. Create index on cart_id
CREATE INDEX idx_cart_id ON Cart_Items(cart_id);

-- 6. Insert sample cart items
INSERT INTO Cart_Items (cart_id, product_id, quantity, price, discount, status)
VALUES
(11, 21, 1, 499.00, 0.00, 'Active'),
(11, 22, 2, 799.00, 10.00, 'Active');

-- 7. Update quantity for a product in cart
UPDATE Cart_Items
SET quantity = quantity + 1
WHERE cart_id = 1 AND product_id = 1;

-- 8. Update discount for promotional items
UPDATE Cart_Items
SET discount = 20.00
WHERE cart_item_type='Promotional';

-- 9. Delete removed items (Logical AND)
DELETE FROM Cart_Items
WHERE status='Removed' AND quantity=1;

-- 10. Change cart_item_type to proper case (if using string function)
UPDATE Cart_Items
SET cart_item_type = CONCAT(UPPER(LEFT(cart_item_type,1)),LOWER(SUBSTRING(cart_item_type,2)));

-- 11. List cart items with product names and prices (JOIN + Alias)
SELECT ci.cart_item_id AS ItemID, p.product_name AS Product, ci.quantity AS Qty, ci.price AS Price
FROM Cart_Items ci
JOIN Products p ON ci.product_id = p.product_id
ORDER BY ci.cart_id, ci.added_at DESC;

-- 12. Count items per cart (GROUP BY + Alias)
SELECT cart_id, COUNT(cart_item_id) AS TotalItems
FROM Cart_Items
GROUP BY cart_id
ORDER BY TotalItems DESC;

-- 13. Carts having more than 2 items (HAVING)
SELECT cart_id, COUNT(cart_item_id) AS TotalItems
FROM Cart_Items
GROUP BY cart_id
HAVING COUNT(cart_item_id) > 2;

-- 14. Products starting with 'B' in cart (LIKE)
SELECT cart_item_id, product_id
FROM Cart_Items ci
JOIN Products p ON ci.product_id = p.product_id
WHERE p.product_name LIKE 'B%';

-- 15. Active or saved items (Logical OR)
SELECT cart_item_id, cart_id, status
FROM Cart_Items
WHERE status='Active' OR status='Saved for Later';

-- 16. Average price per cart (Arithmetic + GROUP BY)
SELECT cart_id, AVG(price) AS AvgPrice
FROM Cart_Items
GROUP BY cart_id
ORDER BY AvgPrice DESC;

-- 17. Items not in 'Active' status (Logical NOT)
SELECT cart_item_id, cart_id, status
FROM Cart_Items
WHERE NOT status='Active';

-- 18. Distinct statuses (DISTINCT + ORDER BY)
SELECT DISTINCT status
FROM Cart_Items
ORDER BY status;

-- 19. Count items by status (GROUP BY)
SELECT status AS ItemStatus, COUNT(*) AS CountItems
FROM Cart_Items
GROUP BY status;

-- 20. Cascade test — delete cart should delete items
INSERT INTO Carts (user_id, created_at, status)
VALUES (1, CURRENT_TIMESTAMP, 'Active');

SET @cart_test = LAST_INSERT_ID();

INSERT INTO Cart_Items (cart_id, product_id, quantity, price)
VALUES (@cart_test, 1, 2, 499.00);

DELETE FROM Carts WHERE cart_id=@cart_test;  -- Items auto-deletes (ON DELETE CASCADE)



-- ------------------------------- 13 Reviews-------------------------------------------------------------------------- 


-- 1. Add column for review_type
ALTER TABLE Reviews
ADD COLUMN review_type ENUM('Positive','Neutral','Negative') DEFAULT 'Positive';

-- 2. Add ON DELETE / ON UPDATE CASCADE for user_id → Users
ALTER TABLE Reviews DROP FOREIGN KEY Reviews_ibfk_1;
ALTER TABLE Reviews
ADD CONSTRAINT fk_reviews_user FOREIGN KEY (user_id)
REFERENCES Users(user_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add ON DELETE / ON UPDATE CASCADE for product_id → Products
ALTER TABLE Reviews
ADD CONSTRAINT fk_reviews_product FOREIGN KEY (product_id)
REFERENCES Products(product_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 4. Add CHECK constraint to ensure rating between 1 and 5
ALTER TABLE Reviews
ADD CONSTRAINT chk_rating_range CHECK (rating BETWEEN 1 AND 5);

-- 5. Create index on review_date
CREATE INDEX idx_review_date ON Reviews(review_date);

-- 6. Insert sample reviews
INSERT INTO Reviews (user_id, product_id, order_id, rating, review_text, review_date, is_verified, helpful_votes, status)
VALUES
(21, 121, 5021, 4, 'Good product, works well.', '2024-03-01', TRUE, 3, 'Active'),
(22, 122, 5022, 5, 'Excellent quality, highly recommend!', '2024-03-02', TRUE, 7, 'Active');

-- 7. Update helpful_votes for useful reviews
UPDATE Reviews
SET helpful_votes = helpful_votes + 1
WHERE rating>=4;

-- 8. Update status for old reviews (Comparison)
UPDATE Reviews
SET status='Inactive'
WHERE review_date < '2024-01-01';

-- 9. Delete unverified reviews with rating <= 2 (Logical AND)
DELETE FROM Reviews
WHERE is_verified=FALSE AND rating <=2;

-- 10. Update review_type based on rating
UPDATE Reviews
SET review_type = CASE 
    WHEN rating>=4 THEN 'Positive'
    WHEN rating=3 THEN 'Neutral'
    ELSE 'Negative'
END;

-- 11. List reviews with user and product names (JOIN + Alias)
SELECT r.review_id AS ReviewID, u.full_name AS UserName, p.product_name AS Product, r.rating, r.review_text
FROM Reviews r
JOIN Users u ON r.user_id = u.user_id
JOIN Products p ON r.product_id = p.product_id
ORDER BY r.review_date DESC;

-- 12. Count reviews per product (GROUP BY + Alias)
SELECT product_id, COUNT(review_id) AS TotalReviews
FROM Reviews
GROUP BY product_id
ORDER BY TotalReviews DESC;

-- 13. Products having more than 2 reviews (HAVING)
SELECT product_id, COUNT(review_id) AS TotalReviews
FROM Reviews
GROUP BY product_id
HAVING COUNT(review_id) > 2;

-- 14. Reviews containing 'good' in text (LIKE)
SELECT review_id, review_text
FROM Reviews
WHERE review_text LIKE '%good%';

-- 15. Verified or positive reviews (Logical OR)
SELECT review_id, rating, is_verified
FROM Reviews
WHERE is_verified=TRUE OR review_type='Positive';

-- 16. Average rating per product (Arithmetic + GROUP BY)
SELECT product_id, AVG(rating) AS AvgRating
FROM Reviews
GROUP BY product_id
ORDER BY AvgRating DESC;

-- 17. Reviews not active (Logical NOT)
SELECT review_id, status
FROM Reviews
WHERE NOT status='Active';

-- 18. Distinct review types (DISTINCT + ORDER BY)
SELECT DISTINCT review_type
FROM Reviews
ORDER BY review_type;

-- 19. Count reviews by status (GROUP BY)
SELECT status AS ReviewStatus, COUNT(*) AS CountReviews
FROM Reviews
GROUP BY status;

-- 20. Cascade test — delete user should delete reviews
INSERT INTO Users (email, phone, first_name, last_name, gender, dob, account_status, city_id)
VALUES ('testreview@amazon.in','9898989899','Test','User','Other','2000-01-01','Active',101);

SET @user_test = LAST_INSERT_ID();

INSERT INTO Reviews (user_id, product_id, order_id, rating, review_text, review_date)
VALUES (@user_test,1,6001,5,'Great product','2024-03-10');

DELETE FROM Users WHERE user_id=@user_test;  -- Reviews auto-deletes (ON DELETE CASCADE)



-- ------------------------------- 14 RATINGS -------------------------------------------------------------------------- 


-- 1. Add column for rating_type
ALTER TABLE Ratings
ADD COLUMN rating_type ENUM('Positive','Neutral','Negative') DEFAULT 'Positive';

-- 2. Add ON DELETE / ON UPDATE CASCADE for user_id → Users
ALTER TABLE Ratings DROP FOREIGN KEY Ratings_ibfk_1;
ALTER TABLE Ratings
ADD CONSTRAINT fk_ratings_user FOREIGN KEY (user_id)
REFERENCES Users(user_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add ON DELETE / ON UPDATE CASCADE for product_id → Products
ALTER TABLE Ratings DROP FOREIGN KEY Ratings_ibfk_2;
ALTER TABLE Ratings
ADD CONSTRAINT fk_ratings_product FOREIGN KEY (product_id)
REFERENCES Products(product_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 4. Add ON DELETE / ON UPDATE CASCADE for review_id → Reviews
ALTER TABLE Ratings DROP FOREIGN KEY Ratings_ibfk_3;
ALTER TABLE Ratings
ADD CONSTRAINT fk_ratings_review FOREIGN KEY (review_id)
REFERENCES Reviews(review_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 5. Add CHECK constraint for stars between 1 and 5
ALTER TABLE Ratings
ADD CONSTRAINT chk_stars_range CHECK (stars BETWEEN 1 AND 5);

-- 6. Create index on rating_date
CREATE INDEX idx_rating_date ON Ratings(rating_date);

-- 7. Insert sample ratings
INSERT INTO Ratings (rating_id, user_id, product_id, stars, rating_date, review_id, status)
VALUES
(31, 21, 106, 5, '2024-03-01', 21, 'Active'),
(32, 22, 107, 4, '2024-03-02', 22, 'Active');

-- 8. Update stars for product improvements
UPDATE Ratings
SET stars = stars + 1
WHERE stars < 5;

-- 9. Update status for old ratings
UPDATE Ratings
SET status='Inactive'
WHERE rating_date < '2024-01-01';

-- 10. Delete inactive ratings with stars <= 2 (Logical AND)
DELETE FROM Ratings
WHERE status='Inactive' AND stars <=2;

-- 11. Change rating_type based on stars
UPDATE Ratings
SET rating_type = CASE
    WHEN stars>=4 THEN 'Positive'
    WHEN stars=3 THEN 'Neutral'
    ELSE 'Negative'
END;

-- 12. List ratings with user and product names (JOIN + Alias)
SELECT r.rating_id AS RatingID, u.full_name AS UserName, p.product_name AS Product, r.stars, r.status
FROM Ratings r
JOIN Users u ON r.user_id = u.user_id
JOIN Products p ON r.product_id = p.product_id
ORDER BY r.rating_date DESC;

-- 13. Count ratings per product (GROUP BY + Alias)
SELECT product_id, COUNT(rating_id) AS TotalRatings
FROM Ratings
GROUP BY product_id
ORDER BY TotalRatings DESC;

-- 14. Products having average stars >=4 (GROUP BY + HAVING)
SELECT product_id, AVG(stars) AS AvgStars
FROM Ratings
GROUP BY product_id
HAVING AVG(stars) >= 4;

-- 15. Ratings for stars 4 or 5 (Logical OR)
SELECT rating_id, stars
FROM Ratings
WHERE stars=4 OR stars=5;

-- 16. Average stars per user (Arithmetic + GROUP BY)
SELECT user_id, AVG(stars) AS AvgStars
FROM Ratings
GROUP BY user_id
ORDER BY AvgStars DESC;

-- 17. Ratings not active (Logical NOT)
SELECT rating_id, status
FROM Ratings
WHERE NOT status='Active';

-- 18. Distinct rating types (DISTINCT + ORDER BY)
SELECT DISTINCT rating_type
FROM Ratings
ORDER BY rating_type;

-- 19. Count ratings by status (GROUP BY)
SELECT status AS RatingStatus, COUNT(*) AS CountRatings
FROM Ratings
GROUP BY status;

-- 20. Cascade test — delete user should delete ratings
INSERT INTO Users (email, phone, first_name, last_name, gender, dob, account_status, city_id)
VALUES ('testrating@amazon.in','9898989999','Test','Rating','Other','2000-01-01','Active',101);

SET @user_test = LAST_INSERT_ID();

INSERT INTO Ratings (rating_id, user_id, product_id, stars, rating_date)
VALUES (33,@user_test,1,5,'2024-03-10');

DELETE FROM Users WHERE user_id=@user_test;  -- Ratings auto-delete (ON DELETE CASCADE)

-- ------------------------------- 15 WISHLIST TABLE ----------------------------------

-- 1. Add column for wishlist_type
ALTER TABLE Wishlist
ADD COLUMN wishlist_type ENUM('Personal','Gift','Shared') DEFAULT 'Personal';

-- 2. Add ON DELETE / ON UPDATE CASCADE for user_id → Users
ALTER TABLE Wishlist DROP FOREIGN KEY Wishlist_ibfk_1;
ALTER TABLE Wishlist
ADD CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id)
REFERENCES Users(user_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add index on date_added
CREATE INDEX idx_wishlist_date ON Wishlist(date_added);

-- 4. Insert additional sample wishlist items
INSERT INTO Wishlist (user_id, date_added, status, wishlist_type) VALUES
(4, '2024-01-08', 'Active', 'Gift'),
(5, '2024-01-09', 'Active', 'Shared');

-- 5. Update status for old wishlist items
UPDATE Wishlist
SET status='Inactive'
WHERE date_added < '2024-01-01';

-- 6. Delete inactive wishlist items (Logical AND)
DELETE FROM Wishlist
WHERE status='Inactive';

-- 7. Change wishlist_type based on user preference
UPDATE Wishlist
SET wishlist_type = CASE
    WHEN user_id IN (1,2) THEN 'Gift'
    ELSE 'Personal'
END;

-- 8. List wishlist items with user names (JOIN + Alias)
SELECT w.wishlist_id AS WishlistID, u.full_name AS UserName, w.date_added, w.status
FROM Wishlist w
JOIN Users u ON w.user_id = u.user_id
ORDER BY w.date_added DESC;

-- 9. Count wishlist items per user (GROUP BY + Alias)
SELECT user_id, COUNT(wishlist_id) AS TotalItems
FROM Wishlist
GROUP BY user_id
ORDER BY TotalItems DESC;

-- 10. Users having more than 1 wishlist item (HAVING)
SELECT user_id, COUNT(wishlist_id) AS TotalItems
FROM Wishlist
GROUP BY user_id
HAVING COUNT(wishlist_id) > 1;

-- 11. Wishlist added in January 2024 (LIKE or BETWEEN)
SELECT wishlist_id, date_added
FROM Wishlist
WHERE date_added BETWEEN '2024-01-01' AND '2024-01-31';

-- 12. Active or shared wishlist items (Logical OR)
SELECT wishlist_id, status, wishlist_type
FROM Wishlist
WHERE status='Active' OR wishlist_type='Shared';

-- 13. Count wishlist items by type (GROUP BY)
SELECT wishlist_type AS Type, COUNT(*) AS CountItems
FROM Wishlist
GROUP BY wishlist_type;

-- 14. Distinct statuses (DISTINCT + ORDER BY)
SELECT DISTINCT status
FROM Wishlist
ORDER BY status;

-- 15. Update wishlist_type to proper case (String functions)
UPDATE Wishlist
SET wishlist_type = CONCAT(UPPER(LEFT(wishlist_type,1)),LOWER(SUBSTRING(wishlist_type,2)));

-- 16. Delete wishlist for a specific user
DELETE FROM Wishlist
WHERE user_id=5;

-- 17. Count total wishlist items (Aggregate)
SELECT COUNT(*) AS TotalWishlistItems
FROM Wishlist;

-- 18. List wishlist items not active (Logical NOT)
SELECT wishlist_id, status
FROM Wishlist
WHERE NOT status='Active';

-- 19. Average number of wishlist items per user (Arithmetic)
SELECT AVG(TotalItems) AS AvgWishlistItems
FROM (
    SELECT user_id, COUNT(wishlist_id) AS TotalItems
    FROM Wishlist
    GROUP BY user_id
) AS SubQuery;

-- 20. Cascade test — delete user should delete wishlist
INSERT INTO Users (email, phone, first_name, last_name, gender, dob, account_status, city_id)
VALUES ('testwishlist@amazon.in','9898989988','Test','Wishlist','Other','2000-01-01','Active',101);

SET @user_test = LAST_INSERT_ID();

INSERT INTO Wishlist (user_id, date_added)
VALUES (@user_test, '2024-03-10');

DELETE FROM Users WHERE user_id=@user_test;  -- Wishlist auto-deletes (ON DELETE CASCADE)



-- ------------------------------- 16 WISHLIST_ITEMS -------------------------------------------------------------------------- 


USE Amazon;

-- 1. Add column for item_status
ALTER TABLE Wishlist_Items
ADD COLUMN item_status ENUM('Active','Purchased','Removed') DEFAULT 'Active';

-- 2. Add ON DELETE / ON UPDATE CASCADE for wishlist_id → Wishlist
ALTER TABLE Wishlist_Items DROP FOREIGN KEY Wishlist_Items_ibfk_1;
ALTER TABLE Wishlist_Items
ADD CONSTRAINT fk_wishlist_items_wishlist FOREIGN KEY (wishlist_id)
REFERENCES Wishlist(wishlist_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 3. Add CHECK constraint for quantity > 0
ALTER TABLE Wishlist_Items
ADD CONSTRAINT chk_quantity_positive CHECK (quantity > 0);

-- 4. Create index on added_date
CREATE INDEX idx_wishlist_items_date ON Wishlist_Items(added_date);

-- 5. Insert additional sample wishlist items
INSERT INTO Wishlist_Items (wishlist_id, added_date, quantity, notes, item_status) VALUES
(2, '2024-02-03', 1, 'Smartwatch', 'Active'),
(1, '2024-02-04', 2, 'Bluetooth speaker', 'Active');

-- 6. Update quantity for specific items
UPDATE Wishlist_Items
SET quantity = quantity + 1
WHERE notes LIKE '%mobile%';

-- 7. Update item_status for purchased items
UPDATE Wishlist_Items
SET item_status='Purchased'
WHERE added_date < '2024-01-15';

-- 8. Delete removed items (Logical AND)
DELETE FROM Wishlist_Items
WHERE item_status='Removed' AND quantity=0;

-- 9. Change item_status based on quantity
UPDATE Wishlist_Items
SET item_status = CASE 
    WHEN quantity>1 THEN 'Active'
    ELSE 'Purchased'
END;

-- 10. List wishlist items with user name and wishlist date (JOIN + Alias)
SELECT wi.wishlist_item_id AS ItemID, u.full_name AS UserName, w.date_added AS WishlistDate, wi.notes, wi.quantity
FROM Wishlist_Items wi
JOIN Wishlist w ON wi.wishlist_id = w.wishlist_id
JOIN Users u ON w.user_id = u.user_id
ORDER BY wi.added_date DESC;

-- 11. Count items per wishlist (GROUP BY + Alias)
SELECT wishlist_id, COUNT(wishlist_item_id) AS TotalItems
FROM Wishlist_Items
GROUP BY wishlist_id
ORDER BY TotalItems DESC;

-- 12. Wishlists having more than 3 items (GROUP BY + HAVING)
SELECT wishlist_id, COUNT(wishlist_item_id) AS TotalItems
FROM Wishlist_Items
GROUP BY wishlist_id
HAVING COUNT(wishlist_item_id) > 3;

-- 13. Items with notes containing 'gift' (LIKE)
SELECT wishlist_item_id, notes
FROM Wishlist_Items
WHERE notes LIKE '%gift%';

-- 14. Active or purchased items (Logical OR)
SELECT wishlist_item_id, item_status
FROM Wishlist_Items
WHERE item_status='Active' OR item_status='Purchased';

-- 15. Total quantity per wishlist (Arithmetic + GROUP BY)
SELECT wishlist_id, SUM(quantity) AS TotalQuantity
FROM Wishlist_Items
GROUP BY wishlist_id;

-- 16. Items not active (Logical NOT)
SELECT wishlist_item_id, item_status
FROM Wishlist_Items
WHERE NOT item_status='Active';

-- 17. Distinct item_status (DISTINCT + ORDER BY)
SELECT DISTINCT item_status
FROM Wishlist_Items
ORDER BY item_status;

-- 18. Delete wishlist items for a specific wishlist
DELETE FROM Wishlist_Items
WHERE wishlist_id=2;

-- 19. Average quantity per wishlist (Arithmetic + Subquery)
SELECT AVG(TotalQuantity) AS AvgQuantity
FROM (
    SELECT wishlist_id, SUM(quantity) AS TotalQuantity
    FROM Wishlist_Items
    GROUP BY wishlist_id
) AS SubQuery;

-- 20. Cascade test — delete wishlist should delete items
INSERT INTO Wishlist (user_id, date_added)
VALUES (1, '2024-03-10');

SET @wishlist_test = LAST_INSERT_ID();

INSERT INTO Wishlist_Items (wishlist_id, added_date, quantity, notes)
VALUES (@wishlist_test, '2024-03-12', 1, 'Test Item');

DELETE FROM Wishlist WHERE wishlist_id=@wishlist_test;  -- Items auto-delete (ON DELETE CASCADE)



-- ------------------------------- 17 OFFERS -------------------------------------------------------------------------- 

-- 1. Add column for offer_type
ALTER TABLE Offers
ADD COLUMN offer_type ENUM('Seasonal','New User','Festive','Flash Sale') DEFAULT 'Seasonal';

-- 2. Add index on start_date and end_date
CREATE INDEX idx_offer_dates ON Offers(start_date, end_date);

-- 3. Add CHECK constraint to ensure max_discount_amount >= 0
ALTER TABLE Offers
ADD CONSTRAINT chk_max_discount CHECK (max_discount_amount >= 0);

-- 4. Insert additional sample offers
INSERT INTO Offers (offer_code, description, discount_percentage, start_date, end_date, min_order_value, max_discount_amount, usage_limit, status, offer_type)
VALUES
('VALENTINE20', '20% off on Valentine special', 20.00, '2024-02-10', '2024-02-14', 1000.00, 500.00, 2, 'Active', 'Festive');

-- 5. Update status for expired offers
UPDATE Offers
SET status='Expired'
WHERE end_date < CURRENT_DATE;

-- 6. Delete offers with 0 discount (Logical AND)
DELETE FROM Offers
WHERE discount_percentage=0 AND min_order_value=0;

-- 7. Change offer_type based on discount
UPDATE Offers
SET offer_type = CASE 
    WHEN discount_percentage >= 40 THEN 'Flash Sale'
    WHEN discount_percentage >= 20 THEN 'Festive'
    ELSE 'Seasonal'
END;

-- 8. List offers with formatted discount and alias
SELECT offer_code AS Code, description AS Description, CONCAT(discount_percentage,'%') AS Discount
FROM Offers
ORDER BY discount_percentage DESC;

-- 9. Count offers by status (GROUP BY + Alias)
SELECT status AS OfferStatus, COUNT(offer_id) AS TotalOffers
FROM Offers
GROUP BY status;

-- 10. Offers active in July 2024 (BETWEEN + Date)
SELECT offer_code, start_date, end_date
FROM Offers
WHERE '2024-07-01' BETWEEN start_date AND end_date;

-- 11. Offers with discount >= 30% (Comparison)
SELECT offer_code, discount_percentage
FROM Offers
WHERE discount_percentage >= 30;

-- 12. Users can apply offers with min_order_value < 2000 (Arithmetic)
SELECT offer_code, min_order_value, max_discount_amount
FROM Offers
WHERE min_order_value < 2000;

-- 13. Active or festive offers (Logical OR)
SELECT offer_code, status, offer_type
FROM Offers
WHERE status='Active' OR offer_type='Festive';

-- 14. Offers not expired (Logical NOT)
SELECT offer_code, status
FROM Offers
WHERE NOT status='Expired';

-- 15. Count offers by type (GROUP BY)
SELECT offer_type AS Type, COUNT(*) AS CountType
FROM Offers
GROUP BY offer_type;

-- 16. Update max_discount_amount using arithmetic operation
UPDATE Offers
SET max_discount_amount = max_discount_amount + 50
WHERE offer_type='Seasonal';

-- 17. List offers with discount between 10% and 25% (BETWEEN)
SELECT offer_code, discount_percentage
FROM Offers
WHERE discount_percentage BETWEEN 10 AND 25;

-- 18. Distinct offer types (DISTINCT + ORDER BY)
SELECT DISTINCT offer_type
FROM Offers
ORDER BY offer_type;

-- 19. Delete expired offers
DELETE FROM Offers
WHERE status='Expired';

-- 20. Test cascade-like update (example: change status for high discount)
UPDATE Offers
SET status='Active'
WHERE discount_percentage >= 50;




-- ------------------------------- 18 COUPONS -------------------------------------------------------------------------- 

USE Amazon;

-- 1. Add column for coupon_type
ALTER TABLE Coupons
ADD COLUMN coupon_type ENUM('Seasonal','Flat','Percentage','Festive') DEFAULT 'Flat';

-- 2. Add index on start_date and end_date
CREATE INDEX idx_coupon_dates ON Coupons(start_date, end_date);

-- 3. Add CHECK constraint for min_order_value >= 0
ALTER TABLE Coupons
ADD CONSTRAINT chk_min_order_value CHECK (min_order_value >= 0);

-- 4. Insert new coupon
INSERT INTO Coupons (coupon_code, description, discount_type, discount_value, start_date, end_date, min_order_value, max_discount_amount, usage_limit, status, coupon_type)
VALUES ('FESTIVE100', 'Flat 100 off festive coupon', 'Flat', 100.00, '2024-10-01', '2024-10-31', 500.00, 100.00, 3, 'Active', 'Festive');

-- 5. Update status for expired coupons
UPDATE Coupons
SET status='Expired'
WHERE end_date < CURRENT_DATE;

-- 6. Delete coupons with 0 discount (Logical AND)
DELETE FROM Coupons
WHERE discount_value=0 AND min_order_value=0;

-- 7. Update coupon_type based on discount_type
UPDATE Coupons
SET coupon_type = CASE 
    WHEN discount_type='Percentage' AND discount_value >= 30 THEN 'Seasonal'
    WHEN discount_type='Flat' AND discount_value >= 500 THEN 'Festive'
    ELSE coupon_type
END;

-- 8. Select coupons with alias and formatted discount
SELECT coupon_code AS Code, description AS Description,
       CONCAT(discount_value, CASE WHEN discount_type='Percentage' THEN '%' ELSE '' END) AS Discount
FROM Coupons
ORDER BY discount_value DESC;

-- 9. Count coupons by status (GROUP BY + Alias)
SELECT status AS CouponStatus, COUNT(coupon_id) AS TotalCoupons
FROM Coupons
GROUP BY status;

-- 10. Coupons active in July 2024 (BETWEEN + Date)
SELECT coupon_code, start_date, end_date
FROM Coupons
WHERE '2024-07-01' BETWEEN start_date AND end_date;

-- 11. Coupons with discount >= 20 (Comparison)
SELECT coupon_code, discount_value
FROM Coupons
WHERE discount_value >= 20;

-- 12. Coupons for min_order_value < 1000 (Arithmetic)
SELECT coupon_code, min_order_value, max_discount_amount
FROM Coupons
WHERE min_order_value < 1000;

-- 13. Active or festive coupons (Logical OR)
SELECT coupon_code, status, coupon_type
FROM Coupons
WHERE status='Active' OR coupon_type='Festive';

-- 14. Coupons not expired (Logical NOT)
SELECT coupon_code, status
FROM Coupons
WHERE NOT status='Expired';

-- 15. Count coupons by type (GROUP BY)
SELECT coupon_type AS Type, COUNT(*) AS CountType
FROM Coupons
GROUP BY coupon_type;

-- 16. Increase max_discount_amount by 50 for Flat coupons
UPDATE Coupons
SET max_discount_amount = max_discount_amount + 50
WHERE discount_type='Flat';

-- 17. Coupons with discount between 10 and 25 (BETWEEN)
SELECT coupon_code, discount_value
FROM Coupons
WHERE discount_value BETWEEN 10 AND 25;

-- 18. Distinct coupon types (DISTINCT + ORDER BY)
SELECT DISTINCT coupon_type
FROM Coupons
ORDER BY coupon_type;

-- 19. Delete expired coupons
DELETE FROM Coupons
WHERE status='Expired';

-- 20. Test cascade-style update (example: mark high discount coupons as Active)
UPDATE Coupons
SET status='Active'
WHERE discount_value >= 50;



-- ------------------------------- 19 TRANSACTIONS -------------------------------------------------------------------------- 

-- 1. Add column for transaction_type
ALTER TABLE Transactions
ADD COLUMN transaction_type ENUM('Order Payment','Refund','Wallet Top-up','Cash Collection') DEFAULT 'Order Payment';

-- 2. Create index on transaction_date
CREATE INDEX idx_transaction_date ON Transactions(transaction_date);

-- 3. Add CHECK constraint for amount >= 0
ALTER TABLE Transactions
ADD CONSTRAINT chk_transaction_amount CHECK (amount >= 0);

-- 4. Insert new transaction
INSERT INTO Transactions (user_id, order_id, amount, payment_method, transaction_date, status, reference_no, remarks, transaction_type)
VALUES (5, 121, 1200.00, 'UPI', '2024-03-25 12:00:00', 'Success', 'TXN1021', 'New order payment', 'Order Payment');

-- 5. Update status of pending transactions older than 7 days
UPDATE Transactions
SET status='Failed'
WHERE status='Pending' AND transaction_date < NOW() - INTERVAL 7 DAY;

-- 6. Delete refunded transactions (Logical AND)
DELETE FROM Transactions
WHERE status='Refunded' AND amount < 1000;

-- 7. Update transaction_type for Cash payments
UPDATE Transactions
SET transaction_type='Cash Collection'
WHERE payment_method='Cash';

-- 8. List transactions with user names (JOIN + Alias)
SELECT t.transaction_id, u.full_name AS Customer, t.amount, t.payment_method, t.status
FROM Transactions t
JOIN Users u ON t.user_id = u.user_id
ORDER BY t.transaction_date DESC;

-- 9. Count transactions per payment_method (GROUP BY + Alias)
SELECT payment_method AS Payment, COUNT(transaction_id) AS TotalTransactions
FROM Transactions
GROUP BY payment_method;

-- 10. Transactions above 3000 (Comparison)
SELECT transaction_id, user_id, amount
FROM Transactions
WHERE amount > 3000;

-- 11. Total transaction amount per user (GROUP BY + SUM)
SELECT user_id, SUM(amount) AS TotalSpent
FROM Transactions
GROUP BY user_id
ORDER BY TotalSpent DESC;

-- 12. Transactions in Feb 2024 (BETWEEN dates)
SELECT transaction_id, amount, transaction_date
FROM Transactions
WHERE transaction_date BETWEEN '2024-02-01' AND '2024-02-29';

-- 13. Transactions either Pending or Failed (Logical OR)
SELECT transaction_id, status, amount
FROM Transactions
WHERE status='Pending' OR status='Failed';

-- 14. Transactions not successful (Logical NOT)
SELECT transaction_id, user_id, status
FROM Transactions
WHERE NOT status='Success';

-- 15. Count transactions by status (GROUP BY)
SELECT status AS TransactionStatus, COUNT(transaction_id) AS CountStatus
FROM Transactions
GROUP BY status;

-- 16. Increase all amounts by 50 for Wallet payments (Arithmetic)
UPDATE Transactions
SET amount = amount + 50
WHERE payment_method='Wallet';

-- 17. Transactions between 500 and 2000 (BETWEEN)
SELECT transaction_id, amount
FROM Transactions
WHERE amount BETWEEN 500 AND 2000;

-- 18. Distinct payment methods (DISTINCT + ORDER BY)
SELECT DISTINCT payment_method
FROM Transactions
ORDER BY payment_method;

-- 19. Delete failed transactions older than 30 days
DELETE FROM Transactions
WHERE status='Failed' AND transaction_date < NOW() - INTERVAL 30 DAY;

-- 20. Test cascade-style update — mark high-value transactions as Success
UPDATE Transactions
SET status='Success'
WHERE amount >= 4000;


-- ------------------------------- 20 RETURNS -------------------------------------------------------------------------- 

-- 1. Add column for return_type
ALTER TABLE Returns
ADD COLUMN return_type ENUM('Replacement','Refund','Store Credit') DEFAULT 'Refund';

-- 2. Create index on return_date
CREATE INDEX idx_return_date ON Returns(return_date);

-- 3. Add CHECK constraint for refund_amount >= 0
ALTER TABLE Returns
ADD CONSTRAINT chk_refund_amount CHECK (refund_amount >= 0);

-- 4. Insert new return record
INSERT INTO Returns (order_id, user_id, product_id, reason, return_date, status, refund_amount, remarks, return_type)
VALUES (121, 5, 301, 'Product damaged', '2024-03-25', 'Requested', 0.00, 'Return initiated', 'Replacement');

-- 5. Update status of Requested returns older than 10 days
UPDATE Returns
SET status='Rejected'
WHERE status='Requested' AND return_date < NOW() - INTERVAL 10 DAY;

-- 6. Delete Rejected returns (Logical AND)
DELETE FROM Returns
WHERE status='Rejected' AND refund_amount=0;

-- 7. Update return_type for high-value refunds
UPDATE Returns
SET return_type='Store Credit'
WHERE refund_amount >= 3000;

-- 8. List returns with user names (JOIN + Alias)
SELECT r.return_id, u.full_name AS Customer, r.product_id, r.reason, r.status, r.refund_amount
FROM Returns r
JOIN Users u ON r.user_id = u.user_id
ORDER BY r.return_date DESC;

-- 9. Count returns by status (GROUP BY + Alias)
SELECT status AS ReturnStatus, COUNT(return_id) AS TotalReturns
FROM Returns
GROUP BY status;

-- 10. Returns with refund_amount above 2000 (Comparison)
SELECT return_id, order_id, refund_amount
FROM Returns
WHERE refund_amount > 2000;

-- 11. Total refunded amount per user (GROUP BY + SUM)
SELECT user_id, SUM(refund_amount) AS TotalRefunded
FROM Returns
WHERE status='Refunded'
GROUP BY user_id
ORDER BY TotalRefunded DESC;

-- 12. Returns in Feb 2024 (BETWEEN dates)
SELECT return_id, order_id, return_date, status
FROM Returns
WHERE return_date BETWEEN '2024-02-01' AND '2024-02-29';

-- 13. Returns either Approved or Refunded (Logical OR)
SELECT return_id, status, refund_amount
FROM Returns
WHERE status='Approved' OR status='Refunded';

-- 14. Returns not Rejected (Logical NOT)
SELECT return_id, user_id, status
FROM Returns
WHERE NOT status='Rejected';

-- 15. Count returns by return_type (GROUP BY)
SELECT return_type AS ReturnType, COUNT(return_id) AS CountType
FROM Returns
GROUP BY return_type;

-- 16. Increase refund_amount by 100 for Approved returns (Arithmetic)
UPDATE Returns
SET refund_amount = refund_amount + 100
WHERE status='Approved';

-- 17. Returns with refund_amount between 500 and 3000 (BETWEEN)
SELECT return_id, refund_amount
FROM Returns
WHERE refund_amount BETWEEN 500 AND 3000;

-- 18. Distinct return types (DISTINCT + ORDER BY)
SELECT DISTINCT return_type
FROM Returns
ORDER BY return_type;

-- 19. Delete old Rejected returns (older than 60 days)
DELETE FROM Returns
WHERE status='Rejected' AND return_date < NOW() - INTERVAL 60 DAY;

-- 20. Mark all Requested returns as Approved if return_amount > 1000
UPDATE Returns
SET status='Approved'
WHERE status='Requested' AND refund_amount > 1000;


-- ------------------------------- 21 REFUNDS TABLE -----------------------------------------------------------------

-- 1. Add column for refund_type
ALTER TABLE Refunds
ADD COLUMN refund_type ENUM('Full','Partial') DEFAULT 'Full';

-- 2. Create index on refund_date
CREATE INDEX idx_refund_date ON Refunds(refund_date);

-- 3. Add CHECK constraint for refund_amount >= 0
ALTER TABLE Refunds
ADD CONSTRAINT chk_refund_amount CHECK (refund_amount >= 0);

-- 4. Insert a new refund record
INSERT INTO Refunds (return_id, order_id, user_id, product_id, refund_date, refund_amount, refund_mode, status, remarks, refund_type)
VALUES (21, 121, 5, 301, '2024-03-25', 1200.00, 'Bank Transfer', 'Initiated', 'Refund started', 'Partial');

-- 5. Update status of Processing refunds older than 7 days
UPDATE Refunds
SET status='Completed'
WHERE status='Processing' AND refund_date < NOW() - INTERVAL 7 DAY;

-- 6. Delete failed refunds with amount = 0
DELETE FROM Refunds
WHERE status='Failed' AND refund_amount = 0;

-- 7. Update refund_type to Partial for refunds < 1000
UPDATE Refunds
SET refund_type='Partial'
WHERE refund_amount < 1000;

-- 8. List refunds with user names (JOIN + Alias)
SELECT r.refund_id, u.full_name AS Customer, r.order_id, r.refund_amount, r.status, r.refund_mode
FROM Refunds r
JOIN Users u ON r.user_id = u.user_id
ORDER BY r.refund_date DESC;

-- 9. Count refunds by status (GROUP BY + Alias)
SELECT status AS RefundStatus, COUNT(refund_id) AS TotalRefunds
FROM Refunds
GROUP BY status;

-- 10. Refunds above 2000 (Comparison)
SELECT refund_id, refund_amount, status
FROM Refunds
WHERE refund_amount > 2000;

-- 11. Total refunded amount per user (GROUP BY + SUM)
SELECT user_id, SUM(refund_amount) AS TotalRefunded
FROM Refunds
WHERE status='Completed'
GROUP BY user_id
ORDER BY TotalRefunded DESC;

-- 12. Refunds in March 2024 (BETWEEN dates)
SELECT refund_id, refund_date, refund_amount, status
FROM Refunds
WHERE refund_date BETWEEN '2024-03-01' AND '2024-03-31';

-- 13. Refunds either Completed or Processing (Logical OR)
SELECT refund_id, status, refund_amount
FROM Refunds
WHERE status='Completed' OR status='Processing';

-- 14. Refunds not Failed (Logical NOT)
SELECT refund_id, user_id, status
FROM Refunds
WHERE NOT status='Failed';

-- 15. Count refunds by refund_mode (GROUP BY)
SELECT refund_mode AS Mode, COUNT(refund_id) AS CountMode
FROM Refunds
GROUP BY refund_mode;

-- 16. Increase refund_amount by 50 for Completed refunds (Arithmetic)
UPDATE Refunds
SET refund_amount = refund_amount + 50
WHERE status='Completed';

-- 17. Refunds with refund_amount between 500 and 3000 (BETWEEN)
SELECT refund_id, refund_amount
FROM Refunds
WHERE refund_amount BETWEEN 500 AND 3000;

-- 18. Distinct refund types (DISTINCT + ORDER BY)
SELECT DISTINCT refund_type
FROM Refunds
ORDER BY refund_type;

-- 19. Delete Completed refunds older than 90 days
DELETE FROM Refunds
WHERE status='Completed' AND refund_date < NOW() - INTERVAL 90 DAY;

-- 20. Mark all Initiated refunds as Processing if refund_amount > 2000
UPDATE Refunds
SET status='Processing'
WHERE status='Initiated' AND refund_amount > 2000;

-- ------------------------------- 22 SUPPORT_TICKETS TABLE -----------------------------------------------------------------

USE Amazon;

-- 1. Select all tickets
SELECT * FROM support_tickets;

-- 2. Select ticket subject and status for high priority tickets
SELECT subject, status 
FROM support_tickets 
WHERE priority = 'High';

-- 3. Count tickets by category
SELECT category, COUNT(*) AS ticket_count
FROM support_tickets
GROUP BY category;

-- 4. Count open tickets per user
SELECT user_id, COUNT(*) AS open_tickets
FROM support_tickets
WHERE status = 'Open'
GROUP BY user_id;

-- 5. List tickets created in February 2024
SELECT *
FROM support_tickets
WHERE created_at BETWEEN '2024-02-01' AND '2024-02-29';

-- 6. Select tickets with “Refund” in subject
SELECT *
FROM support_tickets
WHERE subject LIKE '%Refund%';

-- 7. Show tickets sorted by priority (Critical → Low)
SELECT *
FROM support_tickets
ORDER BY 
    CASE 
        WHEN priority = 'Critical' THEN 1
        WHEN priority = 'High' THEN 2
        WHEN priority = 'Medium' THEN 3
        ELSE 4
    END;

-- 8. Join tickets with users (assuming Users table exists)
SELECT s.ticket_id, u.first_name, u.last_name, s.subject, s.status
FROM support_tickets s
JOIN users u ON s.user_id = u.user_id;

-- 9. Count tickets per status
SELECT status, COUNT(*) AS total
FROM support_tickets
GROUP BY status;

-- 10. Update a ticket status to 'Resolved'
UPDATE support_tickets
SET status = 'Resolved', updated_at = CURRENT_DATE
WHERE ticket_id = 3;

-- 11. Delete tickets with status 'Closed'
DELETE FROM support_tickets
WHERE status = 'Closed';

-- 12. Insert a new support ticket
INSERT INTO support_tickets (user_id, order_id, subject, description, category, priority, status, created_at)
VALUES (21, 121, 'Login Issue', 'Unable to login to account', 'Other', 'Medium', 'Open', '2024-10-14');

-- 13. Count tickets per priority using alias
SELECT priority AS Ticket_Priority, COUNT(*) AS Total_Tickets
FROM support_tickets
GROUP BY priority;

-- 14. Select tickets where category is 'Payment' or 'Refund'
SELECT *
FROM support_tickets
WHERE category IN ('Payment', 'Refund');

-- 15. Find tickets not updated yet
SELECT *
FROM support_tickets
WHERE updated_at IS NULL;

-- 16. Join tickets with orders table to get order amount
SELECT s.ticket_id, s.subject, o.order_id, o.amount
FROM support_tickets s
JOIN orders o ON s.order_id = o.order_id;

-- 17. Tickets created after a specific date
SELECT *
FROM support_tickets
WHERE created_at > '2024-02-01';

-- 18. Count tickets per user with status 'Open' using HAVING
SELECT user_id, COUNT(*) AS OpenTickets
FROM support_tickets
WHERE status = 'Open'
GROUP BY user_id
HAVING COUNT(*) > 1;

-- 19. Find the latest ticket for each user
SELECT user_id, MAX(created_at) AS Latest_Ticket
FROM support_tickets
GROUP BY user_id;

-- 20. Update priority for tickets with subject containing 'Delay'
UPDATE support_tickets
SET priority = 'Critical', updated_at = CURRENT_DATE
WHERE subject LIKE '%Delay%';


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

-- ------------------------------- DDL QUERIES ------------------------------------------------------------

-- 1. Add new column manager_id
ALTER TABLE employees ADD COLUMN manager_id INT;

-- 2. Modify salary to bigger range
ALTER TABLE employees MODIFY COLUMN salary DECIMAL(12,2);

-- 3. Rename job_title → designation
ALTER TABLE employees CHANGE job_title designation VARCHAR(50);

-- 4. Drop column phone
ALTER TABLE employees DROP COLUMN phone;

-- 5. Drop table employees
DROP TABLE employees;

-- 6. Insert new employee
INSERT INTO employees (first_name, last_name, email, hire_date, designation, salary, department_id, status, created_at)
VALUES ('Tanvi', 'Kulkarni', 'tanvi.kulkarni@example.com', '2023-02-15', 'Data Scientist', 70000, 1, 'Active', '2023-02-15');

-- 7. Update salary
UPDATE employees SET salary = 95000 WHERE employee_id = 5;

-- 8. Update status to Resigned
UPDATE employees SET status = 'Resigned' WHERE employee_id = 4;

-- 9. Delete resigned employees
DELETE FROM employees WHERE status = 'Resigned';

-- 10. Delete with salary < 30000
DELETE FROM employees WHERE salary < 30000;


-- 10. Select all employees
SELECT * FROM employees;

-- 11. WHERE clause
SELECT employee_id, first_name, designation, salary
FROM employees
WHERE salary > 50000;

-- 12. ORDER BY salary
SELECT employee_id, first_name, designation, salary
FROM employees
ORDER BY salary DESC;

-- 13. GROUP BY department
SELECT department_id, COUNT(employee_id) AS total_employees
FROM employees
GROUP BY department_id;

-- 14. HAVING clause
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 50000;

-- 15. LIMIT
SELECT employee_id, first_name, designation, salary
FROM employees
ORDER BY hire_date ASC
LIMIT 5;

-- 16. Functions
SELECT MAX(salary) AS highest_salary, MIN(salary) AS lowest_salary, COUNT(*) AS total_staff
FROM employees;


-- 17. Update salary
UPDATE employees SET salary = 95000 WHERE employee_id = 5;

-- 18. update status to Resigned
UPDATE employees SET status = 'Resigned' WHERE employee_id = 4;

-- 19. Delete resigned employees
DELETE FROM employees WHERE status = 'Resigned';

-- 20. Delete with salary < 30000
DELETE FROM employees WHERE salary < 30000;

-- ------------------------------- 24 DEPARTMENTS TABLE -----------------------------------------------------
USE Amazon;

-- 1️⃣ Add a new column for department budget
ALTER TABLE departments
ADD COLUMN budget DECIMAL(12,2) DEFAULT 500000;

-- 2️⃣ Modify location column size
ALTER TABLE departments
MODIFY location VARCHAR(150);

-- 3️⃣ Rename column manager_name to head_name
ALTER TABLE departments
CHANGE manager_name head_name VARCHAR(100) NOT NULL;

-- 4️⃣ Add CHECK constraint on budget
ALTER TABLE departments
ADD CONSTRAINT chk_budget CHECK (budget >= 100000);

-- 5️⃣ Insert new department record
INSERT INTO departments (department_name, head_name, location, created_at, budget)
VALUES ('AI Research', 'Shreya Desai', 'Pune', '2022-09-12', 750000);

-- 6️⃣ Update department location
UPDATE departments
SET location = 'New Delhi'
WHERE department_name = 'Finance';

-- 7️⃣ Increase budget by 10% for all Bangalore departments
UPDATE departments
SET budget = budget * 1.10
WHERE location = 'Bangalore';

-- 8️⃣ Delete one department
DELETE FROM departments
WHERE department_name = 'Security';

-- 9️⃣ Select all departments
SELECT * FROM departments;

-- 🔟 Select departments with budget greater than 6 lakhs
SELECT department_name, budget
FROM departments
WHERE budget > 600000;

-- 11️⃣ Count how many departments are in each city
SELECT location, COUNT(*) AS total_departments
FROM departments
GROUP BY location;

-- 12️⃣ Find highest budget among all departments
SELECT department_name, budget
FROM departments
ORDER BY budget DESC
LIMIT 1;

-- 13️⃣ Use alias for better readability
SELECT department_name AS 'Dept Name', head_name AS 'Manager', location AS 'City'
FROM departments;

-- 14️⃣ Show only departments created after 2020
SELECT department_name, created_at
FROM departments
WHERE YEAR(created_at) > 2020;

-- 15️⃣ Find departments whose name starts with 'C'
SELECT * FROM departments
WHERE department_name LIKE 'C%';

-- 16️⃣ Use logical operators (AND / OR)
SELECT * FROM departments
WHERE location = 'Delhi' AND budget > 400000;

-- 17️⃣ Use comparison operator
SELECT * FROM departments
WHERE budget BETWEEN 300000 AND 800000;

-- 18️⃣ Add foreign key in employees table with CASCADE
ALTER TABLE employees
ADD CONSTRAINT fk_dept
FOREIGN KEY (department_id)
REFERENCES departments(department_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 19️⃣ Demonstrate DELETE CASCADE (deleting a department will delete its employees)
DELETE FROM departments WHERE department_id = 3;

-- 20️⃣ Demonstrate UPDATE CASCADE (updating department_id automatically updates in employees)
UPDATE departments
SET department_id = 22
WHERE department_id = 2;



-- ------------------------------- 25 NOTIFICATIONS TABLE -----------------------------------------------------
USE Amazon;

-- 1. Add new column for notification source
ALTER TABLE notifications
ADD COLUMN source VARCHAR(50) DEFAULT 'System';

-- 2. Modify message column size
ALTER TABLE notifications
MODIFY message VARCHAR(300);

-- 3. Rename column 'priority' to 'alert_level'
ALTER TABLE notifications
CHANGE priority alert_level VARCHAR(20) DEFAULT 'Normal' CHECK (alert_level IN ('Low','Normal','High'));

-- 4. Add CHECK constraint on channel to ensure valid values
ALTER TABLE notifications
ADD CONSTRAINT chk_channel CHECK (channel IN ('Email','SMS','App'));

-- 5. Insert new notification record
INSERT INTO notifications (user_id, message, type, status, alert_level, channel, created_at)
VALUES (5, 'Your wishlist item is now on discount!', 'Offer', 'Unread', 'High', 'App', NOW());

-- 6. Update notification status to 'Read'
UPDATE notifications
SET status = 'Read', read_at = NOW()
WHERE notification_id = 3;

-- 7. Update channel type from SMS to App
UPDATE notifications
SET channel = 'App'
WHERE channel = 'SMS';

-- 8. Delete notifications older than December 5, 2023
DELETE FROM notifications
WHERE created_at < '2023-12-05';

-- 9. Display all notifications
SELECT * FROM notifications;

-- 10. Show all unread notifications
SELECT notification_id, message, type, status
FROM notifications
WHERE status = 'Unread';

-- 11. Count notifications by type
SELECT type, COUNT(*) AS total_notifications
FROM notifications
GROUP BY type;

-- 12. Show notifications sent via App channel only
SELECT notification_id, message, channel
FROM notifications
WHERE channel = 'App';

-- 13. Find the most recent 5 notifications
SELECT * FROM notifications
ORDER BY created_at DESC
LIMIT 5;

-- 14. Display notifications with HIGH priority
SELECT message, alert_level
FROM notifications
WHERE alert_level = 'High';

-- 15. Use alias for better readability
SELECT notification_id AS 'ID', message AS 'Notification Message', status AS 'Current Status'
FROM notifications;

-- 16. Find notifications between two dates
SELECT * FROM notifications
WHERE created_at BETWEEN '2023-12-05' AND '2023-12-10';

-- 17. Logical operator example (type = 'Order' OR type = 'Shipment')
SELECT * FROM notifications
WHERE type = 'Order' OR type = 'Shipment';

-- 18. Comparison operator example (notification_id > 10)
SELECT * FROM notifications
WHERE notification_id > 10;

-- 19. Demonstrate foreign key cascade - add ON DELETE CASCADE for user_id
ALTER TABLE notifications
ADD CONSTRAINT fk_user_notify
FOREIGN KEY (user_id)
REFERENCES users(user_id)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- 20. Demonstrate DELETE CASCADE (deleting a user removes their notifications)
DELETE FROM users WHERE user_id = 2;


