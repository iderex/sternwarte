"""Neighbour for no-bare-except-and-no-assert-in-library-code.

A named exception class rather than a bare except, and a raise rather than an
assert. Both survive python -O and both say what went wrong.
"""


def offsets(rows):
    if not rows:
        raise ValueError("no rows")
    try:
        return sum(rows)
    except TypeError:
        return None
