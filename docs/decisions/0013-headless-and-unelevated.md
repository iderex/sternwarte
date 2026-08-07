# 0013 The default suite runs headless and unelevated

A suite acquires its environment by accident. One test needs a display, another
binds a port to check a client, a third writes next to the source tree, and each
of them was reasonable on the machine it was written on. The bill arrives later,
on every other machine, as a list of caveats in a contributing document and a
run that is green because the parts that would have failed were skipped.

What the suite is allowed to need has to be fixed before there is a suite,
because afterwards it is a migration rather than a decision.

## The decision

Every test in the default suite runs with no display attached, with no elevated
privileges, without binding a listening socket, and writing nothing outside a
temporary directory the test framework gave it. This holds on Linux, macOS and
Windows alike, and it is a property of the default suite rather than of a
particular runner.

Plotting is an optional extra and never a runtime dependency. The plotting
module selects the non-interactive drawing backend at import, so importing it on
a host with no display cannot fail and cannot block waiting for one. No test
imports an interactive backend.

Nothing in the default suite is skipped for an environmental reason. A test that
would have to be skipped because the machine lacks something is a test that
belongs somewhere else, and the somewhere else is `tests/integration/`, under a
marker whose name says what it needs. A path goes there when it needs a live
archive, a credential, or hardware. The marker names the requirement rather than
sounding optional, because a marker called `slow` or `extra` tells a reader
nothing about why the coverage is missing on their machine.

## Why

The three constraints are one constraint seen from three sides: the suite must
be the same measurement everywhere it runs. A suite that needs something the
machine may not have does not fail on the machines that lack it. It passes with
less in it, and the difference between a full run and a thin one is invisible in
the exit code.

Elevation is the sharpest of the three and the least obvious. A test that binds
a listener to a machine's own interface address raises a firewall consent dialog
on Windows that only an administrator can answer. That is not a slow test or an
awkward one. It is a test that stops, waits for a person, and takes over the
screen of whoever happens to be at the keyboard. Answering it settles nothing
for the next build directory, because the rule the dialog writes is keyed to the
executable path. So no test binds a listener at all, and the archive layer is
exercised against recorded responses rather than against a local server. That
also gets the property the archive layer wanted anyway, which is that the gating
suite never depends on the network.

A display is the same argument with a cheaper failure. An interactive drawing
backend on a host with no display either raises at import or waits, and a test
that waits is worse than one that raises, because it consumes the whole timeout
before saying anything.

Writing outside a temporary directory is the one that looks harmless. It is how
one test's output becomes another test's input, which turns a suite into
something whose result depends on the order it ran in and on what the last run
left behind.

The rule against environmental skips is what keeps the other three honest. Any
of them can be satisfied by declining to run the test that would have violated
it, and a skip count nobody reads is how that decision hides. Moving the test to
a marked integration path costs the same effort and leaves the gap where a
reader can see it.

## Rejected

- Documenting the requirements instead of fixing them. This is what a list of
  caveats in a contributing document is, and it puts the cost on every
  contributor who reads it after hitting the failure rather than on the change
  that introduced it.
- Skipping the tests that need a display or a socket, and counting the skip. A
  skip is how a gap becomes invisible: the run is green, the count is in a line
  nobody reads, and the coverage that is missing is missing on exactly the
  machines nobody is watching.
- Requiring a display in continuous integration through a virtual framebuffer.
  It works, and it makes the constraint a property of the runner configuration
  rather than of the suite, so the suite quietly stops being runnable by a
  contributor on a laptop.
- Allowing a listener bound to the loopback address only. The consent dialog is
  raised by the bind rather than by the address it reaches, so this trades the
  whole property for a distinction the operating system does not make.
- Running the suite elevated so the question does not arise. This makes every
  test a test of what an administrator can do, and it means a test that damages
  the machine is a test that can.

## What it costs

The archive layer cannot be tested against a real server that this repository
starts, so the recorded responses have to be good enough to stand in for one,
and keeping them faithful is work that never finishes. Recording them is its own
issue, and a recording that drifts from what the archive now returns is a test
that passes against the past.

Anything that genuinely needs a live archive, a credential or hardware is
outside the default run, which means it is outside what a contributor sees
before pushing. That coverage exists and is not gating, and the honest statement
is that the default suite proves less than a full one would.

Plotting is tested only through the non-interactive backend, so nothing here
would catch a fault that appears only when a figure is drawn to a real window.

## What is not enforced

Nothing in this repository refuses a violation of any of the above today. There
is no suite, no source and no check:

    git log --oneline --all -- tests/ src/ pyproject.toml
    (no output)

The check that would refuse a socket bind, a listener class, a privilege
escalation helper or a certificate store write under `tests/unit/` is owed by
issue #17, together with the test that asserts the drawing backend and the
absence of environmental skips. Until both exist, every rule above is read by a
person, and this entry is the argument for them rather than the thing that holds
them.
