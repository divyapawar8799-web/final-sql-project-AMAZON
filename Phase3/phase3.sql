/* ---------------------------------------------------------------------------

   Project: Amazon E-Commerce Database System (AE-DBS)
   Author: Divya Pawar
   Phase-3: Joins | Subqueries | Functions | UDFs
--------------------------------------------------------------------------- */

Use Amazon;

-- ---------------------------- 1 users ----------------------------------

-- 1) INNER JOIN: All users with their orders (only users who placed orders)
SELECT u.user_id, CONCAT(u.first_name, ' ', u.last_name) AS fullname, o.order_id, o.order_date, o.total_amount
FROM Users u
INNER JOIN Orders o ON u.user_id = o.user_id
ORDER BY o.order_date DESC;

-- 2) LEFT JOIN: All users with their delivery address (show users with no address)
SELECT u.user_id, u.email, da.address_id, da.street_address, da.city
FROM Users u
LEFT JOIN Delivery_Address da ON u.user_id = da.user_id
WHERE da.address_id IS NULL; -- users without saved address

-- 3) JOIN across 3 tables: user, orders, shipments — show delivery status per user order
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name, o.order_id, s.tracking_number, s.status AS shipment_status
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
LEFT JOIN Shipments s ON o.order_id = s.order_id
WHERE o.order_date >= '2025-08-01';

-- 4) SELF JOIN: find users who share the same phone number (possible duplicates)
SELECT a.user_id AS id1, CONCAT(a.first_name,' ',a.last_name) AS name1,
       b.user_id AS id2, CONCAT(b.first_name,' ',b.last_name) AS name2, a.phone
FROM Users a
JOIN Users b ON a.phone = b.phone AND a.user_id < b.user_id;

-- 5) RIGHT JOIN: list orders with user details, include orders even if user record missing (if your engine supports RIGHT JOIN)
SELECT u.user_id, u.email, o.order_id, o.total_amount
FROM Users u
RIGHT JOIN Orders o ON u.user_id = o.user_id
ORDER BY o.order_id;

-- 6) CROSS JOIN: sample cart recommendations — pair first 5 users with first 5 popular products (careful: cartesian)
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, p.product_id, p.name AS product_name
FROM (SELECT * FROM Users LIMIT 5) u
CROSS JOIN (SELECT * FROM Products WHERE status='Available' ORDER BY rating DESC LIMIT 5) p;

-- 7) INNER JOIN with aggregation: user and count of orders
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name, COUNT(o.order_id) AS orders_count, SUM(o.total_amount) AS total_spent
FROM Users u
JOIN Orders o ON u.user_id = o.user_id
GROUP BY u.user_id
HAVING COUNT(o.order_id) > 0
ORDER BY total_spent DESC;

-- 8) JOIN with Payments: users and their last successful payment
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name, p.payment_id, p.amount, p.payment_date
FROM Users u
JOIN Payments p ON u.user_id = p.user_id
WHERE p.status = 'Success'
ORDER BY p.payment_date DESC
LIMIT 20;

-- 9) LEFT JOIN + WHERE: users that have notifications but no active orders
SELECT DISTINCT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name, n.notification_id
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.user_id AND o.status IN ('Pending','Shipped')
JOIN notifications n ON u.user_id = n.user_id
WHERE o.order_id IS NULL;

-- 10) Scalar subquery: users whose age > average user age
SELECT user_id, first_name, last_name, TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age
FROM Users
WHERE TIMESTAMPDIFF(YEAR, dob, CURDATE()) > (
    SELECT AVG(TIMESTAMPDIFF(YEAR, dob, CURDATE())) FROM Users
);

-- 11) Correlated subquery: users who registered more recently than the average registration date in their city
SELECT u.user_id, u.email, u.created_at
FROM Users u
WHERE u.created_at > (
    SELECT AVG(u2.created_at) FROM Users u2 WHERE u2.city_id = u.city_id
);

-- 12) Subquery with IN: users who have at least one order with total_amount > 50000
SELECT user_id, email
FROM Users
WHERE user_id IN (
    SELECT user_id FROM Orders WHERE total_amount > 50000
);

-- 13) EXISTS correlated subquery: users who have a pending refund
SELECT u.user_id, u.email
FROM Users u
WHERE EXISTS (
    SELECT 1 FROM refunds r WHERE r.user_id = u.user_id AND r.status <> 'Completed'
);

-- 14) Subquery in FROM: top spenders (derived table)
SELECT t.user_id, CONCAT(u.first_name,' ',u.last_name) AS name, t.total_spent
FROM (
    SELECT user_id, SUM(total_amount) AS total_spent
    FROM Orders
    GROUP BY user_id
    ORDER BY total_spent DESC
    LIMIT 10
) t
JOIN Users u ON u.user_id = t.user_id;

-- 15) ANY/ALL example: users whose single largest order is >= ALL users' average order
SELECT u.user_id, u.email
FROM Users u
WHERE (
    SELECT MAX(o.total_amount) FROM Orders o WHERE o.user_id = u.user_id
) >= ALL (SELECT AVG(total_amount) FROM Orders GROUP BY user_id);

-- 16) String & CONCAT: show names in uppercase with email domain
SELECT user_id, UPPER(CONCAT(first_name, ' ', last_name)) AS NAME_CAPS,
       SUBSTRING_INDEX(email, '@', -1) AS email_domain
FROM Users
ORDER BY last_name;

-- 17) Date/Time functions: users and age, days since registration
SELECT user_id, CONCAT(first_name,' ',last_name) AS name,
       TIMESTAMPDIFF(YEAR, dob, CURDATE()) AS age,
       DATEDIFF(CURDATE(), created_at) AS days_since_registration
FROM Users
WHERE status = 'Active';

-- 18) Aggregate + GROUP BY: count users by city and average age
SELECT u.city_id, COUNT(*) AS users_count, ROUND(AVG(TIMESTAMPDIFF(YEAR, dob, CURDATE())),1) AS avg_age
FROM Users u
GROUP BY u.city_id
ORDER BY users_count DESC;

-- 19) UDF: GetAge(date) -> returns integer age in years
DROP FUNCTION IF EXISTS GetAge;
DELIMITER $$
CREATE FUNCTION GetAge(d DATE) RETURNS INT
DETERMINISTIC
RETURN TIMESTAMPDIFF(YEAR, d, CURDATE());
$$
DELIMITER ;

-- usage example:
-- SELECT user_id, GetAge(dob) AS age FROM Users;

-- 20) UDF: FullName(user_id) -> returns full name string (note: this is a simple example that uses a scalar subquery)
DROP FUNCTION IF EXISTS FullName;
DELIMITER $$
CREATE FUNCTION FullName(uid INT) RETURNS VARCHAR(200)
DETERMINISTIC
RETURN (
    SELECT CONCAT(first_name, ' ', last_name) FROM Users WHERE user_id = uid
);
$$
DELIMITER ;

-- usage example:
-- SELECT user_id, FullName(user_id) FROM Users LIMIT 10;

-- ------------------------- 2. orders -------------------------------------------


-- 1) INNER JOIN – Orders with corresponding Users (customer details) 
SELECT o.order_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name, 
       o.order_date, o.status, o.total_amount
FROM Orders o
INNER JOIN Users u ON o.user_id = u.user_id
ORDER BY o.order_date DESC;

-- 2) LEFT JOIN – Orders with Payment details (show unpaid orders) 
SELECT o.order_id, o.order_date, o.total_amount, p.payment_id, p.status AS payment_status
FROM Orders o
LEFT JOIN Payments p ON o.order_id = p.order_id
WHERE p.payment_id IS NULL;

-- 3) RIGHT JOIN – Shipments linked with orders 
SELECT s.shipment_id, s.tracking_number, s.status AS shipment_status,
       o.order_id, o.order_date
FROM Orders o
RIGHT JOIN Shipments s ON o.order_id = s.order_id;

--  4) JOIN across 3 tables – Orders + Users + Shipments 
SELECT o.order_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       s.tracking_number, s.status AS shipment_status
FROM Orders o
JOIN Users u ON o.user_id = u.user_id
LEFT JOIN Shipments s ON o.order_id = s.order_id
ORDER BY o.order_date DESC;

--  5) SELF JOIN – Orders placed on same date by different users 
SELECT a.order_id AS order_A, a.user_id AS user_A,
       b.order_id AS order_B, b.user_id AS user_B, a.order_date
FROM Orders a
JOIN Orders b ON a.order_date = b.order_date AND a.order_id < b.order_id;

--  6) CROSS JOIN – Random pair of orders and offers for marketing 
SELECT o.order_id, o.total_amount, ofr.offer_title, ofr.discount_percent
FROM (SELECT * FROM Orders LIMIT 5) o
CROSS JOIN (SELECT * FROM Offers LIMIT 2) ofr;

--  7) INNER JOIN + GROUP BY – Total order count and amount per user
SELECT o.user_id, COUNT(o.order_id) AS total_orders, SUM(o.total_amount) AS total_spent
FROM Orders o
GROUP BY o.user_id
ORDER BY total_spent DESC;

-- 8) JOIN with Order_Items – Total items in each order 
SELECT o.order_id, o.order_date, SUM(oi.quantity) AS total_items
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY total_items DESC;

-- 9) JOIN with Refunds – Orders having refunds 
SELECT o.order_id, o.total_amount, r.refund_id, r.amount AS refund_amount, r.status
FROM Orders o
JOIN Refunds r ON o.order_id = r.order_id
WHERE r.status = 'Completed';


-- 10) Scalar Subquery – Orders above average total amount 
SELECT order_id, user_id, total_amount
FROM Orders
WHERE total_amount > (SELECT AVG(total_amount) FROM Orders);

-- 11) Correlated Subquery – Orders greater than user’s average order 
SELECT o.order_id, o.user_id, o.total_amount
FROM Orders o
WHERE o.total_amount > (
    SELECT AVG(o2.total_amount) FROM Orders o2 WHERE o2.user_id = o.user_id
);

-- 12) Subquery with IN – Orders containing products from “Electronics” category 
SELECT order_id, total_amount
FROM Orders
WHERE order_id IN (
    SELECT oi.order_id
    FROM Order_Items oi
    JOIN Products p ON oi.product_id = p.product_id
    JOIN Categories c ON p.category_id = c.category_id
    WHERE c.category_name = 'Electronics'
);

-- 13) EXISTS – Orders that have successful payments
SELECT o.order_id, o.total_amount
FROM Orders o
WHERE EXISTS (
    SELECT 1 FROM Payments p WHERE p.order_id = o.order_id AND p.status = 'Success'
);

-- 14) Subquery in FROM – Top 5 highest order totals
SELECT t.order_id, u.email, t.total_amount
FROM (
    SELECT order_id, user_id, total_amount 
    FROM Orders ORDER BY total_amount DESC LIMIT 5
) t
JOIN Users u ON t.user_id = u.user_id;

-- 15) ANY / ALL – Orders higher than ALL refunds
SELECT order_id, total_amount
FROM Orders
WHERE total_amount > ALL (SELECT amount FROM Refunds);

--  16) Built-in String & Date functions – Format status and days since order 
SELECT order_id,
       CONCAT(UPPER(SUBSTRING(status,1,1)), LOWER(SUBSTRING(status,2))) AS formatted_status,
       DATEDIFF(CURDATE(), order_date) AS days_since_order
FROM Orders;

--  17) Built-in Aggregate – Monthly total revenue
SELECT YEAR(order_date) AS year, MONTH(order_date) AS month,
       COUNT(order_id) AS total_orders, SUM(total_amount) AS monthly_revenue
FROM Orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year DESC, month DESC;

--  18) Built-in Numeric – Round order totals and calculate GST (18%) 
SELECT order_id, ROUND(total_amount,2) AS total_amount,
       ROUND(total_amount * 0.18,2) AS gst_amount,
       ROUND(total_amount + (total_amount * 0.18),2) AS grand_total
FROM Orders;

-- 19) UDF – CalculateOrderGST(order_total) 
DROP FUNCTION IF EXISTS CalculateOrderGST;
DELIMITER $$
CREATE FUNCTION CalculateOrderGST(order_total DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN ROUND(order_total * 0.18,2);
$$
DELIMITER ;
-- Example usage:
-- SELECT order_id, CalculateOrderGST(total_amount) AS gst FROM Orders LIMIT 10;

-- 20) UDF – OrderSummary(order_id) 
DROP FUNCTION IF EXISTS OrderSummary;
DELIMITER $$
CREATE FUNCTION OrderSummary(oid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Order #', order_id, ' | Total: ₹', total_amount, ' | Status: ', status)
    FROM Orders WHERE order_id = oid
);
$$
DELIMITER ;
-- Example usage:
-- SELECT OrderSummary(order_id) AS summary FROM Orders LIMIT 10;


-- ---------------------------------- 3. Products  ----------------------------------------- 

-- 1) INNER JOIN – Show each product with its seller name 
SELECT p.product_id, p.name AS product_name, s.seller_name, s.email
FROM Products p
INNER JOIN Sellers s ON p.seller_id = s.seller_id;

-- 2) LEFT JOIN – All products with category name (show products with no category) 
SELECT p.product_id, p.name, c.category_name
FROM Products p
LEFT JOIN Categories c ON p.category_id = c.category_id
WHERE c.category_id IS NULL;

-- 3) JOIN across 3 tables – Product, Order_Items, Orders → total quantity sold 
SELECT p.product_id, p.name, SUM(oi.quantity) AS total_sold, SUM(oi.subtotal) AS revenue
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
JOIN Orders o ON oi.order_id = o.order_id
GROUP BY p.product_id
ORDER BY revenue DESC;

-- 4) RIGHT JOIN – Sellers with or without products 
SELECT s.seller_id, s.seller_name, p.product_id, p.name AS product_name
FROM Products p
RIGHT JOIN Sellers s ON p.seller_id = s.seller_id;

-- 5) SELF JOIN – Products in the same category 
SELECT a.product_id AS product_1, a.name AS product_name_1,
       b.product_id AS product_2, b.name AS product_name_2, a.category_id
FROM Products a
JOIN Products b ON a.category_id = b.category_id AND a.product_id < b.product_id;

-- 6) CROSS JOIN – Top 3 products × 3 offers (combo recommendations)
SELECT p.name AS product_name, o.offer_title, o.discount_percent
FROM (SELECT * FROM Products ORDER BY rating DESC LIMIT 3) p
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Reviews – Product, average rating, and number of reviews 
SELECT p.product_id, p.name, ROUND(AVG(r.rating),2) AS avg_rating, COUNT(r.review_id) AS total_reviews
FROM Products p
LEFT JOIN Reviews r ON p.product_id = r.product_id
GROUP BY p.product_id;

-- 8) JOIN with Inventory – Product stock details (low stock only) 
SELECT p.product_id, p.name, i.stock_quantity, i.reorder_level
FROM Products p
JOIN Inventory i ON p.product_id = i.product_id
WHERE i.stock_quantity < i.reorder_level;

-- 9) JOIN with Wishlists – Products added to user wishlists 
SELECT DISTINCT w.user_id, u.email, p.name AS product_name
FROM Wishlists w
JOIN Users u ON w.user_id = u.user_id
JOIN Products p ON w.product_id = p.product_id;

-- 10) Scalar Subquery – Products priced above average price 
SELECT product_id, name, price
FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- 11) Correlated Subquery – Product price above average in its category 
SELECT p.product_id, p.name, p.price
FROM Products p
WHERE p.price > (
    SELECT AVG(p2.price) FROM Products p2 WHERE p2.category_id = p.category_id
);

-- 12) Subquery with IN – Products that have been ordered at least once 
SELECT product_id, name
FROM Products
WHERE product_id IN (
    SELECT DISTINCT product_id FROM Order_Items
);

-- 13) EXISTS – Products with at least one review rated 5 
SELECT p.product_id, p.name
FROM Products p
WHERE EXISTS (
    SELECT 1 FROM Reviews r WHERE r.product_id = p.product_id AND r.rating = 5
);

-- 14) Subquery in FROM – Top 5 most reviewed products 
SELECT t.product_id, p.name, t.total_reviews
FROM (
    SELECT product_id, COUNT(*) AS total_reviews FROM Reviews GROUP BY product_id
) t
JOIN Products p ON p.product_id = t.product_id
ORDER BY t.total_reviews DESC
LIMIT 5;

-- 15) ANY / ALL – Products cheaper than ALL products from a specific seller 
SELECT product_id, name, price
FROM Products
WHERE price < ALL (SELECT price FROM Products WHERE seller_id = 1003);

-- 16) Built-in String & Numeric – Format name and round prices
SELECT product_id,
       CONCAT(UPPER(SUBSTRING(name,1,1)), LOWER(SUBSTRING(name,2))) AS formatted_name,
       ROUND(price,2) AS rounded_price
FROM Products;

-- 17) Built-in Date/Time – Products added in the last 30 days 
SELECT product_id, name, created_at
FROM Products
WHERE DATEDIFF(CURDATE(), created_at) <= 30;

-- 18) Aggregate Function – Average price and total products by category 
SELECT category_id, COUNT(*) AS total_products, ROUND(AVG(price),2) AS avg_price
FROM Products
GROUP BY category_id;

-- 19) UDF – CalculateDiscountedPrice(price, discount_percent) 
DROP FUNCTION IF EXISTS CalculateDiscountedPrice;
DELIMITER $$
CREATE FUNCTION CalculateDiscountedPrice(price DECIMAL(10,2), discount_percent DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN price - (price * discount_percent / 100);
$$
DELIMITER ;
-- Example usage:
-- SELECT product_id, name, CalculateDiscountedPrice(price, 10) AS new_price FROM Products;

-- 20) UDF – ProductLabel(product_id) 
DROP FUNCTION IF EXISTS ProductLabel;
DELIMITER $$
CREATE FUNCTION ProductLabel(pid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT(UPPER(name), ' (₹', price, ')') FROM Products WHERE product_id = pid
);
$$
DELIMITER ;
-- Example usage:
-- SELECT ProductLabel(product_id) AS label FROM Products LIMIT 10;


-- ------------------------------------ 4. Categories  --------------------------------------

-- 1) INNER JOIN – Categories with their Products
SELECT c.category_id, c.category_name, p.product_id, p.name AS product_name, p.price
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
ORDER BY c.category_name;

