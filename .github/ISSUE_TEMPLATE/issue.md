---
name: Issue
about: Something is wrong or something is missing. Say what, with the evidence.
title: ''
labels: ''
assignees: ''
---

Scope:

<!--
The paths this issue may change, space separated, on the line above and at
column zero. It is what says whether a landed change belongs to this issue or
merely touched the same files. Write the paths as they will exist, not as a
directory that stands in for them.

Delete every comment block as you fill the sections in. A template left in
place reads as a question nobody answered.
-->

<!--
What is wrong. One paragraph, in the present tense, describing the state of the
tree rather than the change you have in mind. Name the failure this prevents:
the thing that goes wrong for somebody if this stays as it is.
-->

## The evidence

<!--
Every number carries the command that produced it, run against the reference
the reader will have rather than against your working tree. Paste the command
and its output together, indented four spaces so it renders as a block:

    git grep -c 'something' -- path/
    7

A claim that no command can back is written as a claim and says so, and it
names what would settle it. "Not measured" and "measured and clean" are
different statements, and the second one needs the command.
-->

## Done when

<!--
The conditions that close this issue, one per line, each of them something a
reader can check rather than something a reader can agree with. Where a
condition is a test, name what it asserts. Where a condition depends on another
issue, name that issue here so the dependency is visible before the work
starts instead of at the end of it.
-->

-
-
