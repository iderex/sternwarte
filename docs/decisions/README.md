# Decision records

This directory holds the choices that shape the tool, one per file, written
before the code that depends on them exists.

A choice that is visible only in the code it produced cannot be argued with
later. A reader who finds a fourth-order colour polynomial in the source and
cannot tell whether it was reasoned or copied will reimplement it rather than
trust it, and that reimplementation is where the second answer comes from. An
entry here exists so the argument is readable separately from the code, and so
that disagreeing with the code means disagreeing with a written reason.

## Naming

`NNNN-short-title.md`. Four digits, zero padded, allocated in the order the
decisions are taken, and never reused once allocated. The title is lowercase
words joined by hyphens, and it names the decision rather than the area, so
`0004-offsets-come-from-field-stars.md` and not `0004-calibration.md`.

The number a new entry takes is the one above the highest that already exists
here. Two entries written against the same directory at the same time can reach
for one number, so read it rather than remembering it:

    ls docs/decisions/ | grep -E '^[0-9]{4}-' | sort | tail -1

## What an entry contains

An opening paragraph naming what was undecided and what turns on it, then these
four sections:

    ## The decision      what is now fixed, in the present tense
    ## Why               the reasoning, and not a restatement of the decision
    ## Rejected          every alternative that was considered, each with the
                         reason it was not taken
    ## What it costs     what the decision makes harder, or forecloses

An entry may carry further sections where the decision needs them, such as the
failure modes it creates with the guard each one gets, or what an approximation
leaves behind. The four above are the ones every entry has.

An entry that names no rejected alternative is not a decision, it is a
preference. That is the section a hurried entry drops, and it is the one a later
reader needs most, because the alternative somebody is about to propose again is
usually already in it.

The body is present tense. An entry states what is true now, not what somebody
once intended.

Numbers carry the command that produced them. Where a statement cannot be backed
by a command, it is written as a claim and says so, and it names what would
settle it.

## Supersession

A decision is superseded by a new entry that names the old one. The old entry is
not edited, not marked and not deleted. What was believed on the day a choice
was made is the part a later reader needs, and an entry rewritten to match what
is true now destroys exactly that.

A superseding entry carries one line directly under its title:

    Supersedes: 0004-offsets-come-from-field-stars.md

so that whether an entry still stands is answered by a command rather than by a
banner somebody remembered to add:

    git grep -l 'Supersedes: 0004-offsets-come-from-field-stars.md' -- docs/decisions/

No output means nothing has replaced it. This costs the reader of an old entry
one command, and that is the direction the cost belongs in, because the entry
that made the claim stays exactly as it was written.

## What is not enforced

Nothing in this repository refuses an entry that skips a section, names no
rejected alternative, takes a number already used, edits a superseded entry in
place, or lands after the code it claims to precede. The workflows in
`.github/workflows/` read the actions, the dependency diff and the tracked text
for dangerous Unicode, and none of them reads this directory:

    git grep -l 'docs/decisions' -- .github/ ; echo "exit=$?"
    exit=1

An exit of 1 from `git grep` is no match. Every rule above is therefore read by
a person and refused by no machine. This
document explains the rules; it is not the thing that holds them.
