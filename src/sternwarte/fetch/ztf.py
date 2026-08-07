"""Neighbour for no-network-outside-the-fetch-layer.

The same three lines as the tripping fixture, inside the fetch layer, which is
the one place the entry excludes. The edit is the directory and nothing else.
"""

import requests


def to_hub(url):
    response = requests.get(url, timeout=30)
    response.raise_for_status()
    return response
