# 0007 The output artefact format and its provenance header

One calibrated series is the deliverable, so the file it arrives in is part of
the product rather than a detail of how it is delivered. A series whose units,
provenance and per-survey bookkeeping are not in the file is a series a second
person cannot check, and a result a second person cannot check is the thing this
project exists to stop producing.

## The decision

The default output is an enhanced character-separated value file: the tabular
text format whose header is a commented block carrying column names, units, data
types and arbitrary metadata, and which reads directly into an astropy table with
no custom loader. The file extension is `.ecsv`.

FITS and plain comma-separated values are offered as exports and are never the
default. The plain export prints a warning naming what it drops, which is the
units and the whole provenance header.

## Why

A header that diffs is what makes two runs comparable and a regression visible in
review. Two artefacts from the same position, produced a month apart, are
compared with a text diff, and the line that moved is the line that explains the
change. A binary container answers the same question only with a reader and a
script, which means the question is usually not asked.

Units in the file remove the single most common way a downstream user gets an
answer wrong. A column of numbers labelled `mag` in a note somewhere is a column
whose units are whatever the reader assumed.

Provenance in the same file as the numbers is the point rather than a
convenience. A sidecar gets lost on the first copy, and then the series is a
column of magnitudes with no way to tell which release produced it, which
comparison stars were used, or whether the target's colour was measured or
assumed. Once separated they are never rejoined, because nothing in either file
says the other exists.

Reading into a table with no custom loader means the artefact is usable by people
who never read this repository, which is the only definition of usable that
matters for a tool meant to end a per-paper reimplementation.

## What the header carries

Every key below appears in every artefact. A key whose value is unknown carries
an explicit null rather than being absent, because an absent key and a key that
could not be filled are different statements and a reader cannot tell them apart.

Run and provenance:

- `tool_version`. The version of this package that produced the file.
- `generated_utc`. When the run happened, as an ISO 8601 instant.
- `target_query`. The string the operator asked for, exactly as given.
- `target_resolved`. The position used, in degrees, and the resolver and
  catalogue that produced it.
- `target_proper_motion`. The proper motion and reference epoch applied when
  propagating the position to each survey's epoch, with its source.
- `reference_system`. The photometric system every column is in, and the
  magnitude convention, from `0003-reference-photometric-system.md`.
- `output_band`. The band this series is in.
- `time_system`. The time scale and reference frame of the time column, from
  `0005-time-axis.md`.
- `ephemeris`. The solar system ephemeris used for the barycentric correction.
- `config_digest`. A digest over the effective configuration, so two runs that
  differ only in configuration are distinguishable without diffing every key.

Per survey, one block each, for every survey consulted and not only for the ones
that contributed:

- `survey`. The survey identifier.
- `data_release`. The release identifier read, from
  `0010-data-releases-are-pinned.md`.
- `query`. The query issued, in a form that can be reissued.
- `native_time_column`, `native_time_frame`, `native_time_scale` and
  `time_conversion`. The four fields `0005-time-axis.md` requires.
- `transformation_route`. Which chain into the hub was taken.
- `transformation_coefficients`. The coefficients actually applied, with their
  source and their validity range in colour.
- `colour_used` and `colour_source`. The colour the transformation was evaluated
  at, and where it came from, from `0006-colour-axis.md`.
- `colour_extrapolation`. How far the target's colour lies outside the range the
  comparison stars spanned, in magnitudes, zero where it lies inside.
- `ensemble_count` and `ensemble_criteria`. How many comparison stars entered the
  solve and the selection rule that admitted them.
- `ensemble_excluded_crowding` and `ensemble_excluded_variability`. Counts, per
  guard, of stars the guards removed.
- `offset` and `offset_uncertainty`. The fitted zero-point offset for this
  survey.
- `residual_scatter`. The scatter left after calibration.
- `epoch_count`. Epochs contributed.
- `role`. What this survey was used for, which is where the wide-field space
  mission declares that it constrains shape and not zero point, from
  `0011-space-photometry-is-a-shape-constraint.md`.
- `excluded` and `exclusion_reason`. Whether this survey contributed to the joint
  solve, and if not, why. A survey excluded by a guard is the most interesting
  line in the report, so it is present with its reason rather than absent.

There is no aggregate quality key, anywhere, by construction. That is
`0009-uncertainties-are-reported-per-survey.md` and it is a property of this
header rather than a habit of whoever writes a report against it.

The columns carry units and the per-epoch uncertainty is two columns, the
archive's own reported error and the uncertainty contributed by the
transformation, never summed into one.

## Rejected

- Comma-separated values as the default. No units, no metadata, and it is the
  format this field already loses information in. It stays as an export because a
  reader with a spreadsheet is a real reader, and it warns because a default that
  silently drops provenance would make every other decision here decorative.
- FITS as the default. It carries the metadata perfectly well and it does not
  diff, so the comparison between two runs needs a reader for something that
  should be legible in a terminal. It stays as an export because parts of this
  field will not accept anything else.
- Parquet as the default. Fast, compact, well typed, and with no natural home for
  a provenance header a person reads. Unreadable without tooling, which puts the
  provenance behind exactly the barrier this entry exists to remove.
- A separate provenance sidecar beside a simple table. Cleanest to write and
  wrong for the reason given above: the two files separate on the first copy and
  nothing in either says the other existed.

## What it costs

The header is large, and it grows with the number of surveys consulted. For a
target with a short series the header is bigger than the data, which looks absurd
and is correct: the bookkeeping is not proportional to the number of epochs, it
is proportional to the number of decisions the run made.

The format is a text format, so a very long series is a large file and reading it
is slower than reading a binary container. Nothing here has been measured as slow,
and the export path exists for the case where it becomes so.

Committing to one table format also commits to one shape of result. A run that
consulted seven surveys produces one table plus a header block per survey, and a
caller who wants the per-survey blocks as data rather than as metadata has to
parse the header. That is a real cost paid to keep the numbers and their
provenance in one file, and the alternative was the sidecar this entry rejects.
