# Parity with the gate on `iderex/jellyfin-plugin-sso`

The target for this repository's gate is the one that board already runs. Its
protected branch requires thirteen named checks, and that list is what this
document is measured against:

    gh api repos/iderex/jellyfin-plugin-sso/rulesets \
      --jq '.[] | select(.name == "Protect main and 5.0") | .id'
    18802863
    gh api repos/iderex/jellyfin-plugin-sso/rulesets/18802863 \
      --jq '.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks[].context'
    build
    ABI floor build
    Package (JPRM) / Build package
    Package (JPRM) / Generate SBOM
    CodeQL
    Analyze (csharp)
    DCO sign-off
    Deterministic PR-hygiene checks
    Enforce greppable invariants
    Reject Trojan Source Unicode
    Audit workflows (zizmor)
    prettier
    dependency-review

Parity means the same coverage, not the same file names. A check copied without
its reason is a check nobody maintains, so every line below keeps a control,
replaces it with a named counterpart, or drops it, and a replacement or a drop
carries its reasoning.

Each of the thirteen is the first column of exactly one row of the table below,
so what the table covers is extracted rather than counted by eye:

    sed -n 's/^| `\([^`]*\)` |.*/\1/p' docs/parity.md

That command prints thirteen lines, and they are the thirteen above in the same
order. It reads the first column only, so a context name that also occurs inside
another row's reasoning is not counted twice, and several do occur there.

## The table

| Context | Disposition | Counterpart here, and the reasoning |
| --- | --- | --- |
| `build` | Replaced | An interpreted language has no compile step, so the compile-time coverage is split across `lint (ruff)` in #21, `types (mypy strict)` in #22 and the `tests (...)` matrix in #23, which catch the same class before a test runs. |
| `ABI floor build` | Replaced | Becomes `oldest supported dependencies` in #27. There is no binary interface to hold here, and the equivalent risk is the same one: a declared minimum that nothing ever executed. |
| `Package (JPRM) / Build package` | Replaced | Becomes `Package (wheel) / build` in #66. The artefact is a wheel and a source distribution rather than a plugin package, so the packaging step differs while what it proves does not. |
| `Package (JPRM) / Generate SBOM` | Replaced | Becomes `Package (wheel) / SBOM` in #66, for the same reason, over the same artefact. |
| `CodeQL` | Kept | Produces a check run under this name today, landed by #28. It is the code scanning results check rather than a job in the workflow, so it reports whether the analysis found anything new and the two `Analyze (...)` jobs below are what performed it. |
| `Analyze (csharp)` | Replaced | Becomes `Analyze (python)`, which produces a check run under that name today, landed by #28. Same scanner, different language pack, same class of finding. The same workflow also produces `Analyze (actions)`, because the workflow definitions here hold privilege and are analysed alongside the source. |
| `DCO sign-off` | Kept | Runs here unchanged and produces a check run under this name today. |
| `Deterministic PR-hygiene checks` | Kept | Runs here unchanged and produces a check run under this name today, landed by #31. |
| `Enforce greppable invariants` | Replaced | Keeps the name, produces a check run under it today, and gets a different table, landed by #30. The invariants there are about a login path; the ones here are about where a network call, a credential read and a unit conversion may appear. The table is in `scripts/invariants.sh` and every entry in it searches an empty scope while the package is absent, which the script reports rather than passing quietly. |
| `Reject Trojan Source Unicode` | Kept | Runs here unchanged and produces a check run under this name today. |
| `Audit workflows (zizmor)` | Kept | Runs here unchanged and produces a check run under this name today. |
| `prettier` | Dropped | There is no JavaScript, HTML or stylesheet in this tree, so the formatter it exists to keep consistent has nothing to be consistent with, and Python formatting is covered inside #21 by the formatter run in check mode. |
| `dependency-review` | Kept | Runs here unchanged and produces a check run under this name today. |

The checks recorded above as producing a check run are read from a commit rather
than from this file. `14f3e438a6c237fe1e31717c7b52f99426930b20` is on `main` and
was the head of a pull request, so it carries both the checks that run on a pull
request and the checks that run on a push:

    gh api repos/iderex/sternwarte/commits/14f3e438a6c237fe1e31717c7b52f99426930b20/check-runs \
      --jq '.check_runs[] | [.name, .conclusion, .app.slug] | @tsv' | sort -u
    Analyze (actions)	success	github-actions
    Analyze (python)	success	github-actions
    Audit workflows (zizmor)	success	github-actions
    CodeQL	success	github-advanced-security
    DCO sign-off	success	github-actions
    dependency-review	success	github-actions
    Deterministic PR-hygiene checks	success	github-actions
    Enforce greppable invariants	success	github-actions
    Reject Trojan Source Unicode	success	github-actions
    Static analysis (opengrep)	success	github-actions
    zizmor	success	github-advanced-security