-- 2) LEFT JOIN – Categories with Products (include empty categories)
SELECT c.category_id, c.category_name, p.product_id, p.name AS product_name
FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id
WHERE p.product_id IS NULL;

-- 3) RIGHT JOIN – Products with Categories (include uncategorized products)
SELECT p.product_id, p.name, c.category_name
FROM Categories c
RIGHT JOIN Products p ON c.category_id = p.category_id;

-- 4) JOIN across 3 tables – Category, Product, and Order_Items
SELECT c.category_name, p.name AS product_name,
       SUM(oi.quantity) AS total_sold, SUM(oi.subtotal) AS total_revenue
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY c.category_name, p.name
ORDER BY total_revenue DESC;

-- 5) SELF JOIN – Categories that share the same parent_category_id
SELECT a.category_id AS cat1, a.category_name AS category_1,
       b.category_id AS cat2, b.category_name AS category_2, a.parent_category_id
FROM Categories a
JOIN Categories b 
  ON a.parent_category_id = b.parent_category_id AND a.category_id < b.category_id;

-- 6) CROSS JOIN – Categories × Offers (demo for campaign planning)
SELECT c.category_name, o.offer_title, o.discount_percent
FROM (SELECT * FROM Categories LIMIT 5) c
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Sellers – Sellers selling products in each category
SELECT DISTINCT c.category_name, s.seller_name
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
JOIN Sellers s ON p.seller_id = s.seller_id
ORDER BY c.category_name;

-- 8) JOIN with Inventory – Category-wise stock summary
SELECT c.category_name, SUM(i.stock_quantity) AS total_stock
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
JOIN Inventory i ON p.product_id = i.product_id
GROUP BY c.category_name;

-- 9) JOIN with Reviews – Average rating by category
SELECT c.category_name, ROUND(AVG(r.rating),2) AS avg_rating
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
JOIN Reviews r ON p.product_id = r.product_id
GROUP BY c.category_name
ORDER BY avg_rating DESC;

-- 10) Scalar Subquery – Categories with more products than average
SELECT c.category_id, c.category_name
FROM Categories c
WHERE (SELECT COUNT(*) FROM Products p WHERE p.category_id = c.category_id)
      > (SELECT AVG(prod_count) 
         FROM (SELECT COUNT(*) AS prod_count FROM Products GROUP BY category_id) x);

-- 11) Correlated Subquery – Categories whose highest-priced product exceeds 10 000
SELECT c.category_id, c.category_name
FROM Categories c
WHERE (SELECT MAX(p.price) FROM Products p WHERE p.category_id = c.category_id) > 10000;

-- 12) Subquery with IN – Categories containing discounted products
SELECT category_id, category_name
FROM Categories
WHERE category_id IN (
    SELECT DISTINCT category_id FROM Products WHERE discount_percent > 0
);

-- 13) EXISTS – Categories that have at least one review rating 5
SELECT c.category_id, c.category_name
FROM Categories c
WHERE EXISTS (
    SELECT 1 FROM Products p 
    JOIN Reviews r ON p.product_id = r.product_id
    WHERE p.category_id = c.category_id AND r.rating = 5
);

-- 14) Subquery in FROM – Top 5 categories by total sales revenue
SELECT t.category_name, t.total_revenue
FROM (
    SELECT c.category_name, SUM(oi.subtotal) AS total_revenue
    FROM Categories c
    JOIN Products p ON c.category_id = p.category_id
    JOIN Order_Items oi ON p.product_id = oi.product_id
    GROUP BY c.category_name
    ORDER BY total_revenue DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Categories whose minimum product price > ALL category averages
SELECT c.category_id, c.category_name
FROM Categories c
WHERE (
    SELECT MIN(p.price) FROM Products p WHERE p.category_id = c.category_id
) > ALL (
    SELECT AVG(price) FROM Products GROUP BY category_id
);

-- 16) Built-in String – Format category names in proper case
SELECT category_id,
       CONCAT(UPPER(SUBSTRING(category_name,1,1)), LOWER(SUBSTRING(category_name,2))) 
       AS formatted_name
FROM Categories;

-- 17) Built-in Aggregate – Product count and average price by category
SELECT c.category_name, COUNT(p.product_id) AS total_products,
       ROUND(AVG(p.price),2) AS avg_price
FROM Categories c
LEFT JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_name;

-- 18) Built-in Numeric – Round average discount per category
SELECT c.category_name, ROUND(AVG(p.discount_percent),1) AS avg_discount
FROM Categories c
JOIN Products p ON c.category_id = p.category_id
GROUP BY c.category_name;

-- 19) UDF – CategoryProductCount(category_id)
DROP FUNCTION IF EXISTS CategoryProductCount;
DELIMITER $$
CREATE FUNCTION CategoryProductCount(cid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT COUNT(*) FROM Products WHERE category_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT category_id, CategoryProductCount(category_id) AS total_products FROM Categories;

-- 20) UDF – CategorySummary(category_id)
DROP FUNCTION IF EXISTS CategorySummary;
DELIMITER $$
CREATE FUNCTION CategorySummary(cid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Category: ', category_name, 
                  ' | Products: ', CategoryProductCount(category_id))
    FROM Categories WHERE category_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT CategorySummary(category_id) AS summary FROM Categories LIMIT 10;



-- --------------------------------- 5 Carts ------------------------------------------------------------- 
/* ---------------------------------------------------------------------------
   🛒 TABLE 5: CART (20 QUERIES)
   Project: Amazon E-Commerce Database System (AE-DBS)
   Author: Divya Pawar
   Phase-3: Joins | Subqueries | Built-in & User-Defined Functions
--------------------------------------------------------------------------- */

-- 1) INNER JOIN – Show carts with their users (customers)
SELECT c.cart_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name, 
       c.created_at, c.status
FROM Cart c
JOIN Users u ON c.user_id = u.user_id
ORDER BY c.created_at DESC;

-- 2) LEFT JOIN – Carts with items (show empty carts)
SELECT c.cart_id, ci.cart_item_id, ci.product_id
FROM Cart c
LEFT JOIN Cart_Items ci ON c.cart_id = ci.cart_id
WHERE ci.cart_item_id IS NULL;

-- 3) RIGHT JOIN – Cart_Items with Cart (include orphaned items if any)
SELECT c.cart_id, ci.cart_item_id, ci.quantity
FROM Cart_Items ci
RIGHT JOIN Cart c ON ci.cart_id = c.cart_id;

-- 4) JOIN across 3 tables – Cart, Cart_Items, and Products
SELECT c.cart_id, CONCAT(u.first_name,' ',u.last_name) AS user_name,
       p.name AS product_name, ci.quantity, p.price,
       (ci.quantity * p.price) AS item_total
FROM Cart c
JOIN Users u ON c.user_id = u.user_id
JOIN Cart_Items ci ON c.cart_id = ci.cart_id
JOIN Products p ON ci.product_id = p.product_id;

-- 5) SELF JOIN – Carts created on same date
SELECT a.cart_id AS cart1, b.cart_id AS cart2, a.created_at
FROM Cart a
JOIN Cart b ON DATE(a.created_at) = DATE(b.created_at) AND a.cart_id < b.cart_id;

-- 6) CROSS JOIN – First 3 carts × 3 random coupons (demo)
SELECT c.cart_id, cp.coupon_code, cp.discount_percent
FROM (SELECT * FROM Cart LIMIT 3) c
CROSS JOIN (SELECT * FROM Coupons LIMIT 3) cp;

-- 7) JOIN with Coupons – Carts linked with applied coupons
SELECT c.cart_id, cp.coupon_code, cp.discount_percent
FROM Cart c
JOIN Coupons cp ON c.coupon_id = cp.coupon_id;

-- 8) JOIN with Orders – Convert carts to orders
SELECT c.cart_id, o.order_id, o.order_date, o.total_amount
FROM Cart c
JOIN Orders o ON c.cart_id = o.cart_id;

-- 9) JOIN with Cart_Items + Products – Total cart value
SELECT c.cart_id, SUM(ci.quantity * p.price) AS total_value
FROM Cart c
JOIN Cart_Items ci ON c.cart_id = ci.cart_id
JOIN Products p ON ci.product_id = p.product_id
GROUP BY c.cart_id;

-- 10) Scalar Subquery – Carts with total value above average
SELECT cart_id
FROM Cart
WHERE cart_id IN (
    SELECT ci.cart_id
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    GROUP BY ci.cart_id
    HAVING SUM(ci.quantity * p.price) >
           (SELECT AVG(total_value) 
            FROM (SELECT SUM(ci2.quantity * p2.price) AS total_value
                  FROM Cart_Items ci2 
                  JOIN Products p2 ON ci2.product_id = p2.product_id
                  GROUP BY ci2.cart_id) t)
);

-- 11) Correlated Subquery – Carts newer than user's last order
SELECT c.cart_id, c.user_id, c.created_at
FROM Cart c
WHERE c.created_at > (
    SELECT MAX(o.order_date) FROM Orders o WHERE o.user_id = c.user_id
);

-- 12) Subquery with IN – Carts containing Electronics products
SELECT DISTINCT c.cart_id, c.user_id
FROM Cart c
WHERE c.cart_id IN (
    SELECT ci.cart_id
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    JOIN Categories cat ON p.category_id = cat.category_id
    WHERE cat.category_name = 'Electronics'
);

-- 13) EXISTS – Carts that have at least one discounted product
SELECT c.cart_id, c.user_id
FROM Cart c
WHERE EXISTS (
    SELECT 1 FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    WHERE ci.cart_id = c.cart_id AND p.discount_percent > 0
);

-- 14) Subquery in FROM – Top 5 carts by total cart value
SELECT t.cart_id, u.email, t.total_value
FROM (
    SELECT ci.cart_id, SUM(ci.quantity * p.price) AS total_value
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    GROUP BY ci.cart_id
    ORDER BY total_value DESC
    LIMIT 5
) t
JOIN Cart c ON t.cart_id = c.cart_id
JOIN Users u ON c.user_id = u.user_id;

-- 15) ANY / ALL – Carts with value greater than ALL average order totals
SELECT c.cart_id
FROM Cart c
WHERE (
    SELECT SUM(ci.quantity * p.price)
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    WHERE ci.cart_id = c.cart_id
) > ALL (SELECT AVG(total_amount) FROM Orders GROUP BY user_id);

-- 16) Built-in String & Date – Show cart creation month and formatted status
SELECT cart_id,
       CONCAT(UPPER(SUBSTRING(status,1,1)), LOWER(SUBSTRING(status,2))) AS formatted_status,
       MONTHNAME(created_at) AS created_month,
       YEAR(created_at) AS created_year
FROM Cart;

-- 17) Built-in Aggregate – Count of carts created per month
SELECT YEAR(created_at) AS year, MONTH(created_at) AS month, COUNT(*) AS total_carts
FROM Cart
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY year DESC, month DESC;

-- 18) Built-in Numeric – Average quantity of items per cart
SELECT ROUND(AVG(item_count),2) AS avg_items_per_cart
FROM (
    SELECT ci.cart_id, SUM(ci.quantity) AS item_count
    FROM Cart_Items ci
    GROUP BY ci.cart_id
) t;

-- 19) UDF – CalculateCartValue(cart_id)
DROP FUNCTION IF EXISTS CalculateCartValue;
DELIMITER $$
CREATE FUNCTION CalculateCartValue(cid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN (
    SELECT SUM(ci.quantity * p.price)
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    WHERE ci.cart_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT cart_id, CalculateCartValue(cart_id) AS total_value FROM Cart LIMIT 10;

-- 20) UDF – CartSummary(cart_id)
DROP FUNCTION IF EXISTS CartSummary;
DELIMITER $$
CREATE FUNCTION CartSummary(cid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Cart #', cart_id, ' | Items: ',
           (SELECT COUNT(*) FROM Cart_Items WHERE cart_id = cid),
           ' | Value: ₹', CalculateCartValue(cart_id))
    FROM Cart WHERE cart_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT CartSummary(cart_id) AS summary FROM Cart LIMIT 10;

-- ----------------------------------------- 6. Payments -------------------------------- 

-- 1) INNER JOIN – Payments with Orders and Users
SELECT p.payment_id, o.order_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       p.amount, p.payment_date, p.status
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
JOIN Users u ON p.user_id = u.user_id;

-- 2) LEFT JOIN – Payments with Refunds (include payments without refund)
SELECT p.payment_id, p.amount, r.refund_id, r.status AS refund_status
FROM Payments p
LEFT JOIN Refunds r ON p.payment_id = r.payment_id;

-- 3) RIGHT JOIN – Orders with Payments (include unpaid orders)
SELECT o.order_id, o.total_amount, p.payment_id, p.status
FROM Payments p
RIGHT JOIN Orders o ON p.order_id = o.order_id;

-- 4) JOIN across 3 tables – Payments, Orders, and Shipments
SELECT p.payment_id, p.amount, o.order_id, s.tracking_number, s.status AS shipment_status
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
LEFT JOIN Shipments s ON o.order_id = s.order_id
WHERE p.status = 'Success';

-- 5) SELF JOIN – Payments by same user on the same day
SELECT a.payment_id AS payment1, b.payment_id AS payment2, a.user_id, DATE(a.payment_date) AS pay_date
FROM Payments a
JOIN Payments b 
  ON a.user_id = b.user_id AND DATE(a.payment_date) = DATE(b.payment_date) AND a.payment_id < b.payment_id;

-- 6) CROSS JOIN – Top 3 successful payments × 3 offers (demo)
SELECT p.payment_id, p.amount, o.offer_title, o.discount_percent
FROM (SELECT * FROM Payments WHERE status='Success' ORDER BY amount DESC LIMIT 3) p
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Payment_Methods – Payment mode for each transaction
SELECT p.payment_id, p.amount, m.method_name, p.status
FROM Payments p
JOIN Payment_Methods m ON p.method_id = m.method_id;

-- 8) JOIN with Orders – Total payment per order
SELECT o.order_id, SUM(p.amount) AS total_paid
FROM Payments p
JOIN Orders o ON p.order_id = o.order_id
GROUP BY o.order_id;

-- 9) JOIN with Users – Total successful payments per user
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name,
       COUNT(p.payment_id) AS total_txns, SUM(p.amount) AS total_paid
FROM Users u
JOIN Payments p ON u.user_id = p.user_id
WHERE p.status='Success'
GROUP BY u.user_id
ORDER BY total_paid DESC;

-- 10) Scalar Subquery – Payments above average payment amount
SELECT payment_id, amount, status
FROM Payments
WHERE amount > (SELECT AVG(amount) FROM Payments);

-- 11) Correlated Subquery – Payments higher than user's average
SELECT p.payment_id, p.user_id, p.amount
FROM Payments p
WHERE p.amount > (
    SELECT AVG(p2.amount) FROM Payments p2 WHERE p2.user_id = p.user_id
);

-- 12) Subquery with IN – Payments for users with high-value orders
SELECT payment_id, user_id, amount
FROM Payments
WHERE user_id IN (
    SELECT user_id FROM Orders WHERE total_amount > 50000
);

-- 13) EXISTS – Payments linked to shipped orders
SELECT p.payment_id, p.amount
FROM Payments p
WHERE EXISTS (
    SELECT 1 FROM Shipments s 
    JOIN Orders o ON s.order_id = o.order_id
    WHERE o.order_id = p.order_id AND s.status='Delivered'
);

-- 14) Subquery in FROM – Top 5 users by total successful payments
SELECT t.user_id, u.email, t.total_paid
FROM (
    SELECT user_id, SUM(amount) AS total_paid
    FROM Payments
    WHERE status='Success'
    GROUP BY user_id
    ORDER BY total_paid DESC
    LIMIT 5
) t
JOIN Users u ON t.user_id = u.user_id;

-- 15) ANY / ALL – Payments larger than ALL refunds
SELECT payment_id, amount
FROM Payments
WHERE amount > ALL (SELECT amount FROM Refunds);

-- 16) Built-in String & Date – Format status and show payment month
SELECT payment_id,
       CONCAT(UPPER(SUBSTRING(status,1,1)), LOWER(SUBSTRING(status,2))) AS formatted_status,
       MONTHNAME(payment_date) AS payment_month,
       YEAR(payment_date) AS payment_year
FROM Payments;

-- 17) Built-in Aggregate – Monthly total revenue (successful only)
SELECT YEAR(payment_date) AS year, MONTH(payment_date) AS month,
       COUNT(payment_id) AS total_txn,
       SUM(amount) AS monthly_revenue
FROM Payments
WHERE status='Success'
GROUP BY YEAR(payment_date), MONTH(payment_date)
ORDER BY year DESC, month DESC;

-- 18) Built-in Numeric – Round amount and calculate 2% transaction fee
SELECT payment_id, ROUND(amount,2) AS base_amount,
       ROUND(amount * 0.02,2) AS transaction_fee,
       ROUND(amount - (amount * 0.02),2) AS final_amount
FROM Payments
WHERE status='Success';

-- 19) UDF – CalculateTransactionFee(amount)
DROP FUNCTION IF EXISTS CalculateTransactionFee;
DELIMITER $$
CREATE FUNCTION CalculateTransactionFee(amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN ROUND(amount * 0.02,2);
$$
DELIMITER ;
-- Example:
-- SELECT payment_id, CalculateTransactionFee(amount) AS fee FROM Payments LIMIT 10;

-- 20) UDF – PaymentSummary(payment_id)
DROP FUNCTION IF EXISTS PaymentSummary;
DELIMITER $$
CREATE FUNCTION PaymentSummary(pid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Payment #', payment_id, 
                  ' | Amount: ₹', amount, 
                  ' | Status: ', status)
    FROM Payments WHERE payment_id = pid
);
$$
DELIMITER ;
-- Example:
-- SELECT PaymentSummary(payment_id) AS summary FROM Payments LIMIT 10;


-- ------------------------------------ 7.Shipments ------------------------------------ 


-- 1) INNER JOIN – Shipments with corresponding Orders and Users
SELECT s.shipment_id, s.tracking_number, s.status AS shipment_status,
       o.order_id, o.order_date, CONCAT(u.first_name,' ',u.last_name) AS customer_name
