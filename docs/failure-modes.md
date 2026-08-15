# Cases where the answer should not be trusted

This tool produces a light curve for any position it is given. Some of those
positions are ones where the result is wrong in a way the series itself does not
announce, and a reader looking only at the numbers cannot tell them apart from
the ones that worked. The cases below are the ones the plan already knows about.
They are written before the code that produces them exists, because a case first
noticed after somebody has published from it is a case noticed too late.

Nothing here is a bug list. Every case below is a limit of the method, and the
answer to each is to read the artefact, not to wait for a fix.

## How to read an entry

Each entry says what goes wrong, what the output looks like when it does, which
part of the artefact a reader looks at to detect it, and what to do instead.

The detection field sits on a line beginning `Signature:`, naming artefact keys
in backticks. `docs/decisions/0007-output-artefact.md` is the authority for which
keys exist, and the invariants gate refuses an entry here that names a key that
document does not carry:

    bash scripts/invariants.sh

The entry id is `failure-mode-signature-names-a-real-artefact-field`. A
`Signature:` line is one physical line, because the check reads that line and not
what follows it, and a list wrapped onto a second line would put half its keys
where nothing looks. A line left ending in a comma is refused for that reason. What else the check can and cannot decide is written at the
entry itself and repeated in the last section here, because a check whose bound
is only in the script is a check a reader of this document will overestimate.

Two cases below carry no signature at all, and one carries a partial one. The defect is
in the artefact and not in this catalogue: a case a reader cannot detect from
the file is a case the file owes a field for. Each of the
three names the open issue that decides what the artefact carries, and none of
them is answered by anything written here:

    gh issue view 8 --json number,state,title --jq '[.number,.state,.title]|@tsv'
    8	OPEN	Decide the output artefact format and what its provenance header must carry

## A crowded field, where the ensemble is refused

The comparison stars near the target are blended with neighbours, so their
apparent brightness is partly somebody else's light and varies with the seeing of
each frame. The crowding guard removes them. What is left is too few stars to
solve an offset against, or none.

The output looks like a series with one or more surveys missing from the joint
solve, and a shorter baseline than the position alone would suggest. The
dangerous reading is that the missing survey contributed a zero offset, when
what it contributed is nothing.

Signature: `ensemble_excluded_crowding`, `ensemble_count`, `excluded`, `exclusion_reason`

What to do instead. Read the per-survey block before the series. A survey whose
`ensemble_count` is at or near zero has not been calibrated onto the reference
system, and its epochs are not comparable with the rest. For a target in a dense
field, expect the result to rest on the surveys with the coarsest pixels least
often and to lose the ones that resolve the field best, which is the opposite of
the intuition.

## A target whose colour lies outside the ensemble's span

Every transformation between photometric systems carries a colour term, fitted on
the comparison stars. A target redder or bluer than every star the fit saw has
its transformation evaluated outside the range the coefficients were measured on,
and a polynomial outside its range is an extrapolation whichever order it is.

The output looks entirely normal. The offset is a number, the uncertainty is
small, and neither says the colour term was evaluated where nothing constrained
it.

Signature: `colour_extrapolation`, `colour_used`, `colour_source`, `transformation_coefficients`

What to do instead. `colour_extrapolation` is zero when the target's colour lies
inside the span and carries the distance outside it in magnitudes when it does
not. Read it per survey: the same target can be inside one
survey's ensemble span and outside another's. Where it is non-zero, the
transformation's own validity range in colour is in
`transformation_coefficients`, and the honest treatment is to widen the
uncertainty by hand, because the fitted one understates it.

## A target brighter than a survey's saturation limit

Above the saturation limit a detector stops responding linearly, and the reported
magnitude stops tracking the star. The measurement does not fail, it flattens:
the star gets brighter and the number does not follow.

The output looks like a light curve whose amplitude is compressed in one survey
and not in the others, or a flat stretch across the brightest part of a cycle.
Fitted against surveys that were not saturated, that compression enters the
offset solve as if it were a real difference between the systems.

Signature: none.

The adapters declare their saturation and detection limits under issue #39, but
the artefact carries no key stating where the target sits against them, and no
per-epoch flag column list exists to hold one. Issue #8 decides what the artefact
carries and is open.

What to do instead. Until the artefact carries the field, this case is detected
from outside the file. Take the target's brightness in the survey's band, compare
it against that survey's published saturation limit, and read the per-survey
`residual_scatter` for a survey that is anomalously well behaved, because a
flattened series scatters less than a real one.

## A target with high proper motion and no motion measured for it

The position an operator gives is a position at one epoch. Surveys separated by a
century are looking at different sky coordinates for the same star. Propagating
the position needs a proper motion, and where none is measured, every survey is
queried at the same coordinates and the oldest ones return either nothing or a
neighbour.

The output looks like a series that is complete in the recent surveys and empty
or discontinuous in the old ones, or, worse, one where the old epochs are a
different star at a brightness that looks plausible.

Signature: `target_proper_motion`, `target_resolved`

What to do instead. `target_proper_motion` carries the motion and reference epoch
applied and its source. An explicit null there is the case named here, and the
artefact's own rule is that an unknown value is written as a null and never
omitted, so the absence stays legible. Supply a motion where one
is known from elsewhere, and treat a series whose oldest epochs appear without a
propagated position as unmatched.

## A position outside the oldest survey's footprint

