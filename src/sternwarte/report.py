"""Near-miss fixture for no-standard-output-from-the-library.

Trips: print, which writes to standard output from library code.
Does not trip: a logger call, which a caller can route or silence.
"""


def emit(summary):
    print(summary)