FROM Shipments s
JOIN Orders o ON s.order_id = o.order_id
JOIN Users u ON o.user_id = u.user_id;

-- 2) LEFT JOIN – Shipments with Delivery_Address (include shipments missing address)
SELECT s.shipment_id, s.tracking_number, da.address_id, da.city
FROM Shipments s
LEFT JOIN Delivery_Address da ON s.address_id = da.address_id;

-- 3) RIGHT JOIN – Orders with Shipments (include unshipped orders)
SELECT o.order_id, o.total_amount, s.shipment_id, s.status
FROM Shipments s
RIGHT JOIN Orders o ON s.order_id = o.order_id;

-- 4) JOIN across 3 tables – Shipments, Orders, Payments (shipment with payment info)
SELECT s.shipment_id, s.tracking_number, o.order_id, p.payment_id, p.status AS payment_status
FROM Shipments s
JOIN Orders o ON s.order_id = o.order_id
LEFT JOIN Payments p ON o.order_id = p.order_id;

-- 5) SELF JOIN – Shipments from the same courier company
SELECT a.shipment_id AS shipment1, b.shipment_id AS shipment2, a.courier_name
FROM Shipments a
JOIN Shipments b ON a.courier_name = b.courier_name AND a.shipment_id < b.shipment_id;

-- 6) CROSS JOIN – Recent 3 shipments × 3 delivery partners (demo)
SELECT s.shipment_id, s.tracking_number, dp.partner_name
FROM (SELECT * FROM Shipments ORDER BY shipped_date DESC LIMIT 3) s
CROSS JOIN (SELECT * FROM Delivery_Partners LIMIT 3) dp;

-- 7) JOIN with Delivery_Partners – List shipments handled by each partner
SELECT s.shipment_id, s.tracking_number, dp.partner_name, s.status
FROM Shipments s
JOIN Delivery_Partners dp ON s.partner_id = dp.partner_id;

-- 8) JOIN with Orders – Shipment and total order amount
SELECT s.shipment_id, s.tracking_number, o.total_amount
FROM Shipments s
JOIN Orders o ON s.order_id = o.order_id
ORDER BY o.total_amount DESC;

-- 9) JOIN with Refunds – Show refunded shipments
SELECT s.shipment_id, s.tracking_number, r.refund_id, r.amount, r.status AS refund_status
FROM Shipments s
JOIN Refunds r ON s.order_id = r.order_id
WHERE r.status = 'Completed';

-- 10) Scalar Subquery – Shipments delayed more than average days
SELECT shipment_id, tracking_number, 
       DATEDIFF(delivered_date, shipped_date) AS delivery_days
FROM Shipments
WHERE DATEDIFF(delivered_date, shipped_date) > (
    SELECT AVG(DATEDIFF(delivered_date, shipped_date)) FROM Shipments
);

-- 11) Correlated Subquery – Shipments slower than average for their courier
SELECT s.shipment_id, s.courier_name, 
       DATEDIFF(s.delivered_date, s.shipped_date) AS days_taken
FROM Shipments s
WHERE DATEDIFF(s.delivered_date, s.shipped_date) > (
    SELECT AVG(DATEDIFF(s2.delivered_date, s2.shipped_date))
    FROM Shipments s2
    WHERE s2.courier_name = s.courier_name
);

-- 12) Subquery with IN – Shipments belonging to users from specific city
SELECT shipment_id, tracking_number
FROM Shipments
WHERE order_id IN (
    SELECT o.order_id FROM Orders o
    JOIN Delivery_Address da ON o.address_id = da.address_id
    WHERE da.city = 'Mumbai'
);

-- 13) EXISTS – Shipments where payment was successful
SELECT s.shipment_id, s.tracking_number
FROM Shipments s
WHERE EXISTS (
    SELECT 1 FROM Payments p 
    JOIN Orders o ON p.order_id = o.order_id
    WHERE o.order_id = s.order_id AND p.status='Success'
);

-- 14) Subquery in FROM – Top 5 couriers by total shipments handled
SELECT t.courier_name, t.total_shipments
FROM (
    SELECT courier_name, COUNT(*) AS total_shipments
    FROM Shipments
    GROUP BY courier_name
    ORDER BY total_shipments DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Shipments longer than ALL average delivery durations
SELECT shipment_id, tracking_number
FROM Shipments
WHERE DATEDIFF(delivered_date, shipped_date) > ALL (
    SELECT AVG(DATEDIFF(delivered_date, shipped_date)) FROM Shipments GROUP BY courier_name
);

-- 16) Built-in String & Date – Show delivery month and formatted status
SELECT shipment_id,
       CONCAT(UPPER(SUBSTRING(status,1,1)), LOWER(SUBSTRING(status,2))) AS formatted_status,
       MONTHNAME(shipped_date) AS shipped_month,
       DATEDIFF(delivered_date, shipped_date) AS delivery_days
FROM Shipments;

-- 17) Built-in Aggregate – Count shipments by status
SELECT status, COUNT(*) AS total_shipments
FROM Shipments
GROUP BY status;

-- 18) Built-in Numeric – Calculate delay in days and round average delay
SELECT ROUND(AVG(DATEDIFF(delivered_date, shipped_date)),1) AS avg_days,
       MAX(DATEDIFF(delivered_date, shipped_date)) AS longest_delay
FROM Shipments;

-- 19) UDF – CalculateDeliveryDays(ship_id)
DROP FUNCTION IF EXISTS CalculateDeliveryDays;
DELIMITER $$
CREATE FUNCTION CalculateDeliveryDays(sid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT DATEDIFF(delivered_date, shipped_date) FROM Shipments WHERE shipment_id = sid
);
$$
DELIMITER ;
-- Example:
-- SELECT shipment_id, CalculateDeliveryDays(shipment_id) AS total_days FROM Shipments LIMIT 10;

-- 20) UDF – ShipmentSummary(shipment_id)
DROP FUNCTION IF EXISTS ShipmentSummary;
DELIMITER $$
CREATE FUNCTION ShipmentSummary(sid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Shipment #', shipment_id, ' | Courier: ', courier_name,
                  ' | Status: ', status, ' | Days: ',
                  DATEDIFF(delivered_date, shipped_date))
    FROM Shipments WHERE shipment_id = sid
);
$$
DELIMITER ;
-- Example:
-- SELECT ShipmentSummary(shipment_id) AS summary FROM Shipments LIMIT 10;

-- -------------------------------------- 8. delivery_address  ----------------------------------- 

-- 1) INNER JOIN – Delivery addresses with corresponding users
SELECT da.address_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       da.street_address, da.city, da.state, da.pincode
FROM Delivery_Address da
JOIN Users u ON da.user_id = u.user_id;

-- 2) LEFT JOIN – Delivery addresses with orders (include unused addresses)
SELECT da.address_id, da.city, da.pincode, o.order_id
FROM Delivery_Address da
LEFT JOIN Orders o ON da.address_id = o.address_id
WHERE o.order_id IS NULL;

-- 3) RIGHT JOIN – Orders with addresses (include missing address)
SELECT o.order_id, da.address_id, da.city, da.state
FROM Delivery_Address da
RIGHT JOIN Orders o ON da.address_id = o.address_id;

-- 4) JOIN across 3 tables – Address, Orders, and Shipments
SELECT da.address_id, da.city, o.order_id, s.tracking_number, s.status AS shipment_status
FROM Delivery_Address da
JOIN Orders o ON da.address_id = o.address_id
JOIN Shipments s ON o.order_id = s.order_id;

-- 5) SELF JOIN – Addresses within the same city
SELECT a.address_id AS addr1, b.address_id AS addr2, a.city
FROM Delivery_Address a
JOIN Delivery_Address b 
  ON a.city = b.city AND a.address_id < b.address_id;

-- 6) CROSS JOIN – First 3 addresses × 3 available couriers (demo)
SELECT da.address_id, da.city, dp.partner_name
FROM (SELECT * FROM Delivery_Address LIMIT 3) da
CROSS JOIN (SELECT * FROM Delivery_Partners LIMIT 3) dp;

-- 7) JOIN with Cities – Show city details for each address
SELECT da.address_id, da.street_address, c.city_name, c.state_name
FROM Delivery_Address da
JOIN Cities c ON da.city_id = c.city_id;

-- 8) JOIN with Users and Orders – Delivery history per user
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name, 
       da.city, COUNT(o.order_id) AS total_orders
FROM Users u
JOIN Delivery_Address da ON u.user_id = da.user_id
JOIN Orders o ON da.address_id = o.address_id
GROUP BY u.user_id, da.city;

-- 9) JOIN with Refunds – Refunds linked to delivery addresses
SELECT da.address_id, da.city, r.refund_id, r.amount, r.status
FROM Delivery_Address da
JOIN Orders o ON da.address_id = o.address_id
JOIN Refunds r ON o.order_id = r.order_id;

-- 10) Scalar Subquery – Addresses with more than one order
SELECT address_id, city, pincode
FROM Delivery_Address
WHERE (SELECT COUNT(*) FROM Orders o WHERE o.address_id = Delivery_Address.address_id) > 1;

-- 11) Correlated Subquery – Addresses with orders higher than average of that city
SELECT da.address_id, da.city
FROM Delivery_Address da
WHERE (
    SELECT AVG(o.total_amount)
    FROM Orders o 
    JOIN Delivery_Address d2 ON o.address_id = d2.address_id
    WHERE d2.city = da.city
) < (
    SELECT AVG(o2.total_amount)
    FROM Orders o2
    WHERE o2.address_id = da.address_id
);

-- 12) Subquery with IN – Addresses used for orders over ₹10,000
SELECT address_id, city
FROM Delivery_Address
WHERE address_id IN (
    SELECT address_id FROM Orders WHERE total_amount > 10000
);

-- 13) EXISTS – Addresses linked to delivered shipments
SELECT da.address_id, da.city
FROM Delivery_Address da
WHERE EXISTS (
    SELECT 1 FROM Shipments s 
    JOIN Orders o ON s.order_id = o.order_id
    WHERE o.address_id = da.address_id AND s.status = 'Delivered'
);

-- 14) Subquery in FROM – Top 5 cities by number of addresses
SELECT t.city, t.total_addresses
FROM (
    SELECT city, COUNT(*) AS total_addresses
    FROM Delivery_Address
    GROUP BY city
    ORDER BY total_addresses DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Addresses with pincode greater than ALL Mumbai addresses
SELECT address_id, city, pincode
FROM Delivery_Address
WHERE pincode > ALL (
    SELECT pincode FROM Delivery_Address WHERE city = 'Mumbai'
);

-- 16) Built-in String – Format city and state names in proper case
SELECT address_id,
       CONCAT(UPPER(SUBSTRING(city,1,1)), LOWER(SUBSTRING(city,2))) AS formatted_city,
       CONCAT(UPPER(SUBSTRING(state,1,1)), LOWER(SUBSTRING(state,2))) AS formatted_state
FROM Delivery_Address;

-- 17) Built-in Aggregate – Count of addresses per city
SELECT city, COUNT(address_id) AS total_addresses
FROM Delivery_Address
GROUP BY city
ORDER BY total_addresses DESC;

-- 18) Built-in Date/Time – Show recently added addresses (last 30 days)
SELECT address_id, city, created_at
FROM Delivery_Address
WHERE DATEDIFF(CURDATE(), created_at) <= 30;

-- 19) UDF – GetFullAddress(address_id)
DROP FUNCTION IF EXISTS GetFullAddress;
DELIMITER $$
CREATE FUNCTION GetFullAddress(aid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT(street_address, ', ', city, ', ', state, ' - ', pincode)
    FROM Delivery_Address WHERE address_id = aid
);
$$
DELIMITER ;
-- Example:
-- SELECT GetFullAddress(address_id) AS full_address FROM Delivery_Address LIMIT 10;

-- 20) UDF – AddressSummary(address_id)
DROP FUNCTION IF EXISTS AddressSummary;
DELIMITER $$
CREATE FUNCTION AddressSummary(aid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Address ID: ', address_id, ' | City: ', city,
                  ' | Pincode: ', pincode)
    FROM Delivery_Address WHERE address_id = aid
);
$$
DELIMITER ;
-- Example:
-- SELECT AddressSummary(address_id) AS summary FROM Delivery_Address LIMIT 10;


-- ------------------------------------- 9.  cities ------------------------------------------ 

-- 1) INNER JOIN – Cities with delivery addresses
SELECT c.city_id, c.city_name, da.address_id, da.street_address, da.pincode
FROM Cities c
JOIN Delivery_Address da ON c.city_id = da.city_id;

-- 2) LEFT JOIN – Cities with users (include cities without users)
SELECT c.city_id, c.city_name, u.user_id, u.email
FROM Cities c
LEFT JOIN Users u ON c.city_id = u.city_id
WHERE u.user_id IS NULL;

-- 3) RIGHT JOIN – Addresses with cities (include addresses with unknown city)
SELECT da.address_id, da.street_address, c.city_name, c.state_name
FROM Cities c
RIGHT JOIN Delivery_Address da ON c.city_id = da.city_id;

-- 4) JOIN across 3 tables – Cities, Users, and Orders
SELECT c.city_name, u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name,
       COUNT(o.order_id) AS total_orders
FROM Cities c
JOIN Users u ON c.city_id = u.city_id
JOIN Orders o ON u.user_id = o.user_id
GROUP BY c.city_name, u.user_id;

-- 5) SELF JOIN – Cities within the same state
SELECT a.city_id AS city1, a.city_name AS city_name1,
       b.city_id AS city2, b.city_name AS city_name2, a.state_name
FROM Cities a
JOIN Cities b ON a.state_name = b.state_name AND a.city_id < b.city_id;

-- 6) CROSS JOIN – Cities × Sellers (demo combinations)
SELECT c.city_name, s.seller_name
FROM (SELECT * FROM Cities LIMIT 3) c
CROSS JOIN (SELECT * FROM Sellers LIMIT 3) s;

-- 7) JOIN with Sellers – Sellers operating in specific cities
SELECT s.seller_id, s.seller_name, c.city_name
FROM Sellers s
JOIN Cities c ON s.city_id = c.city_id;

-- 8) JOIN with Orders via Users – Total order amount per city
SELECT c.city_name, SUM(o.total_amount) AS total_sales
FROM Cities c
JOIN Users u ON c.city_id = u.city_id
JOIN Orders o ON u.user_id = o.user_id
GROUP BY c.city_name
ORDER BY total_sales DESC;

-- 9) JOIN with Refunds – Total refund amount per city
SELECT c.city_name, SUM(r.amount) AS total_refunded
FROM Cities c
JOIN Users u ON c.city_id = u.city_id
JOIN Refunds r ON u.user_id = r.user_id
GROUP BY c.city_name;

-- 10) Scalar Subquery – Cities with more than average number of users
SELECT c.city_id, c.city_name
FROM Cities c
WHERE (SELECT COUNT(*) FROM Users u WHERE u.city_id = c.city_id) >
      (SELECT AVG(user_count)
       FROM (SELECT COUNT(*) AS user_count FROM Users GROUP BY city_id) t);

-- 11) Correlated Subquery – Cities with higher total order value than average
SELECT c.city_id, c.city_name
FROM Cities c
WHERE (SELECT SUM(o.total_amount)
       FROM Users u JOIN Orders o ON u.user_id = o.user_id
       WHERE u.city_id = c.city_id)
      > (SELECT AVG(total_sales)
         FROM (SELECT SUM(o2.total_amount) AS total_sales
               FROM Users u2 JOIN Orders o2 ON u2.user_id = o2.user_id
               GROUP BY u2.city_id) x);

-- 12) Subquery with IN – Cities having users with refunds
SELECT city_id, city_name
FROM Cities
WHERE city_id IN (
    SELECT DISTINCT u.city_id
    FROM Users u
    JOIN Refunds r ON u.user_id = r.user_id
);

-- 13) EXISTS – Cities with at least one active seller
SELECT c.city_id, c.city_name
FROM Cities c
WHERE EXISTS (
    SELECT 1 FROM Sellers s WHERE s.city_id = c.city_id AND s.status = 'Active'
);

-- 14) Subquery in FROM – Top 5 cities by total orders
SELECT t.city_name, t.total_orders
FROM (
    SELECT c.city_name, COUNT(o.order_id) AS total_orders
    FROM Cities c
    JOIN Users u ON c.city_id = u.city_id
    JOIN Orders o ON u.user_id = o.user_id
    GROUP BY c.city_name
    ORDER BY total_orders DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Cities with user count higher than ALL others’ average
SELECT c.city_id, c.city_name
FROM Cities c
WHERE (SELECT COUNT(*) FROM Users u WHERE u.city_id = c.city_id)
      > ALL (SELECT AVG(user_count)
             FROM (SELECT COUNT(*) AS user_count FROM Users GROUP BY city_id) y);

-- 16) Built-in String – Format city and state names properly
SELECT city_id,
       CONCAT(UPPER(SUBSTRING(city_name,1,1)), LOWER(SUBSTRING(city_name,2))) AS formatted_city,
       CONCAT(UPPER(SUBSTRING(state_name,1,1)), LOWER(SUBSTRING(state_name,2))) AS formatted_state
FROM Cities;

-- 17) Built-in Aggregate – Count of users and sellers per city
SELECT c.city_name,
       COUNT(DISTINCT u.user_id) AS total_users,
       COUNT(DISTINCT s.seller_id) AS total_sellers
FROM Cities c
LEFT JOIN Users u ON c.city_id = u.city_id
LEFT JOIN Sellers s ON c.city_id = s.city_id
GROUP BY c.city_name;

-- 18) Built-in Numeric – Average total sales per city rounded
SELECT c.city_name, ROUND(AVG(o.total_amount),2) AS avg_sales
FROM Cities c
JOIN Users u ON c.city_id = u.city_id
JOIN Orders o ON u.user_id = o.user_id
GROUP BY c.city_name;

