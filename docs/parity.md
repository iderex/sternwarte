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
| `CodeQL` | Replaced | Becomes `Analyze (actions)` in #28. Same scanner, and the workflow definitions here are the part of the tree it still has something to read while the package is being built. |
| `Analyze (csharp)` | Replaced | Becomes `Analyze (python)` in #28. Same scanner, different language pack, same class of finding. |
| `DCO sign-off` | Kept | Runs here unchanged and produces a check run under this name today. |
| `Deterministic PR-hygiene checks` | Kept | Runs here unchanged and produces a check run under this name today, landed by #31. |
| `Enforce greppable invariants` | Replaced | Keeps the name and gets a different table. The invariants there are about a login path; the ones here are about where a network call, a credential read and a unit conversion may appear, and #30 owns that table. |
| `Reject Trojan Source Unicode` | Kept | Runs here unchanged and produces a check run under this name today. |
| `Audit workflows (zizmor)` | Kept | Runs here unchanged and produces a check run under this name today. |
| `prettier` | Dropped | There is no JavaScript, HTML or stylesheet in this tree, so the formatter it exists to keep consistent has nothing to be consistent with, and Python formatting is covered inside #21 by the formatter run in check mode. |
| `dependency-review` | Kept | Runs here unchanged and produces a check run under this name today. |

The five checks recorded above as producing a check run are read from a commit
rather than from this file:

    gh api repos/iderex/sternwarte/commits/425daa50ab1028a306e95684b8d9565f626bf215/check-runs \
      --jq '.check_runs[] | [.name, .conclusion] | @tsv' | sort -u
    Audit workflows (zizmor)	success
    DCO sign-off	success
    dependency-review	success
    Deterministic PR-hygiene checks	success
    Reject Trojan Source Unicode	success
    zizmor	success

None of them is required by the ruleset on this repository's protected branch.
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
- `Static analysis (opengrep)`, #29, as a gate rather than a scheduled scan.
  Untrusted input arriving from seven archives is the dominant class here, and a
  scan whose result nobody has to look at before merging is not a gate.

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
