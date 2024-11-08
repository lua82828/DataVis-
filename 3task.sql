SELECT p.product, COUNT(od.product_id) AS order_count
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN warehouses w ON o.warehouse_id = w.warehouse_id
WHERE o.order_date BETWEEN '2023-08-15' AND '2023-08-30'
  AND w.city = 'Санкт-Петербург'
GROUP BY p.product
ORDER BY order_count DESC
LIMIT 5;