-- 19) UDF – CityUserCount(city_id)
DROP FUNCTION IF EXISTS CityUserCount;
DELIMITER $$
CREATE FUNCTION CityUserCount(cid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT COUNT(*) FROM Users WHERE city_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT city_id, CityUserCount(city_id) AS total_users FROM Cities;

-- 20) UDF – CitySummary(city_id)
DROP FUNCTION IF EXISTS CitySummary;
DELIMITER $$
CREATE FUNCTION CitySummary(cid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('City: ', city_name, 
                  ' | Users: ', CityUserCount(city_id))
    FROM Cities WHERE city_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT CitySummary(city_id) AS summary FROM Cities LIMIT 10;

-- ----------------------------------------- 10. sellers ------------------------------------------ 

-- 1) INNER JOIN – Sellers with their products
SELECT s.seller_id, s.seller_name, p.product_id, p.name AS product_name, p.price
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id;

-- 2) LEFT JOIN – Sellers with orders (include sellers without sales)
SELECT s.seller_id, s.seller_name, o.order_id
FROM Sellers s
LEFT JOIN Orders o ON s.seller_id = o.seller_id
WHERE o.order_id IS NULL;

-- 3) RIGHT JOIN – Products with sellers (include products missing seller)
SELECT p.product_id, p.name, s.seller_name
FROM Sellers s
RIGHT JOIN Products p ON s.seller_id = p.seller_id;

-- 4) JOIN across 3 tables – Sellers, Products, and Orders
SELECT s.seller_name, COUNT(DISTINCT o.order_id) AS total_orders,
       SUM(oi.quantity * oi.price) AS total_sales
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id
JOIN Order_Items oi ON p.product_id = oi.product_id
JOIN Orders o ON oi.order_id = o.order_id
GROUP BY s.seller_name
ORDER BY total_sales DESC;

-- 5) SELF JOIN – Sellers from same city
SELECT a.seller_name AS seller1, b.seller_name AS seller2, a.city_id
FROM Sellers a
JOIN Sellers b 
  ON a.city_id = b.city_id AND a.seller_id < b.seller_id;

-- 6) CROSS JOIN – Sellers × Offers (demo of promotions)
SELECT s.seller_name, o.offer_title, o.discount_percent
FROM (SELECT * FROM Sellers LIMIT 3) s
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Cities – Seller location details
SELECT s.seller_id, s.seller_name, c.city_name, c.state_name
FROM Sellers s
JOIN Cities c ON s.city_id = c.city_id;

-- 8) JOIN with Inventory – Total stock managed by seller
SELECT s.seller_name, SUM(i.stock_quantity) AS total_stock
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id
JOIN Inventory i ON p.product_id = i.product_id
GROUP BY s.seller_name;

-- 9) JOIN with Reviews – Average product rating per seller
SELECT s.seller_name, ROUND(AVG(r.rating),2) AS avg_rating
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id
JOIN Reviews r ON p.product_id = r.product_id
GROUP BY s.seller_name
ORDER BY avg_rating DESC;

-- 10) Scalar Subquery – Sellers with more than average products
SELECT seller_id, seller_name
FROM Sellers
WHERE (SELECT COUNT(*) FROM Products p WHERE p.seller_id = Sellers.seller_id) >
      (SELECT AVG(prod_count)
       FROM (SELECT COUNT(*) AS prod_count FROM Products GROUP BY seller_id) t);

-- 11) Correlated Subquery – Sellers with top product price > 10,000
SELECT s.seller_id, s.seller_name
FROM Sellers s
WHERE (SELECT MAX(p.price) FROM Products p WHERE p.seller_id = s.seller_id) > 10000;

-- 12) Subquery with IN – Sellers having refunded orders
SELECT seller_id, seller_name
FROM Sellers
WHERE seller_id IN (
    SELECT DISTINCT o.seller_id
    FROM Orders o
    JOIN Refunds r ON o.order_id = r.order_id
);

-- 13) EXISTS – Sellers with at least one delivered shipment
SELECT s.seller_id, s.seller_name
FROM Sellers s
WHERE EXISTS (
    SELECT 1 FROM Shipments sh
    JOIN Orders o ON sh.order_id = o.order_id
    WHERE o.seller_id = s.seller_id AND sh.status='Delivered'
);

-- 14) Subquery in FROM – Top 5 sellers by revenue
SELECT t.seller_name, t.total_sales
FROM (
    SELECT s.seller_name, SUM(oi.quantity * oi.price) AS total_sales
    FROM Sellers s
    JOIN Products p ON s.seller_id = p.seller_id
    JOIN Order_Items oi ON p.product_id = oi.product_id
    GROUP BY s.seller_name
    ORDER BY total_sales DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Sellers whose lowest product price > ALL average category prices
SELECT s.seller_id, s.seller_name
FROM Sellers s
WHERE (SELECT MIN(p.price) FROM Products p WHERE p.seller_id = s.seller_id)
      > ALL (SELECT AVG(price) FROM Products GROUP BY category_id);

-- 16) Built-in String – Format seller names properly
SELECT seller_id,
       CONCAT(UPPER(SUBSTRING(seller_name,1,1)), LOWER(SUBSTRING(seller_name,2))) AS formatted_name
FROM Sellers;

-- 17) Built-in Aggregate – Count of products and average price per seller
SELECT s.seller_name, COUNT(p.product_id) AS total_products,
       ROUND(AVG(p.price),2) AS avg_price
FROM Sellers s
LEFT JOIN Products p ON s.seller_id = p.seller_id
GROUP BY s.seller_name;

-- 18) Built-in Numeric – Round seller’s average discount
SELECT s.seller_name, ROUND(AVG(p.discount_percent),1) AS avg_discount
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id
GROUP BY s.seller_name;

-- 19) UDF – SellerProductCount(seller_id)
DROP FUNCTION IF EXISTS SellerProductCount;
DELIMITER $$
CREATE FUNCTION SellerProductCount(sid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT COUNT(*) FROM Products WHERE seller_id = sid
);
$$
DELIMITER ;
-- Example:
-- SELECT seller_id, SellerProductCount(seller_id) AS total_products FROM Sellers;

-- 20) UDF – SellerSummary(seller_id)
DROP FUNCTION IF EXISTS SellerSummary;
DELIMITER $$
CREATE FUNCTION SellerSummary(sid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Seller: ', seller_name,
                  ' | Products: ', SellerProductCount(seller_id))
    FROM Sellers WHERE seller_id = sid
);
$$
DELIMITER ;
-- Example:
-- SELECT SellerSummary(seller_id) AS summary FROM Sellers LIMIT 10;

-- ------------------------------------- 11. Inventory -------------------------------- 
-- 1) INNER JOIN – Inventory with Products
SELECT i.inventory_id, p.product_id, p.name AS product_name, 
       i.stock_quantity, i.last_restocked_date
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id;

-- 2) LEFT JOIN – Inventory with Sellers (include items without seller)
SELECT i.inventory_id, p.name AS product_name, s.seller_name
FROM Inventory i
LEFT JOIN Products p ON i.product_id = p.product_id
LEFT JOIN Sellers s ON p.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- 3) RIGHT JOIN – Products with Inventory (include products with no stock)
SELECT p.product_id, p.name, i.stock_quantity
FROM Inventory i
RIGHT JOIN Products p ON i.product_id = p.product_id;

-- 4) JOIN across 3 tables – Inventory, Products, and Categories
SELECT i.inventory_id, p.name AS product_name, c.category_name, 
       i.stock_quantity
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
ORDER BY c.category_name;

-- 5) SELF JOIN – Inventory items with same stock quantity
SELECT a.inventory_id AS inv1, b.inventory_id AS inv2, a.stock_quantity
FROM Inventory a
JOIN Inventory b ON a.stock_quantity = b.stock_quantity 
                 AND a.inventory_id < b.inventory_id;

-- 6) CROSS JOIN – Inventory × Offers (sample combinations)
SELECT i.inventory_id, p.name AS product_name, o.offer_title
FROM (SELECT * FROM Inventory LIMIT 3) i
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o
JOIN Products p ON i.product_id = p.product_id;

-- 7) JOIN with Sellers – Seller-wise stock summary
SELECT s.seller_name, SUM(i.stock_quantity) AS total_stock
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Sellers s ON p.seller_id = s.seller_id
GROUP BY s.seller_name
ORDER BY total_stock DESC;

-- 8) JOIN with Orders – Items sold vs. stock
SELECT p.name AS product_name,
       SUM(oi.quantity) AS sold_quantity,
       i.stock_quantity AS available_stock
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.name, i.stock_quantity;

-- 9) JOIN with Categories – Total stock per category
SELECT c.category_name, SUM(i.stock_quantity) AS total_stock
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

-- 10) Scalar Subquery – Inventory above average stock
SELECT inventory_id, product_id, stock_quantity
FROM Inventory
WHERE stock_quantity > (SELECT AVG(stock_quantity) FROM Inventory);

-- 11) Correlated Subquery – Items restocked later than category’s average date
SELECT i.inventory_id, i.product_id, i.last_restocked_date
FROM Inventory i
WHERE i.last_restocked_date > (
    SELECT AVG_DATE(last_restocked_date)
    FROM Inventory i2
    JOIN Products p2 ON i2.product_id = p2.product_id
    WHERE p2.category_id = (SELECT category_id FROM Products WHERE product_id = i.product_id)
);

-- 12) Subquery with IN – Inventory items belonging to active sellers
SELECT inventory_id, product_id
FROM Inventory
WHERE product_id IN (
    SELECT product_id FROM Products p
    JOIN Sellers s ON p.seller_id = s.seller_id
    WHERE s.status = 'Active'
);

-- 13) EXISTS – Inventory linked to products with discounts
SELECT i.inventory_id, p.name AS product_name
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
WHERE EXISTS (
    SELECT 1 FROM Products pr 
    WHERE pr.product_id = i.product_id AND pr.discount_percent > 0
);

-- 14) Subquery in FROM – Top 5 most stocked products
SELECT t.product_name, t.stock_quantity
FROM (
    SELECT p.name AS product_name, i.stock_quantity
    FROM Inventory i
    JOIN Products p ON i.product_id = p.product_id
    ORDER BY i.stock_quantity DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Inventory with stock higher than ALL category averages
SELECT i.inventory_id, p.name, i.stock_quantity
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
WHERE i.stock_quantity > ALL (
    SELECT AVG(i2.stock_quantity)
    FROM Inventory i2
    JOIN Products p2 ON i2.product_id = p2.product_id
    GROUP BY p2.category_id
);

-- 16) Built-in String – Format product names and add stock label
SELECT i.inventory_id,
       CONCAT(UPPER(SUBSTRING(p.name,1,1)), LOWER(SUBSTRING(p.name,2))) AS formatted_name,
       CONCAT('Stock: ', i.stock_quantity) AS stock_label
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id;

-- 17) Built-in Aggregate – Total stock and average restock per seller
SELECT s.seller_name, COUNT(i.inventory_id) AS total_items,
       SUM(i.stock_quantity) AS total_stock
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id
JOIN Sellers s ON p.seller_id = s.seller_id
GROUP BY s.seller_name;

-- 18) Built-in Date – Days since last restock
SELECT i.inventory_id, p.name AS product_name,
       DATEDIFF(CURDATE(), i.last_restocked_date) AS days_since_restock
FROM Inventory i
JOIN Products p ON i.product_id = p.product_id;

-- 19) UDF – CalculateStockValue(product_id)
DROP FUNCTION IF EXISTS CalculateStockValue;
DELIMITER $$
CREATE FUNCTION CalculateStockValue(pid INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
RETURN (
    SELECT (i.stock_quantity * p.price)
    FROM Inventory i
    JOIN Products p ON i.product_id = p.product_id
    WHERE i.product_id = pid
);
$$
DELIMITER ;
-- Example:
-- SELECT product_id, CalculateStockValue(product_id) AS stock_value FROM Inventory;

-- 20) UDF – InventorySummary(inventory_id)
DROP FUNCTION IF EXISTS InventorySummary;
DELIMITER $$
CREATE FUNCTION InventorySummary(iid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Inventory ID: ', inventory_id,
                  ' | Product: ', p.name,
                  ' | Stock: ', stock_quantity)
    FROM Inventory i
    JOIN Products p ON i.product_id = p.product_id
    WHERE i.inventory_id = iid
);
$$
DELIMITER ;
-- Example:
-- SELECT InventorySummary(inventory_id) AS summary FROM Inventory LIMIT 10;

-- ----------------------------------- 12.  cart_items   ------------------------------------- 
-- 1) INNER JOIN – Cart items with their carts
SELECT ci.cart_item_id, c.cart_id, c.user_id, ci.product_id, ci.quantity
FROM Cart_Items ci
JOIN Cart c ON ci.cart_id = c.cart_id;

-- 2) LEFT JOIN – Cart items with products (include missing products)
SELECT ci.cart_item_id, ci.cart_id, p.name AS product_name
FROM Cart_Items ci
LEFT JOIN Products p ON ci.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 3) RIGHT JOIN – Products with cart items (include unsold items)
SELECT p.product_id, p.name, ci.cart_item_id
FROM Cart_Items ci
RIGHT JOIN Products p ON ci.product_id = p.product_id;

-- 4) JOIN across 3 tables – Cart_Items, Cart, and Users
SELECT ci.cart_item_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       ci.product_id, ci.quantity
FROM Cart_Items ci
JOIN Cart c ON ci.cart_id = c.cart_id
JOIN Users u ON c.user_id = u.user_id;

-- 5) SELF JOIN – Cart items of same cart
SELECT a.cart_item_id AS item1, b.cart_item_id AS item2, a.cart_id
FROM Cart_Items a
JOIN Cart_Items b 
  ON a.cart_id = b.cart_id AND a.cart_item_id < b.cart_item_id;

-- 6) CROSS JOIN – Cart items × Offers (for promo testing)
SELECT ci.cart_item_id, p.name AS product_name, o.offer_title
FROM (SELECT * FROM Cart_Items LIMIT 3) ci
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o
JOIN Products p ON ci.product_id = p.product_id;

-- 7) JOIN with Products – Show product name and price per cart item
SELECT ci.cart_item_id, ci.cart_id, p.name AS product_name, p.price, ci.quantity
FROM Cart_Items ci
JOIN Products p ON ci.product_id = p.product_id;

-- 8) JOIN with Cart – Calculate total cart value
SELECT c.cart_id, SUM(ci.quantity * p.price) AS total_value
FROM Cart_Items ci
JOIN Cart c ON ci.cart_id = c.cart_id
JOIN Products p ON ci.product_id = p.product_id
GROUP BY c.cart_id;

-- 9) JOIN with Categories – Category-wise items in cart
SELECT c.cart_id, cat.category_name, SUM(ci.quantity) AS total_items
FROM Cart_Items ci
JOIN Products p ON ci.product_id = p.product_id
JOIN Categories cat ON p.category_id = cat.category_id
JOIN Cart c ON ci.cart_id = c.cart_id
GROUP BY c.cart_id, cat.category_name;

-- 10) Scalar Subquery – Cart items above average quantity
SELECT cart_item_id, product_id, quantity
FROM Cart_Items
WHERE quantity > (SELECT AVG(quantity) FROM Cart_Items);

-- 11) Correlated Subquery – Items with higher price than cart average
SELECT ci.cart_item_id, ci.cart_id, p.name, p.price
FROM Cart_Items ci
JOIN Products p ON ci.product_id = p.product_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM Cart_Items ci2
    JOIN Products p2 ON ci2.product_id = p2.product_id
    WHERE ci2.cart_id = ci.cart_id
);

-- 12) Subquery with IN – Cart items containing discounted products
SELECT cart_item_id, product_id
FROM Cart_Items
WHERE product_id IN (
    SELECT product_id FROM Products WHERE discount_percent > 0
);

-- 13) EXISTS – Cart items that belong to active user carts
SELECT ci.cart_item_id, ci.cart_id
FROM Cart_Items ci
WHERE EXISTS (
    SELECT 1 FROM Cart c WHERE c.cart_id = ci.cart_id AND c.status='Active'
);

-- 14) Subquery in FROM – Top 5 carts by total item count
SELECT t.cart_id, t.total_items
FROM (
    SELECT cart_id, SUM(quantity) AS total_items
    FROM Cart_Items
    GROUP BY cart_id
    ORDER BY total_items DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Items whose quantity > ALL average cart quantities
SELECT cart_item_id, cart_id, quantity
FROM Cart_Items
WHERE quantity > ALL (
    SELECT AVG(quantity) FROM Cart_Items GROUP BY cart_id
);

-- 16) Built-in String – Add label to cart item
SELECT cart_item_id,
       CONCAT('Item-', cart_item_id, ' | Qty: ', quantity) AS item_label
FROM Cart_Items;

-- 17) Built-in Aggregate – Total quantity and average quantity per cart
SELECT cart_id, COUNT(cart_item_id) AS item_count, SUM(quantity) AS total_quantity,
       ROUND(AVG(quantity),2) AS avg_quantity
FROM Cart_Items
GROUP BY cart_id;

-- 18) Built-in Numeric – Calculate subtotal for each cart item
SELECT ci.cart_item_id, ci.cart_id, p.name AS product_name,
       p.price, ci.quantity, ROUND(ci.quantity * p.price,2) AS subtotal
FROM Cart_Items ci
JOIN Products p ON ci.product_id = p.product_id;

-- 19) UDF – GetCartItemValue(cart_item_id)
DROP FUNCTION IF EXISTS GetCartItemValue;
DELIMITER $$
CREATE FUNCTION GetCartItemValue(cid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN (
    SELECT (ci.quantity * p.price)
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    WHERE ci.cart_item_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT cart_item_id, GetCartItemValue(cart_item_id) AS item_value FROM Cart_Items;

-- 20) UDF – CartItemSummary(cart_item_id)
DROP FUNCTION IF EXISTS CartItemSummary;
DELIMITER $$
CREATE FUNCTION CartItemSummary(cid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Cart Item #', cart_item_id, 
                  ' | Product: ', p.name, 
                  ' | Qty: ', ci.quantity,
                  ' | Value: ₹', (ci.quantity * p.price))
    FROM Cart_Items ci
    JOIN Products p ON ci.product_id = p.product_id
    WHERE ci.cart_item_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT CartItemSummary(cart_item_id) AS summary FROM Cart_Items LIMIT 10;

-- ---------------------------------------- 13. reviews --------------------------------------- 
-- 1) INNER JOIN – Reviews with users and products
SELECT r.review_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       p.name AS product_name, r.rating, r.comment
FROM Reviews r
JOIN Users u ON r.user_id = u.user_id
JOIN Products p ON r.product_id = p.product_id;

