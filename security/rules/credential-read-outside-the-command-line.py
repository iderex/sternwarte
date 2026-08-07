# Fixtures for credential-read-outside-the-command-line.
#
# The positive cases reach into the environment for a credential. The negative
# neighbours take the credential as an argument, which is where entry 0012 puts
# it, and read a non-credential environment value, which the rule is not about.

import os
from os import environ, getenv


def build_session_from_environment():
    # ruleid: credential-read-outside-the-command-line
    token = os.environ["SURVEY_API_TOKEN"]
    return token


def build_session_from_getenv():
    # ruleid: credential-read-outside-the-command-line
    return os.getenv("TWIN_TELESCOPE_PASSWORD", "")


def build_session_from_environ_get():
    # ruleid: credential-read-outside-the-command-line
    return os.environ.get("ARCHIVE_SECRET", None)


def build_session_from_bare_environ():
    # ruleid: credential-read-outside-the-command-line
    return environ["PORTAL_AUTH_HEADER"]


def build_session_from_bare_getenv():
    # ruleid: credential-read-outside-the-command-line
    return getenv("SURVEY_APIKEY", "")


def build_session_from_argument(token):
    # ok: credential-read-outside-the-command-line
    return {"Authorization": f"Bearer {token}"}


def read_the_cache_directory():
    # Not a credential. The rule is about what leaks, not about the environment.
    # ok: credential-read-outside-the-command-line
    return os.environ.get("STERNWARTE_CACHE_DIR", None)


def read_the_home_directory():
    # ok: credential-read-outside-the-command-line
    return os.getenv("HOME", "")
