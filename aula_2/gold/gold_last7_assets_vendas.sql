CREATE OR REPLACE VIEW public.gold_last7_assets_vendas AS
SELECT
  s.data_dia::date AS data,
  s.symbol_cotacao_norm AS ativo,
  SUM(s.notional_abs_usd) AS volume_vendas_usd
FROM public.silver_sales_enriched s
WHERE s.data_dia >= current_date - INTERVAL '6 days'
  AND s.tipo_operacao = 'VENDA'
GROUP BY 1, 2;