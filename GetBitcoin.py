import requests
import pandas as pd
from datetime import datetime

#url para obter preço do Bitcoin
def get_bitcoin_df():
    url = "https://api.coinbase.com/v2/prices/spot"

    #Requisição Get para a API
    response = requests.get(url)
    data = response.json()

    #Extrair os dados que preciso
    ativo = data['data']['base']
    preco = float(data['data']['amount'])
    moeda = data['data']['currency']
    horario_de_coleta = datetime.now()

    df = pd.DataFrame([{
        'ativo': ativo,
        'preco' : preco,
        'moeda': moeda,
        'horario_coleta': horario_de_coleta
    }])
    return df