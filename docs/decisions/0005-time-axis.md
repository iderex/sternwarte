# 0005 The time axis, and the conversion recorded per survey

The surveys deliver times in different systems. Some give a heliocentric Julian
date, some a modified Julian date at the observatory, one gives a barycentric
Julian date offset by a fixed constant, and the reference frames and the time
scales differ underneath those names. Joining columns that are all called "time"
is how an eclipse moves by minutes and a period derivative becomes a discovery.

## The decision

Every epoch is converted to a barycentric Julian date on the barycentric
dynamical time scale, written `BJD_TDB`. The conversion applied to each survey is
recorded in the output artefact. No native time column reaches the joined series,
and no epoch enters the join without a recorded conversion.

## Why

Three separate errors hide under the word "time", and each of them is larger
than the precision this tool is built to reach.

The geometric one is the largest. Light arrives at the solar system barycentre
and at a telescope at different moments, and the difference is bounded by the
light travel time across one astronomical unit:

    awk 'BEGIN{printf "%.6f s = %.5f min\n", 149597870700/299792458, 149597870700/299792458/60}'
    499.004784 s = 8.31675 min

using the IAU 2012 definition of the astronomical unit and the defined speed of
light. The actual correction varies with the target's position on the sky and
with the time of year, so it is not a constant that cancels between two epochs of
one survey, and it certainly does not cancel between two surveys observing at
different times of year. Over a long baseline that is a systematic, not a
rounding error, and it is the kind that looks like astrophysics.

The reference frame matters within that. A heliocentric date corrects to the
centre of the Sun and a barycentric date corrects to the barycentre of the solar
system, and the two differ because the Sun moves about the barycentre. The
difference reaches a few seconds and is periodic on the outer planets' orbital
periods, which is a signal shaped exactly like a slow drift in an eclipse time
(Eastman, Siegel and Agol 2010, PASP 122, 935).

The scale matters as much as the frame, and it is the part that is easiest to
lose. Coordinated universal time is not uniform: leap seconds are inserted into
it, so an interval measured across one is short by a second. Terrestrial time
runs ahead of international atomic time by a fixed 32.184 seconds, and atomic
time is ahead of coordinated universal time by the accumulated leap seconds,
currently 37:

    awk 'BEGIN{printf "%.3f s\n", 32.184 + 37}'
    69.184 s

so a column labelled only "JD" is ambiguous at the minute level once the frame is
in it and at the minute level again if the frame is already applied. The
barycentric coordinate time scale is a further trap, because it is a perfectly
respectable scale that simply runs at a different rate: the rate difference alone
accumulates to

    awk 'BEGIN{printf "%.2f s\n", 1.550519768e-8 * 25*365.25*86400}'
    12.23 s

over twenty-five years, using the defining constant L_B. A survey that publishes
on that scale and a survey that publishes on the dynamical scale therefore
disagree by more than ten seconds today, growing, for reasons that have nothing
to do with either target.

Recording the conversion matters as much as doing it. A reader who disagrees with
a correction needs to be able to undo it, and that is only possible if the input
time system, the target position used for the correction, and the tool version
are all in the artefact. A correction that cannot be undone is a correction the
reader has to take on trust, and this project exists because taking calibration
on trust is how the second answer gets published.

## What is recorded per survey

For every survey the artefact carries four fields, in the provenance header
described in `0007-output-artefact.md`, which is where they are named:
`native_time_column`, the column name as the archive publishes it;
`native_time_frame` and `native_time_scale`, the reference frame and the scale
the archive states for that column; and `time_conversion`, the conversion this
tool applied. Four rather than three, because the frame and the scale are two
keys of that header and not one, and the count here is taken from the header
rather than from a reading of the sentence above it.

What follows is the table as it stands before any adapter exists. Two entries are
established by the mission's own published documentation and are written as
established. The rest are written as claims, because the only thing that settles
what an archive actually sends is a response from that archive, and this
repository holds none yet. The recorded archive responses and their manifests are
what will settle them, one survey at a time, and an adapter lands with its row of
this table corrected against the recording rather than against this file.