-- 2) LEFT JOIN – Products with reviews (show products with no reviews)
SELECT p.product_id, p.name, r.review_id
FROM Products p
LEFT JOIN Reviews r ON p.product_id = r.product_id
WHERE r.review_id IS NULL;

-- 3) RIGHT JOIN – Reviews with products (show missing product links)
SELECT r.review_id, r.comment, p.product_id, p.name
FROM Reviews r
RIGHT JOIN Products p ON r.product_id = p.product_id;

-- 4) JOIN across 3 tables – Reviews, Products, and Sellers
SELECT s.seller_name, p.name AS product_name, 
       ROUND(AVG(r.rating),2) AS avg_rating, COUNT(r.review_id) AS total_reviews
FROM Reviews r
JOIN Products p ON r.product_id = p.product_id
JOIN Sellers s ON p.seller_id = s.seller_id
GROUP BY s.seller_name, p.name
ORDER BY avg_rating DESC;

-- 5) SELF JOIN – Reviews written by same user for different products
SELECT a.review_id AS rev1, b.review_id AS rev2, a.user_id
FROM Reviews a
JOIN Reviews b ON a.user_id = b.user_id AND a.review_id < b.review_id;

-- 6) CROSS JOIN – Reviews × Coupons (demo combination)
SELECT r.review_id, r.rating, c.coupon_code
FROM (SELECT * FROM Reviews LIMIT 3) r
CROSS JOIN (SELECT * FROM Coupons LIMIT 3) c;

-- 7) JOIN with Orders – Verify review authenticity by order
SELECT r.review_id, p.name AS product_name, o.order_id, o.order_date
FROM Reviews r
JOIN Products p ON r.product_id = p.product_id
JOIN Orders o ON r.user_id = o.user_id AND o.product_id = p.product_id;

-- 8) JOIN with Categories – Average rating per category
SELECT c.category_name, ROUND(AVG(r.rating),2) AS avg_rating, COUNT(r.review_id) AS total_reviews
FROM Reviews r
JOIN Products p ON r.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY avg_rating DESC;

-- 9) JOIN with Ratings – Compare user ratings and review text
SELECT r.review_id, rt.rating_value AS numeric_rating, r.comment
FROM Reviews r
JOIN Ratings rt ON r.review_id = rt.review_id;

-- 10) Scalar Subquery – Reviews above average rating
SELECT review_id, product_id, rating, comment
FROM Reviews
WHERE rating > (SELECT AVG(rating) FROM Reviews);

-- 11) Correlated Subquery – Reviews better than product’s average
SELECT r.review_id, r.product_id, r.rating
FROM Reviews r
WHERE r.rating > (
    SELECT AVG(r2.rating) FROM Reviews r2 WHERE r2.product_id = r.product_id
);

-- 12) Subquery with IN – Products that have 5-star reviews
SELECT DISTINCT p.product_id, p.name
FROM Products p
WHERE p.product_id IN (
    SELECT product_id FROM Reviews WHERE rating = 5
);

-- 13) EXISTS – Users who wrote at least one review
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name
FROM Users u
WHERE EXISTS (SELECT 1 FROM Reviews r WHERE r.user_id = u.user_id);

-- 14) Subquery in FROM – Top 5 products by number of reviews
SELECT t.product_name, t.total_reviews
FROM (
    SELECT p.name AS product_name, COUNT(r.review_id) AS total_reviews
    FROM Reviews r
    JOIN Products p ON r.product_id = p.product_id
    GROUP BY p.name
    ORDER BY total_reviews DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Reviews with rating higher than ALL category averages
SELECT r.review_id, r.rating, p.name AS product_name
FROM Reviews r
JOIN Products p ON r.product_id = p.product_id
WHERE r.rating > ALL (
    SELECT AVG(r2.rating)
    FROM Reviews r2
    JOIN Products p2 ON r2.product_id = p2.product_id
    GROUP BY p2.category_id
);

-- 16) Built-in String – Display shortened comment
SELECT review_id,
       CONCAT(LEFT(comment,30), '...') AS short_comment,
       rating
FROM Reviews;

-- 17) Built-in Aggregate – Count of reviews per rating
SELECT rating, COUNT(review_id) AS total_reviews
FROM Reviews
GROUP BY rating
ORDER BY rating DESC;

-- 18) Built-in Date – Reviews posted in last 30 days
SELECT review_id, product_id, rating, review_date
FROM Reviews
WHERE DATEDIFF(CURDATE(), review_date) <= 30;

-- 19) UDF – AverageProductRating(product_id)
DROP FUNCTION IF EXISTS AverageProductRating;
DELIMITER $$
CREATE FUNCTION AverageProductRating(pid INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
RETURN (
    SELECT ROUND(AVG(rating),2)
    FROM Reviews
    WHERE product_id = pid
);
$$
DELIMITER ;
-- Example:
-- SELECT product_id, AverageProductRating(product_id) AS avg_rating FROM Products LIMIT 10;

-- 20) UDF – ReviewSummary(review_id)
DROP FUNCTION IF EXISTS ReviewSummary;
DELIMITER $$
CREATE FUNCTION ReviewSummary(rid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Review ID: ', review_id, 
                  ' | Rating: ', rating, 
                  ' | Comment: ', LEFT(comment,30), '...')
    FROM Reviews WHERE review_id = rid
);
$$
DELIMITER ;
-- Example:
-- SELECT ReviewSummary(review_id) AS summary FROM Reviews LIMIT 10;


-- ---------------------------------------- 14. ratings   ---------------------------------------------------- 

-- 1) INNER JOIN – Ratings with Users and Products
SELECT r.rating_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       p.name AS product_name, r.rating_value, r.rating_date
FROM Ratings r
JOIN Users u ON r.user_id = u.user_id
JOIN Products p ON r.product_id = p.product_id;

-- 2) LEFT JOIN – Products with ratings (include unrated)
SELECT p.product_id, p.name, r.rating_id
FROM Products p
LEFT JOIN Ratings r ON p.product_id = r.product_id
WHERE r.rating_id IS NULL;

-- 3) RIGHT JOIN – Ratings with Products (include missing products)
SELECT r.rating_id, r.rating_value, p.name AS product_name
FROM Ratings r
RIGHT JOIN Products p ON r.product_id = p.product_id;

-- 4) JOIN across 3 tables – Ratings, Products, and Categories
SELECT c.category_name, p.name AS product_name,
       ROUND(AVG(r.rating_value),2) AS avg_rating, COUNT(r.rating_id) AS total_ratings
FROM Ratings r
JOIN Products p ON r.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.name
ORDER BY avg_rating DESC;

-- 5) SELF JOIN – Ratings given by same user
SELECT a.rating_id AS rating1, b.rating_id AS rating2, a.user_id
FROM Ratings a
JOIN Ratings b 
  ON a.user_id = b.user_id AND a.rating_id < b.rating_id;

-- 6) CROSS JOIN – Ratings × Offers (demo combination)
SELECT r.rating_id, r.rating_value, o.offer_title
FROM (SELECT * FROM Ratings LIMIT 3) r
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Sellers – Seller performance by rating
SELECT s.seller_name, ROUND(AVG(r.rating_value),2) AS avg_rating
FROM Ratings r
JOIN Products p ON r.product_id = p.product_id
JOIN Sellers s ON p.seller_id = s.seller_id
GROUP BY s.seller_name
ORDER BY avg_rating DESC;

-- 8) JOIN with Reviews – Compare rating vs written review
SELECT r.rating_id, r.rating_value, rv.comment
FROM Ratings r
JOIN Reviews rv ON r.review_id = rv.review_id;

-- 9) JOIN with Orders – Ratings for verified orders
SELECT r.rating_id, r.rating_value, o.order_id, o.total_amount
FROM Ratings r
JOIN Orders o ON r.user_id = o.user_id AND r.product_id = o.product_id;

-- 10) Scalar Subquery – Ratings above global average
SELECT rating_id, product_id, rating_value
FROM Ratings
WHERE rating_value > (SELECT AVG(rating_value) FROM Ratings);

-- 11) Correlated Subquery – Ratings higher than product’s average
SELECT r.rating_id, r.product_id, r.rating_value
FROM Ratings r
WHERE r.rating_value > (
    SELECT AVG(r2.rating_value)
    FROM Ratings r2
    WHERE r2.product_id = r.product_id
);

-- 12) Subquery with IN – Products with at least one 5-star rating
SELECT product_id, name
FROM Products
WHERE product_id IN (
    SELECT product_id FROM Ratings WHERE rating_value = 5
);

-- 13) EXISTS – Users who have rated any product
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name
FROM Users u
WHERE EXISTS (
    SELECT 1 FROM Ratings r WHERE r.user_id = u.user_id
);

-- 14) Subquery in FROM – Top 5 products by average rating
SELECT t.product_name, t.avg_rating
FROM (
    SELECT p.name AS product_name, ROUND(AVG(r.rating_value),2) AS avg_rating
    FROM Ratings r
    JOIN Products p ON r.product_id = p.product_id
    GROUP BY p.name
    ORDER BY avg_rating DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Ratings higher than ALL category averages
SELECT r.rating_id, r.product_id, r.rating_value
FROM Ratings r
JOIN Products p ON r.product_id = p.product_id
WHERE r.rating_value > ALL (
    SELECT AVG(r2.rating_value)
    FROM Ratings r2
    JOIN Products p2 ON r2.product_id = p2.product_id
    GROUP BY p2.category_id
);

-- 16) Built-in String – Add label for rating level
SELECT rating_id,
       CASE
           WHEN rating_value = 5 THEN 'Excellent'
           WHEN rating_value = 4 THEN 'Good'
           WHEN rating_value = 3 THEN 'Average'
           WHEN rating_value = 2 THEN 'Poor'
           ELSE 'Very Poor'
       END AS rating_label
FROM Ratings;

-- 17) Built-in Aggregate – Count of ratings per star value
SELECT rating_value, COUNT(rating_id) AS total_ratings
FROM Ratings
GROUP BY rating_value
ORDER BY rating_value DESC;

-- 18) Built-in Date – Ratings added in last 15 days
SELECT rating_id, product_id, rating_value, rating_date
FROM Ratings
WHERE DATEDIFF(CURDATE(), rating_date) <= 15;

-- 19) UDF – ProductAverageRating(product_id)
DROP FUNCTION IF EXISTS ProductAverageRating;
DELIMITER $$
CREATE FUNCTION ProductAverageRating(pid INT)
RETURNS DECIMAL(3,2)
DETERMINISTIC
RETURN (
    SELECT ROUND(AVG(rating_value),2)
    FROM Ratings
    WHERE product_id = pid
);
$$
DELIMITER ;
-- Example:
-- SELECT product_id, ProductAverageRating(product_id) AS avg_rating FROM Ratings LIMIT 10;

-- 20) UDF – RatingSummary(rating_id)
DROP FUNCTION IF EXISTS RatingSummary;
DELIMITER $$
CREATE FUNCTION RatingSummary(rid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Rating #', rating_id,
                  ' | Product ID: ', product_id,
                  ' | Value: ', rating_value,
                  ' | Date: ', rating_date)
    FROM Ratings WHERE rating_id = rid
);
$$
DELIMITER ;
-- Example:
-- SELECT RatingSummary(rating_id) AS summary FROM Ratings LIMIT 10;

--  ------------------------------------ 15. wishlist  ---------------------------------- 
-- 1) INNER JOIN – Wishlist with Users
SELECT w.wishlist_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, 
       w.created_at
FROM Wishlist w
JOIN Users u ON w.user_id = u.user_id;

-- 2) LEFT JOIN – Wishlist with Wishlist_Items (include empty wishlists)
SELECT w.wishlist_id, wi.wishlist_item_id, wi.product_id
FROM Wishlist w
LEFT JOIN Wishlist_Items wi ON w.wishlist_id = wi.wishlist_id
WHERE wi.wishlist_item_id IS NULL;

-- 3) RIGHT JOIN – Wishlist_Items with Wishlist (include unlinked items)
SELECT wi.wishlist_item_id, wi.product_id, w.wishlist_id
FROM Wishlist_Items wi
RIGHT JOIN Wishlist w ON wi.wishlist_id = w.wishlist_id;

-- 4) JOIN across 3 tables – Wishlist, Wishlist_Items, and Products
SELECT w.wishlist_id, u.first_name AS user_name, 
       p.name AS product_name, p.price
FROM Wishlist w
JOIN Users u ON w.user_id = u.user_id
JOIN Wishlist_Items wi ON w.wishlist_id = wi.wishlist_id
JOIN Products p ON wi.product_id = p.product_id;

-- 5) SELF JOIN – Wishlists created on same date
SELECT a.wishlist_id AS wish1, b.wishlist_id AS wish2, a.created_at
FROM Wishlist a
JOIN Wishlist b 
  ON DATE(a.created_at) = DATE(b.created_at) AND a.wishlist_id < b.wishlist_id;

-- 6) CROSS JOIN – Wishlist × Offers (demo combinations)
SELECT w.wishlist_id, o.offer_title, o.discount_percent
FROM (SELECT * FROM Wishlist LIMIT 3) w
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Orders – Users who bought items from their wishlist
SELECT DISTINCT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name
FROM Wishlist w
JOIN Wishlist_Items wi ON w.wishlist_id = wi.wishlist_id
JOIN Orders o ON w.user_id = o.user_id
JOIN Order_Items oi ON o.order_id = oi.order_id
WHERE wi.product_id = oi.product_id;

-- 8) JOIN with Categories – Category-wise wishlist items
SELECT c.category_name, COUNT(wi.wishlist_item_id) AS total_items
FROM Wishlist_Items wi
JOIN Products p ON wi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name;

-- 9) JOIN with Products – Show product details of wishlists
SELECT w.wishlist_id, p.product_id, p.name, p.price
FROM Wishlist w
JOIN Wishlist_Items wi ON w.wishlist_id = wi.wishlist_id
JOIN Products p ON wi.product_id = p.product_id;

-- 10) Scalar Subquery – Wishlists having more than average items
SELECT wishlist_id, user_id
FROM Wishlist
WHERE (SELECT COUNT(*) FROM Wishlist_Items wi WHERE wi.wishlist_id = Wishlist.wishlist_id) >
      (SELECT AVG(item_count) FROM (SELECT COUNT(*) AS item_count FROM Wishlist_Items GROUP BY wishlist_id) t);

-- 11) Correlated Subquery – Wishlists created after user’s first order
SELECT w.wishlist_id, w.user_id, w.created_at
FROM Wishlist w
WHERE w.created_at > (
    SELECT MIN(o.order_date) FROM Orders o WHERE o.user_id = w.user_id
);

-- 12) Subquery with IN – Wishlists containing discounted products
SELECT DISTINCT w.wishlist_id, w.user_id
FROM Wishlist w
WHERE w.wishlist_id IN (
    SELECT wishlist_id FROM Wishlist_Items wi
    JOIN Products p ON wi.product_id = p.product_id
    WHERE p.discount_percent > 0
);

-- 13) EXISTS – Wishlists that include products rated 5
SELECT DISTINCT w.wishlist_id, w.user_id
FROM Wishlist w
WHERE EXISTS (
    SELECT 1 FROM Wishlist_Items wi
    JOIN Ratings r ON wi.product_id = r.product_id
    WHERE w.wishlist_id = wi.wishlist_id AND r.rating_value = 5
);

-- 14) Subquery in FROM – Top 5 users with most wishlist items
SELECT t.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, t.total_items
FROM (
    SELECT w.user_id, COUNT(wi.wishlist_item_id) AS total_items
    FROM Wishlist w
    JOIN Wishlist_Items wi ON w.wishlist_id = wi.wishlist_id
    GROUP BY w.user_id
    ORDER BY total_items DESC
    LIMIT 5
) t
JOIN Users u ON t.user_id = u.user_id;

-- 15) ANY / ALL – Wishlists with more items than ALL user averages
SELECT w.wishlist_id, w.user_id
FROM Wishlist w
WHERE (SELECT COUNT(*) FROM Wishlist_Items wi WHERE wi.wishlist_id = w.wishlist_id)
      > ALL (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM Wishlist_Items GROUP BY wishlist_id) x);

-- 16) Built-in String – Label wishlist with user and date
SELECT wishlist_id,
       CONCAT('Wishlist by ', u.first_name, ' (', DATE_FORMAT(w.created_at, '%M %Y'), ')') AS label
FROM Wishlist w
JOIN Users u ON w.user_id = u.user_id;

-- 17) Built-in Aggregate – Count of wishlists created per month
SELECT YEAR(created_at) AS year, MONTHNAME(created_at) AS month, COUNT(*) AS total_wishlists
FROM Wishlist
GROUP BY YEAR(created_at), MONTHNAME(created_at)
ORDER BY year DESC, month DESC;

-- 18) Built-in Date – Recent wishlists (last 15 days)
SELECT wishlist_id, user_id, created_at
FROM Wishlist
WHERE DATEDIFF(CURDATE(), created_at) <= 15;

-- 19) UDF – WishlistItemCount(wishlist_id)
DROP FUNCTION IF EXISTS WishlistItemCount;
DELIMITER $$
CREATE FUNCTION WishlistItemCount(wid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT COUNT(*) FROM Wishlist_Items WHERE wishlist_id = wid
);
$$
DELIMITER ;
-- Example:
-- SELECT wishlist_id, WishlistItemCount(wishlist_id) AS total_items FROM Wishlist;

-- 20) UDF – WishlistSummary(wishlist_id)
DROP FUNCTION IF EXISTS WishlistSummary;
DELIMITER $$
CREATE FUNCTION WishlistSummary(wid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Wishlist #', wishlist_id, 
                  ' | User ID: ', user_id,
                  ' | Total Items: ', WishlistItemCount(wishlist_id))
    FROM Wishlist WHERE wishlist_id = wid
);
$$
DELIMITER ;
-- Example:
-- SELECT WishlistSummary(wishlist_id) AS summary FROM Wishlist LIMIT 10;

-- ----------------------------------------------- 16. wishlist_items -------------------------------- 

