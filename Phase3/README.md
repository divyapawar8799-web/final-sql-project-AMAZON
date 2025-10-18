# 🛒 Amazon E-Commerce Database System (AE-DBS) – Phase 3

## 📄 Overview
Phase 3 of the **Amazon E-Commerce Database System (AE-DBS)** focuses on **advanced SQL queries and database operations**.  
This phase builds upon the foundational tables and relationships created in Phase 1 and Phase 2, adding **operational insights, notifications management, department analytics, and user activity queries**.  

It demonstrates the use of **joins, subqueries, aggregates, built-in functions, and user-defined functions (UDFs)** to simulate real-world e-commerce database operations.

---

## 🗂️ Tables Covered
- **Departments** – Departmental details, managers, locations, and employee associations  
- **Employees** – Employee data, designations, salaries, and support ticket handling  
- **Notifications** – User notifications for orders, payments, shipments, offers, and general updates  
- **Users** – Basic user details for join operations  
- **Orders, Payments, Shipments, Offers** – Associated operational data for complex queries  

---

## 🚀 Key Features & Queries
Phase 3 includes **20+ queries per table** covering:

1. **Joins**
   - INNER, LEFT, RIGHT, SELF, CROSS joins  
   - Multi-table joins for analytics and operational reporting  

2. **Subqueries**
   - Scalar, correlated, IN, EXISTS  
   - Nested queries for department and user-specific analytics  

3. **Aggregates & Functions**
   - COUNT, AVG, MAX, MIN, GROUP BY  
   - Built-in string and date functions for formatting and filtering  

4. **User-Defined Functions (UDFs)**
   - `AnnualSalary(employee_id)` – calculates yearly salary  
   - `EmployeeSummary(employee_id)` – detailed employee information  
   - `TotalEmployees(department_id)` – employee count per department  
   - `DepartmentSummary(department_id)` – formatted department summary  
   - `NotificationSummary(notification_id)` – formatted notification details  

---

## 📌 Sample Queries
- Departments with average employee salary  
- Employees handling support tickets  
- High-priority unread notifications  
- Latest notification per user  
- Top 5 highest-paid employees  

> All queries are fully compatible with MySQL and ready for execution on the AE-DBS database.

---
