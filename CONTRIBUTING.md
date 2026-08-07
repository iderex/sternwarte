# Contributing

## What a contribution has to carry

Every change starts as an issue and lands as a pull request. Direct pushes to
`main` are refused by the ruleset on this repository.

An issue says what is wrong, what the evidence is, and what "done" means. **A
number in an issue or in a pull request body carries the command that produced
it**, run at the commit being pushed and against the reference the reader will
have, not against your working tree. Where a claim cannot be backed by a
command, write it as a claim and say what would settle it. A claim about another
artefact, made from the nearest thing to hand instead of from the thing itself,
is the largest defect class this kind of work produces, and reading a working
checkout and reporting it as the mainline is its canonical form.

A negative disclosure never becomes a positive assurance. If a pull request body
says a thing was not run, that admission survives every later edit of the body.

## Sign off every commit

Every commit carries a `Signed-off-by` trailer whose name and email match the
commit author. The trailer asserts the Developer Certificate of Origin 1.1, the
text of which is in [`DCO`](DCO) at the root of this repository. Read it once
before your first contribution.

    git commit -s -m "Say what changed and why (#12)"

To add the trailer to commits you already made:

    git rebase --signoff origin/main

The certificate's clause (a) refers to "the open source license indicated in the
file". **This repository has no license file yet**:

    gh api repos/iderex/sternwarte --jq '.license | tostring'
    null

    git ls-files | grep -iE '^(LICENSE|COPYING)' ; echo "exit=$?"
    exit=1

An exit of 1 from `grep` is no match. Until a license is chosen, the default is
exclusive copyright, so nobody may legally use, modify or redistribute this code,
and the sentence in `NOTICE.md` about the license carrying the warranty
disclaimer points at a file that does not exist. The choice is issue #2, entry 1,
and it is unanswered. This is stated here rather than left for a contributor to
discover after signing off on it.

## Commits and pull requests

One topic per commit and per pull request. A commit carrying two unrelated
changes has a message describing one of them.

