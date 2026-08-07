"""Neighbour for no-environment-read-outside-the-command-line.

The same line as the tripping fixture, in the command line layer, which is
where entry 0012 in docs/decisions/ puts credential reading.
"""

import os


def atlas_token():
    return os.environ["ATLAS_TOKEN"]
