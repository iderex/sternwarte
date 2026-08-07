<!--
Delete every comment block as you fill a section in. A template left in place
reads as a question nobody answered.
-->

<!--
What this change does, in a sentence or two, and the failure it prevents.
-->

Closes #

<!--
The issue this change belongs to. One issue per pull request. If two issues are
being closed here, that is two pull requests unless every one of them lands
only records or documents.

If this change does not close its issue, write `Advances #` instead and say in
the section below which condition is still unmet, so the issue is not read as
finished.
-->

## The means

<!--
One sentence naming what this artefact is made of, and why that fits this
change: the language, the format, the tool, the runtime. Asked every time, and
never carried over from habit, because a means that was right for the last
change is an assumption about this one.

What is checked here is that the question was answered in writing. Whether the
answer is right is a judgement, and the review is where a wrong one is caught.

Answer these where they apply. Can the means carry a refusable property, an
executed proof and a claim with its command behind it? Does it add a language,
a runtime or a dependency this tree does not already carry, and is that cost
paid knowingly? Would it be testable by the suites that already exist, or does
it need a parallel apparatus nobody will maintain?
-->

## What was verified

<!--
The commands you ran and their output, pasted together and indented four spaces
so they render as a block:

    uv run pytest -q
    ...

Run them at the commit being pushed and against the reference the reader will
have, not against your working tree. A claim about another artefact, made from
the nearest thing to hand instead of from the thing itself, is the largest
defect class this kind of work produces.

Where this change adds a guard, show it biting: the fixture that trips it, and
the neighbouring case that does not.
-->

## What is not covered

<!--
What you did not run, what you could not measure, and what you are asserting
without a command behind it. A test skipped for an environmental reason is
named here together with the reason, because a skip is how a gap becomes
invisible.

An admission here survives every later edit. If a passage says something was
not done, it is not rewritten into a line saying it was.
-->
