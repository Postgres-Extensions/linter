# lint.mk — adds a `lint` target to any project that vendors this repo.
#
# Not meant to be included directly. Each consuming repo keeps its own thin
# lint.mk (see the top-level README) that ensures this repo is checked out as
# the .vendor/linter submodule, then does:
#
#   include .vendor/linter/lint.mk
#
# Provides:
#   make lint   — run sql-lint on LINT_TARGETS (default sql/ test/, relative
#                 to the consuming repo's own directory). sql-lint skips
#                 vendored trees (deps/, pgxntool/) and auto-generated files.
#
# Set LINT_TARGETS in the consuming repo's own Makefile, before its
# `include .vendor/linter/lint.mk` line, to lint a different set of paths —
# e.g. to exclude frozen version-snapshot files that are never hand-edited:
#
#   LINT_TARGETS = sql/cat_tools.sql.in sql/omit_column.sql test/
#   include .vendor/linter/lint.mk

_LINT_MK_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
SQL_LINT     := $(_LINT_MK_DIR)sql/bin/sql-lint

LINT_TARGETS ?= sql/ test/

.PHONY: lint
lint:
	$(SQL_LINT) $(LINT_TARGETS)
