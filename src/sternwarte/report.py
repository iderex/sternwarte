"""Neighbour for no-standard-output-from-the-library.

A logger call rather than print. The caller decides where it goes and can
silence it, which is the difference the entry is about.
"""

import logging

logger = logging.getLogger(__name__)


def emit(summary):
    logger.info("%s", summary)
