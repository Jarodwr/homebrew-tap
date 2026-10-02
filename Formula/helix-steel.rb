class HelixSteel < Formula
  desc "Post-modern modal text editor, with the Steel plugin system"
  homepage "https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md"
  # mattwparas/helix, branch steel-event-system (upstream PR helix-editor/helix#8675)
  url "https://github.com/mattwparas/helix/archive/ee451df4ff6b0f6416a128f26affc2052b0669c6.tar.gz"
  version "25.07.1-steel.20260930"
  sha256 "4c8d590e82ea35b66762044f6ab0cc87c0bac4cb3244109ffcb3799df6fef870"
  license "MPL-2.0"
  head "https://github.com/mattwparas/helix.git", branch: "steel-event-system"

  depends_on "rust" => :build

  conflicts_with "helix", because: "both install `hx` binaries"
  conflicts_with "evil-helix", because: "both install `hx` binaries"
  conflicts_with "hex", because: "both install `hx` binaries"

  def install
    system "cargo", "install", "-vv", "--features", "steel", *std_cargo_args(path: "helix-term")
    rm_r "runtime/grammars/sources/" if File.directory?("runtime/grammars/sources")
    libexec.install "runtime"
    bin.env_script_all_files libexec/"bin", HELIX_RUNTIME: "${HELIX_RUNTIME:-#{libexec}/runtime}"

    bash_completion.install "contrib/completion/hx.bash" => "hx"
    fish_completion.install "contrib/completion/hx.fish"
    zsh_completion.install "contrib/completion/hx.zsh" => "_hx"
  end

  def caveats
    <<~EOS
      Steel plugins are configured in ~/.config/helix/helix.scm and init.scm.
      See https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md

      This formula installs only `hx`. The `steel` CLI, steel language server
      and the `forge` package manager come from `cargo xtask steel` in a
      checkout of the fork.
    EOS
  end

  test do
    assert_match "post-modern text editor", shell_output("#{bin}/hx --help")
    # Not `hx --health` like homebrew-core's helix: on this fork it never
    # returns inside the brew test sandbox (fine on a normal shell).
    assert_match(/helix \d+\.\d+/, shell_output("#{bin}/hx --version"))
  end
end
