"""Near-miss fixture for no-magnitude-compared-to-a-float-literal-for-equality.

Trips: equality against a float literal.
Does not trip: math.isclose, one call away.
"""


def is_unset(mag):
    return mag == 0.0
