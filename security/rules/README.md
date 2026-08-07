# Project rules for the pattern scanner

Four rules, each about untrusted input arriving from an archive this project
does not control. They are here rather than in a community rule set because
none of them is a general Python defect: each one is about a boundary this
tool has and most tools do not.

- `archive-query-built-by-concatenation`. A query assembled by string building
  instead of by handing parameters to the client.
- `path-from-archive-response-not-resolved`. A filesystem path taken from a
  response field and opened without being resolved against a base directory.
- `archive-response-deserialised-executably`. Stored archive bytes read back
  with a deserialiser that can construct arbitrary objects.
- `credential-read-outside-the-command-line`. A credential read from the
  environment, which entry `0012-library-first-api.md` keeps out of the
  library.

## The pairs

Each rule has a fixture file of the same name. Every case in it is marked
`# ruleid:` where the rule must fire or `# ok:` where it must not, and the
scanner's own test command reads those marks:

    opengrep test security/rules/

The negative neighbour in each pair is deliberately one edit from the positive
case, because a neighbour that could not have been written proves nothing about
the rule. The one for the deserialiser rule is a single keyword argument.

## Why this directory is excluded from the gating scan

The fixtures are violations on purpose. A scan that included them would be red
on every run, and a gate that is always red is a gate nobody reads. The
workflow excludes this directory from the scan and runs the test command over
it instead, so what stands behind these files is the assertion that each rule
fires on its positive case and stays silent on its negative one, rather than
the absence of findings.

The exclusion is written in `.github/workflows/opengrep.yml` at the scan step
and nowhere else.

## What is not covered

`credential-read-outside-the-command-line` carries a `paths.exclude` naming the
command line layer, which is where entry `0012-library-first-api.md` puts
credential reading. That exclusion is not exercised by the pair: the layer it
names does not exist in this repository yet, so the rule's behaviour inside it
is declared and not tested. When the package lands, the pair gains a case under
the excluded path.

The rules are patterns and not proofs. Each one catches the shape it names and
none of them catches the same mistake written another way. A rule going quiet
because the code moved to a spelling it does not know is the failure mode here,
and nothing in this directory detects it.
