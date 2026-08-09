#!/usr/bin/env bash
#
# Enforce the invariants that can be decided by searching the tree.
#
# Several rules in this project are sentences in documents, and a sentence is an
# explanation of a rule rather than a rule. Where an invariant can be decided by
# a search, the search is what decides it, and this script is that search.
#
# Run it with no arguments, from anywhere inside the checkout:
#
#     bash scripts/invariants.sh
#
# The workflow runs exactly this command. There is no second spelling.
#
# Three things this script refuses to do quietly.
#
# It prints EVERY entry in the table with its own verdict, so a run that covered
# less than the table cannot be read as one that covered it and found nothing.
#
# It distinguishes "no subjects" from "pass". An entry whose scope holds no
# tracked file has refused nothing, and reporting that as a pass is how an empty
# gate reads as a clean one. Those entries are counted separately in the summary.
#
# It fails closed on a scanner error. `git grep` exits 0 on a match, 1 on no
# match, and 2 or above when it could not do its job. A broken scanner is not a
# clean tree, so anything above 1 ends the run non-zero.
#
# What it cannot do, and this is not a defect to be fixed here.
#
# A SEARCH READS TEXT AND NOT CODE. A pattern matches a comment, a docstring and
# a string literal exactly as it matches a call, so an entry can fail on a file
# that only mentions the thing it forbids. That was measured rather than
# supposed: the neighbour fixture written for the default-suite entry named the
# forbidden module in its own docstring and the entry refused it. Refusing a
# mention is the honest behaviour for a searcher and a false positive for a
# reader, and the repair is to reword the prose rather than to weaken the
# pattern. Anything that could tell a call from a mention would be a parser, and
# a parser is a different means with a different argument behind it.
#
# EACH PATTERN CATCHES THE SPELLING IT NAMES AND NO OTHER. A rule going quiet
# because the code moved to a spelling it does not know is the failure mode of
# every entry below, and nothing here detects it.

set -uo pipefail

cd "$(git rev-parse --show-toplevel)" || {
    printf 'invariants: not inside a git checkout\n' >&2
    exit 2
}

# One scratch file, reused. Every search writes here and is read back from here
# with a shell loop, rather than being captured through a pipeline into `sed` or
# `wc`. That keeps the process count to one per entry: everything else is done by
# the shell itself. `< /dev/null` on each search is there so nothing can block
# reading a standard input it was never given.
scratch=$(mktemp) || exit 2
trap 'rm -f "$scratch"' EXIT

failed=0
errored=0
empty=0
checked=0

# refuse <id> <prevents> <pattern> <pathspec>...
#
# The pattern must not match any tracked file in the scope. The scope is a git
# pathspec list, so an exclusion is written as :(exclude)<path> and needs no
# second mechanism.
refuse() {
    local id="$1" prevents="$2" pattern="$3"
    shift 3

    local subjects rc=0 line
    git ls-files -- "$@" > "$scratch" 2>&1 < /dev/null
    subjects=0
    while IFS= read -r line; do
        subjects=$((subjects + 1))
    done < "$scratch"

    printf '%s\n' "--------------------------------------------------------------"
    if [ "$subjects" -eq 0 ]; then
        empty=$((empty + 1))
        printf '[ no subjects ] %s\n' "$id"
        printf '                prevents: %s\n' "$prevents"
        printf '                scope:    %s (0 tracked files)\n' "$*"
        printf '                pattern:  %s\n' "$pattern"
        printf '                NOTHING WAS SEARCHED. This entry refused nothing.\n'
        return
    fi

    checked=$((checked + 1))

    git grep -nIP -- "$pattern" -- "$@" > "$scratch" 2>&1 < /dev/null || rc=$?

    case "$rc" in
        1)
            printf '[ pass        ] %s\n' "$id"
            printf '                prevents: %s\n' "$prevents"
            printf '                scope:    %s (%s tracked files)\n' "$*" "$subjects"
            printf '                pattern:  %s\n' "$pattern"
            ;;
        0)
            failed=$((failed + 1))
            printf '[ FAIL        ] %s\n' "$id"
            printf '                prevents: %s\n' "$prevents"
            printf '                scope:    %s (%s tracked files)\n' "$*" "$subjects"
            printf '                pattern:  %s\n' "$pattern"
            while IFS= read -r line; do
                printf '                  %s\n' "$line"
            done < "$scratch"
            ;;
        *)
            errored=$((errored + 1))
            printf '[ SCANNER ERR ] %s\n' "$id"
            printf '                git grep exited %s. Failing closed rather than\n' "$rc"
            printf '                reading a broken scanner as a clean tree.\n'
            while IFS= read -r line; do
                printf '                  %s\n' "$line"
            done < "$scratch"
            ;;
    esac
}

