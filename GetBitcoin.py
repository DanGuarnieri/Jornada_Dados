import requests
import pandas as pd
from datetime import datetime

#url para obter preço do Bitcoin

url = "https://api.coinbase.com/v2/prices/spot"

#Requisição Get para a API
response = requests.get(url)
data = response.json()

#Extrair os dados que preciso
preco = float(data['data']['amount'])
ativo = data['data']['base']
moeda = data['data']['currency']
horario_de_coleta = datetime.now()

df = pd.DataFrame([{
    'preco' : preco,
    'ativo': ativo,
    'moeda': moeda,
    'hora_de_coleta': horario_de_coleta
}])
