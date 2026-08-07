# 0012 The library is the product and the command line is a shell over it

The tool has to be usable from a notebook, from a pipeline and from a terminal.
Which of those the code is written for decides how testable it is, and a core
that reaches for the terminal cannot be tested without one.

## The decision

The library is the product. The command line is a thin shell over it.

One entry point, `sternwarte.reduce`, takes a resolved position and a
configuration and returns the calibrated series together with its per-survey
report. Every stage below it is separately callable, with plain data in and
plain data out:

- fetch, which turns a position and a configuration into raw archive responses
- transform, which turns raw responses into epochs in the reference system
- solve, which measures the per-survey offsets on the comparison-star ensemble
- assemble, which turns transformed epochs and offsets into the one series

Four things the library does not do:

- read the environment
- parse arguments
- write to standard output or standard error
- exit the process

Logging goes through the standard logging module, and the library configures no
handler.

The command line owns argument parsing, exit codes, terminal output, and the
reading of credentials from the environment.

## Why

A core with no ambient dependencies is a core that can be tested headlessly, in
parallel, and without a display. That is a birth requirement for this project
rather than a preference, and it is much cheaper to keep than to restore.

The stage boundaries are what let a stage be replaced. A user who disagrees with
the ensemble selection calls the other three stages unchanged and substitutes
one, which is the difference between a tool somebody can build on and a tool
somebody has to fork.

Keeping credential reading in the shell rather than in the library is
deliberate. A library that reaches into the environment for a token can carry it
into a serialised object, a log line or a repr without anybody having asked it
to, and the object that leaks it is usually the one written for debugging.

Configuring no logging handler is the same argument in a smaller place. A
library that installs a handler fights the application that imports it, and the
application loses in a way that surfaces as missing or duplicated output rather
than as an error.

## Rejected

- Command line first, with the library extracted later. The extraction never
  happens on schedule, and by the time it is attempted the shape of the code
  assumes argv and a terminal in places nobody remembers writing.
- One call that does everything. Untestable in pieces, and it forces a user who
  disagrees with one stage to fork all of them.
- Library-configured logging, for the convenience of users who did not set any
  up. It takes a decision that belongs to the application, and it takes it
  invisibly.
- Reading credentials in the library, so that a notebook user does not have to
  pass one. It moves a secret into the layer that has the most ways to leak it,
  to save one argument.
- Stages that pass an opaque context object between them. It reads as plain data
  in and plain data out and is not, because a stage can then depend on anything
  another stage happened to leave in the context.

## What it costs

The shell has to repeat things. Defaults, validation and help text live at the
command line, and some of them will look like duplication of what the library
already knows. That is the price of the library not knowing about a terminal,
and resisting the urge to move one of them down is ongoing work.

Passing configuration explicitly through four stages is more verbose than
reading it from the environment where it is needed, and the verbosity is
visible at every call site while the benefit is not visible anywhere.

The four prohibitions are stated here and nothing refuses a violation of them
today. There is no check in this repository that fails a module which reads the
environment or installs a logging handler, so until the tests that own those
properties exist, this entry is read by a person and enforced by nothing.
