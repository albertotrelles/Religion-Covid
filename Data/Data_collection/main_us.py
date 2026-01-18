import pandas as pd
import numpy as np
import pyautogui
import time
import os
from gt_functions import *

country='US'
states = {'AL':'Alabama','AK':'Alaska','AZ':'Arizona','AR':'Arkansas','CA':'California','CO':'Colorado','CT':'Connecticut','DE':'Delaware','FL':'Florida','GA':'Georgia','HI':'Hawaii','ID':'Idaho','IL':'Illinois','IN':'Indiana','IA':'Iowa','KS':'Kansas','KY':'Kentucky','LA':'Louisiana','ME':'Maine','MD':'Maryland','MA':'Massachusetts','MI':'Michigan','MN':'Minnesota','MS':'Mississippi','MO':'Missouri','MT':'Montana','NE':'Nebraska','NV':'Nevada','NH':'New Hampshire','NJ':'New Jersey','NM':'New Mexico','NY':'New York','NC':'North Carolina','ND':'North Dakota','OH':'Ohio','OK':'Oklahoma','OR':'Oregon','PA':'Pennsylvania','RI':'Rhode Island','SC':'South Carolina','SD':'South Dakota','TN':'Tennessee','TX':'Texas','UT':'Utah','VT':'Vermont','VA':'Virginia','WA':'Washington','WV':'West Virginia','WI':'Wisconsin','WY':'Wyoming'}

yr2019 = "2018-12-30 2019-04-13"
yr2020 = "2019-12-29 2020-04-11"
weeks = "2018-12-30 2020-04-05"
dtopics = {'/m/02zq2':'Faith', 
           '/m/0d05l6':'God', 
           '/m/0517l':'Meditation', 
           '/m/0687y':'Prayer', 
           '/m/06bvp':'Religion', 
           '/m/03bty4x':'Spirituality'}

data = []
for state_code, state_name in states.items():
    row = {'State': state_name}

    for mid, topic_name in dtopics.items():
        row[f'{topic_name}_2019'] = gt_link(mid=mid, timeframe=yr2019, country=country, state=state_code)
        row[f'{topic_name}_2020'] = gt_link(mid=mid, timeframe=yr2020, country=country, state=state_code)
        row[f'{topic_name}_weekly'] = gt_link(mid=mid, timeframe=weeks, country=country, state=state_code)
    
    data.append(row)
df_urls = pd.DataFrame(data)
df_urls.to_excel('urls_midvalues_us.xlsx', index=False)

#---------------------------------#
#--- (1.1) Data for mid-values ---#
#---------------------------------#
coord = (1400, 500)
current_path = r'C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid/Data/Data_collection'

for state_code, state_name in states.items():    
    for mid, topic in dtopics.items():                   
         
        # Daily 2019
        path = f'{current_path}/raw/US/nocat/{state_code}daily19_{topic}_{state_code}.csv'
        get_gt(mid=mid, timeframe=yr2019, country='US', path=path, coord=coord, state=state_code)
        time.sleep(2)
        pyautogui.hotkey('alt', 'f4')

        # Daily 2020
        path = f'{current_path}/raw/US/nocat/{state_code}/daily20_{topic}_{state_code}.csv'
        get_gt(mid=mid, timeframe=yr2020, country='US', path=path, coord=coord, state=state_code)
        time.sleep(2)
        pyautogui.hotkey('alt', 'f4')

        # Weekly
        path = f'{current_path}/raw/US/nocat/{state_code}/weekly_{topic}_{state_code}.csv'
        get_gt(mid=mid, timeframe=weeks, country='US', path=path, coord=coord, state=state_code)
        time.sleep(2)
        pyautogui.hotkey('alt', 'f4')

#-----------------------------#
#-- (1.2) Verify and clean ---#
#-----------------------------#
missing_files = pd.DataFrame(columns=['state_code', 'state_name', 'mid', 'topic', 'timeframe'])

for state_code, state_name in states.items():
    for mid, topic in dtopics.items():    
        for timeframe in ['daily19', 'daily20', 'weekly']:

            file_path = f'{current_path}/raw/US/nocat/{state_code}/{timeframe}_{topic}_{state_code}.csv'    
            if not os.path.exists(file_path):
                missing_files.loc[len(missing_files)] = {
                    'state_code': state_code,
                    'state_name': state_name,
                    'mid': mid,
                    'topic': topic,
                    'timeframe': timeframe
                }

# Download missing files 
timeframes = {'daily19': yr2019, 'daily20': yr2020, 'weekly': weeks}

for row in missing_files.itertuples(index=False):
    timeframe = timeframes[row.timeframe]
    path = f'{current_path}/raw/US/nocat/{row.state_code}/{row.timeframe}_{row.topic}_{row.state_code}.csv'
    get_gt(mid=row.mid, timeframe=timeframe, country='US', path=path, coord=coord, state=row.state_code)

# Clean empty series 
daily2019_dates = pd.read_csv('C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid/Data/Data_collection/raw/US/nocat/AL/daily19_Faith_AL.csv').index
daily2020_dates = pd.read_csv('C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid/Data/Data_collection/raw/US/nocat/AL/daily20_Faith_AL.csv').index
weekly_dates = pd.read_csv('C:/Users/ALBERTO TRELLES/Dropbox/Religion-Covid/Data/Data_collection/raw/US/nocat/AL/weekly_Faith_AL.csv').index

for state_code, state_name in states.items():
    for mid, topic in dtopics.items():    
        
        # Daily 2019
        path = f'{current_path}/raw/US/nocat/{state_code}/daily19_{topic}_{state_code}.csv'
        df = pd.read_csv(path)
        if df.shape == (1,1):
            df = na_fill_empty_df(df, daily2019_dates) 
            df.to_csv(path, index=True) 

        # Daily 2020
        path = f'{current_path}/raw/US/nocat/{state_code}/daily20_{topic}_{state_code}.csv'
        df = pd.read_csv(path)
        if df.shape == (1,1):
            df = na_fill_empty_df(df, daily2020_dates) 
            df.to_csv(path, index=True) 

        # Weekly 
        path = f'{current_path}/raw/US/nocat/{state_code}/weekly_{topic}_{state_code}.csv'
        df = pd.read_csv(path)
        if df.shape == (1,1):
            df = na_fill_empty_df(df, weekly_dates) 
            df.to_csv(path, index=True) 

        
