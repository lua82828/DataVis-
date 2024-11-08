SELECT DISTINCT o.user_id
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE o.order_date BETWEEN '2023-08-01' AND '2023-08-15'
  AND p.category = 'корм для животных'
  AND p.product != 'Корм Kitekat для кошек, с кроликом в соусе, 85 г'
GROUP BY o.user_id
HAVING COUNT(DISTINCT p.product_id) >= 2;
