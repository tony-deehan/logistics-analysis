-- ========================================
-- LOGISTICS PERFORMANCE ANALYSIS
-- Olist Brazilian E-Commerce Dataset
-- ========================================

-- Objective: Identify key drivers of late deliveries.


-- ========================================
-- 1. INITIAL DATA EXPLORATION
-- ========================================

-- Preview orders table
SELECT *
FROM `course-work-479212.logistics_analysis.orders`
LIMIT 10;


-- Check orders schema
SELECT
  column_name,
  data_type
FROM `course-work-479212.logistics_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'orders';


-- ========================================
-- 2. DATA VALIDATION
-- ========================================

-- Validate delivery date completeness
SELECT
  COUNT(*) AS total_orders,
  COUNT(order_delivered_customer_date) AS delivered_count,
  COUNT(order_estimated_delivery_date) AS estimated_count
FROM `course-work-479212.logistics_analysis.orders`;


-- Check dataset date range
SELECT
  MIN(order_purchase_timestamp) AS earliest_order,
  MAX(order_purchase_timestamp) AS latest_order
FROM `course-work-479212.logistics_analysis.orders`;


-- Check order ID uniqueness
SELECT
  COUNT(*) AS total_orders,
  COUNT(DISTINCT order_id) AS unique_orders
FROM `course-work-479212.logistics_analysis.orders`;


-- ========================================
-- 3. METRIC ENGINEERING
-- ========================================

-- Create delivery performance metrics
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
)

SELECT
  order_id,
  order_purchase_timestamp,
  order_delivered_customer_date,
  order_estimated_delivery_date,

  DATE_DIFF(order_delivered_customer_date, order_purchase_timestamp, DAY) AS delivery_time_days,

  DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS delay_days,

  CASE
    WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
    ELSE 0
  END AS is_late

FROM delivered_orders
LIMIT 20;


-- ========================================
-- 4. OVERALL DELIVERY PERFORMANCE
-- ========================================

-- Calculate overall on-time rate
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

calculated AS (
  SELECT
    order_id,
    DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS delay_days,
    CASE
      WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late
  FROM delivered_orders
)

SELECT
  COUNT(*) AS total_orders,
  SUM(is_late) AS late_orders,
  ROUND(1 - SAFE_DIVIDE(SUM(is_late), COUNT(*)), 4) AS on_time_rate
FROM calculated;


-- Analyse delay distribution
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

calculated AS (
  SELECT
    DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) AS delay_days
  FROM delivered_orders
)

SELECT
  MIN(delay_days) AS min_delay,
  MAX(delay_days) AS max_delay,
  AVG(delay_days) AS avg_delay
FROM calculated;


-- Categorise delivery outcomes
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

calculated AS (
  SELECT
    CASE
      WHEN DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) <= -3 THEN 'Early (3+ days)'
      WHEN DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) BETWEEN -2 AND 0 THEN 'On Time'
      WHEN DATE_DIFF(order_delivered_customer_date, order_estimated_delivery_date, DAY) BETWEEN 1 AND 3 THEN 'Slight Delay'
      ELSE 'Severe Delay'
    END AS delivery_category
  FROM delivered_orders
)

SELECT
  delivery_category,
  COUNT(*) AS orders
FROM calculated
GROUP BY delivery_category
ORDER BY orders DESC;


-- ========================================
-- 5. TREND ANALYSIS
-- ========================================

-- Monthly on-time delivery trend
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

calculated AS (
  SELECT
    DATE_TRUNC(order_purchase_timestamp, MONTH) AS order_month,

    CASE
      WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late

  FROM delivered_orders
)

SELECT
  order_month,
  COUNT(*) AS total_orders,
  SUM(is_late) AS late_orders,
  ROUND(1 - SAFE_DIVIDE(SUM(is_late), COUNT(*)), 4) AS on_time_rate
FROM calculated
GROUP BY order_month
ORDER BY order_month;


-- ========================================
-- 6. REGIONAL ANALYSIS
-- ========================================

-- Delivery performance by state
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

joined AS (
  SELECT
    o.order_id,
    c.customer_state,

    CASE
      WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late

  FROM delivered_orders o
  JOIN `course-work-479212.logistics_analysis.customers` c
    ON o.customer_id = c.customer_id
)

SELECT
  customer_state,
  COUNT(*) AS total_orders,
  SUM(is_late) AS late_orders,
  ROUND(1 - SAFE_DIVIDE(SUM(is_late), COUNT(*)), 4) AS on_time_rate
FROM joined
GROUP BY customer_state
ORDER BY on_time_rate ASC;


-- Compare order volume by state
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

joined AS (
  SELECT
    c.customer_state,
    COUNT(*) AS total_orders,

    SUM(
      CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
        ELSE 0
      END
    ) AS late_orders

  FROM delivered_orders o
  JOIN `course-work-479212.logistics_analysis.customers` c
    ON o.customer_id = c.customer_id

  GROUP BY c.customer_state
)

SELECT
  customer_state,
  total_orders,
  late_orders,
  ROUND(1 - SAFE_DIVIDE(late_orders, total_orders), 4) AS on_time_rate
FROM joined
ORDER BY total_orders DESC;


-- ========================================
-- 7. SELLER ANALYSIS
-- ========================================

-- Worst-performing sellers
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

joined AS (
  SELECT
    oi.seller_id,

    CASE
      WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late

  FROM delivered_orders o
  JOIN `course-work-479212.logistics_analysis.order_items` oi
    ON o.order_id = oi.order_id
),

seller_performance AS (
  SELECT
    seller_id,
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(1 - SAFE_DIVIDE(SUM(is_late), COUNT(*)), 4) AS on_time_rate
  FROM joined
  GROUP BY seller_id
  HAVING COUNT(*) > 50
)

SELECT
  *,
  (SELECT AVG(on_time_rate) FROM seller_performance) AS avg_on_time_rate
FROM seller_performance
ORDER BY on_time_rate ASC
LIMIT 20;


-- Sellers contributing most late orders
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

joined AS (
  SELECT
    oi.seller_id,
    CASE
      WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late
  FROM delivered_orders o
  JOIN `course-work-479212.logistics_analysis.order_items` oi
    ON o.order_id = oi.order_id
),

seller_performance AS (
  SELECT
    seller_id,
    COUNT(*) AS total_orders,
    SUM(is_late) AS late_orders,
    ROUND(1 - SAFE_DIVIDE(SUM(is_late), COUNT(*)), 4) AS on_time_rate
  FROM joined
  GROUP BY seller_id
  HAVING COUNT(*) > 50
)

SELECT
  seller_id,
  total_orders,
  late_orders,
  on_time_rate,
  ROUND(
    SAFE_DIVIDE(
      late_orders,
      SUM(late_orders) OVER ()
    ),
    4
  ) AS share_of_all_late_orders
FROM seller_performance
ORDER BY late_orders DESC
LIMIT 20;


-- Seller performance by state
WITH delivered_orders AS (
  SELECT *
  FROM `course-work-479212.logistics_analysis.orders`
  WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
),

joined AS (
  SELECT
    oi.seller_id,
    c.customer_state,

    CASE
      WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
      ELSE 0
    END AS is_late

  FROM delivered_orders o
  JOIN `course-work-479212.logistics_analysis.order_items` oi
    ON o.order_id = oi.order_id
  JOIN `course-work-479212.logistics_analysis.customers` c
    ON o.customer_id = c.customer_id
)

SELECT
  customer_state,
  seller_id,
  COUNT(*) AS total_orders,
  SUM(is_late) AS late_orders,
  ROUND(1 - SAFE_DIVIDE(SUM(is_late), COUNT(*)), 4) AS on_time_rate
FROM joined
GROUP BY customer_state, seller_id
HAVING COUNT(*) > 50
ORDER BY on_time_rate ASC
LIMIT 20;


-- ========================================
-- 8. TABLEAU EXPORT DATASETS
-- ========================================

-- Export: Regional / trend analysis dataset
SELECT
  o.order_id,
  o.customer_id,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  c.customer_state,

  DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY) AS delay_days,

  CASE
    WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
    ELSE 0
  END AS is_late

FROM `course-work-479212.logistics_analysis.orders` o
JOIN `course-work-479212.logistics_analysis.customers` c
  ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;


-- Export: Seller analysis dataset
SELECT
  o.order_id,
  oi.seller_id,
  c.customer_state,
  o.order_purchase_timestamp,

  DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY) AS delay_days,

  CASE
    WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
    ELSE 0
  END AS is_late

FROM `course-work-479212.logistics_analysis.orders` o
JOIN `course-work-479212.logistics_analysis.customers` c
  ON o.customer_id = c.customer_id
JOIN `course-work-479212.logistics_analysis.order_items` oi
  ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;