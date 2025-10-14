# 🛒 Amazon eCommerce Database System (AE-DBS)

This repository tracks the development of a **comprehensive Amazon eCommerce Database System (AE-DBS)** designed to efficiently manage **products, customers, sellers, orders, payments, shipments, and post-sale support**.

---

## 🚀 Phase 2: Core Operational & Analytical Queries

Phase 2 builds upon the Phase 1 Database Architecture by implementing **SQL queries essential for operational reporting, analytics, and business insights**. These queries extract meaningful patterns from a **25-table relational schema** covering every functional area of an Amazon-like platform.

---

## 🎯 Objectives

### Operational Queries (CRUD)
- Create essential `SELECT`, `INSERT`, `UPDATE`, and `DELETE` statements to manage daily operations across modules such as **orders, products, and users**.

### Analytical Queries
- Implement complex SQL queries using **JOINs, GROUP BY, subqueries, and aggregate functions** to generate insights into **sales, inventory, customer engagement, and delivery performance**.

### Data Reliability
- Use **constraints, cascades, and validation logic** to maintain referential integrity between dependent tables.

### Data Dictionary & Documentation
- Document each query’s **purpose, involved tables, and expected outcome** for **easy integration into APIs and dashboards**.

---

## 📁 Phase 2 SQL File

**Main SQL file:**  
`ProjectPhase2_DIVYA_Amazon_Ecommerce.sql`

This file is structured into sections corresponding to major **business areas and tables**.

| Table / Area           | Query Focus                 | Example Capabilities |
|------------------------|----------------------------|--------------------|
| Users                  | Customer Profiles & Activity | Retrieve top buyers, update account status, list premium members |
| Orders & Payments      | Sales Operations            | Track daily orders, calculate total sales per region, identify top payment modes |
| Products & Categories  | Inventory & Pricing         | List low-stock items, find most-reviewed products, calculate category-wise revenue |
| Cart & Offers          | Shopping Behavior           | Analyze abandoned carts, list users who used active coupons, evaluate offer performance |
| Sellers & Transactions | Vendor Management           | Find sellers with highest order value, track commissions, analyze refund patterns |
| Shipments & Delivery_Address | Logistics             | Identify delayed shipments, calculate average delivery time, list undelivered orders |
| Ratings & Reviews      | Customer Feedback           | Calculate average product rating, detect fake reviews, find most-reviewed items |
| Support_Tickets        | Customer Support            | List unresolved tickets, categorize complaints, find response-time averages |

---

## 🧠 Highlights of Implemented Queries

- **Joins & Relationships:**  
  `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, `CROSS JOIN` between **customer, order, and payment modules**.

- **Subqueries:**  
  Nested queries for filtering **top-performing products, sellers, and buyers**.

- **Aggregate Functions:**  
  `SUM()`, `COUNT()`, `AVG()`, `MAX()`, `MIN()` for **sales, ratings, and inventory metrics**.

- **User-Defined Functions (UDFs):**  
  Compute **discount percentages and final order totals automatically**.

- **Triggers & Constraints:**  
  Automate updates like **inventory count adjustment after order placement**.

---

## 🛠️ Execution & Usage

### Ensure Database is Ready
- The **Phase 1 database schema** must be created and populated with sample data.

### Execute Queries
- Run `ProjectPhase2_DIVYA_Amazon_Ecommerce.sql` using **MySQL Workbench, DBeaver, VS Code SQL Tools**, or any compatible SQL client.

### Test & Verify
- Each section is modular; queries can be executed individually to verify **correctness and performance**.
