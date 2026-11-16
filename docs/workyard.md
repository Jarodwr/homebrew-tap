# workyard: how this build is packaged

`Formula/workyard.rb` builds the `workyard` CLI from the
[Workyard source](https://github.com/Jarodwr/workyard) (MIT licence) and installs the Claude Code
plugin next to it. `Casks/workyard.rb` installs the desktop app from the
release dmg instead. Keep this file up to date whenever either changes.

## Pins

| What | Pinned to | Where |
|---|---|---|
| Workyard | `v0.1.1` | `url` / `sha256` (`version` is read from the tag) |

`brew install --HEAD jarodwr/tap/workyard` builds the `main` branch instead.

## What the formula does

- `cargo install` (`--locked` comes from `std_cargo_args`) of `crates/workyard-cli`, the only binary needed.
- Installs the plugin directory to `share/workyard/plugin`. The CLI looks for
  it at `<exe dir>/../share/workyard/plugin` after resolving the `bin/workyard`
  symlink, so `workyard doctor` reports the plugin as found.
- `caveats` print the `claude plugin marketplace add` steps and `workyard doctor`.
- `test` checks `workyard --version` and `workyard doctor --json`. `doctor`
  exits 1 when `claude` or `git` is missing, so the test puts stub `claude` and
  `git` scripts on `PATH`, then checks the reported version and that the
  plugin manifest was installed.

## The cask

`brew install --cask jarodwr/tap/workyard` installs `Workyard.app` and links the
bundled CLI as `workyard`. It conflicts in practice with the formula (same
binary name); install one of them. The cask is Apple silicon only: `scripts/release.sh --app`
builds one dmg for the host architecture. For Intel, build a second dmg on an Intel Mac and switch
the cask to `arch` and `sha256 arm: ..., intel: ...`.

The dmg is not notarized unless it was built with the `APPLE_*` variables; see docs/HOMEBREW.md in the Workyard repository.

## Updating

1. Tag and release in the Workyard repository (`docs/RELEASING.md` there).
2. `scripts/render-homebrew.sh <version> <source-sha256> [<dmg-sha256>]`
   regenerates the formula, cask and this page.
3. Open a PR in the tap so test-bot builds the bottle, then run **brew pr-pull**.
