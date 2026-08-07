# Governance

## Who holds access

One maintainer, who owns the repository and is the only account with write
access to it. Everything else is a fork and a pull request. Derived rather than
remembered:

    gh api repos/iderex/sternwarte/collaborators --jq '.[] | "\(.login) \(.permissions | to_entries | map(select(.value)) | map(.key) | join(","))"'
    iderex admin,maintain,pull,push,triage

    gh api repos/iderex/sternwarte --jq '.owner.login + " " + .owner.type'
    iderex User

The first of those two commands needs push access on this repository to answer,
so a reader without it gets a 404 rather than the list. The second answers for
anybody, and it is the one that carries the load here.

The repository is owned by a personal account and not by an organisation, so
there is no team, no owner group and no second administrator. That is the single
most important fact in this document and everything below follows from it.

## How a decision is made

A decision that shapes the tool is written down before the code that depends on
it, under `docs/decisions/`. `docs/decisions/README.md` says what an entry
contains and how one is superseded. An entry names the alternatives that were
rejected and why, because the alternative somebody is about to propose again is
usually already in it.

Anybody may argue with a decision, on the issue tracker, at any time. The way to
change one is a new entry that names the old one and gives a reason, not an edit
to the old entry. What was believed on the day a choice was made is the part a
later reader needs.

Where a decision is the maintainer's alone, it is collected in one place so that
it is not answered by whoever reaches it first, and work that depends on an
unanswered entry says so rather than proceeding on a guess. Issue #2 is that
place.

The maintainer decides. This is not a consensus project and describing it as one
would be a description of something else.

## What a change goes through

Every change is an issue, then a branch, then a pull request.
[`CONTRIBUTING.md`](CONTRIBUTING.md) has the mechanics and the gate.

**No second reader is guaranteed.** With one maintainer, a change written by the
maintainer is read by its own author and by nobody else before it lands. This is
a real weakness and it is not softened here. What stands in place of a review is
the pull request body: the commands that were run, their output, the guard shown
biting, and what is not covered. A body that asserts without commands is what a
missing reviewer looks like in this project, and it is the thing to object to.

Outside contributions are read by the maintainer before they land, so a
contribution from anybody else does get a second reader. The gap is one
directional.

## Adding a maintainer

There is no process, because there is nobody to run it. If somebody contributes
enough that the question arises, the answer is a decision entry naming them, the
scope of their access, and what changes about the paragraph above. Until then this
section is a statement that the question is open rather than a procedure.

## If the maintainer stops

This is the case a single-maintainer project owes an answer to, because it is the
likely one and not the exotic one.

The repository is public and everything needed to continue it is in the tree: the
decisions with their reasons, the gate as workflow files, and the issue tracker
as the plan. A fork carries all of it except the tracker.

**What a fork cannot carry today is the right to use the code.** There is no
license file, so the default is exclusive copyright:

    gh api repos/iderex/sternwarte --jq '.license | tostring'
    null

Until issue #2, entry 1 is answered, nobody may legally continue this work from a
fork, whatever state the maintainer is in. That makes the license the single
point of failure of this section, and it is the reason that entry is named as the
one that is answered first.

Once a license exists, continuation needs no permission and no handover: fork it,
and say in the fork's README that it is a fork and from where. The maintainer
does not undertake to transfer the repository, the name or the distribution
channel, and a plan that depended on that would be a plan depending on somebody
being available, which is the condition this section exists for.

## The limits of this document

Nothing here is enforced by a machine. No check in this repository reads it, and
the ruleset on `main` refuses a direct push and a deletion and nothing else,
which [`CONTRIBUTING.md`](CONTRIBUTING.md) shows with the command that reads it.
This document describes how the project is run. It is not what holds it.
