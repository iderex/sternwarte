# 0006 Where an object's colour comes from

Every transformation between two photometric systems carries a colour term, so
every transformation needs a colour for the object it is applied to. Where that
colour comes from has to be one answer for the whole tool, because a colour term
evaluated on colours from two different sources is two different
transformations wearing the same name.

## The decision

The canonical colour is the Gaia blue-minus-red photometer colour, BP minus RP,
taken from the pinned Gaia data release. It is taken from that same release for
the target and for every comparison star in the ensemble.

Where no Gaia colour exists for an object, the survey is transformed with the
colour term evaluated at the median colour of the ensemble, and every epoch
produced that way carries the flag `colour_assumed`. The flag is a column in the
artefact, one value per epoch, and the artefact header names the colour used and
its source.

## Why

One colour source is what keeps the colour terms comparable across surveys. Two
sources would mean the difference between two surveys' transformed magnitudes
depends partly on which catalogue supplied each object's colour, which is
indistinguishable in the output from a real offset between the surveys.

This source in particular, because it exists almost everywhere this tool will be
asked to look, for the target and for the comparison stars alike, which is what
the ensemble method needs. A colour source that covers the target but not the
field would leave the ensemble uncalibrated in exactly the fields where the
ensemble matters.

Taking the colour from the survey being transformed was the obvious alternative
and it is circular: the colour would then be a function of the calibration being
solved for, so the solve would be fitting a quantity that depends on its own
output.

The fallback is deliberately visible rather than silent. An assumed colour is a
real approximation with a real residual, and an epoch that carries one is not
the same measurement as an epoch with a measured colour. Flagging it per epoch
rather than per run is what lets a reader drop those epochs, or keep them and
say so, without rerunning anything.

## What this approximates, and what it leaves behind

A variable star's colour changes with phase, and one colour per object is
therefore an approximation for exactly the objects this tool is built for. For a
large-amplitude variable observed in a narrow band, the residual this leaves can
reach the size of the offsets being measured, which means the approximation is
not negligible in the regime that matters most.

The decision is to take the approximation and report what it leaves, rather than
to pretend a static colour is exact. The artefact carries the colour used for
every object, and the per-survey residual report carries the sensitivity of the
result to the colour term, so a reader can see how much of a residual is
attributable to the colour rather than guessing.

The epoch-dependent alternative, taking the colour from simultaneous two-band
observations wherever they exist, is worth building later. It is deliberately
not in the first release: only some of the seven surveys observe two bands close
enough in time for it, so it would apply unevenly across the set and make the
surveys less comparable rather than more. Fixing that unevenness is a larger
piece of work than the first release should carry, and doing it badly would
undo the comparability this entry exists to protect.

## Rejected

- Per-survey colours, each from the survey's own catalogue. Different systems,
  different epochs, and the colour becomes part of what is being solved for.
- A colour fitted alongside the offsets. It adds a free parameter per survey to
  a model whose entire purpose is to have fewer of them, which is the failure
  the offset decision was written to avoid.
- No colour term at all. It discards the largest known term in every
  transformation in this set, and it fails hardest for red objects, which are
  well represented among the targets this tool is for.
- Dropping the epochs that have no colour, instead of flagging them. Silently
  shortens the baseline, which is the one thing the project exists to lengthen,
  and it does so without leaving a trace in the artefact.

## What it costs

The tool now depends on one external catalogue for a quantity every
transformation needs, so a target with no entry in that release falls back for
every survey at once, not just for one. The fallback is the ensemble median
colour, which is a statement about the field rather than about the target, and
for an object whose colour is far from the field median it is a poor one. The
flag says the approximation was made; it does not say how bad it was.

Pinning the colour to a data release ties this entry to the release-pinning
decision. A new release changes colours, and therefore changes transformed
magnitudes, for reasons that have nothing to do with the target. That is a
declared change with a before-and-after comparison, and this entry is one of the
reasons that rule is not negotiable.
