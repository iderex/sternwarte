# 0001 Decisions are recorded

Nothing in this repository recorded why it is shaped the way it is. The plan
names several choices that everything downstream will assume, and each of them
was about to become visible only in the code it produced.

## The decision

Every decision that shapes the architecture is written down in `docs/decisions/`
before the code that depends on it exists. One decision per file, numbered,
present tense, in the shape `docs/decisions/README.md` states: what was
undecided, what was decided, why, which alternatives were rejected and the
reason each one was rejected, and what the decision costs.

A decision is superseded by a new file that names the old one, never by editing
the old one.

This entry is that rule applied to itself. It states what was undecided, gives
the reasoning, names the alternatives that were rejected with the reason each
was rejected, and says what it costs.

## Why

The failure this prevents is a reader finding a fourth-order colour polynomial
in the source, being unable to tell whether it was reasoned or copied from
somewhere, and reimplementing it rather than trusting it. That reader is the
person this tool exists for, and the per-paper reimplementation of a
cross-calibration is the thing the project is meant to end.

Writing the entry before the code is what makes it a decision rather than a
description. An entry written afterwards is reverse-engineered from what was
built, and it will not name the alternative that was dropped on the day, because
by then nobody remembers there was one. The alternatives are the part that
carries forward; the choice on its own is just an instruction.

Requiring the rejected alternatives is the load-bearing part of the shape. A
choice with no alternatives written beside it can be obeyed or ignored but not
argued with, and the reader who ignores it writes the second implementation.

Keeping the entries in the tree, next to the code and in the same review as the
change, is what keeps them honest. A record that is fetched separately from the
thing it describes is a record nobody sees when it stops being true.

## Rejected

- Commit messages as the record. They are per change rather than per decision,
  a superseded decision cannot be revised in one, and finding the message that
  explains a design means guessing which change introduced it.
- A wiki, or a document outside the repository. It is not fetched with a clone,
  it is not reviewed alongside the change that contradicts it, and it drifts
  with nothing in the repository showing that it has.
- Comments in the source. A comment explains the line it sits on. A decision
  spans files, and the alternatives it rejected touch no line at all, so there
  is nowhere for the important half to live.
- No record, on the argument that the code is the truth. The code is the truth
  about what happens. It says nothing about what was considered and discarded,
  which is what a later reader needs in order to change it safely.
- Recording only the decisions that turn out to be contentious. Which ones those
  are is known afterwards, and the entry has to exist before the argument.

## What it costs

Every architectural change now carries a writing step before it can start, and
that step is real work rather than a formality. The cost falls hardest on the
decisions that are least clear, which is also where it is worth most, so it is
felt as friction exactly when it is doing its job.

It creates a register that can rot. An entry can be contradicted by code that
lands later and nothing here refuses that, so a reader who trusts an entry
without checking it against the code can be misled by this directory in a way
they could not be misled by an empty one. The supersession rule keeps the
history readable. It does not keep the directory true.

It also fixes a shape, and a shape invites entries written to fill the sections
rather than to settle anything. An entry whose rejected alternatives were
invented after the fact to satisfy the form is worse than no entry, because it
reads as though the alternatives were weighed. The review is the only thing
standing between this directory and that, and nothing mechanical helps.
