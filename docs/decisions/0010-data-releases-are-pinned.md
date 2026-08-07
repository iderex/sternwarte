# 0010 Data releases are pinned, and a release bump is a declared change

Survey data releases move, and they move in ways that change photometry. A tool
that reads "the current release" produces a different answer next year with
nothing in its output to say why, which is the failure a twenty-five year
baseline can least afford.

## The decision

Every adapter names the data release it reads. The name lives in configuration
rather than in code, and the release identifier travels into the cache key and
into the artefact's provenance header.

Moving to a newer release is a deliberate change with its own issue, its own
recorded review of the transformation coefficients where those change, and a
recorded comparison of the validation set before and after.

## Why

Reproducibility is the whole reason the provenance header exists, and a release
identifier is the smallest thing that makes two runs comparable. Without it, two
artefacts from the same position and the same code are not comparable and
nothing in either says so.

A release that changes a reference catalogue changes the zero point, and the
zero point is the quantity this project is built to measure. A silent release
bump therefore moves the science, and it moves it in the one direction that is
indistinguishable from a result: a step in the calibrated series at the date the
operator happened to upgrade.

Putting the identifier in configuration rather than in code is what keeps the
bump from happening as a side effect. In code, a release is bumped by whoever is
editing the adapter for an unrelated reason, in a diff about something else,
reviewed by somebody looking at something else.

One case is scheduled rather than hypothetical. The next Gaia release is
expected around the end of 2026, and it is expected to carry epoch photometry
for very much more sources than the current release, which publishes it for a
subset only. That takes the Gaia adapter from a narrow special case to a broad
one, and it changes the colour source that every other survey's transformation
depends on. Building the adapter so that a release is a configuration value
makes that arrival a configuration change plus a coefficient review, rather than
a redesign under time pressure. The date is an expectation published outside
this repository, not a commitment, and nothing here depends on it being right.

## What a release bump owes

- An issue of its own, naming the survey, the release being left and the release
  being taken.
- A review of the transformation coefficients for that survey, recorded, because
  a release that changes a reference catalogue can change them.
- A run of the validation set before and after, with the difference recorded.
  The comparison is the evidence that the bump did what was expected and nothing
  else, and a bump that moves a validation target without an explanation is a
  finding rather than a formality.

## Rejected

- Always the latest release. Non-reproducible by construction, and it hides the
  exact change that matters most, since the day the archive publishes is the day
  the answer moves.
- Pinning in code. It makes a release bump a code change inside the adapter,
  which invites the bump to ride along with unrelated work.
- Supporting exactly one release, forever. A release eventually stops being
  served, and the tool would then be unable to reproduce its own past results at
  the moment it most needs to.
- Recording the release in the artefact but not in the cache key. The artefact
  would then be able to name a release that is not what its bytes came from,
  which is worse than not naming one.

## What it costs

Configuration surface, on every adapter, for a value most operators will never
change. It also means the default configuration ages: a shipped default pins a
release that will eventually be superseded, and keeping those defaults current
is recurring work with its own issue each time.

The before-and-after comparison makes a bump expensive, and it is meant to. The
cost lands on whoever wants the newer data, which will sometimes be the person
who needs it most urgently, and there is no shortcut available to them that does
not defeat the point.

Pinning also does not make a release immutable. An archive can revise a release
in place, and this decision would not detect that. What it detects is a change
of release identifier, which is the common case and not the only one.
