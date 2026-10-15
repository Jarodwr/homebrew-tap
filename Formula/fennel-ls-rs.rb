class FennelLsRs < Formula
  desc "Language server for Fennel, written in Rust"
  homepage "https://github.com/Jarodwr/fennel-tools"
  url "https://github.com/Jarodwr/fennel-tools/archive/09a7c960ab6674ce9e6cd8e4408e639642411643.tar.gz"
  version "0.2.2"
  sha256 "511cb6c9a83a8b6d5e8a475142fc05e21c05c9242a144261fc7ed2d15c5bd252"
  head "https://github.com/Jarodwr/fennel-tools.git", branch: "main"

  depends_on "rust" => :build

  # Same `fennel-ls` binary name as homebrew-core's Lua implementation, which
  # is also the server name Helix's defaults use for Fennel.
  conflicts_with "fennel-ls", because: "both install a `fennel-ls` binary"

  def install
    system "cargo", "install", *std_cargo_args(path: "fennel-ls")
  end

  test do
    assert_match "fennel-ls #{version}", shell_output("#{bin}/fennel-ls --version")

    (testpath/"bad.fnl").write "(fn add [a b]\n  (+ a b)\n"
    # `check` prints diagnostics and exits 1 when it finds errors
    assert_match "unclosed delimiter", shell_output("#{bin}/fennel-ls check #{testpath}/bad.fnl", 1)
  end
end
