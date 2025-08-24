-- Recria a tabela (caso exista)
DROP TABLE IF EXISTS silver_sales_normalized CASCADE;

-- CTAS: une BTC + Commodities, normaliza símbolo e materializa hora truncada
CREATE TABLE silver_sales_normalized AS
SELECT
    b.transaction_id,
    -- hora truncada (para joins e partições)
    date_trunc('hour', b.data_hora)           AS data_hora_h,
    -- componentes úteis de data
    (b.data_hora AT TIME ZONE 'UTC')::date    AS data_dia,
    EXTRACT(YEAR  FROM b.data_hora)::int      AS ano,
    EXTRACT(MONTH FROM b.data_hora)::int      AS mes,
    EXTRACT(DAY   FROM b.data_hora)::int      AS dia,
    EXTRACT(HOUR  FROM b.data_hora)::int      AS hora,

    TRIM(b.ativo) AS asset_raw,
    CASE
        WHEN UPPER(TRIM(b.ativo)) = 'BTC'     THEN 'BTC-USD'
        WHEN UPPER(TRIM(b.ativo)) = 'GOLD'    THEN 'GC=F'
        WHEN UPPER(TRIM(b.ativo)) = 'OIL'     THEN 'CL=F'
        WHEN UPPER(TRIM(b.ativo)) = 'SILVER'  THEN 'SI=F'
        ELSE TRIM(b.ativo)
    END AS symbol_cotacao_norm,

    b.quantidade,
    b.tipo_operacao,
    b.moeda,
    b.cliente_id,
    b.canal,
    b.mercado
FROM bronze_sales_btc_excel b

UNION ALL

SELECT
    c.transaction_id,
    date_trunc('hour', c.data_hora)           AS data_hora_h,
    (c.data_hora AT TIME ZONE 'UTC')::date    AS data_dia,
    EXTRACT(YEAR  FROM c.data_hora)::int      AS ano,
    EXTRACT(MONTH FROM c.data_hora)::int      AS mes,
    EXTRACT(DAY   FROM c.data_hora)::int      AS dia,
    EXTRACT(HOUR  FROM c.data_hora)::int      AS hora,

    TRIM(c.commodity_code) AS asset_raw,
    CASE
        WHEN UPPER(TRIM(c.commodity_code)) = 'BTC'     THEN 'BTC-USD'
        WHEN UPPER(TRIM(c.commodity_code)) = 'GOLD'    THEN 'GC=F'
        WHEN UPPER(TRIM(c.commodity_code)) = 'OIL'     THEN 'CL=F'
        WHEN UPPER(TRIM(c.commodity_code)) = 'SILVER'  THEN 'SI=F'
        ELSE TRIM(c.commodity_code)
    END AS symbol_cotacao_norm,

    c.quantidade,
    c.tipo_operacao,
    c.moeda,
    c.cliente_id,
    c.canal,
    c.mercado
FROM bronze_sales_commodities_sql c
;

-- PK técnica append-only
ALTER TABLE silver_sales_normalized
  ADD COLUMN silver_norm_id BIGSERIAL PRIMARY KEY;

-- (Opcional mas recomendado p/ performance nas análises/join)
CREATE INDEX IF NOT EXISTS idx_silver_norm_asset_hora
  ON silver_sales_normalized (symbol_cotacao_norm, data_hora_h);