DROP TABLE IF EXISTS silver_sales_enriched CASCADE;

CREATE TABLE silver_sales_enriched AS
SELECT
  n.transaction_id,
  n.data_hora_h,        -- já truncado
  n.data_dia, n.ano, n.mes, n.dia, n.hora,
  n.asset_raw,
  n.symbol_cotacao_norm,
  n.quantidade,
  n.tipo_operacao,
  n.moeda,
  n.cliente_id,
  n.canal,
  n.mercado,

  p.cotacao_id,
  p.cotacao_ts,
  p.preco AS preco_unitario_usd,

  -- métricas
  n.quantidade * p.preco AS notional_abs_usd,
  (CASE WHEN n.tipo_operacao = 'VENDA' THEN 1
        WHEN n.tipo_operacao = 'COMPRA' THEN -1
        ELSE NULL END) * (n.quantidade * p.preco) AS notional_signed_usd

FROM silver_sales_normalized n
LEFT JOIN silver_prices_hourly p
  ON p.ativo = n.symbol_cotacao_norm
 AND p.moeda = 'USD'
 AND p.hora  = n.data_hora_h
;

ALTER TABLE silver_sales_enriched
  ADD COLUMN silver_enriched_id BIGSERIAL PRIMARY KEY;

-- (Opcional) índice para consultas por ativo e hora
CREATE INDEX IF NOT EXISTS idx_silver_enriched_asset_hora
  ON silver_sales_enriched (symbol_cotacao_norm, data_hora_h);