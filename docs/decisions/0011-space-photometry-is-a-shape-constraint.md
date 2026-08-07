# 0011 The wide-field space mission constrains shape, not the zero point

Six of the seven sources in the set are calibrated against sky catalogues and can
be tied to a common zero point. One of them, the wide-field space photometry
mission, is not comparable in that way. Treating it as if it were would put its
systematics into the joined series, and they would arrive in the form of a
zero-point term that looks like a measurement.

## The decision

Photometry from the wide-field space mission enters as a constraint on variation
within an observing sector, and is excluded from the joint zero-point solution
under the default configuration. It contributes no term to that solve.

The exclusion is visible in the per-survey report rather than implied by the
survey's absence from it. The block carries the role the source was used for and
the reason it was excluded, as `0009-uncertainties-are-reported-per-survey.md`
requires of every excluded source.

## Why

Three mechanisms, and each of them acts on the timescales a long baseline is
searching.

The background estimate is the first. The mission's pixels are large, so the flux
in an aperture contains a background contribution that has to be estimated and
removed, and an error in that estimate is an error in the magnitude that is
constant within a sector and different in the next one.

Scattered light from the Earth and the Moon is the second. It varies through each
orbit and through each sector, and the correction for it is imperfect in a way
that varies with where the target sits on the detector, which changes between
sectors because the pointing changes.

The detrending applied to remove instrumental drift is the third and the worst
for this purpose. It is designed to remove systematics on timescales of days and
longer, which is the same band a long-period variable occupies, so it removes
real signal along with the artefacts. A series calibrated against detrended
photometry inherits a zero point that was set partly by what the detrending
removed.

The transformation is the fourth reason and it compounds the first three. The
mission's band is very broad and red, spanning most of the reference system's
three reddest bands at once, so the step into the hub is strongly colour
dependent and carries transformation uncertainty larger than any other entry's,
as `0003-reference-photometric-system.md` records. So the source with the least
trustworthy zero point is also the one whose transformation adds the most
uncertainty, and the joint solve would be weighting it on a formal error that
does not describe either problem.

What the mission is genuinely good at is short-timescale shape at high cadence,
and that is a real contribution rather than a consolation. Eclipse profiles,
pulsation shape, and the timing of a sharp feature are all measurable from it at
a precision no ground-based survey in this set reaches, and none of those
quantities depends on the absolute zero point. Keeping it in that role uses its
strength and refuses its weakness, which is the whole of this decision.

## Rejected

- Including it in the zero-point solution with a large uncertainty. This is the
  proposal that sounds like caution and is not. A large uncertainty on a
  systematic that is not random does not make the systematic harmless. It makes
  it invisible, because the fit absorbs the bias and reports an error bar that
  covers it, and the resulting offset is wrong by less than its stated
  uncertainty while being wrong in a fixed direction.
- Excluding it entirely. Throws away the best short-timescale coverage in the
  set, over a large part of the sky, to avoid a problem that only exists in one
  use of the data. The failure was in the use, not in the source.
- Detrending harder and then including it. Detrending is what removes the signal.
  A stronger version removes more of it, and the zero point that comes out is
  better behaved for exactly the reason that makes it useless.
- Including it for targets where the sector coverage is long enough that the
  detrending is arguably safe. A rule with a threshold nobody can defend, applied
  per target, produces a series whose calibration depends on how much coverage
  happened to exist, which is the least reproducible property available.

## What it costs

The default is a default and not a law. An operator who has a reason to include
the source in the solve can configure it, and the artefact then records that the
default was overridden, so the resulting series says what was done rather than
looking like every other run. Making it configurable is what keeps this entry
from being a rule that gets worked around by editing the source.

The exclusion also means the joined series has a gap in its zero-point coverage
exactly where this mission dominates the epoch count, which for some targets is
most of the recent baseline. The series is shorter in effective calibrated
coverage than the raw epoch count suggests, and a reader counting epochs will
overestimate what was calibrated. The per-survey block is where that is legible,
and this entry is one of the reasons an excluded survey is reported rather than
omitted.

Nothing here is enforced by a machine yet. The property that the source
contributes no term to the joint solve is a property of code that does not exist,
and until the solve and its test exist, this file is an explanation of a rule
rather than the rule. What would settle it is a test asserting that the joint
solve's term list omits this source under the default configuration, and that
test is owed by the issue this entry was written for.
