# 🍕 Pizza Sales Data Analytics (SQL Project)
SQL-based data analysis project analyzing pizza sales data using multi-table JOINs, aggregations,  common table expressions (CTE) and window functions in MySQL Workbench.

## 📌 Project Overview
This project presents an end-to-end SQL data analysis of a pizza restaurant's operational dataset using **MySQL Workbench**. The objective is to solve realistic business problems categorized into **Basic**, **Intermediate**, and **Advanced** levels, focusing on revenue performance, ordering patterns, product preferences, and temporal sales trends.

---

## 🛠️ Tech Stack & Key Concepts Used
- **Database Management System:** MySQL Workbench
- **Language:** Structured Query Language (SQL)
- **Core Concepts Applied:**
  - Multi-table Aggregations (`JOIN`, `GROUP BY`, `ORDER BY`, `LIMIT`)
  - Subqueries and Common Table Expressions (`CTE`)
  - Window Functions (`DENSE_RANK()`, `SUM() OVER()`)
  - Date & Time Analytics Functions (`HOUR()`, `DATE()`)

---

## 🔍 Key Business Questions Solved

### 1. Basic Level
- **Total Orders & Revenue:** Calculated overall order count and generated gross revenue from sales.
- **Top Products & Sizes:** Identified the highest-priced pizza, the most frequently ordered size, and top 5 pizza types by quantity.

### 2. Intermediate Level
- **Category Quantities:** Summarized quantity distributions across various pizza categories.
- **Peak Hour Analysis:** Extracted order traffic trends by hours of the day (`HOUR(order_time)`).
- **Daily Averages & Revenue:** Computed the average number of pizzas sold daily and top 3 pizzas by revenue.

### 3. Advanced Level
- **Percentage Distribution:** Measured the percentage contribution of each pizza category to total overall revenue using Window Functions.
- **Cumulative Revenue:** Tracked daily sales and calculated cumulative revenue over time.
- **Category Rankings:** Ranked top 3 pizzas within each category based on revenue using `DENSE_RANK()` and `CTE`.

---

## 📜 SQL Script Breakdown

<details>
<summary><b>Click to Expand SQL Queries</b></summary>

```sql
-- ===================================================
-- 1. BASIC QUERIES
-- ===================================================

-- Retrieve total orders placed
SELECT COUNT(order_id) AS total_orders 
FROM orders;

-- Calculate total revenue generated
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details AS od
JOIN pizzas AS p ON od.pizza_id = p.pizza_id;

-- Identify the highest-priced pizza
SELECT pt.name, p.price
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered
SELECT p.size, COUNT(od.order_details_id) AS count_order
FROM pizzas AS p
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY COUNT(p.size) DESC;

-- List top 5 most ordered pizza types
SELECT pt.name, SUM(od.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;

-- ===================================================
-- 2. INTERMEDIATE QUERIES
-- ===================================================

-- Total quantity of each pizza category ordered
SELECT pt.category, SUM(od.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category;

-- Distribution of orders by hour of the day
SELECT HOUR(order_time) AS hour, COUNT(order_id) AS count_of_orders
FROM orders
GROUP BY hour;

-- Category-wise distribution of pizzas
SELECT category, COUNT(pizza_type_id) AS count
FROM pizza_types
GROUP BY category;

-- Average number of pizzas ordered per day
SELECT ROUND(AVG(quantity), 0) AS avg_pizza_order
FROM (
  SELECT o.order_date, SUM(od.quantity) AS quantity
  FROM orders AS o
  JOIN order_details AS od ON o.order_id = od.order_id
  GROUP BY o.order_date
) AS order_quantity;

-- Top 3 most ordered pizza types based on revenue
SELECT pt.name, SUM(od.quantity * p.price) AS revenue
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- ===================================================
-- 3. ADVANCED QUERIES
-- ===================================================

-- Percentage contribution of each pizza category to total revenue
SELECT pt.category,
       ROUND(SUM(od.quantity * p.price) * 100 / SUM(SUM(od.quantity * p.price)) OVER(), 2) AS percentage_distribution
FROM pizza_types AS pt
JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category;

-- Analyze cumulative revenue over time
SELECT o.order_date,
       ROUND(SUM(od.quantity * p.price), 3) AS daily_revenue, 
       ROUND(SUM(SUM(od.quantity * p.price)) OVER(ORDER BY o.order_date), 3) AS cummulative_revenue
FROM orders AS o
JOIN order_details AS od ON od.order_id = o.order_id
JOIN pizzas AS p ON p.pizza_id = od.pizza_id
GROUP BY o.order_date
ORDER BY o.order_date;

-- Top 3 most ordered pizza types based on revenue for each category
WITH cte_name AS (
    SELECT
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue,
        DENSE_RANK() OVER(PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS rank_no
    FROM pizza_types AS pt
    JOIN pizzas AS p ON p.pizza_type_id = pt.pizza_type_id
    JOIN order_details AS od ON od.pizza_id = p.pizza_id
    GROUP BY pt.category, pt.name
)
SELECT category, name, revenue, rank_no
FROM cte_name
WHERE rank_no <= 3
ORDER BY category, rank_no;