-- 1) INNER JOIN – Wishlist items with wishlist
SELECT wi.wishlist_item_id, wi.wishlist_id, w.user_id, wi.product_id
FROM Wishlist_Items wi
JOIN Wishlist w ON wi.wishlist_id = w.wishlist_id;

-- 2) LEFT JOIN – Wishlist items with products (include removed products)
SELECT wi.wishlist_item_id, wi.wishlist_id, p.name AS product_name
FROM Wishlist_Items wi
LEFT JOIN Products p ON wi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- 3) RIGHT JOIN – Products with wishlist items (include un-wishlisted)
SELECT p.product_id, p.name, wi.wishlist_item_id
FROM Wishlist_Items wi
RIGHT JOIN Products p ON wi.product_id = p.product_id;

-- 4) JOIN across 3 tables – Wishlist items, wishlist, and users
SELECT wi.wishlist_item_id, CONCAT(u.first_name,' ',u.last_name) AS user_name,
       p.name AS product_name, p.price
FROM Wishlist_Items wi
JOIN Wishlist w ON wi.wishlist_id = w.wishlist_id
JOIN Users u ON w.user_id = u.user_id
JOIN Products p ON wi.product_id = p.product_id;

-- 5) SELF JOIN – Different items in the same wishlist
SELECT a.wishlist_item_id AS item1, b.wishlist_item_id AS item2, a.wishlist_id
FROM Wishlist_Items a
JOIN Wishlist_Items b 
  ON a.wishlist_id = b.wishlist_id AND a.wishlist_item_id < b.wishlist_item_id;

-- 6) CROSS JOIN – Wishlist items × offers (demo combinations)
SELECT wi.wishlist_item_id, p.name AS product_name, o.offer_title
FROM (SELECT * FROM Wishlist_Items LIMIT 3) wi
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o
JOIN Products p ON wi.product_id = p.product_id;

-- 7) JOIN with Categories – Show item category
SELECT wi.wishlist_item_id, c.category_name, p.name AS product_name
FROM Wishlist_Items wi
JOIN Products p ON wi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id;

-- 8) JOIN with Orders – Wishlist items that were purchased
SELECT DISTINCT wi.wishlist_item_id, w.user_id, p.name AS product_name
FROM Wishlist_Items wi
JOIN Wishlist w ON wi.wishlist_id = w.wishlist_id
JOIN Orders o ON w.user_id = o.user_id
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Products p ON wi.product_id = p.product_id
WHERE wi.product_id = oi.product_id;

-- 9) JOIN with Ratings – Show rated wishlist items
SELECT wi.wishlist_item_id, p.name AS product_name, r.rating_value
FROM Wishlist_Items wi
JOIN Products p ON wi.product_id = p.product_id
JOIN Ratings r ON p.product_id = r.product_id;

-- 10) Scalar Subquery – Wishlist items from top-rated products
SELECT wi.wishlist_item_id, wi.wishlist_id, wi.product_id
FROM Wishlist_Items wi
WHERE wi.product_id IN (
    SELECT product_id FROM Ratings 
    GROUP BY product_id 
    HAVING AVG(rating_value) > (SELECT AVG(rating_value) FROM Ratings)
);

-- 11) Correlated Subquery – Items costlier than wishlist average
SELECT wi.wishlist_item_id, wi.wishlist_id, p.name, p.price
FROM Wishlist_Items wi
JOIN Products p ON wi.product_id = p.product_id
WHERE p.price > (
    SELECT AVG(p2.price)
    FROM Wishlist_Items wi2
    JOIN Products p2 ON wi2.product_id = p2.product_id
    WHERE wi2.wishlist_id = wi.wishlist_id
);

-- 12) Subquery with IN – Items from discounted products
SELECT wishlist_item_id, product_id
FROM Wishlist_Items
WHERE product_id IN (SELECT product_id FROM Products WHERE discount_percent > 0);

-- 13) EXISTS – Items in wishlists that belong to active users
SELECT wi.wishlist_item_id, wi.wishlist_id
FROM Wishlist_Items wi
WHERE EXISTS (
    SELECT 1 FROM Wishlist w
    JOIN Users u ON w.user_id = u.user_id
    WHERE w.wishlist_id = wi.wishlist_id AND u.status='Active'
);

-- 14) Subquery in FROM – Top 5 most-wishlisted products
SELECT t.product_name, t.total_wishlisted
FROM (
    SELECT p.name AS product_name, COUNT(wi.wishlist_item_id) AS total_wishlisted
    FROM Wishlist_Items wi
    JOIN Products p ON wi.product_id = p.product_id
    GROUP BY p.name
    ORDER BY total_wishlisted DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Items whose product price > ALL category averages
SELECT wi.wishlist_item_id, p.name, p.price
FROM Wishlist_Items wi
JOIN Products p ON wi.product_id = p.product_id
WHERE p.price > ALL (
    SELECT AVG(p2.price)
    FROM Products p2
    GROUP BY p2.category_id
);

-- 16) Built-in String – Format wishlist item label
SELECT wishlist_item_id,
       CONCAT('Item #', wishlist_item_id, ' (Product ID: ', product_id, ')') AS item_label
FROM Wishlist_Items;

-- 17) Built-in Aggregate – Count of items per wishlist
SELECT wishlist_id, COUNT(wishlist_item_id) AS total_items
FROM Wishlist_Items
GROUP BY wishlist_id
ORDER BY total_items DESC;

-- 18) Built-in Numeric – Show price × 1.18 (GST demo)
SELECT wi.wishlist_item_id, p.name AS product_name, p.price,
       ROUND(p.price * 1.18,2) AS price_with_gst
FROM Wishlist_Items wi
JOIN Products p ON wi.product_id = p.product_id;

-- 19) UDF – WishlistItemValue(wishlist_item_id)
DROP FUNCTION IF EXISTS WishlistItemValue;
DELIMITER $$
CREATE FUNCTION WishlistItemValue(wiid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN (
    SELECT p.price FROM Wishlist_Items wi
    JOIN Products p ON wi.product_id = p.product_id
    WHERE wi.wishlist_item_id = wiid
);
$$
DELIMITER ;
-- Example:
-- SELECT wishlist_item_id, WishlistItemValue(wishlist_item_id) AS value FROM Wishlist_Items;

-- 20) UDF – WishlistItemSummary(wishlist_item_id)
DROP FUNCTION IF EXISTS WishlistItemSummary;
DELIMITER $$
CREATE FUNCTION WishlistItemSummary(wiid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Wishlist Item #', wishlist_item_id,
                  ' | Product: ', p.name,
                  ' | Price: ₹', p.price)
    FROM Wishlist_Items wi
    JOIN Products p ON wi.product_id = p.product_id
    WHERE wi.wishlist_item_id = wiid
);
$$
DELIMITER ;
-- Example:
-- SELECT WishlistItemSummary(wishlist_item_id) AS summary FROM Wishlist_Items LIMIT 10;

-- ------------------------------------------ 17. offers   ---------------------------------------------- 

-- 1) INNER JOIN – Offers with Products
SELECT o.offer_id, o.offer_title, p.product_id, p.name AS product_name, 
       o.discount_percent
FROM Offers o
JOIN Products p ON o.product_id = p.product_id;

-- 2) LEFT JOIN – Offers with Categories (include offers not linked to categories)
SELECT o.offer_id, o.offer_title, c.category_name
FROM Offers o
LEFT JOIN Categories c ON o.category_id = c.category_id
WHERE c.category_id IS NULL;

-- 3) RIGHT JOIN – Categories with Offers (include categories with no offers)
SELECT c.category_name, o.offer_title, o.discount_percent
FROM Offers o
RIGHT JOIN Categories c ON o.category_id = c.category_id;

-- 4) JOIN across 3 tables – Offers, Products, and Sellers
SELECT o.offer_title, s.seller_name, p.name AS product_name, o.discount_percent
FROM Offers o
JOIN Products p ON o.product_id = p.product_id
JOIN Sellers s ON p.seller_id = s.seller_id;

-- 5) SELF JOIN – Offers with same discount percent
SELECT a.offer_id AS offer1, b.offer_id AS offer2, a.discount_percent
FROM Offers a
JOIN Offers b 
  ON a.discount_percent = b.discount_percent AND a.offer_id < b.offer_id;

-- 6) CROSS JOIN – Offers × Cities (demo combination for regional campaigns)
SELECT o.offer_title, o.discount_percent, c.city_name
FROM (SELECT * FROM Offers LIMIT 3) o
CROSS JOIN (SELECT * FROM Cities LIMIT 3) c;

-- 7) JOIN with Orders – Orders that used an offer
SELECT o.offer_id, o.offer_title, od.order_id, od.total_amount
FROM Offers o
JOIN Orders od ON o.offer_id = od.offer_id;

-- 8) JOIN with Users via Orders – Total offer usage per user
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, 
       COUNT(DISTINCT od.order_id) AS offer_used
FROM Offers o
JOIN Orders od ON o.offer_id = od.offer_id
JOIN Users u ON od.user_id = u.user_id
GROUP BY u.user_id;

-- 9) JOIN with Payments – Total payment after offer applied
SELECT o.offer_title, p.payment_id, p.amount, p.status
FROM Offers o
JOIN Orders od ON o.offer_id = od.offer_id
JOIN Payments p ON od.order_id = p.order_id;

-- 10) Scalar Subquery – Offers with discount higher than average
SELECT offer_id, offer_title, discount_percent
FROM Offers
WHERE discount_percent > (SELECT AVG(discount_percent) FROM Offers);

-- 11) Correlated Subquery – Offers better than category average discount
SELECT o.offer_id, o.offer_title, o.discount_percent
FROM Offers o
WHERE o.discount_percent > (
    SELECT AVG(o2.discount_percent)
    FROM Offers o2
    WHERE o2.category_id = o.category_id
);

-- 12) Subquery with IN – Offers used in orders above ₹50,000
SELECT offer_id, offer_title
FROM Offers
WHERE offer_id IN (
    SELECT offer_id FROM Orders WHERE total_amount > 50000
);

-- 13) EXISTS – Offers linked to at least one active product
SELECT o.offer_id, o.offer_title
FROM Offers o
WHERE EXISTS (
    SELECT 1 FROM Products p 
    WHERE p.product_id = o.product_id AND p.status = 'Active'
);

-- 14) Subquery in FROM – Top 5 offers by discount percent
SELECT t.offer_title, t.discount_percent
FROM (
    SELECT offer_title, discount_percent
    FROM Offers
    ORDER BY discount_percent DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Offers higher than ALL category average discounts
SELECT offer_id, offer_title, discount_percent
FROM Offers
WHERE discount_percent > ALL (
    SELECT AVG(discount_percent)
    FROM Offers
    GROUP BY category_id
);

-- 16) Built-in String – Format offer titles and add percentage label
SELECT offer_id,
       CONCAT(UPPER(SUBSTRING(offer_title,1,1)), LOWER(SUBSTRING(offer_title,2))) AS formatted_title,
       CONCAT(discount_percent, '% OFF') AS discount_label
FROM Offers;

-- 17) Built-in Date – Offers active this month
SELECT offer_id, offer_title, start_date, end_date
FROM Offers
WHERE MONTH(start_date) = MONTH(CURDATE()) 
  OR MONTH(end_date) = MONTH(CURDATE());

-- 18) Built-in Aggregate – Total number of offers and average discount
SELECT COUNT(*) AS total_offers, ROUND(AVG(discount_percent),2) AS avg_discount
FROM Offers;

-- 19) UDF – OfferValidityDays(offer_id)
DROP FUNCTION IF EXISTS OfferValidityDays;
DELIMITER $$
CREATE FUNCTION OfferValidityDays(oid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT DATEDIFF(end_date, start_date)
    FROM Offers WHERE offer_id = oid
);
$$
DELIMITER ;
-- Example:
-- SELECT offer_id, OfferValidityDays(offer_id) AS validity_days FROM Offers LIMIT 10;

-- 20) UDF – OfferSummary(offer_id)
DROP FUNCTION IF EXISTS OfferSummary;
DELIMITER $$
CREATE FUNCTION OfferSummary(oid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Offer: ', offer_title,
                  ' | Discount: ', discount_percent, '%',
                  ' | Duration: ', OfferValidityDays(offer_id), ' days')
    FROM Offers WHERE offer_id = oid
);
$$
DELIMITER ;
-- Example:
-- SELECT OfferSummary(offer_id) AS summary FROM Offers LIMIT 10;


-- ----------------------------------------- 18. coupons   --------------------------------------- 
-- 1) INNER JOIN – Coupons with Orders
SELECT c.coupon_id, c.coupon_code, c.discount_value, o.order_id, o.total_amount
FROM Coupons c
JOIN Orders o ON c.coupon_id = o.coupon_id;

-- 2) LEFT JOIN – Coupons with Users (include unused coupons)
SELECT c.coupon_id, c.coupon_code, u.user_id, u.email
FROM Coupons c
LEFT JOIN Users u ON c.assigned_to = u.user_id
WHERE u.user_id IS NULL;

-- 3) RIGHT JOIN – Orders with Coupons (include orders without coupon)
SELECT o.order_id, o.total_amount, c.coupon_code
FROM Coupons c
RIGHT JOIN Orders o ON c.coupon_id = o.coupon_id;

-- 4) JOIN across 3 tables – Coupons, Orders, and Payments
SELECT c.coupon_code, c.discount_value, o.order_id, p.payment_id, p.amount
FROM Coupons c
JOIN Orders o ON c.coupon_id = o.coupon_id
JOIN Payments p ON o.order_id = p.order_id;

-- 5) SELF JOIN – Coupons with same discount value
SELECT a.coupon_code AS coupon1, b.coupon_code AS coupon2, a.discount_value
FROM Coupons a
JOIN Coupons b 
  ON a.discount_value = b.discount_value AND a.coupon_id < b.coupon_id;

-- 6) CROSS JOIN – Coupons × Offers (demo promotion combos)
SELECT c.coupon_code, c.discount_value, o.offer_title
FROM (SELECT * FROM Coupons LIMIT 3) c
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Users – Coupons used by customers
SELECT DISTINCT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS user_name, c.coupon_code
FROM Coupons c
JOIN Orders o ON c.coupon_id = o.coupon_id
JOIN Users u ON o.user_id = u.user_id;

-- 8) JOIN with Cities via Users – Coupon usage by city
SELECT ct.city_name, COUNT(DISTINCT o.order_id) AS used_count
FROM Coupons c
JOIN Orders o ON c.coupon_id = o.coupon_id
JOIN Users u ON o.user_id = u.user_id
JOIN Cities ct ON u.city_id = ct.city_id
GROUP BY ct.city_name;

-- 9) JOIN with Payments – Total discounted amount per coupon
SELECT c.coupon_code, SUM(p.amount) AS total_paid
FROM Coupons c
JOIN Orders o ON c.coupon_id = o.coupon_id
JOIN Payments p ON o.order_id = p.order_id
GROUP BY c.coupon_code;

-- 10) Scalar Subquery – Coupons above average discount value
SELECT coupon_id, coupon_code, discount_value
FROM Coupons
WHERE discount_value > (SELECT AVG(discount_value) FROM Coupons);

-- 11) Correlated Subquery – Coupons used more than average usage count
SELECT c.coupon_id, c.coupon_code
FROM Coupons c
WHERE (SELECT COUNT(*) FROM Orders o WHERE o.coupon_id = c.coupon_id) >
      (SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM Orders GROUP BY coupon_id) x);

-- 12) Subquery with IN – Coupons used for large orders
SELECT coupon_id, coupon_code
FROM Coupons
WHERE coupon_id IN (
    SELECT coupon_id FROM Orders WHERE total_amount > 20000
);

-- 13) EXISTS – Coupons still active today
SELECT coupon_id, coupon_code, end_date
FROM Coupons c
WHERE EXISTS (
    SELECT 1 FROM Coupons x 
    WHERE x.coupon_id = c.coupon_id 
      AND CURDATE() BETWEEN x.start_date AND x.end_date
);

-- 14) Subquery in FROM – Top 5 coupons by total usage
SELECT t.coupon_code, t.usage_count
FROM (
    SELECT c.coupon_code, COUNT(o.order_id) AS usage_count
    FROM Coupons c
    JOIN Orders o ON c.coupon_id = o.coupon_id
    GROUP BY c.coupon_code
    ORDER BY usage_count DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Coupons with discount higher than ALL averages
SELECT coupon_id, coupon_code, discount_value
FROM Coupons
WHERE discount_value > ALL (
    SELECT AVG(discount_value) FROM Coupons GROUP BY category_id
);

-- 16) Built-in String – Add formatted label for coupons
SELECT coupon_id,
       CONCAT(coupon_code, ' (', discount_value, '% OFF)') AS formatted_label
FROM Coupons;

-- 17) Built-in Date – Coupons expiring within 10 days
SELECT coupon_id, coupon_code, end_date
FROM Coupons
WHERE DATEDIFF(end_date, CURDATE()) <= 10;

-- 18) Built-in Aggregate – Total coupons and average discount
SELECT COUNT(*) AS total_coupons, ROUND(AVG(discount_value),2) AS avg_discount
FROM Coupons;

-- 19) UDF – CouponValidityDays(coupon_id)
DROP FUNCTION IF EXISTS CouponValidityDays;
DELIMITER $$
CREATE FUNCTION CouponValidityDays(cid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT DATEDIFF(end_date, start_date)
    FROM Coupons WHERE coupon_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT coupon_id, CouponValidityDays(coupon_id) AS validity_days FROM Coupons LIMIT 10;

-- 20) UDF – CouponSummary(coupon_id)
DROP FUNCTION IF EXISTS CouponSummary;
DELIMITER $$
CREATE FUNCTION CouponSummary(cid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Coupon: ', coupon_code,
                  ' | Discount: ', discount_value, '%',
                  ' | Validity: ', CouponValidityDays(coupon_id), ' days')
    FROM Coupons WHERE coupon_id = cid
);
$$
DELIMITER ;
-- Example:
-- SELECT CouponSummary(coupon_id) AS summary FROM Coupons LIMIT 10;

-- ---------------------------------------- 19. Transactions ---------------------------------------------- 

