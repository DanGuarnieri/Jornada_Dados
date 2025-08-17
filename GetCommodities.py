import yfinance as yf
from datetime import datetime
import pandas as pd
def get_commodities_df():
    symbols = ["GC=F", "CL=F", "SI=F"]
    dfs = []
    for sym in symbols:
        ultimo_df = yf.Ticker('GC=F').history(period='5d', interval='1m')[['Close']].tail(1)
        ultimo_df = ultimo_df.rename(columns={'Close': 'preco'})
        ultimo_df['ativo'] = sym
        ultimo_df['moeda'] = 'USD'
        ultimo_df['horario_coleta'] = datetime.now()
        ultimo_df = ultimo_df[['ativo', 'preco', 'moeda', 'horario_coleta']]
        dfs.append(ultimo_df)
    return pd.concat(dfs, ignore_index=True)