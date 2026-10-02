# helix-steel: how this build differs from the fork

`Formula/helix-steel.rb` builds Helix from
[mattwparas/helix `steel-event-system`](https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md),
the fork that adds the Steel plugin system. It starts from homebrew-core's
`helix` formula and changes the following. Keep this file up to date whenever
the formula changes.

## Pins

| What | Pinned to | Where |
|---|---|---|
| Helix fork | `ee451df` (2026-09-30) | `url` / `version` / `sha256` |
| Steel (for `forge`) | `24cd215`, the `steel-core` commit in the fork's `Cargo.lock` | `resource "steel"` |
| fennel-tools (Fennel grammars + queries) | `ebbb8d1`, the same commit as `fennel-ls-rs` | `resource "fennel-tools"` |

`brew install --HEAD` builds the fork's branch tip instead. The resources stay
pinned either way, so after a HEAD build check that the fork's `Cargo.lock`
still uses the same `steel-core` commit.

## Changes

### 1. Steel enabled

`cargo install --features steel`. homebrew-core's `helix` builds without it.

### 2. `forge` installed

Steel's package manager, built from the `steel` resource (`crates/forge`) and
installed next to `hx`. It's built from the Steel commit that the fork's
`Cargo.lock` pins, not Steel's latest as the fork's own `cargo xtask steel`
does, so plugins installed with it run on the same Steel runtime that Helix
embeds.

- `depends_on "openssl@3"` and `pkgconf` (build) were added for it: forge links
  libssl when Homebrew's OpenSSL is present, which it is on CI (through rust).
- Only `forge` is installed, not the `steel` CLI or the Steel language server.

### 3. Fennel grammars from fennel-tools

Before `cargo install`, `use_fennel_tools_grammars` edits the fork's
`languages.toml`. Helix compiles that file into the binary and builds the
grammars it lists during the build, so the edits ship in the bottle and no
machine needs a compiler or `hx --grammar build`.

- **`fennel` grammar**: its source changes from `alexmozaidze/tree-sitter-fennel`
  (git) to fennel-tools' `tree-sitter-fennel` (a local path to the staged
  resource). The `fennel` language entry itself (file types, `fennel-ls`,
  `fnlfmt`, indent) is unchanged.
- **`fennel_sexp` grammar** (new): fennel-tools' `tree-sitter-fennel/generic`, a
  simpler s-expression grammar.
- **`fennel-sexp` language** (new): uses `fennel_sexp` and has no file types,
  so it never applies to a buffer. It exists so plugins can parse with it by
  name (Parry's Fennel dialect does, via `rope->tssyntax`).

### 4. Fennel queries from fennel-tools

`runtime/queries/fennel/` is replaced by fennel-tools'
`tree-sitter-fennel/queries/` (highlights, locals, rainbows). These were
adapted from Helix's own (MPL-2.0) and are maintained alongside the grammar,
because a query that names a node the grammar doesn't have makes Helix drop
highlighting for the language entirely.

### 5. Test

- `hx --help`, plus `hx --version` instead of homebrew-core's `hx --health`:
  on this fork `--health` never returns inside the brew test sandbox (it's
  fine in a normal shell), which timed out test-bot.
- `forge help`, with `STEEL_HOME` pointed into the test sandbox.
- The installed runtime has the `fennel_sexp` grammar and fennel-tools'
  queries.

### 6. Revisions

The version string tracks the fork commit (`25.07.1-steel.<date>`). Changes that
don't move the fork pin bump `revision` instead, so installs upgrade and CI
builds a new bottle.

## Updating

- **Fork**: change `url`, `version`, `sha256` (`curl -sL <url> | shasum -a 256`).
  Then move the `steel` resource to the fork's new `steel-core` commit
  (`grep -A2 'name = "steel-core"' Cargo.lock` in the fork), and check the
  fork's Fennel `[[grammar]]` line still matches the `inreplace` (the build
  fails if it doesn't).
- **fennel-tools**: move the `fennel-tools` resource and the `fennel-ls-rs`
  formula to the same commit, and bump `helix-steel`'s `revision`.
- Formula changes go through a PR so test-bot builds bottles; then run the
  **brew pr-pull** workflow with the PR number.