# pairs <id> <prevents> <scope-dir> <manifest-suffix>
#
# A recording and its manifest exist as a pair, and the entry reads both ways.
# Every file in the scope that is not itself a manifest has a manifest beside it,
# named by appending the suffix to the whole file name, and every manifest has
# the file it is named after. Appending rather than replacing the extension, so a
# recording and its manifest sort together and a recording with two extensions
# cannot collide with another recording's manifest.
#
# THE SECOND DIRECTION IS WHAT NAMES THE MISTAKE. Replacing the extension instead
# of appending it is the one-character version of getting this wrong, and it
# breaks both directions at once: the recording has no manifest beside it, and
# the manifest that was written points at a name nothing produced. Reading only
# the first direction reports that a recording is undocumented and never says
# that the documentation is sitting one filename away.
#
# IT READS THE INDEX FOR THE SUBJECT AND THE WORKING TREE FOR THE PARTNER.
# `git ls-files` supplies the files this entry judges, and the partner is looked
# for with a test on the filesystem, so a partner present in the checkout and
# never added satisfies this entry here and is absent for every other reader.
# That bound is older than the second direction and the second direction inherits
# it rather than adding it.
pairs() {
    local id="$1" prevents="$2" scope="$3" suffix="$4"

    local subjects f
    git ls-files -- "$scope" > "$scratch" 2>&1 < /dev/null
    subjects=0
    while IFS= read -r f; do
        subjects=$((subjects + 1))
    done < "$scratch"

    printf '%s\n' "--------------------------------------------------------------"
    if [ "$subjects" -eq 0 ]; then
        empty=$((empty + 1))
        printf '[ no subjects ] %s\n' "$id"
        printf '                prevents: %s\n' "$prevents"
        printf '                scope:    %s (0 tracked files)\n' "$scope"
        printf '                rule:     every file has <name>%s beside it, and\n' "$suffix"
        printf '                          every <name>%s has its file\n' "$suffix"
        printf '                NOTHING WAS SEARCHED. This entry refused nothing.\n'
        return
    fi

    checked=$((checked + 1))

    local unpaired=""
    while IFS= read -r f; do
        case "$f" in
            *"$suffix")
                if [ ! -f "${f%"$suffix"}" ]; then
                    unpaired="${unpaired}no recording for ${f}"$'\n'
                fi
                continue
                ;;
        esac
        if [ ! -f "${f}${suffix}" ]; then
            unpaired="${unpaired}no manifest for ${f}"$'\n'
        fi
    done < "$scratch"

    if [ -z "$unpaired" ]; then
        printf '[ pass        ] %s\n' "$id"
        printf '                prevents: %s\n' "$prevents"
        printf '                scope:    %s (%s tracked files)\n' "$scope" "$subjects"
        printf '                rule:     every file has <name>%s beside it, and\n' "$suffix"
        printf '                          every <name>%s has its file\n' "$suffix"
    else
        failed=$((failed + 1))
        printf '[ FAIL        ] %s\n' "$id"
        printf '                prevents: %s\n' "$prevents"
        printf '                scope:    %s (%s tracked files)\n' "$scope" "$subjects"
        printf '                rule:     every file has <name>%s beside it, and\n' "$suffix"
        printf '                          every <name>%s has its file\n' "$suffix"
        printf '%s' "$unpaired" > "$scratch"
        while IFS= read -r f; do
            printf '                  %s\n' "$f"
        done < "$scratch"
    fi
}

