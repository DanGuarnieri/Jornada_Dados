CREATE OR REPLACE VIEW gold_kpi_by_customer AS
SELECT
  c.customer_id,
  c.customer_name,
  SUM(e.notional_abs_usd)    AS volume_gross_usd,
  SUM(e.notional_signed_usd) AS fluxo_liquido_usd,
  COUNT(*)                   AS transacoes
FROM silver_sales_enriched e
JOIN bronze_customers c
  ON c.customer_id = e.cliente_id
GROUP BY c.customer_id, c.customer_name;