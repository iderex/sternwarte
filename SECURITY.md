# Security

## Reporting

**Never on the public tracker.** An issue is public the moment it is opened, and
a report that names a parsing flaw in a tool that reads seven public archives is
a report anybody can act on before there is a fix.

Report privately through GitHub's private vulnerability reporting on this
repository:

<https://github.com/iderex/sternwarte/security/advisories/new>

That route is enabled here:

    gh api repos/iderex/sternwarte/private-vulnerability-reporting
    {"enabled":true}

If that form is unavailable to you, write to <nils.lehnen@proton.me> instead and
say in the subject that the message concerns this repository.

Include what you did, what happened, what you expected, and the smallest input
that reproduces it. If a number is part of the report, include the command that
produced it.

## What is in scope

Nothing here authenticates a user, serves a request or holds a session, so the
usual web classes do not apply. What this tool does is read bytes from seven
services it does not control and turn them into a file and a number. The
realistic classes follow from that, and these three are the ones a report is
wanted for:

- **A malicious or malformed archive response reaching a parser.** The tool
  parses tabular and binary astronomical formats from remote archives. An input
  that causes code execution, an unbounded allocation, an infinite loop, or a
  write outside the intended directory is in scope, and so is one that makes the
  parser return a silently wrong value.
- **A path written or read from a survey-supplied value.** Response fields
  become cache keys and file names. A field that escapes the cache directory, or
  that overwrites something outside it, is in scope.
- **A credential leaking into an artefact, a log or a recorded response.** One
  of the surveys in scope is reached with a per-user token. A token that reaches
  an output file, a log line, a cached response or a recording committed to this
  repository is in scope, and it is in scope even where the leak requires the
  operator to have done something ordinary.

Reports outside those three are still read. The list says what this project
expects to be wrong, not what it will refuse to hear.

## What is out of scope

The archives themselves. If a survey's service has a flaw, report it to that
survey. This repository can only decide what it does with the bytes it receives.

The absence of a check that is not built yet. The gate on this repository is
partly unbuilt, which is stated plainly in [`CONTRIBUTING.md`](CONTRIBUTING.md)
with the command that shows which parts are open. A missing check is an open
issue, not a vulnerability report.

## What you can expect

An acknowledgement that the report was received and read. A statement of whether
it is accepted, with the reason if it is not. Where it is accepted, the fix
lands as a normal change with its issue and its pull request, and the advisory is
published once the fix is available.

There is one maintainer, and this section promises no schedule because a
schedule this project cannot keep would be worth less than no schedule at all.
[`GOVERNANCE.md`](GOVERNANCE.md) says what that means and what happens if the
maintainer stops.

## Handling of what you send

A report is treated as confidential until it is fixed or until you say otherwise.
Nothing you send is redistributed. If your report contains a credential, say so,
and it will be treated as a live secret and not quoted anywhere.
