🏬 **Amazon E-Commerce Database System**  
This repository manages a comprehensive Amazon-like e-commerce system designed to handle products, orders, sales, inventory, users, payments, shipments, and customer feedback.

🚀 **Phase 2: Core Operational and Analytical Queries**  
Phase 2 builds upon the Phase 1 Database Architecture by developing core SQL queries necessary for **daily operations, analytics, and business intelligence**. These queries help extract insights from the 25-table relational schema.  

### **Objectives of Phase 2**
1. **Develop Operational Queries (CRUD)**: Create essential `SELECT`, `INSERT`, `UPDATE`, and `DELETE` statements across key tables like Orders, Products, Users, Cart, and Payments.  
2. **Generate Analytical Queries**: Implement queries with `JOINs`, `GROUP BY`, and aggregation functions to support **business reporting** (e.g., total sales, top-selling products, revenue per seller).  
3. **Establish Data Dictionary**: Document each query’s purpose and expected output for future API and dashboard integration.  

---

### 📁 **Phase 2 SQL File Structure**
The file `PHASE2_AMAZON.SQL` contains all queries, organized by **primary table focus**, making it modular and easy to maintain.  

---

### **Highlights of Implemented Queries**

| Table / Area | Query Focus | Example Capabilities |
|--------------|-------------|--------------------|
| **Users (T1) & Customers (T2)** | Customer Management & Analytics | List active users, count users per city/state, identify top buyers. |
| **Products (T3) & Categories (T4)** | Inventory & Product Analytics | Find products with low stock, top-selling products, average price per category. |
| **Orders (T5) & Payments (T6)** | Sales & Financial Reporting | Total revenue per day/month, pending payments, average order value, top buyers. |
| **Cart & Cart_Items (T7, T8)** | Shopping Behavior | Identify abandoned carts, total cart value per user, most added products. |
| **Sellers & Inventory (T9, T10)** | Seller Performance | List sellers by sales, calculate total stock per seller, find sellers with delayed shipments. |
| **Shipments & Delivery_Address (T11, T12)** | Logistics & Delivery | Count shipments per status, track delayed shipments, identify addresses with repeated delivery issues. |
| **Coupons & Offers (T13, T14)** | Marketing Analytics | List active coupons, calculate total discount redeemed, top-used offers. |
| **Reviews & Ratings (T15, T16)** | Customer Feedback | Average product rating, top-rated products, users with multiple reviews. |
| **Support_Tickets (T17)** | Customer Support | Count tickets per category/status, identify high-priority unresolved tickets. |
| **Refunds & Returns (T18, T19)** | Returns & Refunds Analytics | Total refund amount, products most returned, average refund processing time. |
| **Transactions (T20)** | Payment & Revenue Tracking | Sum of successful transactions, failed payments, total revenue per payment method. |
| **Notifications (T21)** | Communication Tracking | Count notifications sent/read, most common notification type. |
| **Complex Joins & Cross-Domain Analytics** | Business Intelligence | Identify products sold but out-of-stock, total revenue per seller including returns, top-selling categories in a region. |

---

### 🛠️ **Execution and Usage**
1. **Ensure Schema is Ready**: Verify the Amazon database is created and Phase 1 tables are populated with sample data.  
2. **Execute Queries**: Run the `PHASE2_AMAZON.SQL` file using MySQL Workbench, DBeaver, or your preferred SQL client. Queries are structured for **easy testing and review**.  
3. **Next Steps**: These queries will feed **reporting dashboards and API endpoints** in Phase 3 for analytics and operational monitoring.
