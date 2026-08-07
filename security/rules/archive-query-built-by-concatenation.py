# Fixtures for archive-query-built-by-concatenation.
#
# The positive cases build the request target out of a value that came from
# outside the process. The negative neighbours are the same requests written so
# the value is data the client encodes, which is the repair the rule's message
# asks for. The pair is deliberately one edit apart, because a near-miss that
# could not have been written is a near-miss that proves nothing.

import requests


def fetch_epochs_by_interpolation(base, ra, dec, radius):
    # ruleid: archive-query-built-by-concatenation
    return requests.get(f"{base}/cone?ra={ra}&dec={dec}&sr={radius}", timeout=30)


def fetch_epochs_by_format(base, ra, dec):
    # ruleid: archive-query-built-by-concatenation
    return requests.get("{0}/cone?ra={1}&dec={2}".format(base, ra, dec), timeout=30)


def fetch_epochs_by_addition(base, ra):
    # ruleid: archive-query-built-by-concatenation
    return requests.get("https://archive.example/cone?ra=" + ra, timeout=30)


def fetch_epochs_by_percent(ra):
    # ruleid: archive-query-built-by-concatenation
    return requests.get("https://archive.example/cone?ra=%s" % ra, timeout=30)


def select_detections_by_interpolation(client, source_id):
    # ruleid: archive-query-built-by-concatenation
    return client.query(f"SELECT mag FROM detections WHERE source_id = {source_id}")


def fetch_epochs_by_parameters(base, ra, dec, radius):
    # ok: archive-query-built-by-concatenation
    return requests.get(
        base + "/cone",
        params={"ra": ra, "dec": dec, "sr": radius},
        timeout=30,
    )


def select_detections_by_binding(client, source_id):
    # ok: archive-query-built-by-concatenation
    return client.query(
        "SELECT mag FROM detections WHERE source_id = :source_id",
        {"source_id": source_id},
    )


def log_the_position(ra, dec):
    # An f-string that is not a request target. The rule is about what reaches
    # the archive, not about string building in general.
    # ok: archive-query-built-by-concatenation
    return f"resolved to ra={ra} dec={dec}"