Eleven names, and the two from `github-advanced-security` are results checks over
what a scanner uploaded rather than jobs in a workflow file. Four of the eleven
are not first-column entries in the table above: `Analyze (python)` and
`Analyze (actions)` are the jobs behind `CodeQL` and the counterpart named in the
`Analyze (csharp)` row, `Static analysis (opengrep)` is in the added list below,
and `zizmor` is the results check beside the job named `Audit workflows (zizmor)`.
The first column holds only the thirteen contexts the other board requires, so a
name that runs here without being required there belongs in a row's reasoning or
in the added list rather than in the column.

Which commit is quoted decides what the answer looks like, so the merge commit on
top of that head is worth reading beside it:

    gh api repos/iderex/sternwarte/commits/a9f2726a0cd36f9128f174bfde6be70fb6224d27/check-runs \
      --jq '[.check_runs[].name] | sort | unique | .[]'
    Analyze (actions)
    Analyze (python)
    Audit workflows (zizmor)
    Enforce greppable invariants
    Reject Trojan Source Unicode
    Scorecard analysis
    Static analysis (opengrep)

Seven rather than eleven, and the difference is the trigger rather than a
failure. `DCO sign-off`, `dependency-review` and `Deterministic PR-hygiene
checks` are declared on `pull_request` alone, and `CodeQL` and `zizmor` are
results checks a pull request gets and a push does not. `Scorecard analysis` goes
the other way and appears only here. So a reader sampling a merge commit sees
four of the thirteen contexts covered and a reader sampling the head sees eight,
and neither number is a statement about coverage.

The check named `Enforce greppable invariants` runs a table whose every entry has
an empty scope today, and the script says so instead of reporting a pass:

    bash scripts/invariants.sh | tail -3
    Summary: 0 checked, 8 with no subjects, 0 failed, 0 scanner errors
    Passing, and 8 of the entries above searched nothing at all.
    That is a green run over an absent subject, not a clean tree.

So the counterpart to that context exists and is wired in, and what it currently
refuses is nothing, because the paths it looks at arrive with the package.

None of the eleven is required by the ruleset on this repository's protected
branch.
What that ruleset holds is read rather than described:

    gh api repos/iderex/sternwarte/rulesets/20519818 \
      --jq '{enforcement, bypass: .bypass_actors, required: [.rules[].type]}'
    {"bypass":[],"enforcement":"active","required":["deletion","non_fast_forward","pull_request"]}

There is no `required_status_checks` rule in it, so every check named in this
document is advisory until #32 lands. A green column on a pull request here is
not a thing the merge asked for.

## Added, because this project carries risks the original does not

- `coverage floor`, #24. A wrong coefficient here does not crash, it publishes,
  so the amount of the calibration that any test reaches is gated rather than
  reviewed.
- `no network in the gating suite`, #25. Seven external services are in scope,
  so the suite's independence from them is refused rather than requested.
- `lockfile is frozen`, #26. A scientific dependency tree moves week to week,
  and a moving floor makes every failure ambiguous between the code and a
  dependency.
- `Static analysis (opengrep)`, landed by #29 and producing a check run under
  that name today, as a gate rather than a scheduled scan. Untrusted input
  arriving from seven archives is the dominant class here, and a scan whose
  result nobody has to look at before merging is not a gate.

## Deferred, each with the reason and where it is owed

- The release channel checks. They gate a distribution channel that does not
  exist yet, and both the channel and the versioning policy are #67 in the
  release milestone.
- The documentation site linter. It has nothing to lint until the documentation
  site exists, which is #65 in the release milestone.
- The package manifest freshness check and the nightly build. No issue in this
  repository owns either of them today. Both are about a published distribution
  and the machinery around it, so they belong with #67, and this line records
  that they are unclaimed rather than covered.

## What this document does not do

Nothing reads it. No check compares the table against either ruleset, so a
context added or removed on the other board, or a counterpart issue closed
without its check existing, leaves this document saying what it said before. The
three commands above are what a reader runs to find that out, and they are run
by a person.

The table also claims nothing about whether a counterpart is as good as what it
replaces. Every replacement above is a named issue or a running check, which is
what makes the claim checkable; whether the coverage is actually equivalent is a
judgement, and it is settled by the pull request that lands each counterpart
rather than here.
