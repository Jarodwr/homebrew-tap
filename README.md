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

### helix-steel

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

`forge` is built from the Steel commit that the fork's `Cargo.lock` pins, so
when moving the Helix pin, update the `steel` resource to match
(`grep -A2 'name = "steel-core"' Cargo.lock` in the fork).

To move the pin, change `url`, `version` and `sha256` in
`Formula/helix-steel.rb` (`curl -sL <url> | shasum -a 256`).

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

