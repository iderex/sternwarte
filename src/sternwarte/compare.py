"""Neighbour for no-magnitude-compared-to-a-float-literal-for-equality.

math.isclose rather than ==. One call away from the tripping fixture.
"""

import math


def is_unset(mag):
    return math.isclose(mag, 0.0, abs_tol=1e-9)