The headline claim of this tool is a long baseline. That baseline is the union of
the surveys that cover the position, and the oldest survey does not cover the
whole sky. For a position outside it the series starts decades later than the
claim.

The output looks like a perfectly good light curve. Nothing about it is wrong.
What is wrong is a reader taking the baseline from the tool's description. It is
in the file.

Signature: `excluded`, `exclusion_reason`, `epoch_count`

What to do instead. Read the baseline off the series and the per-survey blocks,
never off the description of the tool. The artefact carries a block for every
survey consulted and not only for the ones that contributed, so a survey that
covered nothing is present with `epoch_count` at zero and a reason, which is what
distinguishes "outside the footprint" from "never asked".

## A target too faint for the reference survey, which removes the hub

Every survey is transformed into the reference system through a route, and the
reference survey is the hub most of those routes pass through. A target too faint
to be measured there, or in a part of the sky it does not cover, leaves the
routes without their common point.

The output looks like several surveys excluded at once, for what reads as
unrelated reasons, and a joint solve resting on whatever pairs could still be
connected directly.

Signature: `transformation_route`, `ensemble_count`, `excluded`, `exclusion_reason`

What to do instead. Read `transformation_route` across the per-survey blocks
before reading the series. Several surveys naming no route, or naming a route
that does not pass through the hub, is what this case looks like, and the offsets that did solve are then tied to each other
rather than to the reference system.

## A survey excluded because no route to the reference system existed

Distinct from the case above, and it looks the same at first. Here the hub is
fine and one survey's band has no published transformation into it, or the
transformation that exists is not valid over the target's colour. The survey is
dropped rather than transformed with a coefficient nobody measured.

The output looks like a series with a gap in time where that survey would have
contributed, and no other sign.

Signature: `transformation_route`, `excluded`, `exclusion_reason`

What to do instead. The dropped survey is in the file with its reason, which is
the point of carrying a block for every survey consulted. Where the drop matters
for the question being asked, the repair is a published transformation for that
band, recorded with its source and its validity range, and not a coefficient
fitted on the target itself.

## A target whose colour changes strongly with phase

The canonical colour is one colour per object, taken from one release. A star
whose colour swings over its cycle has its colour term evaluated at a colour it
holds only part of the time. For a large-amplitude variable in a narrow band the
residual this leaves can reach the size of the offsets being measured, which is
recorded in `docs/decisions/0006-colour-axis.md` rather than being a surprise.

The output looks like a series with a per-survey residual that varies with phase
rather than with time, and offsets that shift if the same target is reduced again
from epochs covering a different part of the cycle.

Signature: `colour_used`, `colour_source`

That signature is partial and the missing half is named rather than assumed.
`docs/decisions/0006-colour-axis.md` declares a per-epoch flag for an epoch whose
colour was assumed rather than measured, and no per-epoch column list exists for
it to appear in. What the artefact carries is decided by issue #8, which is open.
Until it lands, `colour_source` distinguishes a measured colour from an assumed
one per survey but not per epoch.

What to do instead. Read `colour_used` against the star's published colour range.
Where the range is wide, the per-survey residual report is the thing to read, not
the offset, and the colour-term sensitivity in it is what says how much of the
residual the single colour accounts for.

## A target that is itself a calibrator

A variable star bright enough and steady enough on the timescale a survey cared
about can have been used in that survey's own calibration. The survey's zero
point then already contains the star. Solving an offset for that survey against
that star is solving against a quantity that is partly a function of the star's
own brightness, and the fit is happy.

The output looks like a survey with an unusually small residual and an offset
that absorbs part of the variation the tool exists to measure. The amplitude
comes out too small and nothing in the fit objects.

Signature: none.

The artefact records which comparison stars entered the solve through
`ensemble_count` and `ensemble_criteria`, and it records nothing about whether the
target appears in a survey's own calibration. Issue #8 decides what the artefact
carries and is open.

What to do instead. Until the artefact carries the field, this is checked from
outside the file, against each survey's published calibration source list. The
signal inside the file is weak and is worth naming anyway: a survey whose
`residual_scatter` is far below its neighbours, together with an `offset` that
moves when the target's own epochs are excluded from the solve, is the shape this
case makes.

## What this document does not do

It does not say which of these cases a given reduction hit. That is the artefact's
job and the per-survey residual report's job, and this document only says where to
look.

It is not a list of every way an answer can be wrong. It is the list of the cases
the plan already knows about, and a case discovered later belongs here with its
signature at the time it is discovered.

It carries no test. The second condition of issue #61 asks that every case here
have a validation target exercising it or a synthetic test producing it, with the
document pointing at which. There is no suite and no validation set in this
repository yet:

    git ls-tree --name-only origin/main -- tests/ src/ docs/validation-set.md ; echo "exit=$?"
    exit=0

An exit of 0 with no output is a listing that matched none of the paths given. So
every "what to do instead" above is reasoning from the plan and not a procedure
anybody has run against a real reduction, and the entries carry no evidence that
the signature they name would actually fire.

The check that reads this file has three bounds, and they are worth stating
where a reader of the document will meet them and not only in the script. It reads the lines
beginning `Signature:` and nothing else, so an artefact key named in the prose of
an entry is not checked. It decides whether a name appears in
`docs/decisions/0007-output-artefact.md` and never whether that key means what the
entry claims. And that document is the authority only because the artefact does
not exist yet as code; once it does, the authority is the code, and leaving the
check pointed at a document afterwards would make it agree with a decision record
while disagreeing with what the tool writes.