# crossref <id> <prevents> <document> <authority>
#
# Every artefact key named in backticks on a line of <document> beginning
# `Signature: ` also appears, in backticks, somewhere in <authority>.
#
# Three bounds, and they belong here rather than only in the document, because a
# reader who trusts this entry is trusting these.
#
# IT READS THE `Signature: ` LINE AND NOTHING ELSE. A key named in the prose of an
# entry is not checked. That is why a line ending in a comma is refused: a list
# wrapped onto a second line puts half its keys where nothing looks, and the
# wrapped half is exactly the half a writer stops thinking about.
#
# IT DECIDES THAT A NAME EXISTS AND NEVER WHAT IT MEANS. A key spelled correctly
# and pointing at the wrong quantity passes, and the review is where that is
# caught.
#
# THE AUTHORITY IS A DOCUMENT BECAUSE THE ARTEFACT IS NOT CODE YET. Once the
# writer exists, the authority is the writer, and an entry still reading a
# decision record would agree with what was decided while disagreeing with what
# the tool emits.
crossref() {
    local id="$1" prevents="$2" document="$3" authority="$4"

    local subjects line
    git ls-files -- "$document" "$authority" > "$scratch" 2>&1 < /dev/null
    subjects=0
    while IFS= read -r line; do
        subjects=$((subjects + 1))
    done < "$scratch"

    printf '%s\n' "--------------------------------------------------------------"
    if [ "$subjects" -ne 2 ]; then
        empty=$((empty + 1))
        printf '[ no subjects ] %s\n' "$id"
        printf '                prevents: %s\n' "$prevents"
        printf '                scope:    %s %s (%s of 2 tracked)\n' \
            "$document" "$authority" "$subjects"
        printf '                rule:     every `key` on a Signature: line of the first\n'
        printf '                          file is named in the second\n'
        printf '                NOTHING WAS SEARCHED. This entry refused nothing.\n'
        return
    fi

    checked=$((checked + 1))

    local authority_text="" rest token missing="" wrapped="" names=0
    while IFS= read -r line; do
        authority_text="${authority_text}${line}"$'\n'
    done < "$authority"

    while IFS= read -r line; do
        case "$line" in
            'Signature: '*) ;;
            *) continue ;;
        esac
        case "$line" in
            *,) wrapped="${wrapped}${line}"$'\n' ;;
        esac
        rest="${line#Signature: }"
        while :; do
            case "$rest" in
                *'`'*) ;;
                *) break ;;
            esac
            rest="${rest#*\`}"
            case "$rest" in
                *'`'*) ;;
                *) break ;;
            esac
            token="${rest%%\`*}"
            rest="${rest#*\`}"
            [ -n "$token" ] || continue
            names=$((names + 1))
            case "$authority_text" in
                *'`'"$token"'`'*) ;;
                *) missing="${missing}${token}"$'\n' ;;
            esac
        done
    done < "$document"

    if [ -z "$missing" ] && [ -z "$wrapped" ]; then
        printf '[ pass        ] %s\n' "$id"
        printf '                prevents: %s\n' "$prevents"
        printf '                scope:    %s %s (2 tracked files)\n' "$document" "$authority"
        printf '                rule:     every `key` on a Signature: line of the first\n'
        printf '                          file is named in the second (%s checked)\n' "$names"
        return
    fi

    failed=$((failed + 1))
    printf '[ FAIL        ] %s\n' "$id"
    printf '                prevents: %s\n' "$prevents"
    printf '                scope:    %s %s (2 tracked files)\n' "$document" "$authority"
    printf '                rule:     every `key` on a Signature: line of the first\n'
    printf '                          file is named in the second (%s checked)\n' "$names"
    if [ -n "$missing" ]; then
        printf '%s' "$missing" > "$scratch"
        while IFS= read -r token; do
            printf '                  %s is named in %s and not in %s\n' \
                "$token" "$document" "$authority"
        done < "$scratch"
    fi
    if [ -n "$wrapped" ]; then
        printf '%s' "$wrapped" > "$scratch"
        while IFS= read -r line; do
            printf '                  line ends in a comma, so its list continues where\n'
            printf '                  nothing reads it: %s\n' "$line"
        done < "$scratch"
    fi
}

