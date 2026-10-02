class HelixSteel < Formula
  desc "Post-modern modal text editor, with the Steel plugin system"
  homepage "https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md"
  # mattwparas/helix, branch steel-event-system (upstream PR helix-editor/helix#8675)
  url "https://github.com/mattwparas/helix/archive/ee451df4ff6b0f6416a128f26affc2052b0669c6.tar.gz"
  version "25.07.1-steel.20260930"
  sha256 "4c8d590e82ea35b66762044f6ab0cc87c0bac4cb3244109ffcb3799df6fef870"
  license "MPL-2.0"
  revision 2
  head "https://github.com/mattwparas/helix.git", branch: "steel-event-system"

  bottle do
    root_url "https://github.com/Jarodwr/homebrew-tap/releases/download/helix-steel-25.07.1-steel.20260930_1"
    sha256 cellar: :any, arm64_tahoe: "ba4220b399224ac373c87c31af24500f799bb11135d990d168f5044921fae59b"
  end

  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  # forge's git/https support links libssl when Homebrew's OpenSSL is present
  depends_on "openssl@3"

  conflicts_with "helix", because: "both install `hx` binaries"
  conflicts_with "evil-helix", because: "both install `hx` binaries"
  conflicts_with "hex", because: "both install `hx` binaries"

  # forge, Steel's package manager, built from the same Steel commit the fork's
  # Cargo.lock pins (steel-core), so plugins see the runtime Helix embeds.
  resource "steel" do
    url "https://github.com/mattwparas/steel/archive/24cd21598c091fb88bc10a6375a1ded25e677c37.tar.gz"
    sha256 "b2bcea2bf30c3906c4b073caf3f9b8ff33834e4b91d79d3eae4d5408ee77907b"
  end

  # Fennel grammars and Helix queries from fennel-tools. Keep this pinned to
  # the same commit as the fennel-ls-rs formula.
  resource "fennel-tools" do
    url "https://github.com/Jarodwr/fennel-tools/archive/ebbb8d10f9f58be986f0ea232a890462c2bca579.tar.gz"
    sha256 "76f34fff8440f10896d78005148964d7b68f7c15fd9cbd572fbf1f5436ef36cc"
  end

  def install
    use_fennel_tools_grammars

    system "cargo", "install", "-vv", "--features", "steel", *std_cargo_args(path: "helix-term")
    resource("steel").stage do
      system "cargo", "install", "-vv", *std_cargo_args(path: "crates/forge")
    end
    rm_r "runtime/grammars/sources/" if File.directory?("runtime/grammars/sources")
    libexec.install "runtime"
    bin.env_script_all_files libexec/"bin", HELIX_RUNTIME: "${HELIX_RUNTIME:-#{libexec}/runtime}"

    bash_completion.install "contrib/completion/hx.bash" => "hx"
    fish_completion.install "contrib/completion/hx.fish"
    zsh_completion.install "contrib/completion/hx.zsh" => "_hx"
  end

  # Swap the fork's Fennel grammar (alexmozaidze/tree-sitter-fennel) for
  # fennel-tools' grammars and queries. Helix compiles languages.toml into the
  # binary and builds the grammars it lists during `cargo install`, so this has
  # to happen first. See docs/helix-steel.md.
  def use_fennel_tools_grammars
    fennel_tools = buildpath/"fennel-tools"
    resource("fennel-tools").stage(fennel_tools)
    grammars = fennel_tools/"tree-sitter-fennel"

    inreplace "languages.toml",
      'source = { git = "https://github.com/alexmozaidze/tree-sitter-fennel", ' \
      'rev = "3f0f6b24d599e92460b969aabc4f4c5a914d15a0" }',
      "source = { path = \"#{grammars}\" }"

    # The simpler s-expression grammar, for Parry. A language with no file
    # types never applies to a buffer; it only lets plugins parse with it by
    # name (rope->tssyntax).
    File.open("languages.toml", "a") do |f|
      f.puts <<~TOML

        [[language]]
        name = "fennel-sexp"
        scope = "source.fennel-sexp"
        grammar = "fennel_sexp"
        file-types = []

        [[grammar]]
        name = "fennel_sexp"
        source = { path = "#{grammars}/generic" }
      TOML
    end

    rm_r "runtime/queries/fennel"
    cp_r grammars/"queries", "runtime/queries/fennel"
  end

  def caveats
    <<~EOS
      Steel plugins are configured in ~/.config/helix/helix.scm and init.scm.
      See https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md

      Also installs `forge`, Steel's package manager. To install plugins from a
      cog.scm that lists them as dependencies, run `forge build` in its folder.
      The `steel` CLI and steel language server are not included; they come
      from `cargo xtask steel` in a checkout of the fork.
    EOS
  end

  test do
    assert_match "post-modern text editor", shell_output("#{bin}/hx --help")
    # Not `hx --health` like homebrew-core's helix: on this fork it never
    # returns inside the brew test sandbox (fine on a normal shell).
    assert_match(/helix \d+\.\d+/, shell_output("#{bin}/hx --version"))

    # Fennel grammars and queries come from fennel-tools
    assert_path_exists libexec/"runtime/grammars/#{shared_library("fennel_sexp")}"
    assert_match "jarodwr/tap helix-steel", (libexec/"runtime/queries/fennel/highlights.scm").read

    ENV["STEEL_HOME"] = testpath/"steel"
    assert_match "Steel Package Manager", shell_output("#{bin}/forge help")
  end
end
