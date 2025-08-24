-- ============================================
-- BRONZE • COTAÇÕES (base fornecida)
-- ============================================
CREATE TABLE IF NOT EXISTS bronze_cotacoes (
  id              BIGSERIAL PRIMARY KEY,
  ativo           TEXT NOT NULL,           -- Ex.: BTC-USD, GC=F, CL=F, SI=F
  preco           NUMERIC(18,6) NOT NULL,  -- Preço coletado
  moeda           CHAR(3) NOT NULL DEFAULT 'USD',
  horario_coleta  TIMESTAMPTZ NOT NULL,    -- Quando o script coletou
  inserido_em     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- (Se preferir padronizar o nome como bronze_prices, crie uma VIEW)
-- CREATE OR REPLACE VIEW bronze_prices AS SELECT * FROM public.cotacoes;


-- ============================================
-- BRONZE • CLIENTES
-- PK própria + ID de origem preservado
-- ============================================
CREATE TABLE IF NOT EXISTS bronze_customers (
  bronze_customer_id BIGSERIAL PRIMARY KEY,   -- PK da camada Bronze (surrogate)
  customer_id        TEXT NOT NULL,           -- ID de origem (ex.: C001)
  customer_name      VARCHAR(200) NOT NULL,
  documento          VARCHAR(32),
  segmento           VARCHAR(64),
  pais               VARCHAR(64),
  estado             VARCHAR(16),
  cidade             VARCHAR(100),
  created_at         TIMESTAMPTZ NOT NULL
);

-- Opcional (evita duplicar cliente da mesma carga):
-- ALTER TABLE bronze_customers ADD CONSTRAINT uq_bronze_customers_src UNIQUE (customer_id);


-- ============================================
-- BRONZE • VENDAS BTC (sem preço unitário)
-- PK própria + transaction_id de origem preservado
-- ============================================
CREATE TABLE IF NOT EXISTS bronze_sales_btc_excel (
  bronze_sales_btc_id BIGSERIAL PRIMARY KEY,  -- PK append-only
  transaction_id      TEXT NOT NULL,          -- ID da planilha/origem
  data_hora           TIMESTAMPTZ NOT NULL,
  ativo               VARCHAR(16) NOT NULL,   -- "BTC"
  quantidade          NUMERIC(18,6) NOT NULL CHECK (quantidade > 0),
  tipo_operacao       VARCHAR(10) NOT NULL CHECK (tipo_operacao IN ('COMPRA','VENDA')),
  moeda               VARCHAR(10) NOT NULL,
  cliente_id          TEXT,                   -- referencia ao customer_id da origem
  canal               VARCHAR(32),
  mercado             VARCHAR(8),
  arquivo_origem      VARCHAR(256),
  importado_em        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Opcional:
-- ALTER TABLE bronze_sales_btc_excel ADD CONSTRAINT uq_btc_tx UNIQUE (transaction_id);


-- ============================================
-- BRONZE • VENDAS COMMODITIES (sem preço unitário)
-- PK própria + transaction_id de origem preservado
-- ============================================
CREATE TABLE IF NOT EXISTS bronze_sales_commodities_sql (
  bronze_sales_comm_id BIGSERIAL PRIMARY KEY, -- PK append-only
  transaction_id       TEXT NOT NULL,         -- ID da origem transacional
  data_hora            TIMESTAMPTZ NOT NULL,
  commodity_code       VARCHAR(20) NOT NULL,  -- GOLD, OIL, COFFEE, SILVER...
  quantidade           NUMERIC(18,6) NOT NULL CHECK (quantidade > 0),
  tipo_operacao        VARCHAR(10) NOT NULL CHECK (tipo_operacao IN ('COMPRA','VENDA')),
  unidade              VARCHAR(16) NOT NULL,  -- kg, bbl, oz...
  moeda                VARCHAR(10) NOT NULL,
  cliente_id           TEXT,                  -- referencia ao customer_id da origem
  canal                VARCHAR(32),
  mercado              VARCHAR(8),
  arquivo_origem       VARCHAR(256),
  importado_em         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Opcional:
-- ALTER TABLE bronze_sales_commodities_sql ADD CONSTRAINT uq_comm_tx UNIQUE (transaction_id);