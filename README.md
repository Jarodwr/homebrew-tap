# homebrew-tap

Homebrew formulae for my own projects and custom builds.

```sh
brew tap jarodwr/tap
brew install jarodwr/tap/<formula>
```

## Formulae

| Formula | What |
|---|---|
| `helix-steel` | [Helix](https://helix-editor.com) built from [mattwparas/helix `steel-event-system`](https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md), with the Steel plugin system enabled, plus `forge`, Steel's package manager |
| `fennel-ls-rs` | [fennel-ls](https://github.com/Jarodwr/fennel-tools), the Fennel language server from fennel-tools (Rust). Conflicts with homebrew-core's Lua `fennel-ls` |

### helix-steel

Everything this build changes compared with the fork (Steel, forge, the Fennel
grammars and queries from fennel-tools) is documented in
[docs/helix-steel.md](docs/helix-steel.md).

Installs `hx`, so it conflicts with homebrew-core's `helix`:

```sh
brew unlink helix   # or: brew uninstall helix
brew install jarodwr/tap/helix-steel
```

The stable version is pinned to a commit of the fork. To build the branch's
latest commit instead:

```sh
brew install --HEAD jarodwr/tap/helix-steel
brew upgrade --fetch-HEAD jarodwr/tap/helix-steel   # later, to update
```

To move a pin, see [Updating](docs/helix-steel.md#updating).

## Bottles (prebuilt binaries)

The workflows are the ones `brew tap-new` generates:

1. Open a pull request that adds or changes a formula. **brew test-bot**
   (`.github/workflows/tests.yml`) builds and tests it on macOS and uploads
   the bottles as a workflow artifact.
2. Once it's green, run the **brew pr-pull** workflow (Actions → brew pr-pull →
   Run workflow) with the PR number. It merges the PR, uploads the bottles to
   a GitHub Release and commits the `bottle do` block to the formula.

After that, `brew install` downloads the bottle instead of compiling. Pushes
straight to `main` only run the syntax check, so formula changes should go
through a PR to get bottles.

