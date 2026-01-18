import urllib.parse
import webbrowser
import pyautogui
import time
import subprocess
import random
import pandas as pd
import numpy as np
NORDVPN_EXE = r"C:\Program Files\NordVPN\nordvpn.exe"

def gt_link(mid='', timeframe='', country='', state=None, subcat=None):
    '''
    Google Trends link for a MID value (subcategory optional), in some timeframe and country (state optional)
    
    Args:
        country (str): Country code, e.g., 'US'
        mid (str): MID value, e.g., '/m/0d05l6'. Can be empty if using subcat only.
        timeframe (str): Timeframe string, e.g., '2018-12-30 2020-04-05'
        state (str, optional): Two-letter state code, e.g., 'CA'
        subcat (int or str, optional): Google Trends subcategory ID, e.g., 864
    
    Returns:
        str: Google Trends URL
    '''
    geo = f'{country}-{state}' if state else country
    base_url = 'https://trends.google.com/trends/explore'
    
    params = {
        'geo': geo,
        'hl': 'en',
        'date': timeframe
    }
    
    # Add subcategory if provided
    if subcat:
        params['cat'] = str(subcat)
    
    # Add MID query if present
    if mid:
        params['q'] = mid
    
    # Encode parameters
    encoded_params = urllib.parse.urlencode(params, quote_via=urllib.parse.quote)
    url = f'{base_url}?{encoded_params}'
    return url  

def open_url(url, delay=5):
    webbrowser.open(url, new=1) #Open url in new window; wait 5 sec to load 
    time.sleep(delay)

def download_file(coord, path):
    '''
    Automate a file download by clicking a button and saving the file.

    Args:
        coord (tuple): (x, y) pixel coordinates of the download button.
        path (str): Full path and filename for saving, e.g. 'C:/Users/Me/Downloads/data.csv'.
    '''
    x, y = coord

    # Move to the button and click
    pyautogui.moveTo(x, y, duration=0)
    time.sleep(4)
    pyautogui.click()
    time.sleep(10)

    # Begin download 
    safe_path = path.replace('/', '\\')
    pyautogui.typewrite(safe_path, interval=0.1)  # interval = delay between keystrokes
    pyautogui.press('enter')
    time.sleep(2)

    # Close window 
    #pyautogui.hotkey('alt', 'f4')

def vpn_connect(country="Peru", timeout=30):
    try:
        # Always disconnect first
        subprocess.run(
            [NORDVPN_EXE, '-d'],
            capture_output=True,
            text=True,
            timeout=10
        )

        # Connect
        result = subprocess.run(
            [NORDVPN_EXE, '-c', '-g', country],
            capture_output=True,
            text=True,
            timeout=timeout
        )

        if result.returncode != 0:
            print(f"❌ NordVPN failed: {result.stderr.strip()}")
            return False

        # Verify IP
        ip = subprocess.run(
            ['curl', 'ipinfo.io/ip'],
            capture_output=True,
            text=True,
            timeout=10
        )

        print(f"✅ Connected to {country} | IP: {ip.stdout.strip()}")
        return True

    except subprocess.TimeoutExpired:
        print(f"⏰ Timeout while connecting to {country}")
        subprocess.run([NORDVPN_EXE, '-d'], capture_output=True)
        return False

    except FileNotFoundError:
        print("❌ nordvpn.exe not found — check installation path")
        return False
    
def vpn_connect_rand(max_attempts=10, delay=5):
    nordvpn_countries =  [
    'Albania',
    'Andorra',
    'Bulgaria',
    'Croatia',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Estonia',
    'Finland',
    'Greece',
    'Hong Kong',
    'Hungary',
    'Iceland',
    'Ireland',
    'Israel',
    'Latvia',
    'Lithuania',
    'Luxembourg',
    'Malaysia',
    'Moldova',
    'New Zealand',
    'North Macedonia',
    'Poland',
    'Portugal',
    'Romania',
    'Serbia',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'South Africa',
    'South Korea',
    'Taiwan',
    'Thailand',
    'Turkey',
    'Ukraine',
    'Vietnam'
]

    for attempt in range(1, max_attempts + 1):
        country = random.choice(nordvpn_countries)
        print(f"🔄 Attempting connection to {country} (Attempt {attempt})")

        if vpn_connect(country):
            return country

        time.sleep(delay)

    print("⚠️ Max attempts reached. Giving up.")
    return None

def get_gt(mid='', timeframe='', country='', path='', coord='', state=None, subcat=None, delay=30):
    '''
    Full pipeline:
    1. Connect to VPN (random country)
    2. Build Google Trends link
    3. Open URL (wait 5 sec)
    4. Click and download CSV to path
    '''

    vpn_connect_rand()
    url = gt_link(mid, timeframe, country, state, subcat)
    open_url(url, delay=5)
    time.sleep(delay)
    download_file(coord, path)

    print(f"✅ Successfully downloaded data for "
          f"mid={mid or 'N/A'}, "
          f"subcat={subcat or 'N/A'}, "
          f"country={country}, "
          f"state={state or 'N/A'}, "
          f"timeframe='{timeframe}'")

def na_fill_empty_df(df: pd.DataFrame, template_index: pd.Index) -> pd.DataFrame:
    """
    Expands an empty or 1x1 DataFrame to match a given index of dates,
    filling all data rows with NaN while preserving the original header row.

    Parameters
    ----------
    df : pd.DataFrame
        The small or corrupted DataFrame read from CSV (e.g., Alaska case).
    template_index : pd.Index
        The target index (dates + 'Día') to expand to.

    Returns
    -------
    pd.DataFrame
        A DataFrame with the same structure as valid ones (like df2),
        with NaNs for all data rows and the first row preserved.
    """

    # Extract first (and only) row: e.g. "Día    Fe: (Alaska)"
    first_row = df.iloc[[0]]

    # Create a NaN-filled DataFrame with the desired index and same column name
    nan_rows = pd.DataFrame(
        np.nan,
        index=template_index,
        columns=df.columns
    )

    # Combine the header row with the NaN rows
    df_filled = pd.concat([first_row, nan_rows])

    # Remove any duplicate index entries (keep the first “Día”)
    df_filled = df_filled[~df_filled.index.duplicated(keep='first')]

    return df_filled