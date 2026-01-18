from pytrends.request import TrendReq
import pandas as pd
import urllib.parse
import webbrowser
import time

#For automation
import pyautogui
import time
import os


#Link generator
def generate_google_trends_url_subcat(subcategory, date, countries):
    base_url = "https://trends.google.com/trends/explore"
    encoded_date = urllib.parse.quote(date)
    urls = [f"{base_url}?cat={subcategory}&date={encoded_date}&geo={country}&hl=en" for country in countries]
    return urls

#Link openning
def open_links(urls, delay=1):
    for url in urls:
        webbrowser.open_new_tab(url)
        time.sleep(delay)

#Download automation 
def click_download_and_save(filename, target_folder, coord):
    # 1. Click download button
    pyautogui.moveTo(coord[0], coord[1], duration=1)
    pyautogui.click()
    time.sleep(4)

    # 2. Type full path with filename
    full_path = f"{target_folder}\\{filename}"
    pyautogui.write(full_path, interval=0.01)
    pyautogui.press('enter')
    print(f"saved {full_path}")
    time.sleep(2)
