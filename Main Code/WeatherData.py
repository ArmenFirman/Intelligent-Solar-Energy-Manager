# -*- coding: utf-8 -*-
"""
@author: Amin Asbai
"""
import json
import pandas as pd
import requests


def update_Weather_data(df):
    url='http://api.openweathermap.org/data/2.5/weather?q=Andratx&units=metric&appid=1e47e582bff799e3514239429b76f2aa'
    response = requests.get(url)
    climate_data=response.json()
    data=clean_data(climate_data)
    updated_dataframe=update_dataframe(df,data)
    return updated_dataframe

def clean_data(climate_data):
    main_data=climate_data["main"]
    wind_data=climate_data["wind"]
    data = {**main_data, **wind_data}
    data.pop("feels_like", None)
    data.pop("temp_min", None)
    data.pop("temp_max", None)
    data["pressure"]=100*data["pressure"]
    data["irradiance"]=None
    return data

def update_dataframe(df,dict_weather):
    df = df.iloc[1:]
    df = df.drop(columns=['Hour', 'Month'])
    aux_df=pd.DataFrame()
    for i in df.columns:
        aux_df.loc[0,i]=dict_weather[i]
    aux_df.insert(0, 'TimeStamp', pd.to_datetime('now').replace(second=0,microsecond=0))
    aux_df.set_index('TimeStamp', inplace=True)
    df=df.append(aux_df)
    df['Hour']=df.index.hour
    df['Month']=df.index.month
    return df