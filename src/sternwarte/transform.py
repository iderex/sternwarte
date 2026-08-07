"""Near-miss fixture for no-network-outside-the-fetch-layer.

Trips: this call sits outside src/sternwarte/fetch/, which the entry excludes.
Does not trip: the same three lines in src/sternwarte/fetch/ztf.py.
"""

import requests


def to_hub(url):
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response
