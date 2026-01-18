from functions import *

countries = ["AT", "BE", "FR", "DE", "IE", "IT", "LU", "NL", "PT", "ES", "CH", "GB"]
yr2019 = "2018-12-30 2019-04-10"
yr2020 = "2019-12-30 2020-04-07"
period = "2018-12-30 2020-04-05"

subcat = [448, 862, 864, 866, 868, 869, 449, 1258, 1296, 1251, 870, 975, 101, 1340]

astrology = subcat[0]
buddhism = subcat[1]
christianity = subcat[2]
hinduism = subcat[3]
islam = subcat[4]
judaism = subcat[5]
paranormal = subcat[6]
pagan = subcat[7]
places_workship = subcat[8]
scientology = subcat[9]
self_help = subcat[10]
skeptic = subcat[11]
spirituality = subcat[12]
theology = subcat[13]

#---------------------------------------------------------------------------#
#--- DOWNLOAD DATA ---------------------------------------------------------#
#---------------------------------------------------------------------------#

#---(1) Astrology---#
#-------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=astrology, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=astrology, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=astrology, date=period,  countries=countries)

open = False 
if open:
  print(f"Daily 2019 links for subcategory: Astrology & Divination")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Astrology & Divination")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Astrology & Divination")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Astrology"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Astrology.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Astrology.csv"
    else:
        filename = f"weekly_{i - 25}-Astrology.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])

    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(2) Buddhism---#
#------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=buddhism, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=buddhism, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=buddhism, date=period,  countries=countries)

open = False 
if open:
  print(f"Daily 2019 links for subcategory: Buddhism")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Buddhism")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Buddhism")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Buddhism"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Buddhism.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Buddhism.csv"
    else:
        filename = f"weekly_{i - 25}-Buddhism.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(3) Christianity---#
#----------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=christianity, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=christianity, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=christianity, date=period,  countries=countries)

open = False 
if open:
  print(f"Daily 2019 links for subcategory: Christianity")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Christianity")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Christianity")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Christianity"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Christianity.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Christianity.csv"
    else:
        filename = f"weekly_{i - 25}-Christianity.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(4) Hinduism---#
#------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=hinduism, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=hinduism, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=hinduism, date=period,  countries=countries)

open = False 
if open:
  print(f"Daily 2019 links for subcategory: Hinduism")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Hinduism")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Hinduism")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Hinduism"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Hinduism.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Hinduism.csv"
    else:
        filename = f"weekly_{i - 25}-Hinduism.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(5) Islam---#
#---------------#
urls_19 = generate_google_trends_url_subcat(subcategory=islam, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=islam, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=islam, date=period,  countries=countries)

open = False 
if open:
  print(f"Daily 2019 links for subcategory: Islam")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Islam")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Islam")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Islam"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Islam.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Islam.csv"
    else:
        filename = f"weekly_{i - 25}-Islam.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(6) Judaism---#
#-----------------#
urls_19 = generate_google_trends_url_subcat(subcategory=judaism, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=judaism, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=judaism, date=period,  countries=countries)

open = False 
if open:
  print(f"Daily 2019 links for subcategory: Judaism")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Judaism")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Judaism")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Judaism"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Judaism.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Judaism.csv"
    else:
        filename = f"weekly_{i - 25}-Judaism.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(7) Paranormal---#
#--------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=paranormal, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=paranormal, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=paranormal, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Paranormal")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Paranormal")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Paranormal")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Paranormal"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Paranormal.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Paranormal.csv"
    else:
        filename = f"weekly_{i - 25}-Paranormal.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(8) Pagan---#
#---------------#
urls_19 = generate_google_trends_url_subcat(subcategory=pagan, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=pagan, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=pagan, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Pagan")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Pagan")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Pagan")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Pagan"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Pagan.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Pagan.csv"
    else:
        filename = f"weekly_{i - 25}-Pagan.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab') 
    time.sleep(6)



#---(9) Places---#
#----------------#
urls_19 = generate_google_trends_url_subcat(subcategory=places_workship, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=places_workship, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=places_workship, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Places")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Places")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Places")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Places"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Places.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Places.csv"
    else:
        filename = f"weekly_{i - 25}-Places.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(10) Scientology---#
#----------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=scientology, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=scientology, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=scientology, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Scientology")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Scientology")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Scientology")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Scientology"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Scientology.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Scientology.csv"
    else:
        filename = f"weekly_{i - 25}-Scientology.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(11) Self-help---#
#--------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=self_help, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=self_help, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=self_help, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Self-help")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Self-help")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Self-help")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Self-help"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Self-help.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Self-help.csv"
    else:
        filename = f"weekly_{i - 25}-Self-help.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(12) Skeptic---#
#------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=skeptic, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=skeptic, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=skeptic, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Skeptic")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Skeptic")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Skeptic")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Skeptic"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Skeptic.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Skeptic.csv"
    else:
        filename = f"weekly_{i - 25}-Skeptic.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(13) Spirituality---#
#-----------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=spirituality, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=spirituality, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=spirituality, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Spirituality")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Spirituality")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Spirituality")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Spirituality"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Spirituality.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Spirituality.csv"
    else:
        filename = f"weekly_{i - 25}-Spirituality.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(6)


#---(14) Theology---#
#-------------------#
urls_19 = generate_google_trends_url_subcat(subcategory=theology, date=yr2019, countries=countries)
urls_20 = generate_google_trends_url_subcat(subcategory=theology, date=yr2020, countries=countries)
urls_weekly = generate_google_trends_url_subcat(subcategory=theology, date=period,  countries=countries)

open = True 
if open:
  print(f"Daily 2019 links for subcategory: Theology")
  open_links(urls_19)

  print(f"Daily 2020 links for subcategory: Theology")
  open_links(urls_20)

  print(f"Weekly links for subcategory: Theology")
  open_links(urls_weekly)


for i in range(1, 37):
    
    target_folder = r"C:\Users\ALBERTO TRELLES\Dropbox\Religion-Covid\Data\Subcat\Europe\Theology"

    if i <= 12:
        filename = f"daily2019_{i - 1}-Theology.csv"
    elif i <= 24:
        filename = f"daily2020_{i - 13}-Theology.csv"
    else:
        filename = f"weekly_{i - 25}-Theology.csv"

    click_download_and_save(filename=filename, target_folder=target_folder, coord = [1406, 503])
    
    pyautogui.hotkey('ctrl', 'tab')
    time.sleep(5)
