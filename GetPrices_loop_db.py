import time
import pandas as pd
from sqlalchemy import create_engine
from GetBitcoin import get_bitcoin_df
from GetCommodities import get_commodities_df

from dotenv import load_dotenv
import os
import urllib.parse

# Carrega variáveis do .env
load_dotenv()

# Configuração do BD
USER = os.getenv("user")
PASSWORD = urllib.parse.quote_plus(os.getenv("password"))  # <<< Escapa caracteres especiais da senha
HOST = os.getenv("host")
PORT = os.getenv("port")
DBNAME = os.getenv("dbname")

# Construct the SQLAlchemy connection string
DATABASE_URL = f"postgresql+psycopg2://{USER}:{PASSWORD}@{HOST}:{PORT}/{DBNAME}?sslmode=require"

engine = create_engine(DATABASE_URL)

SLEEP_SECONDS = 60

if __name__ == "__main__":
    while True:
        try:
            # Coleta
            df_btc = get_bitcoin_df()
            df_comm = get_commodities_df()

            # Concatenar bases
            df = pd.concat([df_btc, df_comm], ignore_index=True)

            # Salva no banco
            df.to_sql("cotacoes", engine, if_exists="append", index=False)

            print("Cotações inseridas com sucesso!")

        except Exception as e:
            print("Erro ao inserir dados:", e)

        time.sleep(SLEEP_SECONDS)
