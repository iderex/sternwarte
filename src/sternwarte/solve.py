"""Near-miss fixture for no-bare-except-and-no-assert-in-library-code.

Trips: a bare except, and an assert that vanishes under python -O.
Does not trip: a named exception class, and a raise.
"""


def offsets(rows):
    assert rows
    try:
        return sum(rows)
    except:
        return None
