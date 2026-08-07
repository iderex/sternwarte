# 0009 Uncertainties are reported per survey, with no aggregate quality figure

A calibration that is good on average and wrong for one survey is the failure
this project exists to avoid, and an averaged residual is exactly the thing that
lets a wrong survey pass. Whether the per-survey detail reaches a reader cannot
depend on the habits of whoever writes the report, so it is fixed as a property
of the output.

## The decision

Every result carries a per-survey block, and there is no aggregate quality number
anywhere in the artefact or in the interface. No goodness-of-fit scalar, no
combined chi-squared, no overall grade, no single figure a caller can quote
instead of reading the blocks.

Per survey the block holds the fitted offset and its uncertainty, the residual
scatter left after calibration, the epoch count, the comparison-star count, the
colour range those stars spanned, the extrapolation distance of the target's
colour beyond that range, and the count of stars each guard excluded, given per
guard rather than as one total.

Per-epoch uncertainty is reported as two separate columns, the archive's own
reported error and the uncertainty contributed by the transformation. They are
never added into one column.

A caller who wants a single number computes it and decides what it means. That
decision belongs to the caller because it is a decision about their science, and
this tool does not have the information to make it for them.

## Why

Whatever is easiest to print is what gets printed. A scalar next to a detailed
block is the thing that ends up in the paper, in the plot caption and in the
comparison against somebody else's result, and the block is the thing that gets
skimmed. Refusing to compute the scalar is the only version of this rule that
survives contact with a deadline.

The exclusion counts are per guard because two exclusions with the same total
mean different things. A field where the crowding guard removed most candidates
is a field where the ensemble is thin for a reason a reader can act on, by
choosing a different aperture or a different field. A field where the variability
guard removed most of them is a field where the comparison stars are the problem.
One number covering both says neither.

Separating the two error components matters because they behave differently under
more data. Archive errors shrink as epochs accumulate. Transformation uncertainty
does not, because it is a systematic shared by every epoch from that survey, and
it is the floor the series cannot go below. Summing them into one column lets a
user average away a floor that cannot be averaged away, and the resulting error
bar is smaller than the truth by exactly the amount that matters.

Reporting the colour range and the extrapolation distance is the same argument
applied to the colour term. A transformation evaluated inside the range its
coefficients were fitted over is interpolation. Evaluated outside it, it is an
extrapolation whose error is not described by its formal uncertainty at all, and
the only honest thing to publish is how far outside it went.

## What a per-survey block holds

- `offset` and `offset_uncertainty`. The fitted zero-point offset for the survey.
- `residual_scatter`. Scatter of the comparison stars about the fit, after
  calibration, which is the quantity a reader uses to judge the survey rather
  than the formal uncertainty on the offset.
- `epoch_count`. Epochs this survey contributed.
- `ensemble_count`. Comparison stars that entered the solve.
- `ensemble_colour_range`. The lowest and highest colour those stars spanned.
- `colour_extrapolation`. How far the target's colour lies outside that range,
  in magnitudes, and zero where it lies inside.
- `ensemble_excluded_crowding` and `ensemble_excluded_variability`. One count per
  guard.
- `role`, `excluded` and `exclusion_reason`. What the survey was used for, whether
  it entered the joint solve, and why not where it did not.

A survey excluded by a guard appears in the report with its reason. Reporting
only the surveys that contributed would make the most interesting line of the
report the one that is absent, and absence is not readable: a survey that was
never queried and a survey that was queried and thrown out look identical.

## Rejected

- A goodness-of-fit scalar with the per-survey detail available on request. This
  is the version everybody proposes and it fails for the reason above: the scalar
  is what gets quoted. Making the detail available does not make it read.
- One combined per-epoch error column, with the split available separately. Loses
  the distinction that decides whether collecting more data helps, in the one
  place where a user makes that decision.
- Reporting only the surveys that were used. Hides every exclusion, which is
  where the guards do their work, and turns a guard that fires on everything into
  a silent success.
- A per-survey pass or fail flag instead of the numbers. A threshold applied
  inside the tool is the aggregate figure again, wearing a different name, and it
  is a threshold whose value would have to be right for every target this tool
  will ever be pointed at.

## What it costs

There is no single number to sort by, plot against or watch over time, and that
is genuinely inconvenient. A user tracking whether the calibration improved
between two releases has to compare blocks rather than a figure, and the
comparison is a script they write rather than a column they read.

It also makes the report longer than most readers want. For seven surveys it is
seven blocks, most of which are unremarkable most of the time, and a reader
looking for the one that is not has to look. The alternative was a summary that
would sometimes be wrong in exactly the case the summary was consulted for.

The counts are only as meaningful as the guards that produce them. This entry
fixes what is reported and not what the guards do, so a guard whose criterion is
badly chosen produces a well-reported wrong number. What catches that is the
validation set and the per-survey residual work, not this file.
