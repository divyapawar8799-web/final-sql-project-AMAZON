# 🛒 Amazon E-Commerce Database Management System (AEDMS)

This repository contains the foundational structure and sample data for a comprehensive **Amazon E-Commerce Database Management System (AEDMS)**.  
It is designed to manage every aspect of an online retail platform — including products, orders, customers, payments, logistics, and post-sale support.

---

## 🎯 Phase 1: Database Architecture and Schema Implementation

**Phase 1** focuses on building a robust **relational database schema** for Amazon-like operations.  
This serves as the backend foundation for all future phases — query development, analytics, API integration, and dashboard reporting.

### 🧩 Objectives of Phase 1
- **Schema Definition:** Create 25 well-structured, normalized tables.  
- **Data Integrity:** Define all primary and foreign key relationships for consistent data.  
- **Initial Data Loading:** Populate each table with sample entries for testing and demonstration.  

---

## ⚙️ Core Data Schema Overview (25 Tables)

The AEDMS database includes the following 25 tables organized across functional modules:

| **Domain** | **Tables** | **Description** |
|-------------|-------------|-----------------|
| **User & Account Management** | `users`, `notifications`, `cities`, `delivery_address` | Stores user profiles, location data, and notifications. |
| **Product & Category Management** | `products`, `categories`, `inventory`, `sellers` | Maintains the product catalog, categories, stock, and seller details. |
| **Order & Cart Management** | `orders`, `cart`, `cart_items`, `shipments`, `returns` | Handles order placement, shopping carts, delivery, and return processing. |
| **Payments & Financial Transactions** | `payments`, `transactions`, `refunds`, `coupons`, `offers` | Tracks payments, discounts, transactions, and refund operations. |
| **Customer Service & Feedback** | `support_ticket`, `reviews`, `ratings` | Manages customer support issues, feedback, and ratings. |
| **Administration & HR** | `employees`, `departments` | Stores employee details, roles, and departmental structure. |

---

## ✨ Key Features Enabled by the Schema

### 🛍️ 1. Product & Inventory Management
- Manage product details including category, price, stock level, and seller.  
- Track inventory availability for every product in real time.  

### 🧾 2. Order & Cart Workflow
- Users can add products to the **cart** and proceed to checkout.  
- Orders link to **shipments** and **delivery_address** tables for tracking.  
- **Returns** and **refunds** ensure a complete post-sale workflow.  

### 💳 3. Payment & Transaction Control
- Tracks every payment via multiple methods (Card, UPI, COD, etc.).  
- Manages **offers**, **coupons**, and **refunds** for accurate reconciliation.  
- **Transactions** table ensures every financial movement is auditable.  

### 💬 4. Customer Relationship & Support
- Customers can raise **support_tickets** for order or product issues.  
- Collects **reviews** and **ratings** for seller and product performance.  
- Sends alerts through the **notifications** table.  

### 🧑‍💼 5. Employee & Department Management
- Tracks **employees**, their assigned **departments**, and admin operations.  
- Enables structured access for system management and internal tracking.  

---

## 🚀 Getting Started

Follow these steps to set up the **Amazon Database (Phase 1)** on your system.

### 🧠 Prerequisites
- Installed **MySQL / MariaDB** database server.  
- SQL client software (MySQL Workbench, DBeaver, or Command Line).  

### ⚙️ Installation Steps

1. **Create the Database**
   ```sql
   CREATE DATABASE Amazon;
   USE Amazon;
