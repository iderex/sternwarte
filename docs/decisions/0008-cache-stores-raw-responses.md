# 0008 The cache stores raw archive responses, keyed by data release

Reducing the same target twice must not query the archives twice, and a result
that cannot be rebuilt from stored bytes is not reproducible. What the cache
stores, and what its key is, decides both.

## The decision

Every archive response is written to an on-disk cache exactly as it arrived,
byte for byte, before any parsing. The key is the survey, the data release
identifier, the resolved position, the search radius, and the full set of query
parameters.

The cache lives under a directory the operator controls. Its default is the
platform user cache location. It is never uploaded anywhere.

A re-reduction reads the cache. Re-fetching is an explicit request by the
operator, never an automatic consequence of a code change, a version bump or a
cache entry reaching some age. The request has one shape at each layer, an
option on the command and a parameter on the library entry point, and neither
defaults to on. A re-fetch does not overwrite: the newly arrived bytes are
stored beside the entry they supersede and carry the time they arrived, and a
reduction reads the most recent, so the bytes behind an earlier result survive
the run that replaced them.

Nothing evicts automatically. An entry, once written, is never rewritten or
removed by this tool: the release identifier is part of the key, so a newer
release lands beside the old entry instead of replacing it, and there is no
state in which an entry is stale for its own key. The operator removes entries
by deleting them, and the tool reports the size of the cache when asked rather
than acting on it.

## Why

Storing the raw bytes rather than the parsed table means a parser bug is
repairable without going back to the archive, and a parser change can be tested
against the real responses from the day they arrived. Storing the parsed form
loses whatever the parser did not yet know to keep, and the things a parser does
not know to keep are exactly the things that turn out to matter.

Keying on the data release is what makes a release change visible. A cache keyed
only on position would silently mix two releases inside one series, which is the
same class of error as mixing two photometric systems, and it would do it
without any line in the artefact recording that it happened.

Archive courtesy is the other half. These services are shared, several of them
are rate limited, and a tool that re-queries on every run is a tool that gets
blocked, along with everybody else at the same institution.

No automatic eviction follows from the same reasoning as the raw bytes. An
eviction policy deletes evidence, and it deletes it on a rule that has nothing
to do with whether the evidence is still needed. The cache is the only copy of
what an archive returned on a particular day, since the archive itself will
serve different bytes later and record no diff, so a size cap or an age limit
would quietly convert a reproducible reduction into one that has to be re-fetched
to be repeated.

## The cache never leaves the host

The cache is written to the operator's own disk and read from it. Nothing in
this tool uploads a cache entry, mirrors one, or reports what is in one to
anywhere off the machine it was written on. What an operator looked at, and
when, is a record of that operator's research, and it stays where it was made.

The general statement of that boundary, covering everything this tool does and
not just the cache, is owed by issue #64 and is not written in this repository
yet. `NOTICE.md` is what the repository carries today, and it is about lawful
use rather than about where data goes. Until #64 lands, the sentence above is
the whole of the written boundary for the cache, and no other part of the tree
states one.

## Rejected

- No cache. Every run pays full network cost, the archives absorb it, and the
  same query returns different bytes on different days with nothing recording
  the change.
- Caching the parsed table. Cheaper on disk and it destroys the evidence. Every
  later parser fix then needs the network to be tested against reality.
- A shared or remote cache. It puts what an operator looked at, and when, on
  somebody else's machine. That crosses the boundary described below and is not
  done by default.
- Time-based expiry. An expiry that refetches a response is an automatic,
  unrecorded change of the input data, and it fires on the calendar rather than
  on anything about the data.
- A size cap with least-recently-used eviction. It deletes the oldest evidence
  first, which is the evidence for the longest baseline, and it does it
  silently.

## What it costs

Disk, without a bound. The comparison-star ensemble means the cache holds field
photometry rather than just the target's epochs, and nothing removes an entry,
so a busy operator's cache grows monotonically. That cost is deliberate and it
is transferred to the operator: the tool reports the size, and deleting is a
decision a person makes with the reproducibility consequence in front of them.

Correctness of the key is now load-bearing. Two queries that differ in a
parameter the key does not carry would collide and return each other's bytes,
which is a wrong answer rather than a slow one. That is the risk this design
concentrates, and it is why the key names the full parameter set rather than a
summary of it.

Raw bytes also mean the cache holds whatever the archive sent, including error
pages that arrived with a success status. Detecting those is the parser's
problem and not the cache's, and the cache will faithfully store and replay one.
