# Supply-chain audit findings and their disposition

The supply-chain audit on this repository is the OpenSSF Scorecard run declared
in `.github/workflows/scorecard.yml`. It uploads its result to the code-scanning
tab, so the findings are alerts rather than a log somebody has to open a run to
read.

Every finding it currently reports is listed below with one of two dispositions.
Fixed means the tree no longer produces it. Accepted means it stands and is not
being repaired now, and an acceptance says what the residual risk is rather than
arguing the finding away.

The finding list, and the command that produces it:

    gh api 'repos/iderex/sternwarte/code-scanning/alerts?per_page=100&state=all' \
      --paginate --jq '.[] | [.number, .state, .rule.security_severity_level, .rule.description] | @tsv'
    9	open	low	CII-Best-Practices
    8	open	high	Code-Review
    7	open	high	Maintained
    6	open	medium	Security-Policy
    5	open	low	License
    4	open	medium	Fuzzing
    3	open	high	Dependency-Update-Tool
    2	fixed	medium	SAST
    1	open	high	Branch-Protection

The number in the first column is the alert number and is what the sections
below are keyed on. The list is what the audit reported for the commit it last
scored, and it moves when the audit runs again, so it is re-read rather than
quoted from here.

## 1 Branch-Protection, high, accepted in part

The audit reports a score of 3 and five warnings against `main`: stale review
dismissal disabled, no required approvers, no required codeowners review, last
push approval disabled, and no status checks required to merge.

The last of those five is owed by #32, which is the issue for making the named
checks required on the protected branch, and it is not accepted. It is open work
with an issue against it.

The other four are accepted. What the ruleset holds today is the whole of what is
enforced, and it is read rather than described:

    gh api repos/iderex/sternwarte/rulesets/20519818 \
      --jq '{enforcement, bypass: .bypass_actors, required: [.rules[].type]}'
    {"bypass":[],"enforcement":"active","required":["deletion","non_fast_forward","pull_request"]}

The residual risk is that a change can reach `main` through a pull request that
carries no recorded approval, and that nothing refuses a force-push dismissal
rule being absent. The pull request requirement and the absence of bypass actors
are what stand in the way of a direct push, and they are not a substitute for a
reviewer. Nothing here claims they are.

## 2 SAST, medium, fixed

The audit recorded this finding against commit `4308875557dc227f03c3332bfd165543e0fbe977`
and now reports it as fixed. Its state is read from the alert rather than from
this file:

    gh api repos/iderex/sternwarte/code-scanning/alerts/2 --jq '.state'
    fixed

Why the audit's view of this check changed is not asserted here. What is
recorded is that it is no longer an open finding, and that the static analysis
this repository intends to run as a gate is #29 and is not landed, so a reader
should not take a fixed alert as the gate existing.

## 3 Dependency-Update-Tool, high, accepted

No dependency update tool configuration is detected, which is correct: there is
none.

This is accepted for now rather than fixed. The project metadata and the
dependency floor are #14 and the committed lock is #15, and neither has landed,
so there is no dependency set for such a tool to act on:

    git log --oneline --all -- pyproject.toml uv.lock ; echo "exit=$?"
    exit=0

An exit of 0 with no output is a walk that found no commit touching either path
in any branch here.

The residual risk is real and it starts the day #14 lands rather than today.
From that point a dependency with a published advisory can sit in the lock with
nothing raising it, and the only thing that would surface it is the
`dependency-review` check, which reads the diff of a pull request and therefore
sees a dependency only on the change that introduces or moves it. A dependency
that was already there when an advisory is published is invisible to it. What
retires this finding is a configured update tool, and it belongs with #15 rather
than with this triage.

## 4 Fuzzing, medium, accepted

No fuzzer integration is detected, which is correct.

Fuzzing the archive response parsers is #36, in the quality parity milestone, and
the parsers it would run against do not exist yet. The residual risk is that a
malformed or hostile archive response is a class this repository has no coverage
for at all today, and that class is the one #36 exists for. Seven external
services are in scope for this tool, so it is not a theoretical class.

## 5 License, low, accepted

No license file is detected, which is correct.

The license is an open question on the tracker, entry 1 in #2, and it is not
answered here. Adding a file would answer it, so no file is added.

The residual risk is that the repository is public with no license, which under
default copyright leaves a reader with no permission to use or redistribute what
they can see. `NOTICE.md` is what the tree carries today and it is about
intended use rather than about permission. This finding is retired by #2 being
answered, and by nothing else.

## 6 Security-Policy, medium, accepted

No security policy file is detected, which is correct.

Writing the contributor, conduct, security and governance documents is #20, and
the security policy is the part of it this finding names. The residual risk is
that somebody who finds a defect in this repository has nowhere written to send
it and no statement of what will happen when they do, so the likely outcomes are
a public report or no report.

## 7 Maintained, high, accepted

The audit warns that the repository was created within the last 90 days. That is
a property of the repository's age and no change to the tree moves it.

Accepted, and it is not repairable by anything this triage could do. The
residual risk is on the reader's side rather than on the project's: a consumer
using this score as a signal gets a zero here that says nothing about whether
the code is looked after.

## 8 Code-Review, high, accepted

The audit reports 0 of 6 approved changesets.

Accepted, and stated without softening: changes have reached `main` here without
a recorded approval from a second reader, and the ruleset quoted under finding 1
does not require one. Nothing in this repository refuses that today.

The residual risk is the one the finding names. A defect that a second reader
would have caught is not caught, and there is no record distinguishing a change
that was read by somebody else from one that was not. Where a pull request here
has had no second reader, its body says so.

## 9 CII-Best-Practices, low, accepted

No OpenSSF best practices badge is detected, which is correct: none has been
applied for.

Accepted. The badge is a registration on an external service and is not a
property of this tree, so earning it changes the score and changes nothing a
reader of this repository can check. The residual risk is that the score is
lower than it would otherwise be, and there is no risk to the artefact.

## The two hygiene rules, and what holds them

Both of these hold in the workflows tracked here today. This section exists so
that they keep holding as workflows are added, and the workflow audit gate is
what reads them on a change.

Every action is pinned to a commit and carries its version in a comment. The
command lists every `uses:` line that is not a 40-character pin followed by a
version comment:

    git grep -nE '^\s*(-\s*)?uses:' -- .github/workflows/ | grep -vE 'uses: [^@]+@[0-9a-f]{40} # ' ; echo "exit=$?"
    exit=1

An exit of 1 from `grep` is no match, so no line fails the pattern.

No workflow declares a write permission at the top level. A top-level permission
entry sits at two spaces of indentation and a job-level one at six, so the two
are told apart by the indentation the file already has:

    git grep -nE '^  [a-z-]+: write' -- .github/workflows/ ; echo "exit=$?"
    exit=1

    git grep -nE '^      [a-z-]+: write' -- .github/workflows/ ; echo "exit=$?"
    .github/workflows/scorecard.yml:63:      security-events: write
    .github/workflows/scorecard.yml:65:      id-token: write
    .github/workflows/zizmor.yml:45:      security-events: write # upload the SARIF into the code-scanning tab
    exit=0

The first command finding nothing and the second finding three lines is the
shape this rule asks for: every write scope that exists is granted on the job
that needs it.

Both commands are read by a person. Nothing in this repository refuses a
workflow that breaks either rule at the moment it is added, and the audit that
would notice runs on a push to the default branch rather than on the pull
request that introduces it.

## The bill of materials

A software bill of materials for the built artefact is #66, in the release
milestone. It is referenced from here rather than described, because there is no
built artefact yet and a description written now would be about an intention.
