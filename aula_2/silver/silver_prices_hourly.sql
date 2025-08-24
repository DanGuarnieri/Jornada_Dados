DROP TABLE IF EXISTS silver_prices_hourly CASCADE;

-- DISTINCT ON pega a última cotação dentro da mesma hora
CREATE TABLE silver_prices_hourly AS
SELECT DISTINCT ON (ativo, moeda, date_trunc('hour', horario_coleta))
       ativo,
       moeda,
       date_trunc('hour', horario_coleta) AS hora,
       preco,
       horario_coleta AS cotacao_ts,
       id AS cotacao_id
FROM bronze_cotacoes
ORDER BY ativo, moeda, date_trunc('hour', horario_coleta), horario_coleta DESC;

-- Índice para acelerar o join por hora
CREATE INDEX IF NOT EXISTS idx_prices_hourly_key
  ON silver_prices_hourly (ativo, moeda, hora);