- The space astrometry mission. Established. Its epoch photometry publishes time
  as a barycentric Julian date on the barycentric coordinate time scale, offset by
  the fixed constant 2455197.5 days. The conversion is therefore an offset
  restored and a scale change, and the scale change is the twelve-second term
  computed above rather than a relabelling.
- The wide-field space mission. Established. Its light curves publish time as a
  barycentric Julian date on the barycentric dynamical time scale, offset by the
  fixed constant 2457000. The conversion is an offset restored and nothing else,
  which makes this the one survey where the correction is exact by construction
  and the one where a mistake would be invisible.
- The northern high-cadence survey. Claim. Its light curve tables are expected to
  carry both a heliocentric Julian date and a modified Julian date at the
  observatory, and the conversion is then the full correction from the
  observatory to the barycentre, computed from the target position, applied to
  the observatory time rather than to the already-corrected one.
- The all-sky patrol survey. Claim. Its light curve service is expected to
  publish a heliocentric Julian date. The conversion undoes the heliocentric
  correction and applies the barycentric one, which is the case where taking the
  published column as if it were barycentric costs the few seconds named above.
- The reference survey. Claim. Its detections table is expected to carry a
  modified Julian date at the observatory. The conversion is the full barycentric
  correction.
- The equatorial strip survey. Claim. Its imaging metadata is expected to carry a
  modified Julian date derived from an atomic-time field count, so both a scale
  step and the full barycentric correction apply.
- The twin-telescope survey. Claim. Its forced photometry output is expected to
  carry a modified Julian date at mid-exposure, and the conversion is the full
  barycentric correction.

Marking five of seven as claims is the accurate statement of what is known, and
it is deliberately not softened. A table that read as established throughout
would be the exact defect this repository's standpoint names first: a claim about
another artefact made from the nearest thing to hand instead of from the thing
itself.

## Rejected

- Keeping each survey's native time and correcting at fit time. The correction
  then happens in several places, each of which can drift, and the definition of
  the join lives nowhere. It also means an artefact's time column means something
  different depending on which code path produced it.
- A modified Julian date at the observatory as the axis. Cheap, well defined, and
  it leaves the light travel time inside the data, which is the whole error this
  entry exists to remove.
- Storing both the native and the corrected column. Doubles the width of the
  table and invites a reader to fit the wrong one. The native value is not lost:
  it is reconstructible from the recorded conversion, which is the direction the
  cost belongs in.
- Coordinated universal time as the scale, on the grounds that it is what
  everything else is labelled in. A period fitted across a leap second in a
  non-uniform scale is wrong by the accumulated offset, and the error grows with
  the length of the baseline, which is the quantity this project is trying to
  extend.

## What it costs

The conversion needs the target position and an ephemeris, so the time axis now
depends on the resolution step and on an external solar system ephemeris. A
position that is wrong by an arcminute is a barycentric correction that is wrong,
quietly, in a column nobody inspects. The magnitude of that error is small
against the correction itself, but it is not zero, and this entry does not
measure it. What would settle it is a computation of the correction at two
positions separated by a known angle, which belongs with the code that performs
the conversion rather than with this file.

It also puts a dependency in the middle of the tool. The conversion is not
something to implement here: it is standard, subtle, and already implemented
correctly elsewhere, so the cost of this decision is a dependency on that
implementation and on its ephemeris data. Reimplementing it to avoid the
dependency would move the hard part of this project from cross-calibration to
time scales, where nobody wants it.

A survey whose published column is already barycentric, on a scale this entry
does not accept, is converted rather than trusted. That means the tool applies a
scale change to a number a user may have taken at face value elsewhere, so two
analyses of the same mission's data can disagree by the tens of seconds computed
above. The disagreement is real and the recorded conversion is what makes it
explicable rather than mysterious.
