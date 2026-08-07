"""Near-miss fixture for the default-suite entry.

Trips: socketserver, which is the module that binds and listens.
Does not trip: socket, one word away, which is the client side.
"""

import socketserver


def test_module_is_importable():
    assert socketserver is not None
