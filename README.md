# linter

Style linters shared across [Postgres-Extensions](https://github.com/Postgres-Extensions)
projects. Currently just `sql/` (a PostgreSQL SQL style linter); the layout
leaves room for siblings (e.g. `plpgsql/`, `bash/`) later, each with its own
`Makefile` and test suite, aggregated by the top-level `Makefile`.

See [`sql/README.md`](sql/README.md) for the SQL linter's rules and usage,
and [`sql/DESIGN.md`](sql/DESIGN.md) for design rationale.

## Consuming this repo

Projects vendor this repo as a git submodule at `.vendor/linter`, plus one
small tracked `lint.mk` of their own that self-initializes the submodule
(so `make lint` works right after a plain `git clone`, with no
`--recurse-submodules` step) before handing off to the real `lint.mk` here.
That hand-off file is the entire API — nothing else needs to be copied:

```makefile
# lint.mk — thin wrapper; the whole local footprint for consuming
# https://github.com/Postgres-Extensions/linter. Everything else lives in
# the .vendor/linter submodule; see its README for available targets/rules.
#
# Guarded by $(wildcard .git) so `make dist`/PGXN release tarballs (built via
# `git archive`, which strips .git and submodule content entirely) don't try
# to init the submodule and abort the whole Makefile parse -- `make lint`
# just becomes unavailable there, which is fine since PGXN consumers don't
# need it. Matches both a real .git directory (plain clone) and the .git
# file pointer used inside a git worktree.
ifneq ($(wildcard .git),)
.vendor/linter/lint.mk:
	git submodule update --init -- .vendor/linter

include .vendor/linter/lint.mk
endif
```

Add the submodule once:

```bash
git submodule add https://github.com/Postgres-Extensions/linter.git .vendor/linter
```

Then from the project's own root `Makefile`:

```makefile
# Optional: scope `make lint` to specific paths (default: sql/ test/).
LINT_TARGETS = sql/myext.sql.in test/
include lint.mk
```

CI should invoke `make lint` — the same command a developer would run
locally — rather than pre-initializing the submodule in the checkout step.
That's what actually proves the self-init in `lint.mk` works, not just that
the linter runs once someone's already fetched it by hand.

## Development

```bash
make test          # run every linter's own test suite (currently just sql/)
make -C sql test    # sql linter only
```

This tests the linter itself (fixtures, scanner edge cases) — not a
project's SQL. That's what `make lint` (via the consuming project's
`lint.mk`) is for.