printf 'Greppable invariants\n'
printf 'Tree at %s\n' "$(git rev-parse HEAD)"

refuse \
    'no-network-outside-the-fetch-layer' \
    'a transformation reaching an archive, so a calibration step can silently depend on the network' \
    '\b(requests\.(get|post|put|patch|delete|head|options|request|Session)|urllib\.request|urlopen|httpx\.|aiohttp\.|socket\.socket|pyvo\.|astroquery)' \
    'src/sternwarte' ':(exclude)src/sternwarte/fetch'

refuse \
    'no-environment-read-outside-the-command-line' \
    'a library reaching into the environment for a token and carrying it into a repr, a log line or a cached object' \
    '\b(os\.environ|os\.getenv|[^.\w]getenv\()' \
    'src/sternwarte' ':(exclude)src/sternwarte/cli' ':(exclude)src/sternwarte/cli.py'

refuse \
    'no-listener-no-privilege-no-certificate-store-in-the-default-suite' \
    'a default test that needs a port, an elevation or a machine certificate store, which passes here and fails on somebody else - or worse, raises a consent prompt on their machine' \
    '\.bind\(|\.listen\(|socketserver|http\.server|SimpleHTTPRequestHandler|\bsudo\b|runas|ShellExecute|dev-certs|X509Store|CertOpenStore|update-ca-certificates' \
    'tests/unit'

refuse \
    'no-credential-shaped-string-in-a-recording' \
    'a token committed inside a recorded archive response, where nobody looks because the file is data' \
    '(?i)(api[_-]?key|client[_-]?secret|passwd|password|token)["'"'"'\s]*[:=]["'"'"'\s]*[A-Za-z0-9._~+/-]{12,}|(?i)bearer\s+[A-Za-z0-9._~+/-]{12,}' \
    'tests/responses'

refuse \
    'no-standard-output-from-the-library' \
    'a library that prints, which corrupts a caller piping the artefact and cannot be silenced by a caller who never asked for output' \
    '(^|[^.\w])p?print\(|sys\.(stdout|stderr)\.write\(' \
    'src/sternwarte' ':(exclude)src/sternwarte/cli' ':(exclude)src/sternwarte/cli.py'

refuse \
    'no-bare-except-and-no-assert-in-library-code' \
    'a swallowed error that hides a wrong number, and a check that vanishes under python -O so the guard is absent exactly where the deployment is tuned' \
    '^\s*except\s*:|^\s*assert\s' \
    'src/sternwarte'

refuse \
    'no-magnitude-compared-to-a-float-literal-for-equality' \
    'an equality test on a floating point quantity, which is false for two values that differ in the last bit and true for nothing a measurement produces' \
    '(?i)\b\w*(mag|magnitude|flux|colour|color|zp|zeropoint|offset|residual)\w*\s*[!=]=\s*-?\d+\.\d+' \
    'src/sternwarte'

pairs \
    'recording-and-manifest-exist-as-a-pair' \
    'a recording whose survey, release, query and record date are unknown, which is a recording nobody can tell is stale, and a manifest whose recording is absent, which is a description of bytes no test can read' \
    'tests/responses' \
    '.manifest.json'

crossref \
    'failure-mode-signature-names-a-real-artefact-field' \
    'a catalogue entry sending a reader to an artefact field that does not exist, which reads as a detection route and is a dead end' \
    'docs/failure-modes.md' \
    'docs/decisions/0007-output-artefact.md'

printf '%s\n' "--------------------------------------------------------------"
printf 'Summary: %s checked, %s with no subjects, %s failed, %s scanner errors\n' \
    "$checked" "$empty" "$failed" "$errored"

if [ "$errored" -ne 0 ]; then
    printf 'Refusing: the scanner could not do its job on at least one entry.\n'
    exit 2
fi

if [ "$failed" -ne 0 ]; then
    printf 'Refusing: at least one invariant is violated.\n'
    exit 1
fi

if [ "$empty" -ne 0 ]; then
    printf 'Passing, and %s of the entries above searched nothing at all.\n' "$empty"
    printf 'That is a green run over an absent subject, not a clean tree.\n'
fi

exit 0
