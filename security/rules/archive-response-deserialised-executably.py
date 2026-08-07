# Fixtures for archive-response-deserialised-executably.
#
# The positive cases read stored archive bytes back with a reader that can
# construct arbitrary objects. The negative neighbours read the same bytes with
# a reader that cannot. The yaml pair is one keyword argument apart, which is
# the mistake somebody actually makes.

import json
import marshal
import pickle

import yaml


def load_cached_response_by_pickle(path):
    with open(path, "rb") as handle:
        # ruleid: archive-response-deserialised-executably
        return pickle.load(handle)


def load_cached_response_by_pickles(raw):
    # ruleid: archive-response-deserialised-executably
    return pickle.loads(raw)


def load_cached_response_by_marshal(raw):
    # ruleid: archive-response-deserialised-executably
    return marshal.loads(raw)


def load_manifest_unsafely(raw):
    # ruleid: archive-response-deserialised-executably
    return yaml.load(raw)


def load_coefficients_by_eval(raw):
    # ruleid: archive-response-deserialised-executably
    return eval(raw)


def load_cached_response_by_json(path):
    with open(path, "rb") as handle:
        # ok: archive-response-deserialised-executably
        return json.load(handle)


def load_manifest_safely(raw):
    # ok: archive-response-deserialised-executably
    return yaml.safe_load(raw)


def load_manifest_with_the_safe_loader(raw):
    # ok: archive-response-deserialised-executably
    return yaml.load(raw, Loader=yaml.SafeLoader)
