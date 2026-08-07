---
name: Survey adapter
about: Add or change an adapter for one survey archive.
title: 'Adapter: '
labels: enhancement
assignees: ''
---

Scope:

<!--
The adapter module, its recorded responses and its tests, space separated, on
the line above and at column zero.

An adapter owes a fixed set of things, and they are the sections below. This
template exists because that set is always the same and is always what a
half-finished adapter is missing. Delete every comment block as you fill a
section in.
-->

<!--
Which survey, and what its photometry is of. A survey that changed filter
partway through its own history is two photometric systems wearing one name,
and this is where that is said rather than discovered later.
-->

## The data release

<!--
The release identifier this adapter reads, and the command that lists what
releases the archive currently serves, with its output. The identifier lives in
configuration rather than in code, and it travels into the cache key and into
the artefact's provenance header.

A release bump is its own issue, with a coefficient review and a validation-set
run before and after.
-->

## The endpoint and the query

<!--
The service, the protocol it speaks, the query this adapter sends, and what the
archive returns. Name the limits the service applies: row caps, rate limits, an
account, anything that makes a query fail on a fresh machine and succeed on
yours.
-->

## The recorded response

<!--
The path of the recorded response this adapter is tested against, and the
command and date that fetched it. The gating suite runs against the recording
and never against the network, so an adapter with no recording has no test.
-->

## The transformation into the reference system

<!--
The route from this survey's bands into the reference system, the coefficients
and where they come from, and the colour the colour term is evaluated at. Where
a coefficient is taken from a paper rather than measured here, say so and cite
it.
-->

## Done when

<!--
Include the per-survey residual on the validation set, with the command that
produced it, because an adapter that fetches and transforms without a residual
is an adapter nobody can tell is wrong.
-->

-
-
