"""Neighbour for the default-suite entry.

One word from the tripping fixture: the client module rather than the server
one. The client side binds nothing and listens on nothing.
"""

import socket


def test_module_is_importable():
    assert socket is not None
