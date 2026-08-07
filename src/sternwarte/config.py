"""Near-miss fixture for no-environment-read-outside-the-command-line.

Trips: an environment read in library code.
Does not trip: the same line in src/sternwarte/cli.py, which the entry excludes.
"""

import os


def atlas_token():
    return os.environ["ATLAS_TOKEN"]
