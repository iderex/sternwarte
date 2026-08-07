# Fixtures for path-from-archive-response-not-resolved.
#
# The positive cases take a field out of a parsed archive response and hand it
# straight to something that opens a path. The negative neighbours are the same
# code with the join resolved against the cache base first, which is the one
# edit that separates them.

import pathlib
from pathlib import Path


def resolve_under(base, candidate):
    """Join and refuse anything that leaves the base. The sanitizer the rule names."""
    resolved = (Path(base) / candidate).resolve()
    if not resolved.is_relative_to(Path(base).resolve()):
        raise ValueError("path escapes the cache base")
    return resolved


def write_cutout_from_response(response, base):
    name = response["cutout_filename"]
    # ruleid: path-from-archive-response-not-resolved
    with open(name, "wb") as handle:
        handle.write(b"")


def open_product_from_record(record):
    # ruleid: path-from-archive-response-not-resolved
    return Path(record.get("product_path"))


def open_product_from_row(row):
    # ruleid: path-from-archive-response-not-resolved
    return pathlib.Path(row["local_file"])


def write_cutout_resolved(response, base):
    target = resolve_under(base, response["cutout_filename"])
    # ok: path-from-archive-response-not-resolved
    with open(target, "wb") as handle:
        handle.write(b"")


def open_product_resolved(record, base):
    # ok: path-from-archive-response-not-resolved
    return Path(resolve_under(base, record.get("product_path")))


def open_configured_path(settings):
    # A path from the operator's own configuration, not from an archive. The
    # rule is about what a service this project does not control can steer.
    # ok: path-from-archive-response-not-resolved
    return Path(settings.cache_directory)
