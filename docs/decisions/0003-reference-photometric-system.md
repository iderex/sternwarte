# 0003 The reference photometric system every series is transformed into

Seven surveys arrive in seven photometric systems. Until one system is named as
the one everything is transformed into, every pairwise transformation is a
separate argument and the joined output has no defined meaning. A magnitude
column with no named system is a number whose value depends on which survey
happened to supply the row.

## The decision

Every series is transformed into the Pan-STARRS1 `grizy` system. Magnitudes are
AB magnitudes, which is the convention that system is defined on. The default
output band is `r`.

A caller may ask for another band in the hub system. Nothing is transformed into
a band outside it, and no output is produced in a survey's native system.

## Why

The hub is chosen for the length of the chains that reach it, because every link
in a chain adds its own colour-dependent scatter and its own uncertainty on the
coefficients. Most of the modern surveys in scope already carry a zero point
tied to Pan-STARRS1 or to a reference catalogue built from it, so for those the
step into the hub is a small, well characterised colour term rather than a
high-order extrapolation between unrelated systems.

Coverage is the second reason and it is not a lesser one. A hub that is missing
at the target is not a hub, and Pan-STARRS1 covers the sky north of declination
minus thirty degrees, about three quarters of the sphere (Chambers et al. 2016,
arXiv:1612.05560). At a position the hub does not reach, the transformation is
an extrapolation off the end of every relation in this table at once, which is a
failure this entry does not solve and which the validation catalogue records
instead.

AB magnitudes follow from the system rather than being a separate choice. The
Pan-STARRS1 system is defined on AB (Tonry et al. 2012, ApJ 750, 99), so naming
the system and then declaring a different magnitude convention would mean
carrying an offset in every coefficient for no gain.

## The chain each survey takes to the hub

Short means the survey's photometry is already calibrated against Pan-STARRS1 or
against a catalogue derived from it, so reaching the hub is one colour term with
published coefficients. Long means the survey's band has no such tie, or is
broad enough that the relation is high order in colour and carries scatter that
is not negligible against the offsets this tool measures.

- The reference survey, Pan-STARRS1 itself. No transformation. It is the hub,
  and its detections table is also where the comparison-star photometry comes
  from. Tonry et al. 2012, ApJ 750, 99, defines the system; Chambers et al.
  2016, arXiv:1612.05560, describes the surveys.
- The northern high-cadence survey, in `g`, `r` and `i`. Short. Its photometric
  calibration is performed against Pan-STARRS1 photometry, so the step into the
  hub is small by construction. Masci et al. 2019, PASP 131, 018003.
- The twin-telescope survey, in its two wide bands. Short in zero point and not
  small in colour. Its photometry is calibrated against a stellar reference
  catalogue built on Pan-STARRS1, so the tie is direct, but each of its two
  bands spans roughly two hub bands, so the colour term is large even though the
  chain is one link. Tonry et al. 2018, PASP 130, 064505, for the survey; Tonry
  et al. 2018, ApJ 867, 105, for the reference catalogue.
- The equatorial strip survey, in `ugriz`. Short. The relation between that
  system and the hub is published with the hub system itself, and a
  recalibration of that survey's photometry onto Pan-STARRS1 exists and is the
  stronger route where it applies. Tonry et al. 2012, ApJ 750, 99, table of
  transformations; Finkbeiner et al. 2016, ApJ 822, 66.
- The all-sky patrol survey, in its two photometric systems. Its Sloan-like band
  is short. Its broad-band visual system is long: the band is a Johnson-Cousins
  descendant with no tie to the hub, calibrated through an intermediate
  catalogue, so reaching the hub is two links and a colour term with real
  scatter. Shappee et al. 2014, ApJ 788, 48; Kochanek et al. 2017, PASP 129,
  104502.
- The space astrometry mission, in its broad `G` band with two photometer bands
  beside it. Long. The published relation from that mission's photometry into
  Sloan-like systems is a polynomial in the photometer colour, and the residual
  scatter around it is the largest of any entry here. This survey is also the
  source of the canonical colour, entry `0006-colour-axis.md`, so it appears in
  every other survey's transformation as well as in its own. Riello et al. 2021,
  A&A 649, A3.
- The wide-field space mission, in one very broad red band. Long, and the length
  is the smaller half of the problem. Its band spans most of the hub's `i`,
  `z` and `y` at once, so the transformation is strongly colour dependent, and
  its calibration is not stable across observing sectors. Entry
  `0011-space-photometry-is-a-shape-constraint.md` is where that is decided, and
  the consequence there is that this survey contributes no term to the joint
  zero-point solution. Ricker et al. 2015, JATIS 1, 014003.

Nothing in this repository checks the paragraph above. Each entry is a claim
about what a published paper establishes, and what settles a disputed one is the
paper, read at the section that defines the survey's photometric calibration. No
command here reads them, and no command could: the tree holds no adapter yet.
Once the adapters land, the coefficients actually applied travel into the
artefact's provenance header, entry `0007-output-artefact.md`, so a reader
checks the numbers that were used rather than the ones this file names.

## Rejected

- The equatorial strip survey's `ugriz` as the hub. It is the natural choice if
  the oldest photometry in the set is treated as the anchor. It is refused
  because that survey covers a narrow strip of sky, so the hub would be absent
  at most positions the tool is asked about, and because the modern surveys are
  not calibrated to it, so most inputs would take a longer chain to reach it
  than they take to reach Pan-STARRS1.
- The space astrometry mission's `G` as the hub. One very broad band.
  Transforming five-band photometry into it discards the colour information
  every other system carries, and colour is exactly what the offset model needs.
  A hub that destroys the axis the model is fitted against is not a hub.
- A synthetic internal system, defined by this project. No external check exists
  on it. A series published in a system nobody else uses cannot be compared with
  anybody's measurement, which defeats the purpose of joining the surveys at all,
  and it would make every error in the definition invisible because there is
  nothing to compare against.

## What it costs

Two surveys pay most of the cost. The broad-band visual system of the all-sky
patrol survey and the broad red band of the wide-field space mission each need a
colour-dependent transformation that is high order and carries scatter of its
own. That scatter is reported per survey and never folded into the series, which
is entry `0009-uncertainties-are-reported-per-survey.md`, so the cost is visible
in the output rather than absorbed by it.

Naming a hub also ties this project to somebody else's calibration. If the hub
system is revised, every transformation in the set moves at once, and the move
looks like a step in the calibrated series at the date the release was taken.
That is why the release is pinned and a bump is a declared change, entry
`0010-data-releases-are-pinned.md`, and it is the reason that entry is not
negotiable rather than a convenience.

Positions outside the hub's footprint have no short route to it. This entry does
not decide what happens there, and it does not pretend the extrapolation is
usable. What is owed is that the case is named in the catalogue of situations
where the answer should not be trusted, rather than being met for the first time
by an operator with a southern target.
