class FennelLsRs < Formula
  desc "Language server for Fennel, written in Rust"
  homepage "https://github.com/Jarodwr/fennel-tools"
  url "https://github.com/Jarodwr/fennel-tools/archive/4396690e38066fbcfd0e08a9525dd30d7f9d5dc6.tar.gz"
  version "0.2.0"
  sha256 "2aafe6aa362d1e2011660354f19af3dbffcdabd80765d5cd3b97b253f9bbbe95"
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
