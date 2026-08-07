# Temporary. This file exists to show the community rule set biting on this
# tree, and it is removed again in this same branch before the pull request is
# merged. It is at the root rather than under security/rules/, because that
# directory is excluded from the scan.
#
# The pair is one keyword argument apart, which is the shape of the mistake
# somebody actually makes: a certificate error during development, one argument
# added to get past it, and the argument left behind.
#
# The community rule disabled-cert-validation matches
#
#     requests.get(..., verify=False, ...)
#
# and nothing in security/rules/ reaches it. archive-query-built-by-concatenation
# wants a format string, an f-string or a concatenation as the first argument and
# this is a name. archive-response-deserialised-executably lists deserialisers.
# credential-read-outside-the-command-line reads the environment.
# path-from-archive-response-not-resolved is a taint rule from a response field
# to a filesystem sink. None of the four matches either line below.

import requests


def fetch_epochs(url):
    return requests.get(url, timeout=30, verify=False)


def fetch_epochs_verified(url):
    return requests.get(url, timeout=30)
