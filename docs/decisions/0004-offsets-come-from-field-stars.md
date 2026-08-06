# 0004 Per-survey offsets are measured on field stars, never on the target

Seven surveys observe the same star in seven photometric systems, and joining
them means knowing the systematic offset between each system and the reference
one. How that offset is determined decides whether twenty-five years of baseline
can show a slow signal or quietly cannot. This is the decision the whole product
turns on.

## The decision

The zero-point offset and the colour term between a survey and the reference
system are determined from an ensemble of field stars in the same pointing as
the target, observed by both systems. They are never fitted on the target's own
epochs.

## Why

An offset fitted on the target is a free constant per survey, and a free
constant per survey absorbs exactly the slow variation the long baseline exists
to detect. A target that has brightened by 0.1 mag over twenty years and a
target with a 0.1 mag zero-point error between the old survey and the new one
produce the same data. A fit carrying a free constant per survey will always
prefer the flat explanation, because the flat explanation costs it nothing.

For part of this set the target-only fit is not merely weak. It is degenerate,
because two of the surveys never observed at the same time:

- The repeat imaging of the equatorial strip in SDSS Stripe 82 ends in 2007.
- The Pan-STARRS1 3pi survey begins in 2010.

No epoch pair spans that gap, so no epoch pair constrains the offset between
those two surveys, and every value of that offset fits the data equally well.
The fit does not fail in that case. It returns a number, and the number is
whatever the optimiser reached first.

Both epoch ranges above are a claim taken from the survey documentation, not a
measurement made in this repository, which holds no epochs today. What settles
them is the adapter for each survey: each one pins its data release, and the
range the pinned release actually serves is printed from the release rather than
quoted from here. If the ranges turn out to overlap after all, the degeneracy
argument weakens for that pair and the argument from the free constant above,
which does not depend on any gap, still stands on its own.

Field stars break both problems. They are measured in the same frames as the
target, so their offset is the same instrumental quantity rather than a
comparable one, and there are hundreds of them, so the offset is measured rather
than inferred. The target's residual then stays available as a diagnostic
instead of being consumed by the fit that was supposed to calibrate it.

## The failure modes, each with the guard it gets

Measuring the offset on field stars moves the risk onto the field stars, and it
creates exactly three ways to get a wrong answer that looks right.

- A crowded field, where the comparison stars are blended and their photometry
  is wrong in a correlated way. Correlated is the dangerous part: the errors do
  not average down with the size of the ensemble, so a bigger ensemble looks
  more confident and is not. The guard refuses to solve above a local density
  threshold and says so in the output rather than returning a quiet number.
- A target whose colour lies outside the range spanned by the usable comparison
  stars, which makes the colour term an extrapolation rather than an
  interpolation. The guard reports the extrapolation distance and marks the
  survey, rather than dropping it quietly, because a survey dropped without a
  reason looks the same as a survey that had no data.
- A comparison star that is itself variable, which puts its variability into the
  offset. The guard runs a per-star consistency test, excludes the stars that
  fail it, and reports how many were excluded, because an ensemble that lost
  most of its members is a different measurement from one that lost two.

Each guard is built under its own issue in the cross-calibration milestone, and
each of those issues names this entry.

## Rejected

- Literature transformation coefficients alone. They are averages over a survey
  footprint, and the quantity that matters is the offset at this position, with
  this reference catalogue version. A footprint average is the right answer to a
  different question.
- Averaging the surveys onto a common mean level. This is the cheapest wrong
  answer available, and it does not merely lose the slow signal, it erases it
  while producing a series that looks well calibrated.
- Fitting the offsets and a target model jointly, under a prior that keeps the
  offsets small. The prior decides the answer, and the prior is a guess. It also
  makes the result depend on a choice that no reader of the artefact can see.
- Using the target's own epochs where the surveys do overlap, and field stars
  only where they do not. Two different calibration methods inside one series,
  with a discontinuity wherever they meet, and the reader cannot tell which
  produced any given epoch.

## What it costs

The tool now needs comparison-star photometry from every survey, not just the
target's, so every adapter has to be able to query a field rather than a
position, and the cache holds far more than the target's own epochs. That is a
larger fetch, a larger cache and a slower first run.

It also means the tool can refuse. A field too crowded to give a clean ensemble
produces no calibration for that survey, where the target-only fit would always
have produced something. That is the correct behaviour and it will be
experienced as the tool failing where a simpler one succeeded, which is a real
cost and is paid in explanation rather than in code.

Finally, the ensemble introduces its own uncertainty, and it has to be carried
rather than absorbed. The offset is now a measured quantity with an error bar,
and that error bar has to reach the artefact separately from the archive's own
reported errors, or the improvement in accuracy is spent on a number nobody can
audit.
