# -*- coding: utf-8 -*-
"""
@author: Amin Asbai
"""
from keras.models import model_from_json
from pickle import load
import numpy as np

def import_forecaster():
    json_file = open('C:\\Users\\Amin y Lubna\\Desktop\\Escritorio Virtual\\Carrera Amin\\2.TFG\\Modelo NN y Scaler\\model.json', 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_model_json)
    # load weights into new model
    loaded_model.load_weights("C:\\Users\\Amin y Lubna\\Desktop\\Escritorio Virtual\\Carrera Amin\\2.TFG\Modelo NN y Scaler\\model.h5")
    loaded_target_scaler = load(open('C:\\Users\\Amin y Lubna\\Desktop\\Escritorio Virtual\\Carrera Amin\\2.TFG\Modelo NN y Scaler\\target_scaler.pkl', 'rb'))
    loaded_feature_scaler = load(open('C:\\Users\\Amin y Lubna\\Desktop\\Escritorio Virtual\\Carrera Amin\\2.TFG\Modelo NN y Scaler\\feature_scaler.pkl', 'rb'))
    return loaded_model,loaded_target_scaler,loaded_feature_scaler

def scale_data(unscaled_data,target_scaler,feature_scaler):
    f_columns=['temp','humidity','speed','deg','pressure','Hour','Month']
    unscaled_data.loc[:, f_columns] = feature_scaler.transform(unscaled_data[f_columns].to_numpy())
    unscaled_data['irradiance'] = target_scaler.transform(unscaled_data[['irradiance']])
    return unscaled_data

def forecaster(model,target_scaler,data):
    data=data.to_numpy()
    data=data.reshape(1,data.shape[0],data.shape[1])
    Y=model.predict(data)
    Y=target_scaler.inverse_transform(Y)
    Y=Y.tolist()
    return Y
    

