"""
scrape_gallup_religiosity.py
-----------------------------
Scrapes the Gallup 2017 State Religiosity PDF and saves a clean CSV.

Source:
  Gallup U.S. Daily, January-December 2017
  "Religiosity by State, 2017"
  https://news.gallup.com/file/poll/232235/Religiosity%20by%20State%202017.pdf

Output:
  gallup_religiosity_2017.csv  — columns: state (2-letter abbr), state_name,
                                  fips, pct_very_religious,
                                  pct_moderately_religious, pct_not_religious,
                                  sample_size

Notes:
  - 2017 is the last year for which Gallup published state-level religiosity
    estimates derived from the U.S. Daily tracking survey (~130,000 interviews).
    Gallup discontinued that survey after 2017; no equivalent 2018/2019 data
    exist publicly. For pre-treatment heterogeneity analysis, use the 2017
    figure as your baseline religiosity measure.
  - The "very religious" classification requires BOTH that respondents say
    religion is important in their daily life AND that they attend services
    weekly or almost weekly.

Requirements:
  pip install requests pdfplumber pandas
"""

import re
import io
import requests
import pdfplumber
import pandas as pd

PDF_URL = (
    "https://news.gallup.com/file/poll/232235/"
    "Religiosity%20by%20State%202017.pdf"
)

def fetch_pdf(url: str) -> bytes:
    headers = {"User-Agent": "Mozilla/5.0 (research use)"}
    resp = requests.get(url, headers=headers, timeout=30)
    resp.raise_for_status()
    return resp.content


def parse_pdf(pdf_bytes: bytes) -> pd.DataFrame:
    """Extract state-level religiosity data from the Gallup PDF."""
    records = []

    with pdfplumber.open(io.BytesIO(pdf_bytes)) as pdf:
        full_text = "\n".join(
            page.extract_text() or "" for page in pdf.pages
        )

    # Each data line looks like:
    #  Mississippi 59 29 12 1,187
    # Some state names are two words (e.g. "North Carolina", "New Mexico")
    # Sample sizes may contain commas (e.g. 1,187 or 10,085)
    pattern = re.compile(
        r"^[ \t]*([A-Z][a-zA-Z ]+?)"   # state name (greedy, trimmed below)
        r"\s+(\d{1,2})"                  # pct very religious
        r"\s+(\d{1,2})"                  # pct moderately religious
        r"\s+(\d{1,2})"                  # pct not religious
        r"\s+([\d,]+)"                   # sample size (may have comma)
        r"\s*$",
        re.MULTILINE,
    )

    for m in pattern.finditer(full_text):
        state = m.group(1).strip()
        # Skip header / footnote lines that accidentally match
        if state.lower() in {"very religious", "moderately religious",
                              "not religious", "gallup"}:
            continue
        records.append({
            "state_name":              state,
            "pct_very_religious":      int(m.group(2)),
            "pct_moderately_religious": int(m.group(3)),
            "pct_not_religious":       int(m.group(4)),
            "sample_size":             int(m.group(5).replace(",", "")),
        })

    df = pd.DataFrame(records)
    return df


def add_state_codes(df: pd.DataFrame) -> pd.DataFrame:
    """Merge in two-letter state abbreviations and FIPS codes."""
    fips_map = {
        "Alabama": ("AL", 1), "Alaska": ("AK", 2), "Arizona": ("AZ", 4),
        "Arkansas": ("AR", 5), "California": ("CA", 6), "Colorado": ("CO", 8),
        "Connecticut": ("CT", 9), "Delaware": ("DE", 10),
        "District of Columbia": ("DC", 11), "Florida": ("FL", 12),
        "Georgia": ("GA", 13), "Hawaii": ("HI", 15), "Idaho": ("ID", 16),
        "Illinois": ("IL", 17), "Indiana": ("IN", 18), "Iowa": ("IA", 19),
        "Kansas": ("KS", 20), "Kentucky": ("KY", 21), "Louisiana": ("LA", 22),
        "Maine": ("ME", 23), "Maryland": ("MD", 24),
        "Massachusetts": ("MA", 25), "Michigan": ("MI", 26),
        "Minnesota": ("MN", 27), "Mississippi": ("MS", 28),
        "Missouri": ("MO", 29), "Montana": ("MT", 30),
        "Nebraska": ("NE", 31), "Nevada": ("NV", 32),
        "New Hampshire": ("NH", 33), "New Jersey": ("NJ", 34),
        "New Mexico": ("NM", 35), "New York": ("NY", 36),
        "North Carolina": ("NC", 37), "North Dakota": ("ND", 38),
        "Ohio": ("OH", 39), "Oklahoma": ("OK", 40), "Oregon": ("OR", 41),
        "Pennsylvania": ("PA", 42), "Rhode Island": ("RI", 44),
        "South Carolina": ("SC", 45), "South Dakota": ("SD", 46),
        "Tennessee": ("TN", 47), "Texas": ("TX", 48), "Utah": ("UT", 49),
        "Vermont": ("VT", 50), "Virginia": ("VA", 51),
        "Washington": ("WA", 53), "West Virginia": ("WV", 54),
        "Wisconsin": ("WI", 55), "Wyoming": ("WY", 56),
    }
    df["state"] = df["state_name"].map(lambda s: fips_map.get(s, (None,))[0])
    df["fips"]  = df["state_name"].map(lambda s: fips_map.get(s, (None, None))[1])
    return df


def main():
    print("Fetching PDF …")
    pdf_bytes = fetch_pdf(PDF_URL)

    print("Parsing PDF …")
    df = parse_pdf(pdf_bytes)
    df = add_state_codes(df)

    # Reorder columns: state (2-letter) first, then full name, then data
    df = df[["state", "state_name", "fips",
             "pct_very_religious", "pct_moderately_religious",
             "pct_not_religious", "sample_size"]]

    print(f"Extracted {len(df)} rows.\n")
    print(df.to_string(index=False))

    out_dta = "gallup_religiosity_2017.dta"
    df.to_stata(out_dta, write_index=False)
    print(f"\nSaved → {out_dta}")


if __name__ == "__main__":
    main()
