# 0002 The implementation language and toolchain

The plan says everything this tool needs is reachable in pure Python. That is a
reason to look at Python, not a reason to have chosen it. A language picked
because the last project used one is an assumption about this project rather
than a decision about it, and every later argument about dependencies, typing
and packaging inherits it. Nothing is scaffolded until this entry exists.

## The decision

Python, with `uv` for the environment and the lock, `ruff` for lint and format,
`mypy` in strict mode, `pytest` for the suite, and `hatchling` as the build
backend. The floor is Python 3.12, and the test matrix runs 3.12, 3.13 and 3.14.

## Why

The work is almost entirely reading and reconciling archive responses, and the
readers already exist in Python: VOTable and FITS parsing, TAP and DataLink
clients, barycentric time conversion, and the coordinate machinery that turns a
position and an epoch into what a survey was actually pointing at.
Reimplementing a VOTable parser in another language to avoid a Python dependency
would move the hard part of this project from cross-calibration, where it
belongs, to file format handling, where nobody wants it.

The audience decides the rest. A tool for this job that a researcher cannot
import into a notebook has failed however well it calibrates, and the people who
would extend it, by adding the eighth survey, write Python.

The three properties the work has to be able to carry, it carries. A property
can be refused, because a failing test fails a build. A guard can be shown to
bite, because a fixture can be built that trips it and a neighbouring fixture
that does not. A claim can cite the command that produced it, because the
command is one the reader can run.

The floor of 3.12 follows the scientific Python support window, which drops a
Python version three years after its release. The window for 3.12 runs to
2026-10-01, so the floor moves to 3.13 shortly after this is written. That move
is a deliberate edit with its own issue, not a drift, and it is the reason the
floor is written here rather than only in the project metadata.

The toolchain parts are chosen for the same reason as the language and not
carried over from habit. `uv` because a lockfile that is installed frozen
everywhere is what makes a run reproducible, and the oldest-supported-dependency
run needs a resolver that can be told to pick the floor. `ruff` because lint and
format in one tool is one dependency and one configuration rather than three.
`mypy` in strict mode because the array boundaries are where a numerical library
goes wrong quietly. `hatchling` because the build backend should be the least
interesting thing in the file.

## Rejected

- A compiled language with no scientific stack. The archive access would have to
  be written before any science started, and the calibration is the part that is
  hard. The saving is on a cost nobody is paying.
- Adding a compiled extension for the fit. Premature. Nothing has been measured
  as slow, and a second toolchain is paid by every contributor on every clone,
  including the ones who never touch the fit.
- Notebooks as the deliverable. A notebook cannot be gated, imported or
  versioned meaningfully, and this has to be usable inside other people's
  pipelines.
- A newer floor than 3.12, to get the newer language features. It would exclude
  the environments the intended readers actually run, and none of the features
  is load-bearing for anything here.
- An older floor than 3.12, for wider reach. It is outside the support window
  the scientific stack itself observes, so the dependencies would not support it
  either and the reach is not real.

## What it costs

A Python floor and a dependency tree that moves underneath the project. The
lockfile and the oldest-supported-dependency run are therefore not optional
extras: they are what pays for this choice, and dropping either turns a
reproducible tool into one that behaves differently on the day a transitive
dependency releases.

Strict typing on a numerical codebase is real friction at the array boundaries,
where shapes and units are the thing being asserted and the type system says
little about either. The alternative is a tool that silently accepts a
wrong-shaped array and returns a plausible number, which is the failure this
project can least afford.

The floor is dated. It expires on a schedule set outside this repository, so
this entry is one of the few here that is known in advance to need a successor.
