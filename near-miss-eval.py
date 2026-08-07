# Temporary. This file exists to show the community rule set biting on this
# tree, and it is removed again in this same branch before the pull request is
# merged. It is at the root rather than under security/rules/, because that
# directory is excluded from the scan.
#
# The pair is one edit apart. The community rule eval-detected carries
#
#     pattern-not: eval("...")
#
# so a constant argument is the neighbour that does not trip it, and a name is
# the one that does. None of the four rules in security/rules/ matches either
# case: they are about a query built by concatenation, a path taken from a
# response, a deserialiser that can construct objects, and a credential read
# from the environment.


def evaluate_from_caller(expression):
    return eval(expression)


def evaluate_constant():
    return eval("1 + 1")