**Every commit subject names its issue**, with the number in the subject line
itself and not only in the pull request body:

    Add the transformation graph (#51)

The subject is what `git bisect` and `git blame` show, and they show nothing
else. A reference that lives only in the pull request body is a reference nobody
has when they are looking at a bad commit.

**Commit messages are US-ASCII printable plus line feed.** No tab, no carriage
return, no character above 0x7E. A homoglyph or an invisible separator in a
message is a message that reads differently from how it is stored.

Commit messages state what changed and what failure it prevents. Where a
correction is being made, they say what was wrong and how it was found.

Branch names describe the change: `docs/`, `ci/`, `fix/` or `feat/` followed by
a short description. Delete the branch once its pull request is merged.

The pull request body is where everything about a change goes. The template asks
for the means, what was verified, and what is not covered. Fill all three. If
the body is wrong or out of date, edit the body rather than adding a comment
underneath it.

**Several issues that land only documents share one branch and one pull
request.** Everything else is one pull request per issue.

## Choosing the means

Before an artefact is built, whether the chosen means fits is answered in
writing, in the issue or in the pull request body. The means is the language,
the format, the tool, the runtime, whatever the thing will be made of. Every
time, and never carried over from habit, because a means that was right for the
last artefact is an assumption about this one. What the check asks: can the means
carry a refusable property, an executed proof, and a claim with the command that
produced it behind it; does it add a language, a runtime or a dependency this
tree does not already carry, and is that cost paid knowingly; would it be
testable by the suites that already exist.

What is checkable is that the question was answered, and only because the answer
is written down. Whether the answer was right is a judgement, and the review is
where a wrong one is caught.

## Guards

No guard ships without proof that it bites, for the reason it names. A guard is
proven by the fixture that trips it and the neighbouring case that does not, and
the near-miss is worth more than the obvious violation: pick the one-character
mistake somebody will actually make. The proof goes in the pull request body.

## Decision records

Choices that shape the tool are written down under `docs/decisions/` before the
code that depends on them exists. `docs/decisions/README.md` is the rule for what
an entry contains, how it is numbered and how it is superseded. A choice visible
only in the code it produced cannot be argued with later.

## The gate, and what to run before you push

Every check below is a check run on this repository today. The list is what the
gate actually is at this commit, derived from the workflow files rather than
remembered:

    grep -l . .github/workflows/*.yml
    .github/workflows/dco.yml
    .github/workflows/dependency-review.yml
    .github/workflows/opengrep.yml
    .github/workflows/pr-hygiene.yml
    .github/workflows/scorecard.yml
    .github/workflows/unicode-guard.yml
    .github/workflows/zizmor.yml

### `DCO sign-off`

Refuses any non-merge commit in the range whose message lacks
`Signed-off-by: <author name> <author email>` matching the commit's own author.
Bot identities are exempt through an explicit allowlist. Reproduce it locally:

    git log --format='%H%n%an <%ae>%n%(trailers:key=Signed-off-by,valueonly)' origin/main..HEAD

Simpler, and what the gate does per commit:

    git show -s --format='%B' HEAD | grep -qxF "Signed-off-by: $(git show -s --format='%an <%ae>' HEAD)" ; echo "exit=$?"

An exit of 0 is the trailer present and matching.

### `Deterministic PR-hygiene checks`

Three legs, all reading git and the pull request event. Run the first two
locally:

    for sha in $(git rev-list --no-merges origin/main..HEAD); do git show -s --format='%s' "$sha" | grep -qE '#[0-9]+' || echo "FAIL $sha"; done

Every non-merge commit subject names an issue.

    git log --format='%B' origin/main..HEAD | LC_ALL=C grep -n '[^ -~]' ; echo "exit=$?"

An exit of 1 is no match, which is what this leg wants: every commit message is
inside the allowlist of US-ASCII printable plus line feed.

The third leg reads the pull request body and refuses an empty one, or one that
names no issue. It has no local equivalent, because there is no body until the
pull request exists.

### `Reject Trojan Source Unicode`

Refuses bidirectional overrides, isolates, marks and zero-width characters in
tracked text, which are what make source render differently from how it runs.
The same command the workflow uses:

    git grep -nIP '(*UTF)[\x{202A}-\x{202E}\x{2066}-\x{2069}\x{200E}\x{200F}\x{061C}\x{200B}-\x{200D}\x{2060}]' -- . ; echo "exit=$?"

An exit of 1 is no match. An exit of 2 or higher is the scanner failing, and the
gate fails closed on it rather than reading a broken scanner as a clean tree.

### `Static analysis (opengrep)`

Runs this project's own pattern rules from `security/rules/`. Two steps: the
rules are asserted against their own fixtures first, then the tree is scanned
with `security/rules/` excluded, because the fixtures in it are deliberate
violations. Fetch the pinned scanner the way the workflow does, on Linux or on
macOS with the matching asset name:

    url="https://github.com/opengrep/opengrep/releases/download/v1.26.0/opengrep_manylinux_x86"
    curl -sSfL --retry 3 -o opengrep "$url"
    echo "40c21299eeddabf743b856daa843d24f9d4a027130671cd45b3b21776fd9ab26  opengrep" | sha256sum -c -
    chmod +x opengrep
    ./opengrep test security/rules/
    ./opengrep scan --config security/rules/ --exclude=security/rules --severity=ERROR --error .

The pinned asset is a Linux binary. **There is no local route named here for
Windows**, and a contributor on Windows runs this check by pushing the branch and
reading the check run. That is a gap rather than a policy, and it is written here
so it is not discovered as a silent skip.

### `Audit workflows (zizmor)`

Static analysis of the workflow files themselves, at the pinned version, failing
on any finding of low severity or above:

    uvx --no-build "zizmor@1.26.1" --strict-collection --min-severity=low --format=plain .

`--no-build` installs from the prebuilt wheel only and never runs a source
distribution's build script. `--strict-collection` fails closed if any workflow
fails to parse.

### `dependency-review`

Runs on a pull request only, and compares the dependency diff of that pull
request against the advisory database, failing on any known vulnerability at low
severity or above. It has no local equivalent: the check is a comparison between
two refs performed by GitHub, not a command over the tree.

### `Scorecard analysis`

Not a pull request gate. It runs on a push to the default branch, on a weekly
schedule and on a change to branch protection, and it publishes a supply-chain
score rather than refusing a change. It is listed here because it is a check run
this repository produces, and a document that named only the refusing ones would
leave a reader surprised by it.

### What the gate is not, yet

The lint, type, test, coverage, network and lockfile checks that this project
plans are not built. They are open issues, and the milestone they belong to is
`M3 The gate`:

    gh issue list --milestone "M3 The gate" --state open --json number,title --jq '.[] | "\(.number) \(.title)"'

**Every check in that list is absent, not passing.** Each one that lands owes an
edit to this section, because a document that names a command nothing runs is
worse than a document that names none.

There is also nothing that refuses a merge for a red check. The ruleset on `main`
requires a pull request, refuses deletion and refuses a non-fast-forward push,
and it requires no status check:

    gh api repos/iderex/sternwarte/rulesets --jq '.[] | "\(.id) \(.name)"'
    20519818 gate
    gh api repos/iderex/sternwarte/rulesets/20519818 --jq '[.rules[].type]'
    ["deletion","non_fast_forward","pull_request"]

So a run that never happened leaves the same trace as one that was green, and
every check above is a courtesy that shortens the feedback loop rather than a
gate. Issue #32 is where that gap is held open. This paragraph is not a
formality: it is the difference between a checklist and an enforcement, and this
repository currently has the first.

## Reporting a vulnerability

Never on the public tracker. [`SECURITY.md`](SECURITY.md) has the private route
and the classes that count.
