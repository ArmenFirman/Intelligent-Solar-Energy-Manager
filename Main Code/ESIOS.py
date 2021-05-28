# -*- coding: utf-8 -*-
"""
@author: Amin Asbai
"""
import json
import pandas as pd
import requests

def set_headers(token):
    headers = dict()
    headers['Accept'] = 'application/json; application/vnd.esios-api-v1+json'
    headers['Content-Type'] = 'application/json'
    headers['Host'] = 'api.esios.ree.es'
    headers['Authorization'] = 'Token token=\"' + token + '\"'
    headers['Cookie'] = ''
    return headers

def get_ESIOS_data(ID,token):
    headers=set_headers(token)
    url= 'https://api.esios.ree.es/indicators/'+str(ID)
    response = requests.get(url, headers=headers)
    ESIOS_data=response.json()
    ESIOS_data=ESIOS_data['indicator']
    ESIOS_data=ESIOS_data['values']
    data=[]
    for i in range(len(ESIOS_data)):
        data.append(ESIOS_data[i]['value'])
    scale=lambda x: x/1000
    data=list(map(scale,data))
    return(data)

def get_prices():
    id_buying=1013
    id_selling=1739
    token='29247cff592abd8918ccb372157b768154f77a35fbe3a4abe1d4a6f72b9eedfa'
    buying_price=get_ESIOS_data(id_buying,token)
    selling_price=get_ESIOS_data(id_selling,token)
    return buying_price,selling_price