-- 1) INNER JOIN – Transactions with Payments
SELECT t.transaction_id, p.payment_id, p.amount, t.transaction_date, t.status
FROM Transactions t
JOIN Payments p ON t.payment_id = p.payment_id;

-- 2) LEFT JOIN – Transactions with Orders (include failed/unlinked)
SELECT t.transaction_id, t.transaction_type, o.order_id
FROM Transactions t
LEFT JOIN Orders o ON t.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 3) RIGHT JOIN – Orders with Transactions (include unpaid)
SELECT o.order_id, o.total_amount, t.transaction_id
FROM Transactions t
RIGHT JOIN Orders o ON t.order_id = o.order_id;

-- 4) JOIN across 3 tables – Transactions, Orders, and Users
SELECT t.transaction_id, o.order_id, CONCAT(u.first_name,' ',u.last_name) AS user_name,
       t.transaction_type, t.amount
FROM Transactions t
JOIN Orders o ON t.order_id = o.order_id
JOIN Users u ON o.user_id = u.user_id;

-- 5) SELF JOIN – Transactions on same day
SELECT a.transaction_id AS txn1, b.transaction_id AS txn2, DATE(a.transaction_date) AS txn_date
FROM Transactions a
JOIN Transactions b 
  ON DATE(a.transaction_date) = DATE(b.transaction_date)
 AND a.transaction_id < b.transaction_id;

-- 6) CROSS JOIN – Transactions × Offers (demo marketing linkage)
SELECT t.transaction_id, t.transaction_type, o.offer_title
FROM (SELECT * FROM Transactions LIMIT 3) t
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Coupons – Transactions that used coupons
SELECT t.transaction_id, c.coupon_code, c.discount_value, t.amount
FROM Transactions t
JOIN Orders o ON t.order_id = o.order_id
JOIN Coupons c ON o.coupon_id = c.coupon_id;

-- 8) JOIN with Shipments – Transaction linked shipment details
SELECT t.transaction_id, s.shipment_id, s.status AS shipment_status
FROM Transactions t
JOIN Orders o ON t.order_id = o.order_id
JOIN Shipments s ON o.order_id = s.order_id;

-- 9) JOIN with Refunds – Transactions refunded
SELECT t.transaction_id, r.refund_id, r.refund_amount, r.refund_date
FROM Transactions t
JOIN Refunds r ON t.transaction_id = r.transaction_id;

-- 10) Scalar Subquery – Transactions above average amount
SELECT transaction_id, amount
FROM Transactions
WHERE amount > (SELECT AVG(amount) FROM Transactions);

-- 11) Correlated Subquery – Transactions above customer’s average
SELECT t.transaction_id, t.amount
FROM Transactions t
WHERE t.amount > (
    SELECT AVG(t2.amount)
    FROM Transactions t2
    JOIN Orders o2 ON t2.order_id = o2.order_id
    WHERE o2.user_id = (SELECT o.user_id FROM Orders o WHERE o.order_id = t.order_id)
);

-- 12) Subquery with IN – Transactions linked to high-value orders
SELECT transaction_id, amount
FROM Transactions
WHERE order_id IN (SELECT order_id FROM Orders WHERE total_amount > 40000);

-- 13) EXISTS – Transactions for shipped orders
SELECT transaction_id, order_id
FROM Transactions t
WHERE EXISTS (
    SELECT 1 FROM Shipments s 
    WHERE s.order_id = t.order_id AND s.status='Delivered'
);

-- 14) Subquery in FROM – Top 5 highest transaction amounts
SELECT t.transaction_id, t.amount
FROM (
    SELECT transaction_id, amount
    FROM Transactions
    ORDER BY amount DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Transactions higher than ALL payment averages
SELECT transaction_id, amount
FROM Transactions
WHERE amount > ALL (
    SELECT AVG(amount)
    FROM Payments
    GROUP BY payment_method
);

-- 16) Built-in String – Label transaction type in uppercase
SELECT transaction_id, UPPER(transaction_type) AS txn_type, CONCAT('₹', amount) AS formatted_amount
FROM Transactions;

-- 17) Built-in Date – Transactions in last 7 days
SELECT transaction_id, order_id, transaction_date, amount
FROM Transactions
WHERE DATEDIFF(CURDATE(), transaction_date) <= 7;

-- 18) Built-in Aggregate – Count and total transaction amount by type
SELECT transaction_type, COUNT(*) AS total_txn, SUM(amount) AS total_amount
FROM Transactions
GROUP BY transaction_type;

-- 19) UDF – TransactionFee(transaction_id)
DROP FUNCTION IF EXISTS TransactionFee;
DELIMITER $$
CREATE FUNCTION TransactionFee(tid INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN (
    SELECT ROUND(amount * 0.02,2)
    FROM Transactions WHERE transaction_id = tid
);
$$
DELIMITER ;
-- Example:
-- SELECT transaction_id, TransactionFee(transaction_id) AS txn_fee FROM Transactions LIMIT 10;

-- 20) UDF – TransactionSummary(transaction_id)
DROP FUNCTION IF EXISTS TransactionSummary;
DELIMITER $$
CREATE FUNCTION TransactionSummary(tid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Transaction #', transaction_id,
                  ' | Type: ', transaction_type,
                  ' | Amount: ₹', amount,
                  ' | Fee: ₹', TransactionFee(transaction_id))
    FROM Transactions WHERE transaction_id = tid
);
$$
DELIMITER ;
-- Example:
-- SELECT TransactionSummary(transaction_id) AS summary FROM Transactions LIMIT 10; 

-- -------------------------------- 20. Returns --------------------------------------------- 

-- 1) INNER JOIN – Returns with Orders
SELECT r.return_id, o.order_id, r.reason, r.return_date, r.status
FROM Returns r
JOIN Orders o ON r.order_id = o.order_id;

-- 2) LEFT JOIN – Returns with Refunds (include pending returns)
SELECT r.return_id, r.order_id, f.refund_id, f.refund_amount
FROM Returns r
LEFT JOIN Refunds f ON r.return_id = f.return_id
WHERE f.refund_id IS NULL;

-- 3) RIGHT JOIN – Refunds with Returns (include refunds without returns)
SELECT f.refund_id, f.refund_amount, r.return_id
FROM Returns r
RIGHT JOIN Refunds f ON r.return_id = f.return_id;

-- 4) JOIN across 3 tables – Returns, Orders, and Users
SELECT r.return_id, o.order_id, CONCAT(u.first_name,' ',u.last_name) AS user_name,
       r.reason, r.status
FROM Returns r
JOIN Orders o ON r.order_id = o.order_id
JOIN Users u ON o.user_id = u.user_id;

-- 5) SELF JOIN – Returns with same reason
SELECT a.return_id AS return1, b.return_id AS return2, a.reason
FROM Returns a
JOIN Returns b 
  ON a.reason = b.reason AND a.return_id < b.return_id;

-- 6) CROSS JOIN – Returns × Departments (demo analysis)
SELECT r.return_id, d.department_name
FROM (SELECT * FROM Returns LIMIT 3) r
CROSS JOIN (SELECT * FROM Departments LIMIT 3) d;

-- 7) JOIN with Shipments – Returned shipment details
SELECT r.return_id, s.shipment_id, s.status AS shipment_status
FROM Returns r
JOIN Shipments s ON r.order_id = s.order_id;

-- 8) JOIN with Payments – Refund payment details for returns
SELECT r.return_id, p.payment_id, p.amount, p.status
FROM Returns r
JOIN Refunds f ON r.return_id = f.return_id
JOIN Payments p ON f.payment_id = p.payment_id;

-- 9) JOIN with Products via Orders – Returned product info
SELECT r.return_id, p.product_id, p.name AS product_name
FROM Returns r
JOIN Orders o ON r.order_id = o.order_id
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Products p ON oi.product_id = p.product_id;

-- 10) Scalar Subquery – Returns older than average processing time
SELECT return_id, DATEDIFF(CURDATE(), return_date) AS days_since_return
FROM Returns
WHERE DATEDIFF(CURDATE(), return_date) >
      (SELECT AVG(DATEDIFF(CURDATE(), return_date)) FROM Returns);

-- 11) Correlated Subquery – Returns taking longer than average refund time
SELECT r.return_id, r.status
FROM Returns r
WHERE DATEDIFF(CURDATE(), r.return_date) >
      (SELECT AVG(DATEDIFF(f.refund_date, r2.return_date))
       FROM Refunds f
       JOIN Returns r2 ON f.return_id = r2.return_id
       WHERE r2.return_id = r.return_id);

-- 12) Subquery with IN – Returns with high-value orders
SELECT return_id, order_id
FROM Returns
WHERE order_id IN (
    SELECT order_id FROM Orders WHERE total_amount > 30000
);

-- 13) EXISTS – Returns where refund already processed
SELECT r.return_id, r.order_id
FROM Returns r
WHERE EXISTS (
    SELECT 1 FROM Refunds f WHERE f.return_id = r.return_id
);

-- 14) Subquery in FROM – Top 5 most frequent return reasons
SELECT t.reason, t.total_returns
FROM (
    SELECT reason, COUNT(return_id) AS total_returns
    FROM Returns
    GROUP BY reason
    ORDER BY total_returns DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Returns later than ALL average return dates
SELECT return_id, return_date
FROM Returns
WHERE return_date > ALL (
    SELECT AVG(return_date)
    FROM Returns
    GROUP BY status
);

-- 16) Built-in String – Format return reason text
SELECT return_id,
       CONCAT('Reason: ', UPPER(reason), ' | Status: ', status) AS formatted_reason
FROM Returns;

-- 17) Built-in Date – Returns requested in last 10 days
SELECT return_id, order_id, return_date, status
FROM Returns
WHERE DATEDIFF(CURDATE(), return_date) <= 10;

-- 18) Built-in Aggregate – Count of returns by status
SELECT status, COUNT(*) AS total_returns
FROM Returns
GROUP BY status
ORDER BY total_returns DESC;

-- 19) UDF – ReturnAge(return_id)
DROP FUNCTION IF EXISTS ReturnAge;
DELIMITER $$
CREATE FUNCTION ReturnAge(rid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT DATEDIFF(CURDATE(), return_date)
    FROM Returns WHERE return_id = rid
);
$$
DELIMITER ;
-- Example:
-- SELECT return_id, ReturnAge(return_id) AS days_old FROM Returns LIMIT 10;

-- 20) UDF – ReturnSummary(return_id)
DROP FUNCTION IF EXISTS ReturnSummary;
DELIMITER $$
CREATE FUNCTION ReturnSummary(rid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Return #', return_id,
                  ' | Order ID: ', order_id,
                  ' | Reason: ', reason,
                  ' | Status: ', status,
                  ' | Days Since Return: ', ReturnAge(return_id))
    FROM Returns WHERE return_id = rid
);
$$
DELIMITER ;


-- ---------------------------------  21. Refunds -------------------------------------------------------------- 
-- 1) INNER JOIN – Refunds with Orders and Users
SELECT r.refund_id, o.order_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       r.amount, r.status, r.request_date
FROM Refunds r
JOIN Orders o ON r.order_id = o.order_id
JOIN Users u ON o.user_id = u.user_id;

-- 2) LEFT JOIN – Refunds with Payments (include refunds without payment link)
SELECT r.refund_id, r.amount, p.payment_id, p.status AS payment_status
FROM Refunds r
LEFT JOIN Payments p ON r.payment_id = p.payment_id;

-- 3) RIGHT JOIN – Orders with Refunds (include non-refunded orders)
SELECT o.order_id, o.total_amount, r.refund_id, r.amount, r.status
FROM Refunds r
RIGHT JOIN Orders o ON r.order_id = o.order_id;

-- 4) JOIN across 3 tables – Refunds, Payments, and Orders
SELECT r.refund_id, r.amount, p.payment_id, o.order_date, r.status
FROM Refunds r
JOIN Payments p ON r.payment_id = p.payment_id
JOIN Orders o ON p.order_id = o.order_id;

-- 5) SELF JOIN – Refunds requested on the same date
SELECT a.refund_id AS refund1, b.refund_id AS refund2, a.request_date
FROM Refunds a
JOIN Refunds b ON DATE(a.request_date) = DATE(b.request_date)
AND a.refund_id < b.refund_id;

-- 6) CROSS JOIN – Top 3 refunds × 3 support agents (demo)
SELECT r.refund_id, r.amount, sa.agent_name
FROM (SELECT * FROM Refunds ORDER BY amount DESC LIMIT 3) r
CROSS JOIN (SELECT * FROM Support_Agents LIMIT 3) sa;

-- 7) JOIN with Support_Tickets – Refunds linked with customer complaints
SELECT r.refund_id, r.amount, st.ticket_id, st.subject, st.priority
FROM Refunds r
JOIN Support_Tickets st ON r.order_id = st.order_id;

-- 8) JOIN with Orders – Refund amount vs. order amount
SELECT r.refund_id, o.order_id, o.total_amount, r.amount AS refund_amount,
       ROUND((r.amount / o.total_amount) * 100,2) AS refund_percent
FROM Refunds r
JOIN Orders o ON r.order_id = o.order_id;

-- 9) JOIN with Users – Total refund count and sum per user
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS name,
       COUNT(r.refund_id) AS total_refunds, SUM(r.amount) AS total_amount
FROM Users u
JOIN Refunds r ON u.user_id = r.user_id
GROUP BY u.user_id
ORDER BY total_amount DESC;

-- 10) Scalar Subquery – Refunds above average refund amount
SELECT refund_id, amount, status
FROM Refunds
WHERE amount > (SELECT AVG(amount) FROM Refunds);

-- 11) Correlated Subquery – Refunds greater than user’s average refund
SELECT r.refund_id, r.user_id, r.amount
FROM Refunds r
WHERE r.amount > (
    SELECT AVG(r2.amount) FROM Refunds r2 WHERE r2.user_id = r.user_id
);

-- 12) Subquery with IN – Refunds linked to cancelled orders
SELECT refund_id, amount, status
FROM Refunds
WHERE order_id IN (
    SELECT order_id FROM Orders WHERE status='Cancelled'
);

-- 13) EXISTS – Refunds for orders that had successful payments
SELECT r.refund_id, r.amount
FROM Refunds r
WHERE EXISTS (
    SELECT 1 FROM Payments p 
    WHERE p.payment_id = r.payment_id AND p.status='Success'
);

-- 14) Subquery in FROM – Top 5 users by refund amount
SELECT t.user_id, u.email, t.total_refunded
FROM (
    SELECT user_id, SUM(amount) AS total_refunded
    FROM Refunds
    GROUP BY user_id
    ORDER BY total_refunded DESC
    LIMIT 5
) t
JOIN Users u ON u.user_id = t.user_id;

-- 15) ANY / ALL – Refunds larger than ALL successful payments
SELECT refund_id, amount
FROM Refunds
WHERE amount > ALL (SELECT amount FROM Payments WHERE status='Success');

-- 16) Built-in String & Date – Format status and show refund month
SELECT refund_id,
       CONCAT(UPPER(SUBSTRING(status,1,1)), LOWER(SUBSTRING(status,2))) AS formatted_status,
       MONTHNAME(request_date) AS refund_month,
       YEAR(request_date) AS refund_year
FROM Refunds;

-- 17) Built-in Aggregate – Monthly refund totals
SELECT YEAR(request_date) AS year, MONTH(request_date) AS month,
       COUNT(refund_id) AS total_refunds, SUM(amount) AS total_amount
FROM Refunds
GROUP BY YEAR(request_date), MONTH(request_date)
ORDER BY year DESC, month DESC;

-- 18) Built-in Numeric – Round refund amount and calculate 10% processing fee
SELECT refund_id, ROUND(amount,2) AS base_amount,
       ROUND(amount * 0.10,2) AS processing_fee,
       ROUND(amount - (amount * 0.10),2) AS final_refund
FROM Refunds;

-- 19) UDF – CalculateRefundFee(amount)
DROP FUNCTION IF EXISTS CalculateRefundFee;
DELIMITER $$
CREATE FUNCTION CalculateRefundFee(amount DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN ROUND(amount * 0.10,2);
$$
DELIMITER ;
-- Example:
-- SELECT refund_id, CalculateRefundFee(amount) AS fee FROM Refunds LIMIT 10;

-- 20) UDF – RefundSummary(refund_id)
DROP FUNCTION IF EXISTS RefundSummary;
DELIMITER $$
CREATE FUNCTION RefundSummary(rid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Refund #', refund_id, ' | Amount: ₹', amount,
                  ' | Status: ', status, ' | Date: ', DATE(request_date))
    FROM Refunds WHERE refund_id = rid
);
$$
DELIMITER ;
-- Example:
-- SELECT RefundSummary(refund_id) AS summary FROM Refunds LIMIT 10;

-- ----------------------------------------- 22. support_tickets -------------------------------- 

-- 1) INNER JOIN – Tickets with Users
SELECT t.ticket_id, CONCAT(u.first_name,' ',u.last_name) AS customer_name,
       t.issue_type, t.status, t.created_at
FROM Support_Tickets t
JOIN Users u ON t.user_id = u.user_id;

-- 2) LEFT JOIN – Tickets with Employees (include unassigned)
SELECT t.ticket_id, t.issue_type, e.employee_name
FROM Support_Tickets t
LEFT JOIN Employees e ON t.assigned_to = e.employee_id
WHERE e.employee_id IS NULL;

-- 3) RIGHT JOIN – Employees with Tickets (include idle agents)
SELECT e.employee_id, e.employee_name, t.ticket_id
FROM Support_Tickets t
RIGHT JOIN Employees e ON t.assigned_to = e.employee_id;

-- 4) JOIN across 3 tables – Tickets, Users, and Departments
SELECT t.ticket_id, CONCAT(u.first_name,' ',u.last_name) AS user_name,
       d.department_name, t.priority, t.status
FROM Support_Tickets t
JOIN Users u ON t.user_id = u.user_id
JOIN Departments d ON t.department_id = d.department_id;

-- 5) SELF JOIN – Tickets raised by same user
SELECT a.ticket_id AS ticket1, b.ticket_id AS ticket2, a.user_id
FROM Support_Tickets a
JOIN Support_Tickets b 
  ON a.user_id = b.user_id AND a.ticket_id < b.ticket_id;

-- 6) CROSS JOIN – Support_Tickets × Offers (demo for help campaigns)
SELECT t.ticket_id, t.issue_type, o.offer_title
FROM (SELECT * FROM Support_Tickets LIMIT 3) t
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Orders – Tickets linked to specific orders
SELECT t.ticket_id, o.order_id, o.total_amount, t.status
FROM Support_Tickets t
JOIN Orders o ON t.order_id = o.order_id;

-- 8) JOIN with Returns – Tickets created for product returns
SELECT t.ticket_id, r.return_id, r.status AS return_status
FROM Support_Tickets t
JOIN Returns r ON t.order_id = r.order_id;

-- 9) JOIN with Refunds – Tickets related to refunds
SELECT t.ticket_id, f.refund_id, f.refund_amount
FROM Support_Tickets t
JOIN Refunds f ON t.order_id = f.order_id;

-- 10) Scalar Subquery – Tickets older than average resolution time
SELECT ticket_id, DATEDIFF(CURDATE(), created_at) AS days_open
FROM Support_Tickets
WHERE DATEDIFF(CURDATE(), created_at) >
      (SELECT AVG(DATEDIFF(CURDATE(), created_at)) FROM Support_Tickets);

-- 11) Correlated Subquery – Tickets taking longer than user average
SELECT t.ticket_id, t.user_id, t.status
FROM Support_Tickets t
WHERE DATEDIFF(CURDATE(), t.created_at) >
      (SELECT AVG(DATEDIFF(CURDATE(), t2.created_at))
       FROM Support_Tickets t2
       WHERE t2.user_id = t.user_id);

-- 12) Subquery with IN – High-priority unresolved tickets
SELECT ticket_id, issue_type, priority
FROM Support_Tickets
WHERE ticket_id IN (
    SELECT ticket_id FROM Support_Tickets 
    WHERE priority='High' AND status <> 'Resolved'
);

-- 13) EXISTS – Tickets having assigned employee
SELECT ticket_id, issue_type
FROM Support_Tickets t
WHERE EXISTS (
    SELECT 1 FROM Employees e WHERE e.employee_id = t.assigned_to
);

-- 14) Subquery in FROM – Department with most open tickets
SELECT t.department_name, t.total_open
FROM (
    SELECT d.department_name, COUNT(*) AS total_open
    FROM Support_Tickets st
    JOIN Departments d ON st.department_id = d.department_id
    WHERE st.status='Open'
    GROUP BY d.department_name
    ORDER BY total_open DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Tickets created later than ALL department averages
SELECT ticket_id, created_at
FROM Support_Tickets
WHERE created_at > ALL (
    SELECT AVG(created_at) FROM Support_Tickets GROUP BY department_id
);

-- 16) Built-in String – Format ticket label
SELECT ticket_id,
       CONCAT('Ticket #', ticket_id, ' - ', UPPER(issue_type), ' (', status, ')') AS ticket_label
FROM Support_Tickets;

-- 17) Built-in Date – Tickets created in last 7 days
SELECT ticket_id, issue_type, created_at, status
FROM Support_Tickets
WHERE DATEDIFF(CURDATE(), created_at) <= 7;

-- 18) Built-in Aggregate – Count of tickets by status
SELECT status, COUNT(*) AS total_tickets
FROM Support_Tickets
GROUP BY status
ORDER BY total_tickets DESC;

-- 19) UDF – TicketAge(ticket_id)
DROP FUNCTION IF EXISTS TicketAge;
DELIMITER $$
CREATE FUNCTION TicketAge(tid INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT DATEDIFF(CURDATE(), created_at)
    FROM Support_Tickets WHERE ticket_id = tid
);
$$
DELIMITER ;
-- Example:
-- SELECT ticket_id, TicketAge(ticket_id) AS days_open FROM Support_Tickets LIMIT 10;

-- 20) UDF – TicketSummary(ticket_id)
DROP FUNCTION IF EXISTS TicketSummary;
DELIMITER $$
CREATE FUNCTION TicketSummary(tid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Ticket #', ticket_id,
                  ' | Issue: ', issue_type,
                  ' | Status: ', status,
                  ' | Priority: ', priority,
                  ' | Open Days: ', TicketAge(ticket_id))
    FROM Support_Tickets WHERE ticket_id = tid
);
$$
DELIMITER ;
-- Example:
-- SELECT TicketSummary(ticket_id) AS summary FROM Support_Tickets LIMIT 10;

-- --------------------------------------------- 23. Employees -------------------------------------- 

-- 1) INNER JOIN – Employees with Departments
SELECT e.employee_id, e.employee_name, d.department_name, e.designation
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id;

-- 2) LEFT JOIN – Employees with Support Tickets (include idle employees)
SELECT e.employee_id, e.employee_name, t.ticket_id
FROM Employees e
LEFT JOIN Support_Tickets t ON e.employee_id = t.assigned_to
WHERE t.ticket_id IS NULL;

-- 3) RIGHT JOIN – Departments with Employees (include empty departments)
SELECT d.department_id, d.department_name, e.employee_name
FROM Employees e
RIGHT JOIN Departments d ON e.department_id = d.department_id;

-- 4) JOIN across 3 tables – Employees, Departments, and Support Tickets
SELECT e.employee_name, d.department_name, COUNT(t.ticket_id) AS tickets_handled
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id
LEFT JOIN Support_Tickets t ON e.employee_id = t.assigned_to
GROUP BY e.employee_name, d.department_name;

-- 5) SELF JOIN – Employees in same department
SELECT a.employee_name AS emp1, b.employee_name AS emp2, a.department_id
FROM Employees a
JOIN Employees b 
  ON a.department_id = b.department_id AND a.employee_id < b.employee_id;

-- 6) CROSS JOIN – Employees × Offers (demo pairing for sales campaigns)
SELECT e.employee_name, o.offer_title
FROM (SELECT * FROM Employees LIMIT 3) e
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 7) JOIN with Orders – Employees responsible for orders
SELECT e.employee_name, o.order_id, o.total_amount
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id;

-- 8) JOIN with Support Tickets – Tickets handled by employees
SELECT e.employee_name, t.ticket_id, t.status
FROM Employees e
JOIN Support_Tickets t ON e.employee_id = t.assigned_to;

-- 9) JOIN with Departments – Average salary per department
SELECT d.department_name, ROUND(AVG(e.salary),2) AS avg_salary
FROM Employees e
JOIN Departments d ON e.department_id = d.department_id
GROUP BY d.department_name;

-- 10) Scalar Subquery – Employees earning above average
SELECT employee_id, employee_name, salary
FROM Employees
WHERE salary > (SELECT AVG(salary) FROM Employees);

-- 11) Correlated Subquery – Employees earning above department average
SELECT e.employee_id, e.employee_name, e.salary
FROM Employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
);

-- 12) Subquery with IN – Employees working in active departments
SELECT employee_id, employee_name
FROM Employees
WHERE department_id IN (
    SELECT department_id FROM Departments WHERE status = 'Active'
);

-- 13) EXISTS – Employees handling at least one support ticket
SELECT e.employee_id, e.employee_name
FROM Employees e
WHERE EXISTS (
    SELECT 1 FROM Support_Tickets t WHERE t.assigned_to = e.employee_id
);

-- 14) Subquery in FROM – Top 5 highest-paid employees
SELECT t.employee_name, t.salary
FROM (
    SELECT employee_name, salary
    FROM Employees
    ORDER BY salary DESC
    LIMIT 5
) t;

-- 15) ANY / ALL – Employees earning more than ALL department averages
SELECT employee_id, employee_name, salary
FROM Employees
WHERE salary > ALL (
    SELECT AVG(salary)
    FROM Employees
    GROUP BY department_id
);

-- 16) Built-in String – Employee full info formatted
SELECT employee_id,
       CONCAT(UPPER(employee_name), ' - ', designation, ' (₹', salary, ')') AS emp_info
FROM Employees;

-- 17) Built-in Date – Employees joined this year
SELECT employee_id, employee_name, join_date
FROM Employees
WHERE YEAR(join_date) = YEAR(CURDATE());

-- 18) Built-in Aggregate – Department-wise employee count
SELECT department_id, COUNT(employee_id) AS total_employees
FROM Employees
GROUP BY department_id;

-- 19) UDF – AnnualSalary(employee_id)
DROP FUNCTION IF EXISTS AnnualSalary;
DELIMITER $$
CREATE FUNCTION AnnualSalary(eid INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
RETURN (
    SELECT salary * 12 FROM Employees WHERE employee_id = eid
);
$$
DELIMITER ;
-- Example:
-- SELECT employee_id, AnnualSalary(employee_id) AS yearly_salary FROM Employees LIMIT 10;

-- 20) UDF – EmployeeSummary(employee_id)
DROP FUNCTION IF EXISTS EmployeeSummary;
DELIMITER $$
CREATE FUNCTION EmployeeSummary(eid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Employee: ', employee_name,
                  ' | Dept ID: ', department_id,
                  ' | Salary: ₹', salary,
                  ' | Annual: ₹', AnnualSalary(employee_id))
    FROM Employees WHERE employee_id = eid
);
$$
DELIMITER ;
-- Example:
-- SELECT EmployeeSummary(employee_id) AS summary FROM Employees LIMIT 10;

 -- -------------------------------------- 24. Departments ---------------------------------------- 
 
 -- 1) SELECT all departments
SELECT * FROM departments;

-- 2) SELECT departments in a specific location
SELECT * FROM departments WHERE location = 'Delhi';

-- 3) SELECT department names only
SELECT department_name FROM departments;

-- 4) INNER JOIN – Departments with Employees
SELECT d.department_name, e.employee_name, e.designation
FROM departments d
JOIN Employees e ON d.department_id = e.department_id;

-- 5) LEFT JOIN – Departments with Employees (include empty departments)
SELECT d.department_name, e.employee_name
FROM departments d
LEFT JOIN Employees e ON d.department_id = e.department_id;

-- 6) RIGHT JOIN – Employees with Departments (include unassigned employees)
SELECT d.department_name, e.employee_name
FROM departments d
RIGHT JOIN Employees e ON d.department_id = e.department_id;

-- 7) JOIN across 3 tables – Departments, Employees, Support Tickets
SELECT d.department_name, e.employee_name, COUNT(t.ticket_id) AS tickets_handled
FROM departments d
JOIN Employees e ON d.department_id = e.department_id
LEFT JOIN Support_Tickets t ON e.employee_id = t.assigned_to
GROUP BY d.department_name, e.employee_name;

-- 8) SELF JOIN – Departments in the same location
SELECT a.department_name AS dept1, b.department_name AS dept2, a.location
FROM departments a
JOIN departments b ON a.location = b.location AND a.department_id < b.department_id;

-- 9) CROSS JOIN – Departments × Offers (for demo campaigns)
SELECT d.department_name, o.offer_title
FROM (SELECT * FROM departments LIMIT 3) d
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 10) Scalar Subquery – Departments with employee count above average
SELECT department_name
FROM departments
WHERE department_id IN (
    SELECT department_id
    FROM Employees
    GROUP BY department_id
    HAVING COUNT(employee_id) > (SELECT AVG(emp_count) FROM (SELECT COUNT(employee_id) AS emp_count FROM Employees GROUP BY department_id) t)
);

-- 11) Correlated Subquery – Departments with highest-paid employee
SELECT d.department_name, e.employee_name, e.salary
FROM departments d
JOIN Employees e ON d.department_id = e.department_id
WHERE e.salary = (
    SELECT MAX(salary)
    FROM Employees e2
    WHERE e2.department_id = d.department_id
);

-- 12) Subquery with IN – Departments with employees handling tickets
SELECT department_name
FROM departments
WHERE department_id IN (
    SELECT DISTINCT department_id
    FROM Employees e
    JOIN Support_Tickets t ON e.employee_id = t.assigned_to
);

-- 13) EXISTS – Departments with employees
SELECT department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM Employees e WHERE e.department_id = d.department_id
);

-- 14) Subquery in FROM – Top 3 departments by employee count
SELECT t.department_name, t.emp_count
FROM (
    SELECT d.department_name, COUNT(e.employee_id) AS emp_count
    FROM departments d
    LEFT JOIN Employees e ON d.department_id = e.department_id
    GROUP BY d.department_name
    ORDER BY emp_count DESC
    LIMIT 3
) t;

-- 15) ANY / ALL – Departments with employee salary higher than ALL departments
SELECT department_name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.department_id = d.department_id AND e.salary > ALL (
        SELECT AVG(salary) FROM Employees GROUP BY department_id
    )
);

-- 16) Built-in String – Department full info
SELECT department_id,
       CONCAT(UPPER(department_name), ' | Manager: ', manager_name, ' | Location: ', location) AS dept_info
FROM departments;

-- 17) Built-in Date – Departments created this year
SELECT department_id, department_name, created_at
FROM departments
WHERE YEAR(created_at) = YEAR(CURDATE());

-- 18) Built-in Aggregate – Departments per location
SELECT location, COUNT(department_id) AS total_departments
FROM departments
GROUP BY location;

-- 19) UDF – TotalEmployees(department_id)
DROP FUNCTION IF EXISTS TotalEmployees;
DELIMITER $$
CREATE FUNCTION TotalEmployees(did INT)
RETURNS INT
DETERMINISTIC
RETURN (
    SELECT COUNT(*) FROM Employees WHERE department_id = did
);
$$
DELIMITER ;
-- Example:
-- SELECT department_name, TotalEmployees(department_id) AS employee_count FROM departments;

-- 20) UDF – DepartmentSummary(department_id)
DROP FUNCTION IF EXISTS DepartmentSummary;
DELIMITER $$
CREATE FUNCTION DepartmentSummary(did INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Department: ', department_name,
                  ' | Manager: ', manager_name,
                  ' | Location: ', location,
                  ' | Employees: ', TotalEmployees(department_id))
    FROM departments WHERE department_id = did
);
$$
DELIMITER ;
-- Example:
-- SELECT DepartmentSummary(department_id) AS summary FROM departments;

-- ---------------------------------------- 25. Notifications --------------------------------- 

-- 1) SELECT all notifications
SELECT * FROM notifications;

-- 2) SELECT notifications by type 'Order'
SELECT * FROM notifications WHERE type = 'Order';

-- 3) SELECT unread notifications
SELECT * FROM notifications WHERE status = 'Unread';

-- 4) SELECT notifications for a specific user
SELECT * FROM notifications WHERE user_id = 3;

-- 5) INNER JOIN – Notifications with Users
SELECT n.notification_id, n.message, n.type, u.user_name
FROM notifications n
JOIN users u ON n.user_id = u.user_id;

-- 6) LEFT JOIN – Users with notifications (including users with no notifications)
SELECT u.user_name, n.notification_id, n.message
FROM users u
LEFT JOIN notifications n ON u.user_id = n.user_id;

-- 7) RIGHT JOIN – Notifications with users (include orphan notifications if any)
SELECT n.notification_id, n.message, u.user_name
FROM notifications n
RIGHT JOIN users u ON n.user_id = u.user_id;

-- 8) JOIN across 3 tables – Users, Notifications, Orders
SELECT u.user_name, n.message, o.order_id
FROM users u
JOIN notifications n ON u.user_id = n.user_id
LEFT JOIN Orders o ON u.user_id = o.user_id;

-- 9) SELF JOIN – Notifications of same type
SELECT a.notification_id AS notif1, b.notification_id AS notif2, a.type
FROM notifications a
JOIN notifications b ON a.type = b.type AND a.notification_id < b.notification_id;

-- 10) CROSS JOIN – Notifications × Offers (demo pairing)
SELECT n.message, o.offer_title
FROM (SELECT * FROM notifications LIMIT 3) n
CROSS JOIN (SELECT * FROM Offers LIMIT 3) o;

-- 11) Aggregate – Count of notifications per type
SELECT type, COUNT(notification_id) AS total_notifications
FROM notifications
GROUP BY type;

-- 12) Aggregate – Count of unread notifications per user
SELECT user_id, COUNT(notification_id) AS unread_count
FROM notifications
WHERE status = 'Unread'
GROUP BY user_id;

-- 13) Scalar Subquery – Notifications created today
SELECT *
FROM notifications
WHERE DATE(created_at) = (SELECT CURDATE());

-- 14) Correlated Subquery – Latest notification per user
SELECT n1.user_id, n1.message, n1.created_at
FROM notifications n1
WHERE n1.created_at = (
    SELECT MAX(n2.created_at)
    FROM notifications n2
    WHERE n2.user_id = n1.user_id
);

-- 15) Subquery with IN – Users with high-priority notifications
SELECT *
FROM notifications
WHERE user_id IN (
    SELECT DISTINCT user_id
    FROM notifications
    WHERE priority = 'High'
);

-- 16) EXISTS – Users with unread notifications
SELECT *
FROM notifications n
WHERE EXISTS (
    SELECT 1
    FROM notifications n2
    WHERE n2.user_id = n.user_id AND n2.status = 'Unread'
);

-- 17) Built-in String – Notification summary
SELECT notification_id, CONCAT(type, ' | ', message, ' | ', status) AS summary
FROM notifications;

-- 18) Built-in Date – Notifications in last 7 days
SELECT *
FROM notifications
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY);

-- 19) UDF – MarkNotificationRead(notification_id)
DROP FUNCTION IF EXISTS MarkNotificationRead;
DELIMITER $$
CREATE FUNCTION MarkNotificationRead(nid INT)
RETURNS VARCHAR(50)
DETERMINISTIC
RETURN (
    UPDATE notifications SET status = 'Read', read_at = NOW() WHERE notification_id = nid
);
$$
DELIMITER ;

-- 20) UDF – NotificationSummary(notification_id)
DROP FUNCTION IF EXISTS NotificationSummary;
DELIMITER $$
CREATE FUNCTION NotificationSummary(nid INT)
RETURNS VARCHAR(255)
DETERMINISTIC
RETURN (
    SELECT CONCAT('Notification ID: ', notification_id,
                  ' | User ID: ', user_id,
                  ' | Type: ', type,
                  ' | Status: ', status,
                  ' | Priority: ', priority)
    FROM notifications WHERE notification_id = nid
);
$$
DELIMITER ;
-- Example:
-- SELECT NotificationSummary(notification_id) AS summary FROM notifications LIMIT 10;


